import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/domain/format/money.dart';

void main() {
  group('formatMoney', () {
    test('formats zero paisa', () {
      expect(formatMoney(0), 'NPR 0');
    });

    test('drops the fraction when it is a whole rupee', () {
      expect(formatMoney(100), 'NPR 1');
    });

    test('keeps a single fraction digit for a half-rupee amount', () {
      expect(formatMoney(1), 'NPR 0.01');
      expect(formatMoney(99), 'NPR 0.99');
      expect(formatMoney(12345), 'NPR 123.45');
    });

    test('groups large amounts using the Indian numbering system', () {
      // 12345678 paisa == 123456.78 rupees -> Indian grouping is 1,23,456.78.
      expect(formatMoney(12345678), 'NPR 1,23,456.78');
    });

    test('renders negative paisa (refunds) with a leading minus', () {
      expect(formatMoney(-12345), 'NPR -123.45');
    });

    test('omits the currency prefix when withSymbol is false', () {
      expect(formatMoney(12345, withSymbol: false), '123.45');
    });

    test('honours a custom currency code', () {
      expect(formatMoney(100, currency: 'INR'), 'INR 1');
    });
  });

  group('toPaisa', () {
    test('parses a plain rupee string', () {
      expect(toPaisa('123.45'), 12345);
    });

    test('strips thousands separators before parsing', () {
      expect(toPaisa('1,23,456.78'), 12345678);
      expect(toPaisa('1,234'), 123400);
    });

    test('accepts a numeric input directly', () {
      expect(toPaisa(123.45), 12345);
    });

    test('rounds fractional paisa to the nearest integer', () {
      // Binary floating point makes 1.005 * 100 == 100.4999... rather than
      // 100.5 -- this matches JS Math.round(1.005 * 100) exactly (100), not
      // the mathematically "expected" 101.
      expect(toPaisa(1.005), 100);
      expect(toPaisa(0.5), 50);
    });

    test('throws FormatException on unparseable input', () {
      expect(() => toPaisa('not a number'), throwsFormatException);
    });

    test('throws FormatException on non-finite numeric input', () {
      expect(() => toPaisa(double.nan), throwsFormatException);
      expect(() => toPaisa(double.infinity), throwsFormatException);
    });
  });
}
