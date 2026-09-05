// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_staff.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CurrentStaff _$CurrentStaffFromJson(Map<String, dynamic> json) =>
    _CurrentStaff(
      staffId: json['staff_id'] as String,
      orgId: json['org_id'] as String,
      orgName: json['org_name'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      role: $enumDecode(_$StaffRoleEnumMap, json['role']),
      branchIds: (json['branch_ids'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$CurrentStaffToJson(_CurrentStaff instance) =>
    <String, dynamic>{
      'staff_id': instance.staffId,
      'org_id': instance.orgId,
      'org_name': instance.orgName,
      'full_name': instance.fullName,
      'email': instance.email,
      'role': _$StaffRoleEnumMap[instance.role]!,
      'branch_ids': instance.branchIds,
    };

const _$StaffRoleEnumMap = {
  StaffRole.owner: 'owner',
  StaffRole.manager: 'manager',
  StaffRole.frontDesk: 'front_desk',
  StaffRole.trainer: 'trainer',
};
