// Editing a member, archiving one, inviting one into the member app, and
// handing them an access card.
//
// Declared with manual `Notifier`/`Provider` rather than `@riverpod` to stay
// out of the codegen graph, the same choice `branch_scope.dart` makes.
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/data/members/member_card.dart';
import 'package:logfitness_flutter/data/members/member_cards_repository.dart';
import 'package:logfitness_flutter/data/members/members_repository.dart';
import 'package:logfitness_flutter/data/members/unassigned_card_scan.dart';
import 'package:logfitness_flutter/data/photos/member_photos_repository.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/features/members/member_detail_controller.dart';
import 'package:logfitness_flutter/features/staff/branch_scope.dart';

/// The result of one administrative write.
sealed class MemberAdminOutcome {
  const MemberAdminOutcome();
}

class MemberAdminSucceeded extends MemberAdminOutcome {
  const MemberAdminSucceeded([this.message]);

  /// Something worth telling the desk, when there is something. Inviting a
  /// member returns the address the invitation actually went to, which is the
  /// only way to catch a typo before the member says they never got it.
  final String? message;
}

class MemberAdminFailed extends MemberAdminOutcome {
  const MemberAdminFailed(this.failure);

  final AppFailure failure;

  bool get isRefusal => failure.isRefusal;
}

class MemberAdmin extends Notifier<bool> {
  @override
  bool build() => false; // true while a write is in flight

  /// Saves the member's details.
  ///
  /// `notificationsOptOut` is required rather than optional on purpose: it is
  /// consent, every enqueue job checks it, and a form that quietly defaulted
  /// it would opt someone back in as a side effect of correcting their phone
  /// number.
  Future<MemberAdminOutcome> save({
    required String memberId,
    required String fullName,
    required String phone,
    required String homeBranchId,
    required bool notificationsOptOut,
    String? email,
    DateTime? dateOfBirth,
    MemberGender? gender,
    String? address,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? notes,
  }) {
    return _run(memberId, () async {
      await ref
          .read(membersRepositoryProvider)
          .updateMember(
            memberId: memberId,
            fullName: fullName,
            phone: phone,
            homeBranchId: homeBranchId,
            email: email,
            dateOfBirth: dateOfBirth,
            gender: gender,
            address: address,
            emergencyContactName: emergencyContactName,
            emergencyContactPhone: emergencyContactPhone,
            notes: notes,
            notificationsOptOut: notificationsOptOut,
          );
      return null;
    });
  }

  /// Hides a member from every default list.
  ///
  /// Archiving touches no membership, invoice or payment — nothing financial
  /// is deleted or altered by it. It is not a delete and must never be
  /// presented as one.
  Future<MemberAdminOutcome> archive(String memberId, {String? reason}) {
    return _run(memberId, () async {
      await ref
          .read(membersRepositoryProvider)
          .archiveMember(memberId, reason: reason);
      return null;
    });
  }

  Future<MemberAdminOutcome> restore(String memberId) {
    return _run(memberId, () async {
      await ref.read(membersRepositoryProvider).restoreMember(memberId);
      return null;
    });
  }

  /// Sends the member-app invitation.
  Future<MemberAdminOutcome> inviteToApp({
    required String memberId,
    required String email,
  }) {
    return _run(memberId, () async {
      final invited = await ref
          .read(membersRepositoryProvider)
          .inviteMemberToApp(memberId: memberId, email: email);
      return 'Invitation sent to $invited';
    });
  }

  /// Uploads a photo for this member and points the row at it.
  ///
  /// Upload first, then store the path. An upload that lands and a row update
  /// that fails leaves an orphaned object — storage, and nothing worse. The
  /// other order would point a member at a file that does not exist.
  ///
  /// Refuses a file the bucket itself would refuse, so the failure is a
  /// sentence here rather than a storage exception two round trips later.
  Future<MemberAdminOutcome> setPhoto({
    required String memberId,
    required String orgId,
    required Uint8List bytes,
    required String contentType,
  }) {
    if (!kAllowedPhotoTypes.contains(contentType)) {
      return Future<MemberAdminOutcome>.value(
        const MemberAdminFailed(
          AppFailure(
            FailureKind.invalid,
            'That file is not a JPEG, PNG or WebP image.',
          ),
        ),
      );
    }
    if (bytes.lengthInBytes > kMaxPhotoBytes) {
      return Future<MemberAdminOutcome>.value(
        const MemberAdminFailed(
          AppFailure(
            FailureKind.invalid,
            'That photo is over 5 MB. Take it again at a lower quality.',
          ),
        ),
      );
    }

    return _run(memberId, () async {
      final path = await ref
          .read(memberPhotosRepositoryProvider)
          .upload(
            orgId: orgId,
            memberId: memberId,
            bytes: bytes,
            contentType: contentType,
          );
      await ref.read(membersRepositoryProvider).setPhotoPath(memberId, path);
      return 'Photo saved';
    });
  }

