// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_rule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationRule _$NotificationRuleFromJson(Map<String, dynamic> json) =>
    _NotificationRule(
      id: json['id'] as String,
      orgId: json['org_id'] as String,
      event: $enumDecode(_$NotificationEventEnumMap, json['event']),
      channel: $enumDecode(_$NotificationChannelEnumMap, json['channel']),
      enabled: json['enabled'] as bool,
      offsetDays: (json['offset_days'] as num).toInt(),
      minAmountPaisa: (json['min_amount_paisa'] as num).toInt(),
      repeatAfterDays: (json['repeat_after_days'] as num).toInt(),
      sendAtLocal: json['send_at_local'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$NotificationRuleToJson(_NotificationRule instance) =>
    <String, dynamic>{
      'id': instance.id,
      'org_id': instance.orgId,
      'event': _$NotificationEventEnumMap[instance.event]!,
      'channel': _$NotificationChannelEnumMap[instance.channel]!,
      'enabled': instance.enabled,
      'offset_days': instance.offsetDays,
      'min_amount_paisa': instance.minAmountPaisa,
      'repeat_after_days': instance.repeatAfterDays,
      'send_at_local': instance.sendAtLocal,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$NotificationEventEnumMap = {
  NotificationEvent.renewalReminder: 'renewal_reminder',
  NotificationEvent.duesReminder: 'dues_reminder',
  NotificationEvent.birthdayGreeting: 'birthday_greeting',
  NotificationEvent.staffInvite: 'staff_invite',
  NotificationEvent.testMessage: 'test_message',
  NotificationEvent.customMessage: 'custom_message',
  NotificationEvent.visitorWelcome: 'visitor_welcome',
  NotificationEvent.visitorFollowUp: 'visitor_follow_up',
  NotificationEvent.announcement: 'announcement',
};

const _$NotificationChannelEnumMap = {
  NotificationChannel.sms: 'sms',
  NotificationChannel.viber: 'viber',
  NotificationChannel.email: 'email',
};
