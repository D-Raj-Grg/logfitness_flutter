// Mirrors `public.notification_rules` -- whether, when and how often.
//
// T-7 and T-1 are not two events: they are two rows of one `renewal_reminder`
// with different `offset_days`, so a chain that wants T-3 adds a row rather
// than needing new code.
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';

part 'notification_rule.freezed.dart';
part 'notification_rule.g.dart';

@freezed
abstract class NotificationRule with _$NotificationRule {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory NotificationRule({
    required String id,
    required String orgId,
    required NotificationEvent event,
    required NotificationChannel channel,
    required bool enabled,

    /// Renewal: days before `end_date`. Dues: how old the debt must be.
    /// Birthday: 0. Visitor follow-up: days since the visit.
    required int offsetDays,

    /// Paisa, integer. Dues only: below this, nobody is chased.
    required int minAmountPaisa,

    /// Dues only: how long before the same member is chased again.
    required int repeatAfterDays,

    /// A Postgres `time`, carried as text end to end.
    ///
    /// A `time` has no date and no zone. Parsing it into a `DateTime` invents
    /// both, and the org's timezone is not the phone's -- the sweep runs at
    /// 02:30 in Kathmandu whatever the device thinks the hour is. Same reason
    /// `plain_date.dart` keeps a `date` off an instant.
    required String sendAtLocal,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _NotificationRule;

  const NotificationRule._();

  factory NotificationRule.fromJson(Map<String, dynamic> json) =>
      _$NotificationRuleFromJson(json);

  /// `HH:MM`, which is what a picker and the wire both want.
  String get sendAtHhMm =>
      sendAtLocal.length >= 5 ? sendAtLocal.substring(0, 5) : sendAtLocal;

  TimeOfDay get sendAt {
    final List<String> parts = sendAtHhMm.split(':');
    return TimeOfDay(
      hour: int.tryParse(parts.first) ?? 9,
      minute: parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0,
    );
  }

  /// The welcome rides an `after insert` trigger on `visitors`, so there is no
  /// hour to choose: it goes out within a minute of the walk-in being logged.
  /// Offering a time here would promise a schedule that does not exist.
  bool get isImmediate => event == NotificationEvent.visitorWelcome;

  bool get isDues => event == NotificationEvent.duesReminder;
}

/// `HH:MM` back to the `time` literal the column takes.
String sendAtToWire(TimeOfDay value) {
  final String hh = value.hour.toString().padLeft(2, '0');
  final String mm = value.minute.toString().padLeft(2, '0');
  return '$hh:$mm';
}
