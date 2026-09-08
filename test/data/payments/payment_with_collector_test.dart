// PostgREST returns an embedded resource for `collector:staff!...(full_name)`
// as a nested object on the row, or omits it when the foreign key is null or
// the policy hides the staff row.
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/payments/payment_with_collector.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';

Map<String, dynamic> _row(Map<String, dynamic> overrides) => <String, dynamic>{
  'id': '11111111-1111-4111-8111-111111111111',
  'org_id': '22222222-2222-4222-8222-222222222222',
  'branch_id': '33333333-3333-4333-8333-333333333333',
  'member_id': '44444444-4444-4444-8444-444444444444',
  'membership_id': null,
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
  test('reads the embedded collector name beside the payment', () {
    final PaymentWithCollector row = PaymentWithCollector.fromRow(
      _row(<String, dynamic>{
        'collector': <String, dynamic>{'full_name': 'Sita Gurung'},
      }),
    );

    expect(row.collectorName, 'Sita Gurung');
    // The payment itself is the same model the plain list uses -- one
    // description of the table, not two.
    expect(row.payment.amountPaisa, 150000);
    expect(row.payment.method, PaymentMethod.cash);
    expect(row.payment.kind, PaymentKind.payment);
  });

  test('a null collected_by embeds as null, not as an empty object', () {
    final PaymentWithCollector row = PaymentWithCollector.fromRow(
      _row(<String, dynamic>{'collected_by': null, 'collector': null}),
    );

    expect(row.collectorName, isNull);
    expect(row.payment.collectedBy, isNull);
  });

  test('a row with no collector key at all still maps', () {
    // RLS hiding the staff row and the foreign key being null are
    // deliberately indistinguishable here.
    final PaymentWithCollector row = PaymentWithCollector.fromRow(
      _row(<String, dynamic>{}),
    );

    expect(row.collectorName, isNull);
    expect(row.payment.collectedBy, '77777777-7777-4777-8777-777777777777');
  });
}