  /// Clears the member's photo.
  ///
  /// Unsets the row first and deletes the object afterwards, best effort: a
  /// member showing a face they asked to have removed is the failure that
  /// matters, and a leftover object in a private bucket is not.
  Future<MemberAdminOutcome> clearPhoto({
    required String memberId,
    String? path,
  }) {
    return _run(memberId, () async {
      await ref.read(membersRepositoryProvider).setPhotoPath(memberId, null);
      if (path != null && path.isNotEmpty) {
        try {
          await ref.read(memberPhotosRepositoryProvider).remove(path);
        } on AppFailure {
          // Already unset on the row, which is the part a person sees.
        }
      }
      return 'Photo removed';
    });
  }

  /// Hands the member an access card.
  ///
  /// [cardUid] is normalised the way the RPC normalises it and checked
  /// against the column's rule first, so a mistyped number is a sentence here
  /// rather than a round trip. [replace] revokes a card the member already
  /// holds; without it the RPC refuses.
  Future<MemberAdminOutcome> assignCard({
    required String memberId,
    required String cardUid,
    bool replace = false,
  }) {
    final uid = normalizeCardUid(cardUid);
    if (!isValidCardUid(uid)) {
      return Future<MemberAdminOutcome>.value(
        const MemberAdminFailed(
          AppFailure(
            FailureKind.invalid,
            'A card number is 8 to 20 characters, using 0-9 and A-F.',
          ),
        ),
      );
    }

    return _run(memberId, () async {
      await ref
          .read(memberCardsRepositoryProvider)
          .assign(memberId: memberId, cardUid: uid, replace: replace);
      ref.invalidate(memberLiveCardProvider(memberId));
      // The RPC clears the matching unassigned scans.
      ref.invalidate(unassignedCardScansProvider);
      return 'Card $uid assigned';
    });
  }

  /// Stops the member's card opening the door. The row is kept, with
  /// [reason]: a card is never deleted.
  Future<MemberAdminOutcome> revokeCard({
    required String memberId,
    required String reason,
  }) {
    final trimmed = reason.trim();
    if (trimmed.isEmpty) {
      return Future<MemberAdminOutcome>.value(
        const MemberAdminFailed(
          AppFailure(FailureKind.invalid, 'Say why the card is being revoked.'),
        ),
      );
    }

    return _run(memberId, () async {
      await ref
          .read(memberCardsRepositoryProvider)
          .revoke(memberId: memberId, reason: trimmed);
      ref.invalidate(memberLiveCardProvider(memberId));
      return 'Card revoked';
    });
  }

  Future<MemberAdminOutcome> _run(
    String memberId,
    Future<String?> Function() action,
  ) async {
    if (state) {
      return const MemberAdminFailed(
        AppFailure(FailureKind.invalid, 'That change is already saving.'),
      );
    }

    state = true;
    try {
      final message = await action();
      // Whatever screen is showing this member is now stale.
      ref.invalidate(memberProfileProvider(memberId));
      return MemberAdminSucceeded(message);
    } catch (error, stackTrace) {
      return MemberAdminFailed(mapError(error, stackTrace));
    } finally {
      state = false;
    }
  }
}

final memberAdminProvider = NotifierProvider<MemberAdmin, bool>(
  MemberAdmin.new,
);

/// The most recent taps of unassigned cards in the branches this shell is
/// scoped to, for picking one in the card sheet. Ten, newest first.
final unassignedCardScansProvider =
    FutureProvider.autoDispose<List<UnassignedCardScan>>((ref) {
      final BranchScope scope = ref.watch(branchScopeProvider);
      return ref
          .watch(memberCardsRepositoryProvider)
          .listUnassignedScans(branchIds: scope.effectiveBranchIds);
    });
