// The corrective actions, and the two properties that matter most about
// them: every one reports its outcome, and the two that move money cannot be
// made to run twice by a double tap.
//
// `Override` is not exported by flutter_riverpod 3.1.0, so override lists stay
// untyped literals (TASKS.md, Discovered, 2026-09-05).
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/members/member_rpc_results.dart';
import 'package:logfitness_flutter/data/memberships/membership_rpc_results.dart';
import 'package:logfitness_flutter/data/memberships/memberships_repository.dart';
import 'package:logfitness_flutter/data/payments/payment_rpc_results.dart';
import 'package:logfitness_flutter/data/payments/payments_repository.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/features/memberships/membership_actions_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A slow enough round trip that a second call can observe the in-flight
/// guard, which is the only thing standing between a double tap and a second
/// write.
const Duration _roundTrip = Duration(milliseconds: 10);

class _FakeMembershipsRepository implements MembershipsRepository {
  int freezeCalls = 0;
  int unfreezeCalls = 0;
  int cancelCalls = 0;
  int adjustCalls = 0;
  int setLeftCalls = 0;
  int reactivateCalls = 0;

  Map<String, Object?> lastArgs = <String, Object?>{};
  Object? error;

  Future<void> _wait() async {
    await Future<void>.delayed(_roundTrip);
    if (error != null) {
      throw error!;
    }
  }

  @override
  Future<FreezeMembershipResult> freezeMembership(
    String membershipId, {
    String? notes,
  }) async {
    freezeCalls++;
    lastArgs = <String, Object?>{'membershipId': membershipId, 'notes': notes};
    await _wait();
    return FreezeMembershipResult(
      membershipId: membershipId,
      frozenOn: DateTime.utc(2026, 9, 10),
    );
  }

  @override
  Future<UnfreezeMembershipResult> unfreezeMembership(
    String membershipId,
  ) async {
    unfreezeCalls++;
    await _wait();
    return UnfreezeMembershipResult(
      membershipId: membershipId,
      pausedDays: 12,
      endDate: DateTime.utc(2026, 12, 1),
    );
  }

  @override
  Future<MembershipStatusResult> cancelMembership(
    String membershipId,
    String reason,
  ) async {
    cancelCalls++;
    lastArgs = <String, Object?>{'membershipId': membershipId, 'reason': reason};
    await _wait();
    return MembershipStatusResult(
      membershipId: membershipId,
      status: MembershipStatus.cancelled,
    );
  }

  @override
  Future<AdjustMembershipDatesResult> adjustMembershipDates({
    required String membershipId,
    required DateTime startDate,
    required DateTime? endDate,
    required String reason,
  }) async {
    adjustCalls++;
    lastArgs = <String, Object?>{
      'membershipId': membershipId,
      'startDate': startDate,
      'endDate': endDate,
      'reason': reason,
    };
    await _wait();
    return AdjustMembershipDatesResult(
      membershipId: membershipId,
      memberId: 'member-1',
      previousStartDate: DateTime.utc(2026, 9, 1),
      previousEndDate: DateTime.utc(2026, 12, 1),
      startDate: startDate,
      endDate: endDate,
      daysMoved: 3,
      daysChanged: 0,
      status: MembershipStatus.active,
    );
  }

  @override
  Future<MemberStatusResult> setMemberLeft(
    String memberId, {
    String? reason,
    DateTime? leftOn,
  }) async {
    setLeftCalls++;
    lastArgs = <String, Object?>{
      'memberId': memberId,
      'reason': reason,
      'leftOn': leftOn,
    };
    await _wait();
    return MemberStatusResult(memberId: memberId, status: MemberStatus.left);
  }

  @override
  Future<MemberStatusResult> reactivateMember(String memberId) async {
    reactivateCalls++;
    await _wait();
    // Deliberately `expired`, not `active`: the status is trigger-derived and
    // reactivating someone with no live membership does not sell them one.
    return MemberStatusResult(
      memberId: memberId,
      status: MemberStatus.expired,
    );
  }

  @override
  Never noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not faked');
}

class _FakePaymentsRepository implements PaymentsRepository {
  int refundCalls = 0;
  int reverseCalls = 0;
  Map<String, Object?> lastArgs = <String, Object?>{};
  Object? error;

  Future<void> _wait() async {
    await Future<void>.delayed(_roundTrip);
    if (error != null) {
      throw error!;
    }
  }

