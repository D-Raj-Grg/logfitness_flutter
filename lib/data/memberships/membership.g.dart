// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Membership _$MembershipFromJson(Map<String, dynamic> json) => _Membership(
  id: json['id'] as String,
  orgId: json['org_id'] as String,
  branchId: json['branch_id'] as String,
  memberId: json['member_id'] as String,
  planId: json['plan_id'] as String,
  planName: json['plan_name'] as String,
  planType: $enumDecode(_$PlanTypeEnumMap, json['plan_type']),
  startDate: const PlainDateConverter().fromJson(json['start_date'] as String),
  endDate: const NullablePlainDateConverter().fromJson(
    json['end_date'] as String?,
  ),
  sessionsTotal: (json['sessions_total'] as num?)?.toInt(),
  sessionsRemaining: (json['sessions_remaining'] as num?)?.toInt(),
  pricePaisa: (json['price_paisa'] as num).toInt(),
  discountPaisa: (json['discount_paisa'] as num).toInt(),
  signupFeePaisa: (json['signup_fee_paisa'] as num).toInt(),
  status: $enumDecode(_$MembershipStatusEnumMap, json['status']),
  frozenOn: const NullablePlainDateConverter().fromJson(
    json['frozen_on'] as String?,
  ),
  frozenDays: (json['frozen_days'] as num).toInt(),
  cancelledAt: json['cancelled_at'] == null
      ? null
      : DateTime.parse(json['cancelled_at'] as String),
  cancelReason: json['cancel_reason'] as String?,
  previousMembershipId: json['previous_membership_id'] as String?,
  soldBy: json['sold_by'] as String?,
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$MembershipToJson(
  _Membership instance,
) => <String, dynamic>{
  'id': instance.id,
  'org_id': instance.orgId,
  'branch_id': instance.branchId,
  'member_id': instance.memberId,
  'plan_id': instance.planId,
  'plan_name': instance.planName,
  'plan_type': _$PlanTypeEnumMap[instance.planType]!,
  'start_date': const PlainDateConverter().toJson(instance.startDate),
  'end_date': ?const NullablePlainDateConverter().toJson(instance.endDate),
  'sessions_total': ?instance.sessionsTotal,
  'sessions_remaining': ?instance.sessionsRemaining,
  'price_paisa': instance.pricePaisa,
  'discount_paisa': instance.discountPaisa,
  'signup_fee_paisa': instance.signupFeePaisa,
  'status': _$MembershipStatusEnumMap[instance.status]!,
  'frozen_on': ?const NullablePlainDateConverter().toJson(instance.frozenOn),
  'frozen_days': instance.frozenDays,
  'cancelled_at': ?instance.cancelledAt?.toIso8601String(),
  'cancel_reason': ?instance.cancelReason,
  'previous_membership_id': ?instance.previousMembershipId,
  'sold_by': ?instance.soldBy,
  'notes': ?instance.notes,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

const _$PlanTypeEnumMap = {
  PlanType.time: 'time',
  PlanType.sessionPack: 'session_pack',
};

const _$MembershipStatusEnumMap = {
  MembershipStatus.upcoming: 'upcoming',
  MembershipStatus.active: 'active',
  MembershipStatus.frozen: 'frozen',
  MembershipStatus.expired: 'expired',
  MembershipStatus.cancelled: 'cancelled',
};
