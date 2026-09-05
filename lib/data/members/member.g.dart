// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Member _$MemberFromJson(Map<String, dynamic> json) => _Member(
  id: json['id'] as String,
  orgId: json['org_id'] as String,
  homeBranchId: json['home_branch_id'] as String,
  authUserId: json['auth_user_id'] as String?,
  memberCode: json['member_code'] as String,
  fullName: json['full_name'] as String,
  phone: json['phone'] as String,
  email: json['email'] as String?,
  dateOfBirth: json['date_of_birth'] == null
      ? null
      : DateTime.parse(json['date_of_birth'] as String),
  gender: $enumDecodeNullable(_$MemberGenderEnumMap, json['gender']),
  address: json['address'] as String?,
  photoPath: json['photo_path'] as String?,
  emergencyContactName: json['emergency_contact_name'] as String?,
  emergencyContactPhone: json['emergency_contact_phone'] as String?,
  notes: json['notes'] as String?,
  status: $enumDecode(_$MemberStatusEnumMap, json['status']),
  joinedOn: DateTime.parse(json['joined_on'] as String),
  leftOn: json['left_on'] == null
      ? null
      : DateTime.parse(json['left_on'] as String),
  leftReason: json['left_reason'] as String?,
  createdBy: json['created_by'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$MemberToJson(_Member instance) => <String, dynamic>{
  'id': instance.id,
  'org_id': instance.orgId,
  'home_branch_id': instance.homeBranchId,
  'auth_user_id': ?instance.authUserId,
  'member_code': instance.memberCode,
  'full_name': instance.fullName,
  'phone': instance.phone,
  'email': ?instance.email,
  'date_of_birth': ?instance.dateOfBirth?.toIso8601String(),
  'gender': ?_$MemberGenderEnumMap[instance.gender],
  'address': ?instance.address,
  'photo_path': ?instance.photoPath,
  'emergency_contact_name': ?instance.emergencyContactName,
  'emergency_contact_phone': ?instance.emergencyContactPhone,
  'notes': ?instance.notes,
  'status': _$MemberStatusEnumMap[instance.status]!,
  'joined_on': instance.joinedOn.toIso8601String(),
  'left_on': ?instance.leftOn?.toIso8601String(),
  'left_reason': ?instance.leftReason,
  'created_by': ?instance.createdBy,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

const _$MemberGenderEnumMap = {
  MemberGender.male: 'male',
  MemberGender.female: 'female',
  MemberGender.other: 'other',
};

const _$MemberStatusEnumMap = {
  MemberStatus.active: 'active',
  MemberStatus.expired: 'expired',
  MemberStatus.frozen: 'frozen',
  MemberStatus.left: 'left',
};
