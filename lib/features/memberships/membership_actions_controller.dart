// The corrective half of membership management: freeze, unfreeze, cancel,
// adjust dates, mark left, reactivate, refund and reverse.
//
// Every one of these is a correction to a financial or membership record, and
// every one of them is a single Postgres RPC. None is decomposed into
// `from(...)` calls -- CLAUDE.md: "Multi-table writes go through the existing
// Postgres RPCs". The freeze arithmetic, the cancellation date rule and the
// immutability guards live in the migrations, not here.
//
// Every action reports its outcome. None returns void into a widget that
// assumes success: the web console shipped a bug on 2026-09-07 where a
// `42501` was discarded and a manager could not tell a refused write from a
// completed one. `AppFailure` carries that refusal and this controller makes
// sure something is holding it when it arrives.
//
// Widgets call controllers; controllers call repositories (PLANNING.md §6).
//
// Declared with plain `Notifier` / `NotifierProvider` rather than `@riverpod`
// on purpose: nothing in this file is generated, so it carries no `.g.dart`
// and needs no `build_runner` pass. `lib/features/staff/branch_scope.dart`
// declares its providers the same way.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/data/memberships/membership_rpc_results.dart';
import 'package:logfitness_flutter/data/memberships/memberships_repository.dart';
import 'package:logfitness_flutter/data/members/member_rpc_results.dart';
import 'package:logfitness_flutter/data/payments/payment_rpc_results.dart';
import 'package:logfitness_flutter/data/payments/payments_repository.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';

/// The result of one corrective write. A screen either shows what changed or
/// shows why it did not; there is no third case, and in particular there is
/// no `void` that a caller can mistake for success.
///
/// Generic over the RPC's own result type because these RPCs do not answer
/// the same question: `unfreeze_membership` reports how many days the freeze
/// actually lasted, `adjust_membership_dates` reports the window it moved
/// from, and `refund_payment` reports the negative row it wrote. Collapsing
/// them into a shared shape would throw away the numbers the confirmation
/// needs to state.
sealed class MembershipActionResult<T> {
  const MembershipActionResult();
}

/// The write landed. [value] is whatever the RPC returned.
class MembershipActionSucceeded<T> extends MembershipActionResult<T> {
  const MembershipActionSucceeded(this.value);

  final T value;
}

/// Nothing was written.
class MembershipActionFailed<T> extends MembershipActionResult<T> {
  const MembershipActionFailed(this.failure);

  final AppFailure failure;

  /// The database refused this write. Worth distinguishing at the call site:
  /// role gating in this app is UX only (CLAUDE.md), so a refusal means the
  /// screen offered an action the caller was never allowed to take, and the
  /// message must say so rather than reading as a transient error.
  bool get isRefusal => failure.isRefusal;
}

/// Refused before the RPC was called, because a required reason was blank.
///
/// The database enforces these too -- `cancel_membership` raises a
/// `check_violation` on an empty reason, and `refund_payment` and
/// `reverse_payment` both require one -- so this is a courtesy that saves a
/// round trip, never the rule itself. The rule is in the migration.
const AppFailure _reasonRequired = AppFailure(
  FailureKind.invalid,
  'A reason is required. It is written onto the record and is the only '
  'explanation anyone reading this back will have.',
);

const AppFailure _alreadySaving = AppFailure(
  FailureKind.invalid,
  'That is already being saved.',
);

/// Every corrective action on a membership or a member, behind one in-flight
/// guard.
///
/// The state is `true` while a write is in flight. One guard for all of them
/// rather than one per action is deliberate: these actions correct each
/// other's effects (cancel then refund, freeze then adjust dates), and two of
/// them overlapping on a slow connection is never an intent the desk had.
class MembershipActions extends Notifier<bool> {
  @override
  bool build() => false;

  // --- membership status --------------------------------------------------

  /// Pauses an active membership, with an optional note.
  ///
  /// The RPC takes a note, not a date range: `freeze_membership` stamps
  /// `frozen_on` from `org_today(org_id)` itself and `unfreeze_membership`
  /// measures the elapsed days when the freeze ends. There is no end date to
  /// collect, because the gym does not know one yet -- a screen that asked
  /// for one would be inventing an argument the function does not take.
  Future<MembershipActionResult<FreezeMembershipResult>> freeze(
    String membershipId, {
    String? notes,
  }) {
    return _run(
      () => ref
          .read(membershipsRepositoryProvider)
          .freezeMembership(membershipId, notes: notes),
    );
  }

