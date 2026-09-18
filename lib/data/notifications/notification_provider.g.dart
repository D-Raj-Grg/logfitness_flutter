// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_provider.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationProvider _$NotificationProviderFromJson(
  Map<String, dynamic> json,
) => _NotificationProvider(
  id: json['id'] as String,
  orgId: json['org_id'] as String,
  channel: $enumDecode(_$NotificationChannelEnumMap, json['channel']),
  provider: $enumDecode(_$NotificationProviderKindEnumMap, json['provider']),
  senderId: json['sender_id'] as String?,
  endpointUrl: json['endpoint_url'] as String?,
  config: json['config'] as Map<String, dynamic>? ?? const <String, dynamic>{},
  isActive: json['is_active'] as bool,
  secretName: json['secret_name'] as String?,
  createdBy: json['created_by'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$NotificationProviderToJson(
  _NotificationProvider instance,
) => <String, dynamic>{
  'id': instance.id,
  'org_id': instance.orgId,
  'channel': _$NotificationChannelEnumMap[instance.channel]!,
  'provider': _$NotificationProviderKindEnumMap[instance.provider]!,
  'sender_id': ?instance.senderId,
  'endpoint_url': ?instance.endpointUrl,
  'config': instance.config,
  'is_active': instance.isActive,
  'secret_name': ?instance.secretName,
  'created_by': ?instance.createdBy,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

const _$NotificationChannelEnumMap = {
  NotificationChannel.sms: 'sms',
  NotificationChannel.viber: 'viber',
  NotificationChannel.email: 'email',
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
