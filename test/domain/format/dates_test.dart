import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/domain/format/dates.dart';

void main() {
  group('formatDate', () {
    test('renders dd MMM yyyy in the org timezone', () {
      // 2026-09-05T20:00:00Z is 2026-09-06 01:45 in Kathmandu (UTC+5:45).
      expect(formatDate('2026-09-05T20:00:00Z'), '06 Sep 2026');
    });

    test('accepts a DateTime as well as an ISO string', () {
      expect(
        formatDate(DateTime.utc(2026, 9, 5, 20)),
        formatDate('2026-09-05T20:00:00Z'),
      );
    });
  });

  group('formatTime', () {
    test('renders 24-hour HH:mm in the org timezone', () {
      expect(formatTime('2026-09-05T08:40:00Z'), '14:25');
    });
  });

  group('formatDateTime', () {
    test('renders the combined "dd MMM yyyy, HH:mm" shape', () {
      expect(formatDateTime('2026-09-05T08:40:00Z'), '05 Sep 2026, 14:25');
    });
  });

  group('timezone offsets', () {
    test('falls back to the Kathmandu offset for an unknown timezone', () {
      expect(
        formatTime('2026-09-05T08:40:00Z', timeZone: 'Mars/Olympus'),
        formatTime('2026-09-05T08:40:00Z'),
      );
    });

    test('a known non-default timezone renders a different wall clock', () {
      // Asia/Kolkata is UTC+5:30, fifteen minutes behind Kathmandu.
      expect(
        formatTime('2026-09-05T08:40:00Z', timeZone: 'Asia/Kolkata'),
        '14:10',
      );
    });
  });

  group('daysUntil', () {
    test('is zero for later today in the org timezone', () {
      final DateTime now = DateTime.now().toUtc();
      expect(daysUntil(now.add(const Duration(minutes: 5))), 0);
    });

    test('counts a full day across the Kathmandu midnight boundary', () {
      final DateTime now = DateTime.now().toUtc();
      // Kathmandu midnight is 18:15 UTC the previous day. Anchor "now" just
      // after that boundary so it reads as the start of an org-local day,
      // then step exactly one org-local day forward.
      final DateTime orgToday = DateTime.utc(now.year, now.month, now.day, 19);
      final DateTime orgTomorrow = orgToday.add(const Duration(days: 1));

      expect(
        daysUntil(orgTomorrow) - daysUntil(orgToday),
        1,
      );
    });

    test('is negative once the date has passed', () {
      final DateTime now = DateTime.now().toUtc();
      expect(daysUntil(now.subtract(const Duration(days: 3))), -3);
    });
  });
}
