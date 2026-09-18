// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_template.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationTemplate _$NotificationTemplateFromJson(
  Map<String, dynamic> json,
) => _NotificationTemplate(
  id: json['id'] as String,
  orgId: json['org_id'] as String,
  event: $enumDecode(_$NotificationEventEnumMap, json['event']),
  channel: $enumDecode(_$NotificationChannelEnumMap, json['channel']),
  locale: json['locale'] as String,
  subject: json['subject'] as String?,
  body: json['body'] as String,
  isActive: json['is_active'] as bool,
  updatedBy: json['updated_by'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$NotificationTemplateToJson(
  _NotificationTemplate instance,
) => <String, dynamic>{
  'id': instance.id,
  'org_id': instance.orgId,
  'event': _$NotificationEventEnumMap[instance.event]!,
  'channel': _$NotificationChannelEnumMap[instance.channel]!,
  'locale': instance.locale,
  'subject': ?instance.subject,
  'body': instance.body,
  'is_active': instance.isActive,
  'updated_by': ?instance.updatedBy,
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