  @override
  Future<RefundPaymentResult> refundPayment({
    required String paymentId,
    required int amountPaisa,
    required String reason,
    PaymentMethod? method,
    String? referenceNo,
  }) async {
    refundCalls++;
    lastArgs = <String, Object?>{
      'paymentId': paymentId,
      'amountPaisa': amountPaisa,
      'reason': reason,
      'method': method,
    };
    await _wait();
    // Negative, as the RPC writes it: a refund is an additive negative row.
    return RefundPaymentResult(
      refundId: 'refund-1',
      amountPaisa: -amountPaisa,
    );
  }

  @override
  Future<ReversePaymentResult> reversePayment({
    required String paymentId,
    required String reason,
    int? amountPaisa,
  }) async {
    reverseCalls++;
    lastArgs = <String, Object?>{
      'paymentId': paymentId,
      'reason': reason,
      'amountPaisa': amountPaisa,
    };
    await _wait();
    return ReversePaymentResult(
      reversalId: 'reversal-1',
      paymentId: paymentId,
      amountPaisa: -(amountPaisa ?? 400000),
      invoiceId: 'invoice-1',
      invoiceNo: 'INV-0007',
      duePaisa: 400000,
      status: InvoiceStatus.unpaid,
    );
  }

  @override
  Never noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not faked');
}

