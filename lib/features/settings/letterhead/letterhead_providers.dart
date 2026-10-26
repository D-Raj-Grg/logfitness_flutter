// Reads and the one write behind Settings -> Letterhead.
//
// Hand-written providers, matching the member-side ones: a plain read and a
// plain action do not need codegen.
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/data/orgs/org_profile.dart';
import 'package:logfitness_flutter/data/orgs/orgs_repository.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/domain/validation/org_letterhead.dart';
import 'package:logfitness_flutter/features/settings/catalogue/fee_providers.dart';
import 'package:logfitness_flutter/supabase/supabase_providers.dart';

/// The signed-in org's letterhead. Null when the session has no org claim or
/// RLS hides the row.
final FutureProvider<OrgProfile?> orgProfileProvider =
    FutureProvider<OrgProfile?>((Ref ref) async {
      final String? orgId = ref.watch(claimsProvider)?.orgId;
      if (orgId == null) return null;
      return ref.watch(orgsRepositoryProvider).profile(orgId);
    });

/// Outcome of a save, so the screen either says what happened or why not.
sealed class LetterheadSaveResult {
  const LetterheadSaveResult();
}

class LetterheadSaved extends LetterheadSaveResult {
  const LetterheadSaved();
}

class LetterheadSaveFailed extends LetterheadSaveResult {
  const LetterheadSaveFailed(this.failure);
  final AppFailure failure;
}

class LetterheadSaveController extends Notifier<bool> {
  @override
  bool build() => false; // true while a save is in flight

  Future<LetterheadSaveResult> save({
    required LetterheadValues values,
    required String? currentLogoPath,
    Uint8List? newLogo,
    String? newLogoType,
    bool removeLogo = false,
  }) async {
    final String? orgId = ref.read(claimsProvider)?.orgId;
    if (orgId == null) {
      return const LetterheadSaveFailed(
        AppFailure(
          FailureKind.unauthenticated,
          'No organisation on this session.',
        ),
      );
    }
    state = true;
    try {
      await ref
          .read(orgsRepositoryProvider)
          .saveLetterhead(
            orgId: orgId,
            values: values,
            currentLogoPath: currentLogoPath,
            newLogo: newLogo,
            newLogoType: newLogoType,
            removeLogo: removeLogo,
          );
      // Everything that prints a document, and the sidebar name, reads this.
      ref.invalidate(orgProfileProvider);
      // The legacy list joining fee rides in the sale setup, so a sale quoted
      // before this save would otherwise keep the old reference fee.
      ref.invalidate(feeSetupProvider);
      return const LetterheadSaved();
    } catch (error, stackTrace) {
      return LetterheadSaveFailed(mapError(error, stackTrace));
    } finally {
      state = false;
    }
  }
}

final NotifierProvider<LetterheadSaveController, bool> letterheadSaveProvider =
    NotifierProvider<LetterheadSaveController, bool>(
      LetterheadSaveController.new,
    );
