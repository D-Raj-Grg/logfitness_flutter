// Taking money. The two things that must not go wrong are a double tap
// taking it twice, and a refusal that never reaches the person.
//
// `Override` is not exported by flutter_riverpod 3.1.0, so override lists stay
// untyped literals (TASKS.md, Discovered, 2026-09-05).
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/payments/payment_rpc_results.dart';
import 'package:logfitness_flutter/data/payments/payments_repository.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/features/payments/payment_formatting.dart';
import 'package:logfitness_flutter/features/payments/record_payment_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _FakePaymentsRepository implements PaymentsRepository {
  int recordCallCount = 0;
  Map<String, Object?> lastArgs = <String, Object?>{};
  Object? error;

  /// What the invoice still owes. The fake refuses an overpayment the way the
  /// RPC does, with the same errcode and the same sentence.
  int duePaisa = 400000;

  @override
  Future<RecordPaymentResult> recordPayment({
    required String invoiceId,
    required int amountPaisa,
    PaymentMethod method = PaymentMethod.cash,
    String? referenceNo,
    String? notes,
  }) async {
    recordCallCount++;
    lastArgs = <String, Object?>{
      'invoiceId': invoiceId,
      'amountPaisa': amountPaisa,
      'method': method,
      'referenceNo': referenceNo,
      'notes': notes,
    };
    // Let a concurrent second call observe the in-flight guard.
    await Future<void>.delayed(const Duration(milliseconds: 10));
    if (error != null) {
      throw error!;
    }
    if (amountPaisa > duePaisa) {
      throw PostgrestException(
        message:
            'Payment exceeds the $duePaisa outstanding on invoice INV-0007',
        code: '23514',
      );
    }
    final int paid = amountPaisa;
    return RecordPaymentResult(
      paymentId: 'pay-1',
      invoiceId: invoiceId,
      paidPaisa: paid,
      duePaisa: duePaisa - paid,
      status: duePaisa - paid == 0
          ? InvoiceStatus.paid
          : InvoiceStatus.partial,
    );
  }

  @override
  Never noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not faked');
}

List<dynamic> _overrides(_FakePaymentsRepository repo) => <dynamic>[
  paymentsRepositoryProvider.overrideWithValue(repo),
];

void main() {
  late _FakePaymentsRepository payments;
  late ProviderContainer container;

  setUp(() {
    payments = _FakePaymentsRepository();
    container = ProviderContainer(overrides: [..._overrides(payments)]);

    // The screen holds this provider with `ref.watch`; without an equivalent
    // subscription here the notifier auto-disposes across the first await.
    container.listen<bool>(recordPaymentProvider, (_, _) {});
  });

  tearDown(() => container.dispose());

  RecordPayment notifier() => container.read(recordPaymentProvider.notifier);

  test('rupees reach the RPC as integer paisa, converted exactly once',
      () async {
    // The screen converts at the input boundary and hands the controller
    // paisa; nothing downstream ever sees a double (CLAUDE.md).
    await notifier().submit(
      invoiceId: 'inv-1',
      amountPaisa: paisaOrZero('1234.56'),
    );

    expect(payments.lastArgs['amountPaisa'], 123456);
    expect(payments.lastArgs['amountPaisa'], isA<int>());
  });

  test('a double submit reaches the RPC once', () async {
    // `record_payment` is not idempotent and there is no replay key upstream
    // (CLAUDE.md). A second tap on a slow connection takes the money twice.
    final Future<RecordPaymentOutcome> first = notifier().submit(
      invoiceId: 'inv-1',
      amountPaisa: 250000,
    );
    final Future<RecordPaymentOutcome> second = notifier().submit(
      invoiceId: 'inv-1',
      amountPaisa: 250000,
    );

    final List<RecordPaymentOutcome> results =
        await Future.wait<RecordPaymentOutcome>(<Future<RecordPaymentOutcome>>[
      first,
      second,
    ]);

    expect(payments.recordCallCount, 1);
    expect(results.whereType<RecordPaymentSucceeded>(), hasLength(1));
    expect(results.whereType<RecordPaymentFailed>(), hasLength(1));
  });

  test('the guard clears, so a genuine second payment still goes through',
      () async {
    await notifier().submit(invoiceId: 'inv-1', amountPaisa: 100000);
    await notifier().submit(invoiceId: 'inv-1', amountPaisa: 100000);

    expect(payments.recordCallCount, 2);
  });

  test('a 42501 surfaces as a refusal, not as a generic error', () async {
    payments.error = const PostgrestException(
      message: 'new row violates row-level security policy for table "payments"',
      code: '42501',
    );

    final RecordPaymentOutcome outcome = await notifier().submit(
      invoiceId: 'inv-1',
      amountPaisa: 250000,
    );

    expect(outcome, isA<RecordPaymentFailed>());
    final RecordPaymentFailed failed = outcome as RecordPaymentFailed;
    expect(failed.isRefusal, isTrue);
    expect(failed.failure.kind, FailureKind.refused);
    expect(failed.failure.code, '42501');
  });

  test('an offline attempt says nothing was saved', () async {
    // No local write queue by design (CLAUDE.md), so this must never read as
    // an optimistic success.
    payments.error = const SocketException('Failed host lookup');

    final RecordPaymentOutcome outcome = await notifier().submit(
      invoiceId: 'inv-1',
      amountPaisa: 250000,
    );

    expect(outcome, isA<RecordPaymentFailed>());
    final RecordPaymentFailed failed = outcome as RecordPaymentFailed;
    expect(failed.failure.kind, FailureKind.offline);
    expect(failed.failure.message, contains('nothing was saved'));
  });

  test(
    'an amount over the outstanding balance is refused by the RPC, and its '
    'own sentence is what the desk sees',
    () async {
      // Matched to the console: `record-payment-form.tsx` prefills the amount
      // with the due but does not clamp it, and `record_payment` raises a
      // `check_violation` naming the figure and the invoice. `mapError`
      // passes 23514 through verbatim rather than substituting friendlier,
      // vaguer copy.
      payments.duePaisa = 400000;

      final RecordPaymentOutcome outcome = await notifier().submit(
        invoiceId: 'inv-1',
        amountPaisa: 500000,
      );

      expect(outcome, isA<RecordPaymentFailed>());
      final RecordPaymentFailed failed = outcome as RecordPaymentFailed;
      expect(failed.failure.kind, FailureKind.invalid);
      expect(failed.failure.message, contains('exceeds'));
      expect(failed.failure.message, contains('INV-0007'));
      // The controller sent it unclamped. Clamping here would have hidden a
      // real disagreement about what is owed.
      expect(payments.lastArgs['amountPaisa'], 500000);
    },
  );

  test('a settled invoice comes back as settled, read off the trigger',
      () async {
    payments.duePaisa = 250000;

    final RecordPaymentOutcome outcome = await notifier().submit(
      invoiceId: 'inv-1',
      amountPaisa: 250000,
    );

    expect(outcome, isA<RecordPaymentSucceeded>());
    final RecordPaymentSucceeded ok = outcome as RecordPaymentSucceeded;
    expect(ok.isSettled, isTrue);
    expect(ok.result.duePaisa, 0);
    expect(ok.result.status, InvoiceStatus.paid);
  });
}
