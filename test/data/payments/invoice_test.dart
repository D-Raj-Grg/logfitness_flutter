import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/payments/invoice.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';

Map<String, dynamic> _row(Map<String, dynamic> overrides) => <String, dynamic>{
  'id': '11111111-1111-4111-8111-111111111111',
  'org_id': '22222222-2222-4222-8222-222222222222',
  'branch_id': '33333333-3333-4333-8333-333333333333',
  'member_id': '44444444-4444-4444-8444-444444444444',
  'membership_id': '55555555-5555-4555-8555-555555555555',
  'invoice_no': 'INV-2026-000123',
  'subtotal_paisa': 300000,
  'discount_paisa': 50000,
  'total_paisa': 250000,
  'paid_paisa': 150000,
  'due_paisa': 100000,
  'status': 'partial',
  'issued_on': '2026-09-01',
  'notes': null,
  'created_at': '2026-09-01T04:15:00+00:00',
  'updated_at': '2026-09-01T06:00:00+00:00',
  ...overrides,
};

void main() {
  test('maps a part-paid invoice', () {
    final Invoice invoice = Invoice.fromJson(_row(<String, dynamic>{}));

    expect(invoice.invoiceNo, 'INV-2026-000123');
    expect(invoice.status, InvoiceStatus.partial);
    // Money is integer paisa: subtotal less discount is the total, and total
    // less paid is the generated `due_paisa` column.
    expect(invoice.subtotalPaisa - invoice.discountPaisa, invoice.totalPaisa);
    expect(invoice.totalPaisa - invoice.paidPaisa, invoice.duePaisa);
    expect(invoice.duePaisa, isA<int>());
    // `issued_on` is a `date`. UTC midnight, so the billing day cannot move
    // for an org east of UTC.
    expect(invoice.issuedOn, DateTime.utc(2026, 9, 1));
    expect(invoice.issuedOn.isUtc, isTrue);
    // `created_at` beside it is a `timestamptz` and keeps its time.
    expect(invoice.createdAt, DateTime.parse('2026-09-01T04:15:00+00:00'));
  });

  test('maps a settled invoice with no membership behind it', () {
    final Invoice invoice = Invoice.fromJson(
      _row(<String, dynamic>{
        'membership_id': null,
        'paid_paisa': 250000,
        'due_paisa': 0,
        'status': 'paid',
      }),
    );

    expect(invoice.membershipId, isNull);
    expect(invoice.status, InvoiceStatus.paid);
    expect(invoice.duePaisa, 0);
  });

  test('maps a voided invoice', () {
    // The Postgres value is `void`; the Dart name is `voided` because `void`
    // is a reserved word.
    final Invoice invoice = Invoice.fromJson(
      _row(<String, dynamic>{'status': 'void'}),
    );

    expect(invoice.status, InvoiceStatus.voided);
  });

  test('writes issued_on back date-only, never as a timestamp', () {
    final Invoice invoice = Invoice.fromJson(_row(<String, dynamic>{}));

    expect(invoice.toJson()['issued_on'], '2026-09-01');
    expect(invoice.toJson()['issued_on'], isNot(contains('T')));
  });
}
