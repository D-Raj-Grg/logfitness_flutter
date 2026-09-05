// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MembershipPlan _$MembershipPlanFromJson(Map<String, dynamic> json) =>
    _MembershipPlan(
      id: json['id'] as String,
      orgId: json['org_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      planType: $enumDecode(_$PlanTypeEnumMap, json['plan_type']),
      durationDays: (json['duration_days'] as num?)?.toInt(),
      sessionCount: (json['session_count'] as num?)?.toInt(),
      pricePaisa: (json['price_paisa'] as num).toInt(),
      signupFeePaisa: (json['signup_fee_paisa'] as num).toInt(),
      branchIds: (json['branch_ids'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      isActive: json['is_active'] as bool,
      sortOrder: (json['sort_order'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$MembershipPlanToJson(_MembershipPlan instance) =>
    <String, dynamic>{
      'id': instance.id,
      'org_id': instance.orgId,
      'name': instance.name,
      'description': ?instance.description,
      'plan_type': _$PlanTypeEnumMap[instance.planType]!,
      'duration_days': ?instance.durationDays,
      'session_count': ?instance.sessionCount,
      'price_paisa': instance.pricePaisa,
      'signup_fee_paisa': instance.signupFeePaisa,
      'branch_ids': instance.branchIds,
      'is_active': instance.isActive,
      'sort_order': instance.sortOrder,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$PlanTypeEnumMap = {
  PlanType.time: 'time',
  PlanType.sessionPack: 'session_pack',
};
