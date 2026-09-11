// Editing a member, archiving one, and inviting one into the member app.
//
// Declared with manual `Notifier`/`Provider` rather than `@riverpod` to stay
// out of the codegen graph, the same choice `branch_scope.dart` makes.
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/data/members/members_repository.dart';
import 'package:logfitness_flutter/data/photos/member_photos_repository.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/features/members/member_detail_controller.dart';

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
      await ref.read(membersRepositoryProvider).updateMember(
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
      await ref.read(membersRepositoryProvider).archiveMember(
            memberId,
            reason: reason,
          );
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
      final path = await ref.read(memberPhotosRepositoryProvider).upload(
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

final memberAdminProvider =
    NotifierProvider<MemberAdmin, bool>(MemberAdmin.new);
