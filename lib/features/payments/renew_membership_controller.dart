// Selling the next period.
//
// The whole write is one RPC. `renew_membership` inserts a new `memberships`
// row, raises its invoice and -- if money changed hands -- writes the payment,
// inside one transaction. It never edits the membership being renewed:
// financial history is append-only (CLAUDE.md), so the previous row stays
// exactly as it was sold and the new one points back at it.
//
// Declared with a plain `NotifierProvider` rather than `@riverpod` so this
// folder needs no `build_runner` run.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/data/memberships/membership_rpc_results.dart';
import 'package:logfitness_flutter/data/memberships/memberships_repository.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';

/// What came back from a renewal attempt.
///
/// A sealed outcome rather than a thrown exception or a bare `void`, matching
/// `register_member_controller.dart`: the screen has to tell "sold, nothing
/// outstanding" from "sold, 4,000 still due" from "refused", and each of the
/// three is a different sentence at the counter.
sealed class RenewOutcome {
  const RenewOutcome();
}

/// A membership was inserted. [result] carries the period the database chose
/// and the due it left behind.
class RenewSucceeded extends RenewOutcome {
  const RenewSucceeded(this.result);

  final RenewMembershipResult result;
}

/// Nothing was written.
class RenewFailed extends RenewOutcome {
  const RenewFailed(this.failure);

  final AppFailure failure;

  bool get isRefusal => failure.isRefusal;
}

/// `true` while a renewal is in flight.
class RenewMembership extends Notifier<bool> {
  @override
  bool build() => false;

  /// Sells [planId] to [memberId] at [branchId].
  ///
  /// Money arrives here already in paisa. Rupees are converted exactly once,
  /// at the input boundary, by the screen (CLAUDE.md).
  Future<RenewOutcome> submit({
    required String memberId,
    required String planId,
    required String branchId,
    DateTime? startDate,
    int discountPaisa = 0,
    int amountPaidPaisa = 0,
    PaymentMethod method = PaymentMethod.cash,
    String? referenceNo,
    String? notes,
    DiscountReason? discountReason,
    String? discountNote,
  }) async {
    if (state) {
      // `renew_membership` is not idempotent and there is no replay key
      // upstream (CLAUDE.md, scope discipline). A second tap on a slow
      // connection would sell a second membership and take the money twice,
      // so the guard is the only thing standing between a double tap and a
      // duplicate sale.
      return const RenewFailed(
        AppFailure(FailureKind.invalid, 'That renewal is already saving.'),
      );
    }

    state = true;
    try {
      final RenewMembershipResult result = await ref
          .read(membershipsRepositoryProvider)
          .renewMembership(
            memberId: memberId,
            planId: planId,
            branchId: branchId,
            startDate: startDate,
            discountPaisa: discountPaisa,
            amountPaidPaisa: amountPaidPaisa,
            method: method,
            referenceNo: referenceNo,
            notes: notes,
            discountReason: discountReason,
            discountNote: discountNote,
          );
      return RenewSucceeded(result);
    } catch (error, stackTrace) {
      // Never swallowed. A `42501` has to reach the person as a refusal --
      // the 2026-09-07 console bug is exactly a refusal rendered as silence
      // (`failure_view.dart`).
      return RenewFailed(mapError(error, stackTrace));
    } finally {
      state = false;
    }
  }
}

final renewMembershipProvider = NotifierProvider<RenewMembership, bool>(
  RenewMembership.new,
);
