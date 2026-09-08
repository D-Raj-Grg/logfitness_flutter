// The exact `jsonb` objects and `TABLE` rows the payment RPCs return.
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/payments/payment_rpc_results.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';

void main() {
  group('RecordPaymentResult', () {
    test('maps a part payment, reading the invoice back after the trigger', () {
      final RecordPaymentResult result = RecordPaymentResult.fromJson(
        <String, dynamic>{
          'payment_id': '11111111-1111-4111-8111-111111111111',
          'invoice_id': '22222222-2222-4222-8222-222222222222',
          'paid_paisa': 150000,
          'due_paisa': 100000,
          'status': 'partial',
        },
      );

      expect(result.status, InvoiceStatus.partial);
      // These come from the invoice as the trigger left it, not from adding
      // the amount to whatever the screen was holding -- a concurrent
      // collection at another counter makes the local sum wrong.
      expect(result.paidPaisa, 150000);
      expect(result.duePaisa, 100000);
      expect(result.duePaisa, isA<int>());
    });

    test('maps a payment that settled the invoice', () {
      final RecordPaymentResult result = RecordPaymentResult.fromJson(
        <String, dynamic>{
          'payment_id': '11111111-1111-4111-8111-111111111111',
          'invoice_id': '22222222-2222-4222-8222-222222222222',
          'paid_paisa': 250000,
          'due_paisa': 0,
          'status': 'paid',
        },
      );

      expect(result.status, InvoiceStatus.paid);
      expect(result.duePaisa, 0);
    });
  });

  test('RefundPaymentResult reports the amount negative', () {
    final RefundPaymentResult result = RefundPaymentResult.fromJson(
      <String, dynamic>{
        'refund_id': '11111111-1111-4111-8111-111111111111',
        'amount_paisa': -50000,
      },
    );

    // The RPC is *called* with a positive amount and writes the row negative;
    // this is the row, so it is negative. Financial history is append-only.
    expect(result.amountPaisa, -50000);
    expect(result.amountPaisa, isA<int>());
  });

  group('ReversePaymentResult', () {
    test('maps a reversal against an invoice', () {
      final ReversePaymentResult result = ReversePaymentResult.fromJson(
        <String, dynamic>{
          'reversal_id': '11111111-1111-4111-8111-111111111111',
          'payment_id': '22222222-2222-4222-8222-222222222222',
          'amount_paisa': -150000,
          'invoice_id': '33333333-3333-4333-8333-333333333333',
          'invoice_no': 'INV-2026-000123',
          'due_paisa': 150000,
          'status': 'partial',
        },
      );

      // The id of the entry that was reversed, not of the reversal.
      expect(result.paymentId, '22222222-2222-4222-8222-222222222222');
      expect(result.amountPaisa, -150000);
      // The due the invoice went back to once the negative row landed.
      expect(result.duePaisa, 150000);
      expect(result.status, InvoiceStatus.partial);
    });

    test('maps a reversal of a payment that had no invoice', () {
      final ReversePaymentResult result = ReversePaymentResult.fromJson(
        <String, dynamic>{
          'reversal_id': '11111111-1111-4111-8111-111111111111',
          'payment_id': '22222222-2222-4222-8222-222222222222',
          'amount_paisa': -150000,
          'invoice_id': null,
          'invoice_no': null,
          'due_paisa': null,
          'status': null,
        },
      );

      expect(result.invoiceId, isNull);
      expect(result.duePaisa, isNull);
      expect(result.status, isNull);
    });
  });

  group('DailyCollectionRow', () {
    test('maps a collector row', () {
      final DailyCollectionRow row = DailyCollectionRow.fromJson(
        <String, dynamic>{
          'branch_id': '11111111-1111-4111-8111-111111111111',
          'branch_name': 'Thamel',
          'staff_id': '22222222-2222-4222-8222-222222222222',
          'staff_name': 'Sita Gurung',
          'method': 'esewa',
          'kind': 'payment',
          'txn_count': 14,
          'amount_paisa': 2100000,
        },
      );

      expect(row.branchName, 'Thamel');
      expect(row.staffName, 'Sita Gurung');
      expect(row.method, PaymentMethod.esewa);
      expect(row.kind, PaymentKind.payment);
      expect(row.txnCount, 14);
      // NPR 21,000.00 across fourteen transactions.
      expect(row.amountPaisa, 2100000);
      expect(row.amountPaisa, isA<int>());
    });

    test('maps a refund row as a negative amount', () {
      final DailyCollectionRow row = DailyCollectionRow.fromJson(
        <String, dynamic>{
          'branch_id': '11111111-1111-4111-8111-111111111111',
          'branch_name': 'Thamel',
          'staff_id': null,
          'staff_name': null,
          'method': 'cash',
          'kind': 'refund',
          'txn_count': 1,
          'amount_paisa': -50000,
        },
      );

      // Summing the whole sheet gives net cash, which is the number the
      // drawer has to match.
      expect(row.amountPaisa, -50000);
      // A payment whose collector has since been removed still appears.
      expect(row.staffId, isNull);
      expect(row.staffName, isNull);
    });
  });

  group('ArrearsRow', () {
    test('maps a member with an aged due', () {
      final ArrearsRow row = ArrearsRow.fromJson(<String, dynamic>{
        'member_id': '11111111-1111-4111-8111-111111111111',
        'member_code': 'M00042',
        'full_name': 'Anjali Shrestha',
        'phone': '9800000000',
        'home_branch_id': '22222222-2222-4222-8222-222222222222',
        'home_branch_name': 'Thamel',
        'due_paisa': 150000,
        'oldest_due_on': '2026-07-01',
        'age_days': 70,
        'bucket': '61-90',
      });

      expect(row.duePaisa, 150000);
      expect(row.duePaisa, isA<int>());
      // `oldest_due_on` is a `date`, pinned to UTC midnight.
      expect(row.oldestDueOn, DateTime.utc(2026, 7, 1));
      // Measured in Postgres against the org's today, not recomputed here.
      expect(row.ageDays, 70);
      expect(row.bucket, '61-90');
    });

    test('maps a row whose ageing columns the report left null', () {
      final ArrearsRow row = ArrearsRow.fromJson(<String, dynamic>{
        'member_id': '11111111-1111-4111-8111-111111111111',
        'member_code': 'M00043',
        'full_name': 'Bibek Karki',
        'phone': '9811111111',
        'home_branch_id': '22222222-2222-4222-8222-222222222222',
        'home_branch_name': 'Thamel',
        'due_paisa': 25000,
        'oldest_due_on': null,
        'age_days': null,
        'bucket': null,
      });

      expect(row.oldestDueOn, isNull);
      expect(row.ageDays, isNull);
      expect(row.bucket, isNull);
    });
  });
}
