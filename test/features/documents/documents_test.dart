import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/documents/document_models.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/features/documents/document_layout.dart';
import 'package:logfitness_flutter/features/documents/document_service.dart';
import 'package:logfitness_flutter/features/documents/document_strings.dart';
import 'package:logfitness_flutter/features/documents/invoice_pdf.dart';
import 'package:logfitness_flutter/features/documents/receipt_pdf.dart';

Map<String, dynamic> _org() => <String, dynamic>{
  'name': 'Iron Temple',
  'legal_name': 'Iron Temple Pvt. Ltd.',
  'address': 'Baneshwor, Kathmandu',
  'phone': '9800000000',
  'email': 'hi@iron.test',
  'pan_no': '123456789',
  'tax_note': 'VAT inclusive',
  'invoice_terms': 'Fees are non-refundable.',
  'logo_path': null,
  'currency': 'NPR',
  'timezone': 'Asia/Kathmandu',
};

Map<String, dynamic> _member() => <String, dynamic>{
  'member_code': 'M-0001',
  'full_name': 'Asha Rai',
  'phone': '9811111111',
  'email': null,
  'address': null,
};

Map<String, dynamic> _branch() => <String, dynamic>{
  'name': 'Main',
  'address': null,
  'phone': null,
};

Map<String, dynamic> _invoiceRow({
  int subtotal = 500000,
  int discount = 50000,
  int total = 450000,
  int paid = 0,
  Object? due = 450000,
  Map<String, dynamic>? membership,
  List<Map<String, dynamic>> payments = const <Map<String, dynamic>>[],
  String? reason,
  String? note,
}) => <String, dynamic>{
  'id': 'inv-1',
  'invoice_no': 'INV-0001',
  'issued_on': '2026-10-01',
  'subtotal_paisa': subtotal,
  'discount_paisa': discount,
  'total_paisa': total,
  'paid_paisa': paid,
  'due_paisa': due,
  'discount_reason': reason,
  'discount_note': note,
  'notes': null,
  'org': _org(),
  'member': _member(),
  'branch': _branch(),
  'membership': membership,
  'payments': payments,
};

Map<String, dynamic> _membership({
  int signupFee = 0,
  int feeOff = 0,
  String? previous,
  String planType = 'time',
}) => <String, dynamic>{
  'plan_name': 'Monthly',
  'plan_type': planType,
  'start_date': '2026-10-01',
  'end_date': '2026-10-31',
  'sessions_total': planType == 'session_pack' ? 12 : null,
  'price_paisa': 500000,
  'signup_fee_paisa': signupFee,
  'signup_fee_waived_paisa': feeOff,
  'discount_paisa': 0,
  'previous_membership_id': previous,
  'seller': <String, dynamic>{'full_name': 'Ram'},
};

Map<String, dynamic> _paymentRow({
  String kind = 'payment',
  int amount = 100000,
}) => <String, dynamic>{
  'id': 'abcdef12-0000-0000-0000-000000000000',
  'kind': kind,
  'amount_paisa': amount,
  'method': 'esewa',
  'reference_no': 'TX1',
  'paid_at': '2026-10-02T06:00:00+00:00',
  'reason': kind == 'payment' ? null : 'Mistake',
  'notes': null,
  'collector': <String, dynamic>{'full_name': 'Sita'},
  'org': _org(),
  'member': _member(),
  'branch': _branch(),
  'membership': <String, dynamic>{
    'plan_name': 'Monthly',
    'plan_type': 'time',
    'start_date': '2026-10-01',
    'end_date': '2026-10-31',
    'signup_fee_waived_paisa': 0,
  },
  'invoice': <String, dynamic>{
    'invoice_no': 'INV-0001',
    'total_paisa': 450000,
    'paid_paisa': 100000,
    'due_paisa': 350000,
    'status': 'partial',
    'discount_paisa': 50000,
    'discount_reason': 'student',
    'discount_note': null,
  },
};

bool _isPdf(Uint8List bytes) =>
    bytes.length > 100 && utf8.decode(bytes.sublist(0, 5)) == '%PDF-';