  /// Resumes a frozen membership and pushes its end date out by however long
  /// the freeze lasted.
  ///
  /// The caller must render [UnfreezeMembershipResult.pausedDays] rather than
  /// computing it: the function measures the freeze against the org's own
  /// today, and the device's clock is not that.
  Future<MembershipActionResult<UnfreezeMembershipResult>> unfreeze(
    String membershipId,
  ) {
    return _run(
      () => ref.read(membershipsRepositoryProvider).unfreezeMembership(
            membershipId,
          ),
    );
  }

  /// Ends a membership early, with a reason.
  ///
  /// Nothing financial is deleted. The invoice and its payments stay exactly
  /// where they are (CLAUDE.md: "Financial history is append-only"), and
  /// giving money back is a separate, additive act -- see [refund].
  Future<MembershipActionResult<MembershipStatusResult>> cancel(
    String membershipId,
    String reason,
  ) {
    if (reason.trim().isEmpty) {
      return Future<MembershipActionResult<MembershipStatusResult>>.value(
        const MembershipActionFailed<MembershipStatusResult>(_reasonRequired),
      );
    }
    return _run(
      () => ref
          .read(membershipsRepositoryProvider)
          .cancelMembership(membershipId, reason.trim()),
    );
  }

  /// Moves a membership's window. The correction path, not a routine action.
  ///
  /// [endDate] is passed through as an explicit null when there is none: a
  /// session pack sold without a validity window genuinely has no end date,
  /// and the repository distinguishes that from "leave it alone".
  ///
  /// What this cannot change is the sale. Plan, price, discount and branch
  /// are refused by `guard_membership_immutability` upstream, which is why
  /// this takes dates and a reason and nothing else.
  Future<MembershipActionResult<AdjustMembershipDatesResult>> adjustDates({
    required String membershipId,
    required DateTime startDate,
    required DateTime? endDate,
    required String reason,
  }) {
    if (reason.trim().isEmpty) {
      return Future<MembershipActionResult<AdjustMembershipDatesResult>>.value(
        const MembershipActionFailed<AdjustMembershipDatesResult>(
          _reasonRequired,
        ),
      );
    }
    return _run(
      () => ref.read(membershipsRepositoryProvider).adjustMembershipDates(
            membershipId: membershipId,
            startDate: startDate,
            endDate: endDate,
            reason: reason.trim(),
          ),
    );
  }

  // --- member status ------------------------------------------------------

  /// Records that the member has left.
  ///
  /// This writes `left_on` and `left_reason` and nothing else. `members.status`
  /// is trigger-derived in Postgres and is never written from the client
  /// (CLAUDE.md), which is why the result carries the status back rather than
  /// the caller assuming what it became.
  ///
  /// [leftOn] is an argument the web console does not pass. Omitting it lets
  /// the RPC fall back to `org_today(org_id)`, which is the right default;
  /// pass it only when the desk is recording a departure it is logging late.
  Future<MembershipActionResult<MemberStatusResult>> markLeft(
    String memberId, {
    String? reason,
    DateTime? leftOn,
  }) {
    return _run(
      () => ref.read(membershipsRepositoryProvider).setMemberLeft(
            memberId,
            reason: reason == null || reason.trim().isEmpty
                ? null
                : reason.trim(),
            leftOn: leftOn,
          ),
    );
  }

  /// Clears `left_on` and `left_reason` so the derivation trigger can put the
  /// member back to whatever their memberships say they are.
  ///
  /// Note what this does *not* do: it does not decide the member is active.
  /// It removes the departure and lets Postgres re-derive the status, which
  /// may well be `expired`. The result says which.
  Future<MembershipActionResult<MemberStatusResult>> reactivate(
    String memberId,
  ) {
    return _run(
      () => ref.read(membershipsRepositoryProvider).reactivateMember(memberId),
    );
  }

  // --- money --------------------------------------------------------------

