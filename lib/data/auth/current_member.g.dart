// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CurrentMember _$CurrentMemberFromJson(Map<String, dynamic> json) =>
    _CurrentMember(
      memberId: json['member_id'] as String,
      orgId: json['org_id'] as String,
      orgName: json['org_name'] as String,
      currency: json['currency'] as String,
      timezone: json['timezone'] as String,
      homeBranchId: json['home_branch_id'] as String,
      homeBranchName: json['home_branch_name'] as String,
      memberCode: json['member_code'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String,
      status: $enumDecode(_$MemberStatusEnumMap, json['status']),
    );

Map<String, dynamic> _$CurrentMemberToJson(_CurrentMember instance) =>
    <String, dynamic>{
      'member_id': instance.memberId,
      'org_id': instance.orgId,
      'org_name': instance.orgName,
      'currency': instance.currency,
      'timezone': instance.timezone,
      'home_branch_id': instance.homeBranchId,
      'home_branch_name': instance.homeBranchName,
      'member_code': instance.memberCode,
      'full_name': instance.fullName,
      'email': ?instance.email,
      'phone': instance.phone,
      'status': _$MemberStatusEnumMap[instance.status]!,
    };

const _$MemberStatusEnumMap = {
  MemberStatus.active: 'active',
  MemberStatus.expired: 'expired',
  MemberStatus.frozen: 'frozen',
  MemberStatus.left: 'left',
};
