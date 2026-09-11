// Member photos.
//
// Mirrors `logfitness_saas/lib/db/photos.ts`. The bucket is **private** — a
// gym's member list with faces attached is exactly the kind of thing that must
// not be world-readable — so every render needs a freshly signed URL rather
// than a public link.
//
// Objects are keyed `<org_id>/<member_id>/<file>`, and the storage policies
// read that first path segment. The path *is* the tenant boundary here, the
// way `org_id` is on every table, so it is built rather than accepted from a
// caller.
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:logfitness_flutter/data/repository_guard.dart';
import 'package:logfitness_flutter/supabase/supabase_providers.dart';

part 'member_photos_repository.g.dart';

const String kMemberPhotoBucket = 'member-photos';

/// Matches the bucket's own limit, so an oversized file is refused before it
/// is uploaded rather than after.
const int kMaxPhotoBytes = 5 * 1024 * 1024;

/// Matches the bucket's `allowed_mime_types`.
const List<String> kAllowedPhotoTypes = <String>[
  'image/jpeg',
  'image/png',
  'image/webp',
];

const Map<String, String> _extensions = <String, String>{
  'image/jpeg': 'jpg',
  'image/png': 'png',
  'image/webp': 'webp',
};

/// Builds the object key for a member's photo.
///
/// The timestamp makes each upload a new object rather than a replacement,
/// which keeps a signed URL already handed out from silently changing the
/// face it points at.
String memberPhotoPath({
  required String orgId,
  required String memberId,
  required String contentType,
}) {
  final extension = _extensions[contentType] ?? 'jpg';
  return '$orgId/$memberId/${DateTime.now().millisecondsSinceEpoch}.$extension';
}

class MemberPhotosRepository {
  const MemberPhotosRepository(this._client);

  final SupabaseClient _client;

  StorageFileApi get _bucket => _client.storage.from(kMemberPhotoBucket);

  /// A signed URL for one photo, or null.
  ///
  /// Returns null rather than throwing: a photo that will not load must never
  /// take down a member profile. The face is worth having and never worth a
  /// blank screen.
  Future<String?> signedUrl(String? path, {int expiresIn = 60 * 60}) async {
    if (path == null || path.isEmpty) {
      return null;
    }
    try {
      return await _bucket.createSignedUrl(path, expiresIn);
    } catch (_) {
      return null;
    }
  }

  /// One round trip for a whole page of members, keyed by path.
  ///
  /// A list of forty members must not issue forty signing requests while
  /// someone is scrolling it.
  Future<Map<String, String>> signedUrls(
    Iterable<String?> paths, {
    int expiresIn = 60 * 60,
  }) async {
    final wanted = <String>{
      for (final path in paths)
        if (path != null && path.isNotEmpty) path,
    }.toList(growable: false);

    if (wanted.isEmpty) {
      return const <String, String>{};
    }

    try {
      // `createSignedUrlsResult` rather than the deprecated `createSignedUrls`:
      // the old call silently omits paths it could not sign, so a member whose
      // object has gone missing is indistinguishable from one who never had a
      // photo. Here the failures are visible, and simply absent from the map —
      // which the caller already handles, because a null path means the same
      // thing to it.
      final results = await _bucket.createSignedUrlsResult(wanted, expiresIn);
      return <String, String>{
        for (final result in results.whereType<SignedUrlSuccess>())
          result.path: result.signedUrl,
      };
    } catch (_) {
      // Same rule as the single case: no faces is a worse list than no list
      // is a screen.
      return const <String, String>{};
    }
  }

  /// Uploads a photo and returns its path.
  ///
  /// Writes are gated upstream by `jwt_can_serve_members()` — owner, manager
  /// and front desk, the same roles that may register and edit a member — so a
  /// trainer attempting this gets a refusal from storage, not from here.
  Future<String> upload({
    required String orgId,
    required String memberId,
    required Uint8List bytes,
    required String contentType,
  }) {
    return guardFailures(() async {
      final path = memberPhotoPath(
        orgId: orgId,
        memberId: memberId,
        contentType: contentType,
      );
      await _bucket.uploadBinary(
        path,
        bytes,
        fileOptions: FileOptions(contentType: contentType, upsert: false),
      );
      return path;
    });
  }

  Future<void> remove(String path) {
    return guardFailures(() async {
      await _bucket.remove(<String>[path]);
    });
  }
}

@riverpod
MemberPhotosRepository memberPhotosRepository(Ref ref) {
  return MemberPhotosRepository(ref.watch(supabaseClientProvider));
}

/// A signed URL for one member's photo.
@riverpod
Future<String?> memberPhotoUrl(Ref ref, String? path) {
  return ref.watch(memberPhotosRepositoryProvider).signedUrl(path);
}

/// A stable key for [memberPhotoUrlsProvider].
///
/// A `family` keyed directly on a `List` never matches a previous argument —
/// list identity, not contents — so the provider would rebuild on every frame
/// and re-sign every URL with it. This normalises to a sorted, de-duplicated
/// set and compares by contents.
@immutable
class MemberPhotoPaths {
  MemberPhotoPaths(Iterable<String?> paths)
      : paths = List<String>.unmodifiable(
          <String>{
            for (final path in paths)
              if (path != null && path.isNotEmpty) path,
          }.toList()
            ..sort(),
        );

  final List<String> paths;

  @override
  bool operator ==(Object other) {
    if (other is! MemberPhotoPaths || other.paths.length != paths.length) {
      return false;
    }
    for (var i = 0; i < paths.length; i++) {
      if (other.paths[i] != paths[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(paths);
}

/// Signed URLs for a whole page of members, keyed by storage path.
///
/// One round trip per page. A list of forty members must not issue forty
/// signing requests while someone scrolls it.
@riverpod
Future<Map<String, String>> memberPhotoUrls(Ref ref, MemberPhotoPaths paths) {
  if (paths.paths.isEmpty) {
    return Future<Map<String, String>>.value(const <String, String>{});
  }
  return ref.watch(memberPhotosRepositoryProvider).signedUrls(paths.paths);
}
