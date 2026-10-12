// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MemberCard _$MemberCardFromJson(Map<String, dynamic> json) => _MemberCard(
  id: json['id'] as String,
  orgId: json['org_id'] as String,
  memberId: json['member_id'] as String,
  cardUid: json['card_uid'] as String,
  assignedBy: json['assigned_by'] as String?,
  assignedAt: DateTime.parse(json['assigned_at'] as String),
  revokedAt: json['revoked_at'] == null
      ? null
      : DateTime.parse(json['revoked_at'] as String),
  revokedBy: json['revoked_by'] as String?,
  revokeReason: json['revoke_reason'] as String?,
);

Map<String, dynamic> _$MemberCardToJson(_MemberCard instance) =>
    <String, dynamic>{
      'id': instance.id,
      'org_id': instance.orgId,
      'member_id': instance.memberId,
      'card_uid': instance.cardUid,
      'assigned_by': ?instance.assignedBy,
      'assigned_at': instance.assignedAt.toIso8601String(),
      'revoked_at': ?instance.revokedAt?.toIso8601String(),
      'revoked_by': ?instance.revokedBy,
      'revoke_reason': ?instance.revokeReason,
    };