void main() {
  group('discountLabel', () {
    test('no reason falls back to the bare word', () {
      expect(discountLabel(null, null), 'Discount');
    });
    test('a reason prints its label', () {
      expect(discountLabel(DiscountReason.student, 'ignored'), 'Student');
      expect(discountLabel(DiscountReason.festival, null), 'Festival offer');
    });
    test('other prints the typed note, else the bare word', () {
      expect(
        discountLabel(DiscountReason.other, '  Owner cousin '),
        'Owner cousin',
      );
      expect(discountLabel(DiscountReason.other, '   '), 'Discount');
      expect(discountLabel(DiscountReason.other, null), 'Discount');
    });
  });

  group('strings', () {
    test('house wording is kept', () {
      expect(documentStrings.balanceDue, 'Balance due');
      expect(documentStrings.registrationFeeOff, 'Registration fee off');
      expect(documentStrings.validTo('01 Nov 2026'), 'valid to 01 Nov 2026');
      expect(documentStrings.sessions(12), '12 sessions');
    });
  });

  group('totals and balance', () {
    test('due falls back to total minus paid, never negative', () {
      expect(dueFor(totalPaisa: 100, paidPaisa: 30), 70);
      expect(dueFor(totalPaisa: 100, paidPaisa: 130), 0);
      expect(dueFor(totalPaisa: 100, paidPaisa: 30, duePaisa: -5), -5);
    });

    test('totals rows: discount and paid appear only when present', () {
      final InvoiceForPrint a = InvoiceForPrint.fromRow(_invoiceRow());
      expect(invoiceTotals(a).map((TotalRow r) => r.label), <String>[
        'Subtotal',
        'Discount',
        'Total',
      ]);
      expect(invoiceTotals(a)[1].value, '- NPR 500');
      expect(invoiceTotals(a)[2].value, 'NPR 4,500');

      final InvoiceForPrint b = InvoiceForPrint.fromRow(
        _invoiceRow(discount: 0, total: 500000, paid: 200000, due: 300000),
      );
      expect(invoiceTotals(b).map((TotalRow r) => r.label), <String>[
        'Subtotal',
        'Total',
        'Paid',
      ]);
      expect(invoiceDue(b), 300000);
    });

    test('empty payments on a paid invoice is "hidden", not unpaid', () {
      final InvoiceForPrint hidden = InvoiceForPrint.fromRow(
        _invoiceRow(paid: 450000, due: 0),
      );
      expect(hidden.payments, isEmpty);
      expect(invoicePaymentsHidden(hidden), isTrue);
      expect(invoiceDue(hidden), 0);

      final InvoiceForPrint never = InvoiceForPrint.fromRow(_invoiceRow());
      expect(invoicePaymentsHidden(never), isFalse);
    });

    test('signedAmount puts the minus first', () {
      String f(int p) => 'NPR ${p ~/ 100}';
      expect(signedAmount(-50000, f), '- NPR 500');
      expect(signedAmount(50000, f), 'NPR 500');
    });
  });

  group('invoice lines', () {
    test('no membership prints a single dues line', () {
      final InvoiceForPrint inv = InvoiceForPrint.fromRow(_invoiceRow());
      final List<DocumentLine> lines = invoiceLines(inv);
      expect(lines, hasLength(1));
      expect(lines.single.description, 'Membership dues');
      expect(lines.single.amountPaisa, 500000);
    });

    test('registration fee splits out and the body still sums to subtotal', () {
      final InvoiceForPrint inv = InvoiceForPrint.fromRow(
        _invoiceRow(membership: _membership(signupFee: 100000)),
      );
      final List<DocumentLine> lines = invoiceLines(inv);
      expect(lines.map((DocumentLine l) => l.description), <String>[
        'Monthly',
        'Registration fee',
      ]);
      expect(
        lines.fold<int>(0, (int s, DocumentLine l) => s + l.amountPaisa),
        500000,
      );
      expect(lines.first.detail, '01 Oct 2026 – 31 Oct 2026');
    });

    test('fee off prints as a pair that nets to zero, with the reason', () {
      final InvoiceForPrint renewal = InvoiceForPrint.fromRow(
        _invoiceRow(membership: _membership(feeOff: 100000, previous: 'm0')),
      );
      final List<DocumentLine> lines = invoiceLines(renewal);
      expect(lines, hasLength(3));
      expect(lines[2].description, 'Registration fee off');
      expect(lines[2].amountPaisa, -100000);
      expect(lines[2].detail, 'You paid this when you joined');
      expect(
        lines.fold<int>(0, (int s, DocumentLine l) => s + l.amountPaisa),
        500000,
      );

      final InvoiceForPrint fresh = InvoiceForPrint.fromRow(
        _invoiceRow(membership: _membership(feeOff: 100000)),
      );
      expect(invoiceLines(fresh)[2].detail, 'Included in this plan price');
    });

    test('session pack detail', () {
      final InvoiceForPrint inv = InvoiceForPrint.fromRow(
        _invoiceRow(membership: _membership(planType: 'session_pack')),
      );
      expect(
        invoiceLines(inv).first.detail,
        '12 sessions · valid to 31 Oct 2026',
      );
    });
  });

  group('savings', () {
    test('drops zero credits and sums the rest', () {
      final InvoiceForPrint inv = InvoiceForPrint.fromRow(
        _invoiceRow(membership: _membership(feeOff: 100000), reason: 'student'),
      );
      final real = realSavings(invoiceSavings(inv));
      expect(real.total, 150000);
      expect(real.items.map((SavingsItem i) => i.label), <String>[
        'Registration fee',
        'Student',
      ]);
      expect(
        realSavings(
          invoiceSavings(
            InvoiceForPrint.fromRow(_invoiceRow(discount: 0, total: 500000)),
          ),
        ).total,
        0,
      );
    });

    test('a refund has no savings story', () {
      final PaymentForPrint refund = PaymentForPrint.fromRow(
        _paymentRow(kind: 'refund', amount: -100000),
      );
      expect(receiptSavings(refund), isEmpty);
    });
  });

  group('receipt helpers', () {
    test('titles and labels by kind', () {
      expect(receiptTitle(PaymentKind.payment), 'Payment receipt');
      expect(receiptTitle(PaymentKind.refund), 'Refund receipt');
      expect(receiptTitle(PaymentKind.reversal), 'Payment correction');
      expect(receiptSignatureLabel(PaymentKind.payment), 'Received by');
      expect(receiptSignatureLabel(PaymentKind.refund), 'Authorised signature');
      expect(receiptNumber('abcdef12-3456'), 'ABCDEF12');
    });
  });

  group('PDF output', () {
    test(
      'invoice builds non-empty PDF bytes (with payments and savings)',
      () async {
        final InvoiceForPrint inv = InvoiceForPrint.fromRow(
          _invoiceRow(
            membership: _membership(signupFee: 100000, feeOff: 100000),
            reason: 'festival',
            paid: 100000,
            due: 350000,
            payments: <Map<String, dynamic>>[
              <String, dynamic>{
                'id': 'p1',
                'kind': 'payment',
                'amount_paisa': 100000,
                'method': 'cash',
                'reference_no': null,
                'paid_at': '2026-10-02T06:00:00+00:00',
                'collector': <String, dynamic>{'full_name': 'Sita'},
              },
            ],
          ),
        );
        expect(_isPdf(await buildInvoicePdf(inv)), isTrue);
      },
    );

    test(
      'invoice with hidden payments, bare org, bad logo bytes still builds',
      () async {
        final Map<String, dynamic> row = _invoiceRow(paid: 450000, due: 0);
        row['org'] = <String, dynamic>{'name': 'Bare Gym'};
        final InvoiceForPrint inv = InvoiceForPrint.fromRow(row);
        final Uint8List bytes = await buildInvoicePdf(
          inv,
          logoBytes: Uint8List.fromList(<int>[1, 2, 3, 4]),
        );
        expect(_isPdf(bytes), isTrue);
      },
    );

    test('receipt builds for payment, refund and reversal', () async {
      for (final String kind in <String>['payment', 'refund', 'reversal']) {
        final PaymentForPrint p = PaymentForPrint.fromRow(
          _paymentRow(kind: kind, amount: kind == 'payment' ? 100000 : -100000),
        );
        expect(_isPdf(await buildReceiptPdf(p)), isTrue, reason: kind);
      }
    });

    test('receipt without invoice or membership builds', () async {
      final Map<String, dynamic> row = _paymentRow()
        ..['invoice'] = null
        ..['membership'] = null;
      expect(
        _isPdf(await buildReceiptPdf(PaymentForPrint.fromRow(row))),
        isTrue,
      );
    });
  });

  test('safeFileName strips unsafe characters', () {
    expect(safeFileName('Invoice-INV/0001 x'), 'Invoice-INV-0001-x');
    expect(safeFileName('///'), 'document');
  });
}
