// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationMessage _$NotificationMessageFromJson(Map<String, dynamic> json) =>
    _NotificationMessage(
      id: json['id'] as String,
      orgId: json['org_id'] as String,
      branchId: json['branch_id'] as String?,
      memberId: json['member_id'] as String?,
      staffId: json['staff_id'] as String?,
      visitorId: json['visitor_id'] as String?,
      announcementId: json['announcement_id'] as String?,
      channel: $enumDecode(_$NotificationChannelEnumMap, json['channel']),
      event: $enumDecode(_$NotificationEventEnumMap, json['event']),
      provider: $enumDecodeNullable(
        _$NotificationProviderKindEnumMap,
        json['provider'],
      ),
      toAddress: json['to_address'] as String,
      subject: json['subject'] as String?,
      body: json['body'] as String,
      status: $enumDecode(_$NotificationStatusEnumMap, json['status']),
      attempts: (json['attempts'] as num).toInt(),
      scheduledFor: DateTime.parse(json['scheduled_for'] as String),
      nextAttemptAt: DateTime.parse(json['next_attempt_at'] as String),
      providerStatus: (json['provider_status'] as num?)?.toInt(),
      providerMessageId: json['provider_message_id'] as String?,
      lastError: json['last_error'] as String?,
      sentAt: json['sent_at'] == null
          ? null
          : DateTime.parse(json['sent_at'] as String),
      dedupeKey: json['dedupe_key'] as String,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$NotificationMessageToJson(
  _NotificationMessage instance,
) => <String, dynamic>{
  'id': instance.id,
  'org_id': instance.orgId,
  'branch_id': ?instance.branchId,
  'member_id': ?instance.memberId,
  'staff_id': ?instance.staffId,
  'visitor_id': ?instance.visitorId,
  'announcement_id': ?instance.announcementId,
  'channel': _$NotificationChannelEnumMap[instance.channel]!,
  'event': _$NotificationEventEnumMap[instance.event]!,
  'provider': ?_$NotificationProviderKindEnumMap[instance.provider],
  'to_address': instance.toAddress,
  'subject': ?instance.subject,
  'body': instance.body,
  'status': _$NotificationStatusEnumMap[instance.status]!,
  'attempts': instance.attempts,
  'scheduled_for': instance.scheduledFor.toIso8601String(),
  'next_attempt_at': instance.nextAttemptAt.toIso8601String(),
  'provider_status': ?instance.providerStatus,
  'provider_message_id': ?instance.providerMessageId,
  'last_error': ?instance.lastError,
  'sent_at': ?instance.sentAt?.toIso8601String(),
  'dedupe_key': instance.dedupeKey,
  'created_by': ?instance.createdBy,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

const _$NotificationChannelEnumMap = {
  NotificationChannel.sms: 'sms',
  NotificationChannel.viber: 'viber',
  NotificationChannel.email: 'email',
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
  NotificationEvent.memberWelcome: 'member_welcome',
  NotificationEvent.paymentReceived: 'payment_received',
  NotificationEvent.duesCleared: 'dues_cleared',
};

const _$NotificationProviderKindEnumMap = {
  NotificationProviderKind.sparrowSms: 'sparrow_sms',
  NotificationProviderKind.aakashSms: 'aakash_sms',
  NotificationProviderKind.smspasalSms: 'smspasal_sms',
  NotificationProviderKind.viberBusiness: 'viber_business',
  NotificationProviderKind.resendEmail: 'resend_email',
  NotificationProviderKind.customHttp: 'custom_http',
  NotificationProviderKind.logOnly: 'log_only',
};

const _$NotificationStatusEnumMap = {
  NotificationStatus.queued: 'queued',
  NotificationStatus.sending: 'sending',
  NotificationStatus.sent: 'sent',
  NotificationStatus.failed: 'failed',
  NotificationStatus.cancelled: 'cancelled',
  NotificationStatus.skipped: 'skipped',
};
