import 'package:logfitness_flutter/domain/format/dates.dart';
import 'package:logfitness_flutter/domain/format/money.dart';

/// Dart analogue of `orgFormatters` in `logfitness_saas/lib/format.ts` --
/// closures pre-bound to one org's currency and timezone so call sites never
/// hardcode either.
class OrgFormatters {
  const OrgFormatters({
    required this.money,
    required this.date,
    required this.dateTime,
    required this.time,
  });

  final String Function(int paisa) money;
  final String Function(Object value) date;
  final String Function(Object value) dateTime;
  final String Function(Object value) time;
}

OrgFormatters orgFormatters({
  required String currency,
  required String timezone,
}) {
  return OrgFormatters(
    money: (int paisa) => formatMoney(paisa, currency: currency),
    date: (Object value) => formatDate(value, timeZone: timezone),
    dateTime: (Object value) => formatDateTime(value, timeZone: timezone),
    time: (Object value) => formatTime(value, timeZone: timezone),
  );
}