void main() {
  late _FakeMembershipsRepository memberships;
  late _FakePaymentsRepository payments;
  late ProviderContainer container;

  setUp(() {
    memberships = _FakeMembershipsRepository();
    payments = _FakePaymentsRepository();
    container = ProviderContainer(
      overrides: [
        membershipsRepositoryProvider.overrideWithValue(memberships),
        paymentsRepositoryProvider.overrideWithValue(payments),
      ],
    );

    // The panel holds this provider with `ref.watch`; without an equivalent
    // subscription here the notifier auto-disposes across the first await and
    // the test fails on a disposed Ref rather than on anything real.
    container.listen<bool>(membershipActionsProvider, (_, _) {});
  });

  tearDown(() => container.dispose());

  MembershipActions notifier() =>
      container.read(membershipActionsProvider.notifier);

  group('every action reports its outcome', () {
    test('freeze reports the day the freeze started', () async {
      final result = await notifier().freeze('ms-1', notes: 'Travelling');

      expect(result, isA<MembershipActionSucceeded<FreezeMembershipResult>>());
      final value =
          (result as MembershipActionSucceeded<FreezeMembershipResult>).value;
      // Read back from the RPC, which stamps it from `org_today` -- not from
      // this machine's clock.
      expect(value.frozenOn, DateTime.utc(2026, 9, 10));
      expect(memberships.lastArgs['notes'], 'Travelling');
    });

    test('unfreeze reports how far the end date moved', () async {
      final result = await notifier().unfreeze('ms-1');

      final value = (result
              as MembershipActionSucceeded<UnfreezeMembershipResult>)
          .value;
      expect(value.pausedDays, 12);
    });

    test('cancel reports the status the membership now holds', () async {
      final result = await notifier().cancel('ms-1', 'Member moved away');

      final value =
          (result as MembershipActionSucceeded<MembershipStatusResult>).value;
      expect(value.status, MembershipStatus.cancelled);
      expect(memberships.lastArgs['reason'], 'Member moved away');
    });

    test('adjusting dates reports the signed day counts', () async {
      final result = await notifier().adjustDates(
        membershipId: 'ms-1',
        startDate: DateTime.utc(2026, 9, 4),
        endDate: DateTime.utc(2026, 12, 4),
        reason: 'Started a week late',
      );

      final value = (result
              as MembershipActionSucceeded<AdjustMembershipDatesResult>)
          .value;
      expect(value.daysMoved, 3);
    });

    test('an end date of null is passed through, not dropped', () async {
      // A session pack genuinely has no validity window. "None" and
      // "unchanged" are different instructions to the RPC.
      await notifier().adjustDates(
        membershipId: 'ms-1',
        startDate: DateTime.utc(2026, 9, 4),
        endDate: null,
        reason: 'Pack has no end date',
      );

      expect(memberships.adjustCalls, 1);
      expect(memberships.lastArgs.containsKey('endDate'), isTrue);
      expect(memberships.lastArgs['endDate'], isNull);
    });

    test('mark left reports the derived status rather than assuming it',
        () async {
      final result = await notifier().markLeft('member-1', reason: 'Moved');

      final value =
          (result as MembershipActionSucceeded<MemberStatusResult>).value;
      expect(value.status, MemberStatus.left);
      // `members.status` is never written from the client (CLAUDE.md); only
      // `left_on` and `left_reason` go over the wire.
      expect(memberships.lastArgs['reason'], 'Moved');
    });

    test('mark left omits left_on so the org decides the day', () async {
      await notifier().markLeft('member-1');

      // Omitted, not defaulted to the device's today: the RPC falls back to
      // `org_today(org_id)`, and a phone in the wrong timezone would
      // otherwise record the wrong day.
      expect(memberships.lastArgs['leftOn'], isNull);
      // A blank reason is sent as null rather than as an empty string.
      expect(memberships.lastArgs['reason'], isNull);
    });

    test('reactivate can come back expired, and says so', () async {
      final result = await notifier().reactivate('member-1');

      final value =
          (result as MembershipActionSucceeded<MemberStatusResult>).value;
      expect(value.status, MemberStatus.expired);
    });

    test('refund reports the negative row it wrote', () async {
      final result = await notifier().refund(
        paymentId: 'pay-1',
        amountPaisa: 400000,
        reason: 'Paid twice',
      );

      final value =
          (result as MembershipActionSucceeded<RefundPaymentResult>).value;
      // Passed positive, written negative -- financial history is
      // append-only, so a refund is a row, not an edit.
      expect(payments.lastArgs['amountPaisa'], 400000);
      expect(value.amountPaisa, -400000);
    });

    test('refund sends no method, so the RPC returns it the way it came',
        () async {
      await notifier().refund(
        paymentId: 'pay-1',
        amountPaisa: 400000,
        reason: 'Paid twice',
      );

      expect(payments.lastArgs['method'], isNull);
    });

    test('reverse reports what the invoice owes again', () async {
      final result = await notifier().reverse(
        paymentId: 'pay-1',
        reason: 'Cheque bounced',
      );

      final value =
          (result as MembershipActionSucceeded<ReversePaymentResult>).value;
      expect(value.duePaisa, 400000);
      // Null takes the whole entry back.
      expect(payments.lastArgs['amountPaisa'], isNull);
    });

    test('a partial reversal sends the amount taken back', () async {
      await notifier().reverse(
        paymentId: 'pay-1',
        reason: 'Only gave half',
        amountPaisa: 200000,
      );

      expect(payments.lastArgs['amountPaisa'], 200000);
    });
  });

  group('money moves once, whatever the desk taps', () {
    test('a double refund reaches the RPC once', () async {
      // `refund_payment` is not idempotent and it moves money. Two taps on a
      // slow connection must not hand back twice; there is no idempotency key
      // upstream, so the in-flight guard is the whole defence.
      final first = notifier().refund(
        paymentId: 'pay-1',
        amountPaisa: 400000,
        reason: 'Paid twice',
      );
      final second = notifier().refund(
        paymentId: 'pay-1',
        amountPaisa: 400000,
        reason: 'Paid twice',
      );

      final results = await Future.wait<
          MembershipActionResult<RefundPaymentResult>>(<Future<
          MembershipActionResult<RefundPaymentResult>>>[first, second]);

      expect(payments.refundCalls, 1);
      expect(
        results.whereType<MembershipActionSucceeded<RefundPaymentResult>>(),
        hasLength(1),
      );
      // The loser is told, not silently dropped.
      expect(
        results.whereType<MembershipActionFailed<RefundPaymentResult>>(),
        hasLength(1),
      );
    });

    test('a double reversal reaches the RPC once', () async {
      final first =
          notifier().reverse(paymentId: 'pay-1', reason: 'Never arrived');
      final second =
          notifier().reverse(paymentId: 'pay-1', reason: 'Never arrived');

      await Future.wait<MembershipActionResult<ReversePaymentResult>>(<Future<
          MembershipActionResult<ReversePaymentResult>>>[first, second]);

      expect(payments.reverseCalls, 1);
    });

    test('the guard is shared, so a refund cannot race a cancel', () async {
      // These actions correct each other's effects. Two of them overlapping
      // on a slow connection is never an intent the desk had.
      final refund = notifier().refund(
        paymentId: 'pay-1',
        amountPaisa: 400000,
        reason: 'Paid twice',
      );
      final cancel = notifier().cancel('ms-1', 'Member left');

      await refund;
      final cancelResult = await cancel;

      expect(payments.refundCalls, 1);
      expect(memberships.cancelCalls, 0);
      expect(
        cancelResult,
        isA<MembershipActionFailed<MembershipStatusResult>>(),
      );
    });
  });

  group('a required reason is required', () {
    test('a refund with no reason never reaches the RPC', () async {
      final result = await notifier().refund(
        paymentId: 'pay-1',
        amountPaisa: 400000,
        reason: '   ',
      );

      expect(payments.refundCalls, 0);
      final failed =
          result as MembershipActionFailed<RefundPaymentResult>;
      expect(failed.failure.kind, FailureKind.invalid);
      expect(failed.failure.message, contains('reason is required'));
    });

    test('a reversal with no reason never reaches the RPC', () async {
      final result =
          await notifier().reverse(paymentId: 'pay-1', reason: '');

      expect(payments.reverseCalls, 0);
      expect(result, isA<MembershipActionFailed<ReversePaymentResult>>());
    });

    test('a cancellation with no reason never reaches the RPC', () async {
      final result = await notifier().cancel('ms-1', '');

      expect(memberships.cancelCalls, 0);
      expect(result, isA<MembershipActionFailed<MembershipStatusResult>>());
    });

    test('a date adjustment with no reason never reaches the RPC', () async {
      final result = await notifier().adjustDates(
        membershipId: 'ms-1',
        startDate: DateTime.utc(2026, 9, 4),
        endDate: DateTime.utc(2026, 12, 4),
        reason: '  ',
      );

      expect(memberships.adjustCalls, 0);
      expect(result, isA<MembershipActionFailed<AdjustMembershipDatesResult>>());
    });

    test('a refund of nothing is refused before the RPC', () async {
      final result = await notifier().refund(
        paymentId: 'pay-1',
        amountPaisa: 0,
        reason: 'Paid twice',
      );

      expect(payments.refundCalls, 0);
      expect(result, isA<MembershipActionFailed<RefundPaymentResult>>());
    });
  });

  group('a refusal reaches the caller as a refusal', () {
    test('a refused refund is a refusal, not a generic error', () async {
      // Role gating in this app is UX only. A front desk that reaches
      // `refund_payment` anyway gets a 42501, and it has to arrive as a
      // refusal -- the 2026-09-07 console bug was a swallowed one.
      payments.error = const PostgrestException(
        message: 'permission denied for function refund_payment',
        code: '42501',
      );

      final result = await notifier().refund(
        paymentId: 'pay-1',
        amountPaisa: 400000,
        reason: 'Paid twice',
      );

      final failed = result as MembershipActionFailed<RefundPaymentResult>;
      expect(failed.isRefusal, isTrue);
      expect(failed.failure.kind, FailureKind.refused);
      expect(failed.failure.code, '42501');
    });

    test('a refused cancellation is a refusal too', () async {
      memberships.error = const PostgrestException(
        message: 'permission denied for function cancel_membership',
        code: '42501',
      );

      final result = await notifier().cancel('ms-1', 'Member left');

      expect(
        (result as MembershipActionFailed<MembershipStatusResult>).isRefusal,
        isTrue,
      );
    });

    test('a check violation keeps the database\'s own sentence', () async {
      memberships.error = const PostgrestException(
        message: 'A cancellation needs a reason',
        code: '23514',
      );

      final result = await notifier().cancel('ms-1', 'something');

      final failed = result as MembershipActionFailed<MembershipStatusResult>;
      expect(failed.failure.kind, FailureKind.invalid);
      // Passed through, not reworded: the RPC already wrote a sentence for a
      // person at a desk.
      expect(failed.failure.message, 'A cancellation needs a reason');
    });

    test('offline says loudly that nothing was saved', () async {
      // Writes are never queued locally (PLANNING.md scope: "offline-first is
      // deferred, not solved"), so this cannot read as "will sync later".
      payments.error = const SocketException('Failed host lookup');

      final result = await notifier().refund(
        paymentId: 'pay-1',
        amountPaisa: 400000,
        reason: 'Paid twice',
      );

      final failed = result as MembershipActionFailed<RefundPaymentResult>;
      expect(failed.failure.kind, FailureKind.offline);
      expect(failed.failure.message, contains('nothing was saved'));
    });

    test('the in-flight flag is cleared after a failure', () async {
      memberships.error = const PostgrestException(
        message: 'permission denied',
        code: '42501',
      );
      await notifier().cancel('ms-1', 'Member left');

      // A refused write must not wedge the panel; the next attempt has to be
      // able to run.
      expect(container.read(membershipActionsProvider), isFalse);
      memberships.error = null;
      final second = await notifier().cancel('ms-1', 'Member left');
      expect(second, isA<MembershipActionSucceeded<MembershipStatusResult>>());
    });
  });
}
