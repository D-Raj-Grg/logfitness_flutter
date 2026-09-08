// A `date` column is a calendar day, not an instant. These tests pin the one
// property the whole file exists for: nothing here may ever apply an offset,
// because Kathmandu's +05:45 would move the day.
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/domain/format/plain_date.dart';

void main() {
  const converter = PlainDateConverter();
  const nullableConverter = NullablePlainDateConverter();

  group('PlainDateConverter', () {
    test('decodes a bare yyyy-MM-dd to UTC midnight', () {
      final decoded = converter.fromJson('2026-09-08');

      expect(decoded, DateTime.utc(2026, 9, 8));
      expect(decoded.isUtc, isTrue);
      expect(decoded.hour, 0);
    });

    test('encodes to a bare yyyy-MM-dd, never a timestamp', () {
      final encoded = converter.toJson(DateTime.utc(2026, 9, 8));

      expect(encoded, '2026-09-08');
      expect(encoded, isNot(contains('T')));
      expect(encoded, isNot(contains(':')));
      expect(encoded, isNot(contains('Z')));
    });

    test('pads a single-digit month and day', () {
      expect(converter.toJson(DateTime.utc(2026, 1, 5)), '2026-01-05');
    });

    test('round-trips', () {
      for (final date in <String>[
        '2026-01-01',
        '2026-09-08',
        '2024-02-29',
        '2026-12-31',
      ]) {
        expect(converter.toJson(converter.fromJson(date)), date);
      }
    });

    test('accepts a timestamp PostgREST has already widened', () {
      // A few report RPCs return a date as a full timestamp. The day is read
      // off it, not shifted onto a wall clock.
      expect(
        converter.fromJson('2026-09-08T00:00:00+00:00'),
        DateTime.utc(2026, 9, 8),
      );
    });
  });

  group('NullablePlainDateConverter', () {
    test('passes null through in both directions', () {
      expect(nullableConverter.fromJson(null), isNull);
      expect(nullableConverter.toJson(null), isNull);
    });

    test('behaves like the non-null converter otherwise', () {
      expect(nullableConverter.fromJson('2026-09-08'), DateTime.utc(2026, 9, 8));
      expect(nullableConverter.toJson(DateTime.utc(2026, 9, 8)), '2026-09-08');
    });
  });

  group('the Kathmandu offset does not move the day', () {
    // +05:45 is the offset every org in this market runs on, and it is the
    // one that breaks a naive `toIso8601String()`.
    test('a value decoded from the wire survives a round trip intact', () {
      // The read path is where the offset would bite hardest: a row read at
      // 09:00 in Kathmandu and written back must carry the same day.
      final decoded = converter.fromJson('2026-09-08');

      expect(converter.toJson(decoded), '2026-09-08');
      // The far edges of the day, where an offset would show up first.
      expect(converter.toJson(converter.fromJson('2026-01-01')), '2026-01-01');
      expect(converter.toJson(converter.fromJson('2026-12-31')), '2026-12-31');
    });

    test('plainDate takes the calendar day the user tapped, not the instant',
        () {
      // A picker hands back a local DateTime. Its *components* are the day the
      // user meant; converting it to UTC first would subtract 05:45 and, just
      // after local midnight, hand the database yesterday.
      final justAfterLocalMidnight = DateTime(2026, 9, 8, 0, 30);

      expect(plainDate(justAfterLocalMidnight), DateTime.utc(2026, 9, 8));
      expect(plainDate(justAfterLocalMidnight).isUtc, isTrue);
      // Whatever zone the machine running this is in.
      expect(
        plainDateToWire(plainDate(justAfterLocalMidnight)),
        '2026-09-08',
      );
      expect(
        plainDateToWire(plainDate(DateTime(2026, 9, 8, 23, 45))),
        '2026-09-08',
      );
    });

    test('an instant is not a date, and must be pinned before it is sent', () {
      // Kathmandu midnight on the 8th is 18:15 UTC on the 7th. Handing that
      // instant straight to the wire encoder writes the 7th -- which is why
      // the model holds `visited_on` as UTC midnight and anything picked goes
      // through plainDate() first.
      final instant = DateTime.utc(2026, 9, 7, 18, 15);

      expect(plainDateToWire(instant), '2026-09-07');
    });

    test('an already-UTC value is left exactly where it is', () {
      final utcMidnight = DateTime.utc(2026, 9, 8);

      expect(plainDate(utcMidnight), utcMidnight);
      expect(converter.toJson(utcMidnight), '2026-09-08');
    });
  });
}