  /// Gives money back: a **negative `payments` row** with a reason.
  ///
  /// Not a deletion and not an edit of the original payment -- the app never
  /// deletes or edits a payment (CLAUDE.md). The original row stays exactly
  /// as it was and the refund sits beside it, so summing the column gives net
  /// cash. [RefundPaymentResult.amountPaisa] comes back negative for that
  /// reason; [amountPaisa] is passed in positive.
  ///
  /// A null [method] means "back the way it came": the RPC defaults to the
  /// original payment's method, which is better than this layer guessing cash.
  ///
  /// **Not idempotent, and it moves money.** The in-flight guard in [_run] is
  /// the only thing standing between a double tap on a slow connection and a
  /// second refund, because there is no idempotency key upstream (CLAUDE.md,
  /// scope discipline: a replay queue "needs idempotency keys added upstream
  /// before it is even discussable").
  Future<MembershipActionResult<RefundPaymentResult>> refund({
    required String paymentId,
    required int amountPaisa,
    required String reason,
    PaymentMethod? method,
    String? referenceNo,
  }) {
    if (reason.trim().isEmpty) {
      return Future<MembershipActionResult<RefundPaymentResult>>.value(
        const MembershipActionFailed<RefundPaymentResult>(_reasonRequired),
      );
    }
    if (amountPaisa <= 0) {
      return Future<MembershipActionResult<RefundPaymentResult>>.value(
        const MembershipActionFailed<RefundPaymentResult>(
          AppFailure(
            FailureKind.invalid,
            'Enter how much is going back. A refund of nothing is not a '
            'correction.',
          ),
        ),
      );
    }
    return _run(
      () => ref.read(paymentsRepositoryProvider).refundPayment(
            paymentId: paymentId,
            // Positive here; the function writes the row negative.
            amountPaisa: amountPaisa,
            reason: reason.trim(),
            method: method,
            referenceNo: referenceNo,
          ),
    );
  }

  /// Records that a payment which was rung up **never actually arrived**.
  ///
  /// Mechanically a refund -- a negative row the invoice totals follow
  /// straight back into a due -- but a different fact, and it carries its own
  /// `payment_kind` so the collection sheet can tell money handed back from
  /// money that was never taken. `PaymentKind.reversal` was missing from the
  /// Dart enum until 2026-09-09 and its absence took out payment history for
  /// any org that had reversed an entry; the two kinds are deliberately never
  /// presented as the same action.
  ///
  /// A null [amountPaisa] takes the whole entry back; a value reverses part
  /// of it.
  ///
  /// **Not idempotent, and it moves money** -- see [refund].
  Future<MembershipActionResult<ReversePaymentResult>> reverse({
    required String paymentId,
    required String reason,
    int? amountPaisa,
  }) {
    if (reason.trim().isEmpty) {
      return Future<MembershipActionResult<ReversePaymentResult>>.value(
        const MembershipActionFailed<ReversePaymentResult>(_reasonRequired),
      );
    }
    return _run(
      () => ref.read(paymentsRepositoryProvider).reversePayment(
            paymentId: paymentId,
            reason: reason.trim(),
            amountPaisa: amountPaisa,
          ),
    );
  }

  // ------------------------------------------------------------------------

  /// Runs one write behind the in-flight guard and maps anything thrown.
  ///
  /// Nothing is caught and discarded here. `mapError` always returns
  /// something renderable, so a refusal the database issues always has a
  /// sentence attached by the time it reaches the panel.
  Future<MembershipActionResult<T>> _run<T>(Future<T> Function() action) async {
    if (state) {
      // A double tap is not a second intent. For `refund_payment` and
      // `reverse_payment` this is load-bearing rather than polite: neither is
      // idempotent, and a replayed call moves money a second time.
      return MembershipActionFailed<T>(_alreadySaving);
    }

    state = true;
    try {
      return MembershipActionSucceeded<T>(await action());
    } catch (error, stackTrace) {
      return MembershipActionFailed<T>(mapError(error, stackTrace));
    } finally {
      state = false;
    }
  }
}

/// The write side of the membership action panel.
///
/// Watch it for the busy flag; read `.notifier` to act.
final membershipActionsProvider = NotifierProvider<MembershipActions, bool>(
  MembershipActions.new,
);
