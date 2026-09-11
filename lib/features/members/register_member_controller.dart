// Registering a walk-in, and — when they came from the visitor log — linking
// the visitor row to the member they became.
//
// The whole write is one RPC. `register_member` creates the member, and
// optionally the membership, the invoice and the payment, inside one
// transaction; decomposing it into client calls is what CLAUDE.md forbids and
// what would let a gym end up with a member who has an invoice and no
// membership.
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:logfitness_flutter/data/members/member_rpc_results.dart';
import 'package:logfitness_flutter/data/members/members_repository.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/features/visitors/visitor_actions_controller.dart';

part 'register_member_controller.g.dart';

/// What came back from a registration attempt.
sealed class RegisterOutcome {
  const RegisterOutcome();
}

/// The member exists. [linkFailure] is set when the member was created but the
/// visitor row could not be pointed at them.
class RegisterSucceeded extends RegisterOutcome {
  const RegisterSucceeded(this.result, {this.linkFailure});

  final RegisterMemberResult result;

  /// The visitor link failed *after* the member was created.
  ///
  /// Deliberately not a failure of the whole operation. Registering and then
  /// failing to link leaves a real member and a visitor still marked open,
  /// which a person can correct in a few seconds; refusing the registration
  /// because the link failed would lose the member and the money with them.
  /// The ordering decision is recorded upstream in
  /// `logfitness_saas/PLANNING.md` §4.
  final AppFailure? linkFailure;

  bool get isFullySucceeded => linkFailure == null;
}

/// No member was created.
class RegisterFailed extends RegisterOutcome {
  const RegisterFailed(this.failure);

  final AppFailure failure;

  bool get isRefusal => failure.isRefusal;
}

@riverpod
class RegisterMember extends _$RegisterMember {
  @override
  bool build() => false; // true while a registration is in flight

  /// Registers a member, optionally selling them a plan in the same
  /// transaction, and optionally converting the visitor they walked in as.
  ///
  /// Money arrives here already in paisa. Rupees are converted exactly once,
  /// at the input boundary, by the screen (CLAUDE.md).
  Future<RegisterOutcome> submit({
    required String fullName,
    required String phone,
    required String homeBranchId,
    String? email,
    DateTime? dateOfBirth,
    MemberGender? gender,
    String? address,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? notes,
    String? planId,
    int discountPaisa = 0,
    int amountPaidPaisa = 0,
    PaymentMethod method = PaymentMethod.cash,
    String? referenceNo,
    DateTime? startDate,
    DiscountReason? discountReason,
    String? discountNote,
    String? visitorId,
  }) async {
    if (state) {
      // `register_member` is not idempotent. A second tap on a slow
      // connection would create a second member and take the money twice, so
      // the guard is not politeness — it is the absence of a replay key.
      return const RegisterFailed(
        AppFailure(FailureKind.invalid, 'That registration is already saving.'),
      );
    }

    state = true;
    try {
      final RegisterMemberResult result =
          await ref.read(membersRepositoryProvider).registerMember(
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
                planId: planId,
                discountPaisa: discountPaisa,
                amountPaidPaisa: amountPaidPaisa,
                method: method,
                referenceNo: referenceNo,
                startDate: startDate,
                discountReason: discountReason,
                discountNote: discountNote,
              );

      if (visitorId == null) {
        return RegisterSucceeded(result);
      }

      // Register first, link second — see [RegisterSucceeded.linkFailure].
      final linkResult = await ref
          .read(visitorActionsProvider.notifier)
          .convert(visitorId: visitorId, memberId: result.memberId);

      return switch (linkResult) {
        VisitorActionSucceeded() => RegisterSucceeded(result),
        VisitorActionFailed(:final failure) =>
          RegisterSucceeded(result, linkFailure: failure),
      };
    } catch (error, stackTrace) {
      return RegisterFailed(mapError(error, stackTrace));
    } finally {
      state = false;
    }
  }
}
