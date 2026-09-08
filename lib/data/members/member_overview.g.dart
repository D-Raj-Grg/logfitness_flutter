// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_overview.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MemberOverview _$MemberOverviewFromJson(Map<String, dynamic> json) =>
    _MemberOverview(
      id: json['id'] as String,
      orgId: json['org_id'] as String,
      homeBranchId: json['home_branch_id'] as String,
      homeBranchName: json['home_branch_name'] as String,
      memberCode: json['member_code'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      photoPath: json['photo_path'] as String?,
      status: $enumDecode(_$MemberStatusEnumMap, json['status']),
      joinedOn: const PlainDateConverter().fromJson(
        json['joined_on'] as String,
      ),
      leftOn: const NullablePlainDateConverter().fromJson(
        json['left_on'] as String?,
      ),
      currentMembershipId: json['current_membership_id'] as String?,
      currentPlanId: json['current_plan_id'] as String?,
      currentPlanName: json['current_plan_name'] as String?,
      currentPlanType: $enumDecodeNullable(
        _$PlanTypeEnumMap,
        json['current_plan_type'],
      ),
      membershipStatus: $enumDecodeNullable(
        _$MembershipStatusEnumMap,
        json['membership_status'],
      ),
      membershipStartDate: const NullablePlainDateConverter().fromJson(
        json['membership_start_date'] as String?,
      ),
      membershipEndDate: const NullablePlainDateConverter().fromJson(
        json['membership_end_date'] as String?,
      ),
      sessionsRemaining: (json['sessions_remaining'] as num?)?.toInt(),
      daysToExpiry: (json['days_to_expiry'] as num?)?.toInt(),
      duePaisa: paisaFromJson(json['due_paisa']),
      oldestDueOn: const NullablePlainDateConverter().fromJson(
        json['oldest_due_on'] as String?,
      ),
      hasMembershipHistory: json['has_membership_history'] as bool,
      archivedAt: json['archived_at'] == null
          ? null
          : DateTime.parse(json['archived_at'] as String),
    );

Map<String, dynamic> _$MemberOverviewToJson(
  _MemberOverview instance,
) => <String, dynamic>{
  'id': instance.id,
  'org_id': instance.orgId,
  'home_branch_id': instance.homeBranchId,
  'home_branch_name': instance.homeBranchName,
  'member_code': instance.memberCode,
  'full_name': instance.fullName,
  'phone': instance.phone,
  'email': ?instance.email,
  'photo_path': ?instance.photoPath,
  'status': _$MemberStatusEnumMap[instance.status]!,
  'joined_on': const PlainDateConverter().toJson(instance.joinedOn),
  'left_on': ?const NullablePlainDateConverter().toJson(instance.leftOn),
  'current_membership_id': ?instance.currentMembershipId,
  'current_plan_id': ?instance.currentPlanId,
  'current_plan_name': ?instance.currentPlanName,
  'current_plan_type': ?_$PlanTypeEnumMap[instance.currentPlanType],
  'membership_status': ?_$MembershipStatusEnumMap[instance.membershipStatus],
  'membership_start_date': ?const NullablePlainDateConverter().toJson(
    instance.membershipStartDate,
  ),
  'membership_end_date': ?const NullablePlainDateConverter().toJson(
    instance.membershipEndDate,
  ),
  'sessions_remaining': ?instance.sessionsRemaining,
  'days_to_expiry': ?instance.daysToExpiry,
  'due_paisa': instance.duePaisa,
  'oldest_due_on': ?const NullablePlainDateConverter().toJson(
    instance.oldestDueOn,
  ),
  'has_membership_history': instance.hasMembershipHistory,
  'archived_at': ?instance.archivedAt?.toIso8601String(),
};

const _$MemberStatusEnumMap = {
  MemberStatus.active: 'active',
  MemberStatus.expired: 'expired',
  MemberStatus.frozen: 'frozen',
  MemberStatus.left: 'left',
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
