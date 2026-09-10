// Taking money against an invoice that is already outstanding.
//
// One RPC, not an insert. `record_payment` reads the invoice's org, branch,
// member and membership so the payment cannot be filed against the wrong one,
// refuses an overpayment, and stamps the collector from the caller's own
// claims; the invoice's `paid_paisa`, `due_paisa` and `status` follow by
// trigger and come back in the result.
//
// Declared with a plain `NotifierProvider` rather than `@riverpod` so this
// folder needs no `build_runner` run.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/data/payments/payment_rpc_results.dart';
import 'package:logfitness_flutter/data/payments/payments_repository.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';

/// What came back from a collection attempt.
sealed class RecordPaymentOutcome {
  const RecordPaymentOutcome();
}

/// The money is recorded. [result] carries the invoice as the trigger left
/// it -- render those figures rather than adding the amount to whatever the
/// screen was holding, because a concurrent collection at another counter
/// makes the local sum wrong (`payment_rpc_results.dart`).
class RecordPaymentSucceeded extends RecordPaymentOutcome {
  const RecordPaymentSucceeded(this.result);

  final RecordPaymentResult result;

  /// Whether the invoice is now settled.
  bool get isSettled => result.duePaisa == 0;
}

/// Nothing was taken.
class RecordPaymentFailed extends RecordPaymentOutcome {
  const RecordPaymentFailed(this.failure);

  final AppFailure failure;

  bool get isRefusal => failure.isRefusal;
}

/// `true` while a collection is in flight.
class RecordPayment extends Notifier<bool> {
  @override
  bool build() => false;

  /// Records [amountPaisa] against [invoiceId].
  ///
  /// Money arrives here already in paisa. Rupees are converted exactly once,
  /// at the input boundary, by the screen (CLAUDE.md).
  Future<RecordPaymentOutcome> submit({
    required String invoiceId,
    required int amountPaisa,
    PaymentMethod method = PaymentMethod.cash,
    String? referenceNo,
    String? notes,
  }) async {
    if (state) {
      // `record_payment` is not idempotent. This is the guard CLAUDE.md's
      // scope note is about: a replay queue would need idempotency keys added
      // upstream before it is even discussable, so until then a double tap on
      // a slow connection is prevented here or it takes the money twice.
      return const RecordPaymentFailed(
        AppFailure(FailureKind.invalid, 'That payment is already saving.'),
      );
    }

    state = true;
    try {
      final RecordPaymentResult result = await ref
          .read(paymentsRepositoryProvider)
          .recordPayment(
            invoiceId: invoiceId,
            amountPaisa: amountPaisa,
            method: method,
            referenceNo: referenceNo,
            notes: notes,
          );
      return RecordPaymentSucceeded(result);
    } catch (error, stackTrace) {
      // Every failure reaches the person, verbatim. That includes the
      // `check_violation` the RPC raises for an overpayment -- "Payment
      // exceeds the 4,000 outstanding on invoice INV-0007" is a better
      // sentence than anything this layer could invent, so it is passed
      // through by `mapError` rather than replaced.
      return RecordPaymentFailed(mapError(error, stackTrace));
    } finally {
      state = false;
    }
  }
}

final recordPaymentProvider = NotifierProvider<RecordPayment, bool>(
  RecordPayment.new,
);
