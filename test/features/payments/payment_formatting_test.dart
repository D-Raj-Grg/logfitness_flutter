// The input boundary. Money is integer paisa in `int` (CLAUDE.md), and these
// two functions are the only places on the sales screens where rupees and
// paisa meet.
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/features/payments/payment_formatting.dart';

void main() {
  group('paisaOrZero', () {
    test('converts whole rupees exactly once', () {
      expect(paisaOrZero('2500'), 250000);
    });

    test('converts a fractional amount without a floating-point remainder',
        () {
      // 1234.56 * 100 is 123455.99999999999 in binary floating point. If the
      // conversion ever stops rounding, the desk is out by a paisa on every
      // part payment.
      expect(paisaOrZero('1234.56'), 123456);
      expect(paisaOrZero('0.01'), 1);
      expect(paisaOrZero('99.99'), 9999);
    });

    test('accepts the grouping separators a cashier types', () {
      expect(paisaOrZero('1,20,000'), 12000000);
    });

    test('blank and unparseable both read as zero, so the summary stays live',
        () {
      expect(paisaOrZero(''), 0);
      expect(paisaOrZero('   '), 0);
      expect(paisaOrZero('abc'), 0);
    });
  });

  group('rupeesFromPaisa', () {
    test('round-trips through paisaOrZero without drift', () {
      for (final int paisa in <int>[0, 1, 9999, 123456, 12000000]) {
        expect(paisaOrZero(rupeesFromPaisa(paisa)), paisa);
      }
    });

    test('drops a meaningless decimal on whole rupees', () {
      expect(rupeesFromPaisa(250000), '2500');
      expect(rupeesFromPaisa(123456), '1234.56');
    });
  });

  group('rupeeValidator', () {
    test('lets blank through, so "invoice it" stays expressible', () {
      expect(rupeeValidator(''), isNull);
      expect(rupeeValidator(null), isNull);
    });

    test('refuses a negative and a non-number', () {
      expect(rupeeValidator('-1'), 'That cannot be negative.');
      expect(rupeeValidator('lots'), 'Enter an amount in rupees.');
    });
  });

  group('methodNeedsReference', () {
    test('cash needs none, every digital rail does', () {
      // Mirrors the console's `requireReferenceForDigital`, so the two front
      // ends agree about what a complete payment looks like.
      expect(methodNeedsReference(PaymentMethod.cash), isFalse);
      for (final PaymentMethod method in PaymentMethod.values) {
        if (method != PaymentMethod.cash) {
          expect(methodNeedsReference(method), isTrue, reason: method.wire);
        }
      }
    });
  });

  group('paymentKindLabel', () {
    test('a refund and a reversal are never the same words', () {
      // Different facts about different problems -- see
      // collection_sheet_screen.dart.
      expect(paymentKindLabel(PaymentKind.payment), 'Collected');
      expect(paymentKindLabel(PaymentKind.refund), 'Refunded');
      expect(paymentKindLabel(PaymentKind.reversal), 'Never received');
    });
  });
}
