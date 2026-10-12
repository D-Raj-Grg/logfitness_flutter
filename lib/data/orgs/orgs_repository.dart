// The org's own settings, as far as a counter needs them.
//
// One value today: the gym's list joining fee. It is here rather than inlined
// in a screen because the counter has to show the same waiver the invoice
// will print -- a plan priced without a fee of its own has no other source for
// the amount (`logfitness_saas/lib/db/orgs.ts`, `getOrgStandardSignupFee`).
//
// Org profile editing (letterhead, logo) is owner-only and was brought into
// this app on 2026-10-07 with the Settings parity decision. RLS is the gate:
// `orgs` UPDATE and the `org-logos` storage writes both require
// `jwt_is_owner()`, so a non-owner gets `42501`, never a silent no-op.
//
// RLS scopes `orgs` to the caller's own org, so the id filter below is a
// convenience for `maybeSingle`, never the boundary.
import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:logfitness_flutter/data/orgs/org_profile.dart';
import 'package:logfitness_flutter/data/repository_guard.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/domain/validation/org_letterhead.dart';
import 'package:logfitness_flutter/supabase/supabase_providers.dart';

part 'orgs_repository.g.dart';

const String kOrgLogoBucket = 'org-logos';

const Map<String, String> _logoExtensions = <String, String>{
  'image/jpeg': 'jpg',
  'image/png': 'png',
  'image/webp': 'webp',
};

/// `<org_id>/logo-<epoch>.<ext>`. The first segment is the tenant boundary the
/// storage policies read; the timestamp makes each upload a new object so a
/// document already printed never has its logo swapped underneath it.
String orgLogoPath({required String orgId, required String contentType}) {
  final String ext = _logoExtensions[contentType] ?? 'jpg';
  return '$orgId/logo-${DateTime.now().millisecondsSinceEpoch}.$ext';
}

class OrgsRepository {
  const OrgsRepository(this._client);

  final SupabaseClient _client;

  static const String _table = 'orgs';

  /// The gym's standard joining fee in paisa, or zero when it has none set.
  ///
  /// Zero is also what a failed read would mean, which is why this one does
  /// not swallow: `guardFailures` maps the error and the caller decides. The
  /// screens treat a missing fee as "no waiver to show" rather than blocking
  /// the sale.
  Future<int> standardSignupFeePaisa(String orgId) {
    return guardFailures(() async {
      final Map<String, dynamic>? row = await _client
          .from(_table)
          .select('standard_signup_fee_paisa')
          .eq('id', orgId)
          .maybeSingle();
      final Object? value = row?['standard_signup_fee_paisa'];
      return value is int ? value : 0;
    });
  }

  /// The letterhead row, or null when RLS hides it.
  Future<OrgProfile?> profile(String orgId) {
    return guardFailures(() async {
      final Map<String, dynamic>? row = await _client
          .from(_table)
          .select(OrgProfile.columns)
          .eq('id', orgId)
          .maybeSingle();
      return row == null ? null : OrgProfile.fromRow(row);
    });
  }

  /// Public URL for a logo object. Built, not signed: the bucket is public so a
  /// URL cannot expire while a document is being printed.
  String? logoUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    return _client.storage.from(kOrgLogoBucket).getPublicUrl(path);
  }

  /// Saves the letterhead, replacing or removing the logo as asked.
  ///
  /// Same order as the console's `updateOrgLetterhead`: upload the new object,
  /// update the row, and only then delete the old object (best effort). A
  /// failed row update therefore never leaves the org pointing at a deleted
  /// logo. Returns the path now stored.
  Future<String?> saveLetterhead({
    required String orgId,
    required LetterheadValues values,
    required String? currentLogoPath,
    Uint8List? newLogo,
    String? newLogoType,
    bool removeLogo = false,
  }) {
    return guardFailures(() async {
      String? nextPath = removeLogo ? null : currentLogoPath;
      String? uploaded;
      if (newLogo != null && newLogoType != null) {
        uploaded = orgLogoPath(orgId: orgId, contentType: newLogoType);
        await _client.storage
            .from(kOrgLogoBucket)
            .uploadBinary(
              uploaded,
              newLogo,
              fileOptions: FileOptions(contentType: newLogoType, upsert: false),
            );
        nextPath = uploaded;
      }

      final List<dynamic> updated;
      try {
        updated = await _client
            .from(_table)
            .update(<String, dynamic>{
              'name': values.name,
              'legal_name': values.legalName,
              'address': values.address,
              'phone': values.phone,
              'email': values.email,
              'pan_no': values.panNo,
              'tax_note': values.taxNote,
              'invoice_terms': values.invoiceTerms,
              'standard_signup_fee_paisa': values.standardSignupFeePaisa,
              'logo_path': nextPath,
            })
            .eq('id', orgId)
            .select('id');
      } catch (_) {
        // Do not leave the object we just uploaded orphaned.
        if (uploaded != null) {
          await _removeQuietly(uploaded);
        }
        rethrow;
      }

      // An UPDATE that RLS filters out affects zero rows and raises nothing.
      // Reading the row back is what turns that into a refusal the screen can
      // show instead of a "saved" that wasn't.
      if (updated.isEmpty) {
        if (uploaded != null) {
          await _removeQuietly(uploaded);
        }
        throw const AppFailure(
          FailureKind.refused,
          'Only an owner can change the letterhead.',
        );
      }

      if (currentLogoPath != null &&
          currentLogoPath.isNotEmpty &&
          currentLogoPath != nextPath) {
        await _removeQuietly(currentLogoPath);
      }
      return nextPath;
    });
  }

  Future<void> _removeQuietly(String path) async {
    try {
      await _client.storage.from(kOrgLogoBucket).remove(<String>[path]);
    } catch (_) {
      // An orphaned object costs bytes; a failed cleanup must not fail a save
      // that already succeeded.
    }
  }
}

@riverpod
OrgsRepository orgsRepository(Ref ref) {
  return OrgsRepository(ref.watch(supabaseClientProvider));
}

/// The gym's list joining fee, loaded once and shared by every sale screen.
///
/// Resolves to zero for a session with no org claim — there is nothing to
/// read and nothing to show.
@riverpod
Future<int> orgStandardSignupFee(Ref ref) async {
  final String? orgId = ref.watch(claimsProvider)?.orgId;
  if (orgId == null) {
    return 0;
  }
  return ref.watch(orgsRepositoryProvider).standardSignupFeePaisa(orgId);
}
