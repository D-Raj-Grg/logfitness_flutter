import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/payments/payment.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';

Map<String, dynamic> _row(Map<String, dynamic> overrides) => <String, dynamic>{
  'id': '11111111-1111-4111-8111-111111111111',
  'org_id': '22222222-2222-4222-8222-222222222222',
  'branch_id': '33333333-3333-4333-8333-333333333333',
  'member_id': '44444444-4444-4444-8444-444444444444',
  'membership_id': '55555555-5555-4555-8555-555555555555',
  'invoice_id': '66666666-6666-4666-8666-666666666666',
  'kind': 'payment',
  'amount_paisa': 150000,
  'method': 'cash',
  'reference_no': null,
  'reason': null,
  'collected_by': '77777777-7777-4777-8777-777777777777',
  'paid_at': '2026-09-01T06:00:00+00:00',
  'notes': null,
  'created_at': '2026-09-01T06:00:00+00:00',
  ...overrides,
};

void main() {
  test('maps a cash payment', () {
    final Payment payment = Payment.fromJson(_row(<String, dynamic>{}));

    expect(payment.kind, PaymentKind.payment);
    expect(payment.method, PaymentMethod.cash);
    // Money is integer paisa: NPR 1,500.00.
    expect(payment.amountPaisa, 150000);
    expect(payment.amountPaisa, isA<int>());
    // `paid_at` is a `timestamptz` -- an instant, not a day.
    expect(payment.paidAt, DateTime.parse('2026-09-01T06:00:00+00:00'));
  });

  test('maps a digital payment carrying its transaction reference', () {
    final Payment payment = Payment.fromJson(
      _row(<String, dynamic>{
        'method': 'khalti',
        'reference_no': 'KHL-8817263',
      }),
    );

    expect(payment.method, PaymentMethod.khalti);
    expect(payment.referenceNo, 'KHL-8817263');
  });

  test('maps a refund as a negative row with a reason', () {
    final Payment payment = Payment.fromJson(
      _row(<String, dynamic>{
        'kind': 'refund',
        'amount_paisa': -50000,
        'reason': 'Cancelled within the cooling-off week',
      }),
    );

    expect(payment.kind, PaymentKind.refund);
    // Negative, not a positive amount with a flag: summing the column gives
    // net cash without any sign handling at the call site.
    expect(payment.amountPaisa, -50000);
    expect(payment.reason, 'Cancelled within the cooling-off week');
  });

  test('maps a payment taken with no invoice behind it', () {
    final Payment payment = Payment.fromJson(
      _row(<String, dynamic>{'invoice_id': null, 'membership_id': null}),
    );

    expect(payment.invoiceId, isNull);
    expect(payment.membershipId, isNull);
  });

  test('an unknown payment_method fails loudly rather than defaulting', () {
    expect(
      () => Payment.fromJson(_row(<String, dynamic>{'method': 'crypto'})),
      throwsA(isA<ArgumentError>()),
    );
  });
}
