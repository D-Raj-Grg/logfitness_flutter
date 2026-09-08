// Date-only Postgres columns (`date`, not `timestamptz`).
//
// `members.joined_on`, `members.date_of_birth`, `visitors.visited_on` and the
// membership start/end dates are calendar days, not instants. Dart has no
// date-only type, so they are modelled as [DateTime] pinned to **UTC
// midnight** — the tag carries the promise that no offset has been applied
// and none may be. Formatting goes through `formatPlainDate`, which reads the
// components straight off the value rather than shifting it onto an org's
// wall clock the way `formatDate` does for a real instant.
//
// Without this, `toJson` writes a full ISO timestamp into a `date` column and
// the day drifts by the org's offset — recorded in TASKS.md under Discovered
// on 2026-09-05 as "needs a date-only converter before the app ever writes
// one". Walk-in registration is that write.
import 'package:freezed_annotation/freezed_annotation.dart';

String _encode(DateTime value) {
  final utc = value.isUtc ? value : value.toUtc();
  final month = utc.month.toString().padLeft(2, '0');
  final day = utc.day.toString().padLeft(2, '0');
  return '${utc.year.toString().padLeft(4, '0')}-$month-$day';
}

DateTime _decode(String value) {
  // Accept a bare `yyyy-MM-dd` and also a full timestamp, because a few
  // report RPCs return a date that PostgREST has already widened.
  final parsed = DateTime.parse(value);
  return DateTime.utc(parsed.year, parsed.month, parsed.day);
}

/// Converts a non-null `date` column.
class PlainDateConverter implements JsonConverter<DateTime, String> {
  const PlainDateConverter();

  @override
  DateTime fromJson(String json) => _decode(json);

  @override
  String toJson(DateTime object) => _encode(object);
}

/// Converts a nullable `date` column.
class NullablePlainDateConverter implements JsonConverter<DateTime?, String?> {
  const NullablePlainDateConverter();

  @override
  DateTime? fromJson(String? json) => json == null ? null : _decode(json);

  @override
  String? toJson(DateTime? object) => object == null ? null : _encode(object);
}

/// Normalises any [DateTime] to the UTC-midnight form this converter emits.
/// Use it on anything picked from a calendar widget before it is sent.
DateTime plainDate(DateTime value) =>
    DateTime.utc(value.year, value.month, value.day);

/// The wire form of a date-only value, for RPC arguments typed `date`.
String plainDateToWire(DateTime value) => _encode(value);
