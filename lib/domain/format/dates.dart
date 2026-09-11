import 'package:intl/intl.dart';

/// Mirrors `DEFAULT_TIMEZONE` in `logfitness_saas/lib/format.ts`.
const String kDefaultTimezone = 'Asia/Kathmandu';

/// There is no timezone database package in the stack table (PLANNING.md
/// §2), so an org's timezone is modelled as a fixed UTC offset rather than a
/// real IANA zone with DST rules. This is exact for Nepal, which has never
/// observed DST, and is an approximation for anywhere that does. Extend this
/// map if `orgs.timezone` ever needs a zone that observes DST; an unknown
/// zone falls back to Kathmandu's offset rather than throwing, since a
/// display formatter should never crash a screen.
const Map<String, Duration> _offsets = <String, Duration>{
  'Asia/Kathmandu': Duration(hours: 5, minutes: 45),
  'UTC': Duration.zero,
  'Asia/Kolkata': Duration(hours: 5, minutes: 30),
  'Asia/Dhaka': Duration(hours: 6),
};

Duration _offsetFor(String timeZone) =>
    _offsets[timeZone] ?? _offsets[kDefaultTimezone]!;

DateTime _parse(Object value) {
  if (value is DateTime) {
    return value.isUtc ? value : value.toUtc();
  }
  if (value is String) {
    return DateTime.parse(value).toUtc();
  }
  throw ArgumentError.value(value, 'value', 'Must be a DateTime or ISO string');
}

/// Instant shifted onto the org's wall clock, still tagged UTC so
/// `DateFormat` never reapplies the device's own timezone on top.
DateTime _wallClock(Object value, String timeZone) =>
    _parse(value).add(_offsetFor(timeZone));

String formatDate(Object value, {String timeZone = kDefaultTimezone}) =>
    DateFormat('dd MMM yyyy', 'en_US').format(_wallClock(value, timeZone));

String formatDateTime(Object value, {String timeZone = kDefaultTimezone}) =>
    DateFormat('dd MMM yyyy, HH:mm', 'en_US').format(_wallClock(value, timeZone));

String formatTime(Object value, {String timeZone = kDefaultTimezone}) =>
    DateFormat('HH:mm', 'en_US').format(_wallClock(value, timeZone));

/// Whole days from today until `value`; negative once the date has passed.
/// Compares calendar dates in the org timezone, not raw elapsed time.
int daysUntil(Object value, {String timeZone = kDefaultTimezone}) {
  const int dayInMs = 24 * 60 * 60 * 1000;

  DateTime startOfDay(Object input) {
    final DateTime wall = _wallClock(input, timeZone);

    return DateTime.utc(wall.year, wall.month, wall.day);
  }

  final int diffMs =
      startOfDay(value).difference(startOfDay(DateTime.now())).inMilliseconds;

  return (diffMs / dayInMs).round();
}

/// Formats a date-only value (see `plain_date.dart`). Unlike [formatDate],
/// this applies **no** timezone shift: a `date` column is a calendar day that
/// already happened in the org's own reckoning, and moving it by an offset
/// can only turn it into the wrong day.
String formatPlainDate(DateTime value) {
  final utc = value.isUtc ? value : value.toUtc();
  return DateFormat('dd MMM yyyy', 'en_US')
      .format(DateTime(utc.year, utc.month, utc.day));
}

/// The org's today, as a date-only value pinned to UTC midnight.
///
/// The Dart mirror of the console's `todayInTimezone()`. A phone set to another
/// timezone must not decide what day it is at a gym in Kathmandu: at 00:30
/// Kathmandu the device's UTC date is still yesterday, and a walk-in logged
/// then would land on the wrong calendar day. So the wall clock is resolved
/// through the org's offset first, and only then reduced to a day.
///
/// Returns the same shape `PlainDateConverter` produces, so it can be handed
/// straight to a `date` column (see `plain_date.dart`).
DateTime todayInOrgTimezone({String timeZone = kDefaultTimezone}) {
  final DateTime wall = _wallClock(DateTime.now(), timeZone);
  return DateTime.utc(wall.year, wall.month, wall.day);
}
