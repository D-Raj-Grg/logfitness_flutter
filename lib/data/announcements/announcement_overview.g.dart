// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcement_overview.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AnnouncementOverview _$AnnouncementOverviewFromJson(
  Map<String, dynamic> json,
) => _AnnouncementOverview(
  id: json['id'] as String,
  orgId: json['org_id'] as String,
  branchId: json['branch_id'] as String?,
  branchName: json['branch_name'] as String?,
  title: json['title'] as String,
  body: json['body'] as String,
  channel: $enumDecode(_$NotificationChannelEnumMap, json['channel']),
  audience: $enumDecode(_$AnnouncementAudienceEnumMap, json['audience']),
  memberStatuses: (json['member_statuses'] as List<dynamic>?)
      ?.map((e) => $enumDecode(_$MemberStatusEnumMap, e))
      .toList(),
  visitorDays: (json['visitor_days'] as num?)?.toInt(),
  status: $enumDecode(_$AnnouncementStatusEnumMap, json['status']),
  state: $enumDecode(_$AnnouncementStateEnumMap, json['state']),
  scheduledFor: DateTime.parse(json['scheduled_for'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
  createdBy: json['created_by'] as String?,
  createdByName: json['created_by_name'] as String?,
  total: (json['total'] as num).toInt(),
  queued: (json['queued'] as num).toInt(),
  sent: (json['sent'] as num).toInt(),
  failed: (json['failed'] as num).toInt(),
  skipped: (json['skipped'] as num).toInt(),
  cancelled: (json['cancelled'] as num).toInt(),
  lastSentAt: json['last_sent_at'] == null
      ? null
      : DateTime.parse(json['last_sent_at'] as String),
);

Map<String, dynamic> _$AnnouncementOverviewToJson(
  _AnnouncementOverview instance,
) => <String, dynamic>{
  'id': instance.id,
  'org_id': instance.orgId,
  'branch_id': ?instance.branchId,
  'branch_name': ?instance.branchName,
  'title': instance.title,
  'body': instance.body,
  'channel': _$NotificationChannelEnumMap[instance.channel]!,
  'audience': _$AnnouncementAudienceEnumMap[instance.audience]!,
  'member_statuses': ?instance.memberStatuses
      ?.map((e) => _$MemberStatusEnumMap[e]!)
      .toList(),
  'visitor_days': ?instance.visitorDays,
  'status': _$AnnouncementStatusEnumMap[instance.status]!,
  'state': _$AnnouncementStateEnumMap[instance.state]!,
  'scheduled_for': instance.scheduledFor.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
  'created_by': ?instance.createdBy,
  'created_by_name': ?instance.createdByName,
  'total': instance.total,
  'queued': instance.queued,
  'sent': instance.sent,
  'failed': instance.failed,
  'skipped': instance.skipped,
  'cancelled': instance.cancelled,
  'last_sent_at': ?instance.lastSentAt?.toIso8601String(),
};

const _$NotificationChannelEnumMap = {
  NotificationChannel.sms: 'sms',
  NotificationChannel.viber: 'viber',
  NotificationChannel.email: 'email',
};

const _$AnnouncementAudienceEnumMap = {
  AnnouncementAudience.members: 'members',
  AnnouncementAudience.visitors: 'visitors',
  AnnouncementAudience.both: 'both',
};

const _$MemberStatusEnumMap = {
  MemberStatus.active: 'active',
  MemberStatus.expired: 'expired',
  MemberStatus.frozen: 'frozen',
  MemberStatus.left: 'left',
};

const _$AnnouncementStatusEnumMap = {
  AnnouncementStatus.scheduled: 'scheduled',
  AnnouncementStatus.sending: 'sending',
  AnnouncementStatus.cancelled: 'cancelled',
};

const _$AnnouncementStateEnumMap = {
  AnnouncementState.cancelled: 'cancelled',
  AnnouncementState.scheduled: 'scheduled',
  AnnouncementState.sending: 'sending',
  AnnouncementState.sent: 'sent',
};
