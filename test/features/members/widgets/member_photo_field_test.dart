// Photo capture: the file limits, and the guard that keeps a bad file from
// reaching storage.
//
// `Override` is not exported by flutter_riverpod 3.1.0, so override lists stay
// untyped literals (TASKS.md, Discovered, 2026-09-05).
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/members/members_repository.dart';
import 'package:logfitness_flutter/data/photos/member_photos_repository.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/features/members/member_admin_controller.dart';
import 'package:logfitness_flutter/features/members/widgets/member_photo_field.dart';

class _FakePhotosRepository implements MemberPhotosRepository {
  int uploadCount = 0;
  int removeCount = 0;
  String? lastContentType;

  @override
  Future<String> upload({
    required String orgId,
    required String memberId,
    required Uint8List bytes,
    required String contentType,
  }) async {
    uploadCount++;
    lastContentType = contentType;
    return '$orgId/$memberId/1.jpg';
  }

  @override
  Future<void> remove(String path) async {
    removeCount++;
  }

  @override
  Never noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not faked');
}

class _FakeMembersRepository implements MembersRepository {
  String? lastPath;
  int setPathCount = 0;

  @override
  Future<void> setPhotoPath(String memberId, String? path) async {
    setPathCount++;
    lastPath = path;
  }

  @override
  Never noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not faked');
}

void main() {
  late _FakePhotosRepository photos;
  late _FakeMembersRepository members;
  late ProviderContainer container;

  setUp(() {
    photos = _FakePhotosRepository();
    members = _FakeMembersRepository();
    container = ProviderContainer(
      overrides: [
        memberPhotosRepositoryProvider.overrideWithValue(photos),
        membersRepositoryProvider.overrideWithValue(members),
      ],
    );
    container.listen<bool>(memberAdminProvider, (_, _) {});
  });

  tearDown(() => container.dispose());

  MemberAdmin notifier() => container.read(memberAdminProvider.notifier);

  test('content type is read from the file, not assumed', () {
    expect(photoContentTypeFor('/tmp/a.png'), 'image/png');
    expect(photoContentTypeFor('/tmp/a.WEBP'), 'image/webp');
    expect(photoContentTypeFor('/tmp/a.jpg'), 'image/jpeg');
    // image_picker re-encodes to JPEG when imageQuality is set, so anything
    // unrecognised is far likelier to be a JPEG than an error.
    expect(photoContentTypeFor('/tmp/a.heic'), 'image/jpeg');
  });

  test('uploads, then stores the path', () async {
    final outcome = await notifier().setPhoto(
      memberId: 'm-1',
      orgId: 'org-1',
      bytes: Uint8List.fromList(<int>[1, 2, 3]),
      contentType: 'image/jpeg',
    );

    expect(outcome, isA<MemberAdminSucceeded>());
    expect(photos.uploadCount, 1);
    // Upload first: the other order points a member at a file that does not
    // exist.
    expect(members.setPathCount, 1);
    expect(members.lastPath, 'org-1/m-1/1.jpg');
  });

  test('a file the bucket would refuse never reaches storage', () async {
    final tooBig = await notifier().setPhoto(
      memberId: 'm-1',
      orgId: 'org-1',
      bytes: Uint8List(kMaxPhotoBytes + 1),
      contentType: 'image/jpeg',
    );

    expect(tooBig, isA<MemberAdminFailed>());
    expect((tooBig as MemberAdminFailed).failure.kind, FailureKind.invalid);
    expect(tooBig.failure.message, contains('5 MB'));
    expect(photos.uploadCount, 0);

    final wrongType = await notifier().setPhoto(
      memberId: 'm-1',
      orgId: 'org-1',
      bytes: Uint8List.fromList(<int>[1]),
      contentType: 'application/pdf',
    );

    expect(wrongType, isA<MemberAdminFailed>());
    expect(photos.uploadCount, 0);
  });

  test('clearing unsets the row before deleting the object', () async {
    final outcome = await notifier().clearPhoto(
      memberId: 'm-1',
      path: 'org-1/m-1/1.jpg',
    );

    expect(outcome, isA<MemberAdminSucceeded>());
    // A member still showing a face they asked to have removed is the failure
    // that matters; a leftover object in a private bucket is not.
    expect(members.lastPath, isNull);
    expect(photos.removeCount, 1);
  });

  test('clearing a member who had no photo deletes nothing', () async {
    await notifier().clearPhoto(memberId: 'm-1');
    expect(members.setPathCount, 1);
    expect(photos.removeCount, 0);
  });
}
