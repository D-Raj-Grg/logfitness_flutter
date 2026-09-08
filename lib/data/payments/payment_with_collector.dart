// A payment row with the name of whoever took the money.
//
// The console's `listPaymentsForMember` selects
// `*, collector:staff!payments_collected_by_fkey(full_name)` -- the embedded
// resource PostgREST returns for the `collected_by` foreign key. This is that
// shape in Dart. It composes [Payment] rather than restating its fields so
// there is exactly one description of the `payments` table.
//
// The factory is `fromRow`, not `fromJson`, on purpose: this is not a table,
// it has no round trip, and giving it a `fromJson` would make freezed generate
// a `toJson` implying the app could write it back. Payments are append-only
// and are written only by `record_payment`, `refund_payment` and
// `reverse_payment`.
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:logfitness_flutter/data/payments/payment.dart';

part 'payment_with_collector.freezed.dart';

@freezed
abstract class PaymentWithCollector with _$PaymentWithCollector {
  const factory PaymentWithCollector({
    required Payment payment,

    /// Null when `collected_by` is null, and also when RLS hides the staff
    /// row from this caller. The two are indistinguishable here, which is
    /// correct -- a name the policy will not disclose must not be inferable
    /// from its absence being reported differently.
    String? collectorName,
  }) = _PaymentWithCollector;

  static PaymentWithCollector fromRow(Map<String, dynamic> row) {
    final Object? collector = row['collector'];
    return PaymentWithCollector(
      payment: Payment.fromJson(row),
      collectorName: collector is Map<String, dynamic>
          ? collector['full_name'] as String?
          : null,
    );
  }
}
