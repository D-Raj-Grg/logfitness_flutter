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
  dateOfBirth: const NullablePlainDateConverter().fromJson(
    json['date_of_birth'] as String?,
  ),
  gender: $enumDecodeNullable(_$MemberGenderEnumMap, json['gender']),
  address: json['address'] as String?,
  photoPath: json['photo_path'] as String?,
  emergencyContactName: json['emergency_contact_name'] as String?,
  emergencyContactPhone: json['emergency_contact_phone'] as String?,
  notes: json['notes'] as String?,
  status: $enumDecode(_$MemberStatusEnumMap, json['status']),
  joinedOn: const PlainDateConverter().fromJson(json['joined_on'] as String),
  leftOn: const NullablePlainDateConverter().fromJson(
    json['left_on'] as String?,
  ),
  leftReason: json['left_reason'] as String?,
  invitedBy: json['invited_by'] as String?,
  invitedAt: json['invited_at'] == null
      ? null
      : DateTime.parse(json['invited_at'] as String),
  acceptedAt: json['accepted_at'] == null
      ? null
      : DateTime.parse(json['accepted_at'] as String),
  archivedAt: json['archived_at'] == null
      ? null
      : DateTime.parse(json['archived_at'] as String),
  archivedReason: json['archived_reason'] as String?,
  archivedBy: json['archived_by'] as String?,
  notificationsOptOut: json['notifications_opt_out'] as bool? ?? false,
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
  'date_of_birth': ?const NullablePlainDateConverter().toJson(
    instance.dateOfBirth,
  ),
  'gender': ?_$MemberGenderEnumMap[instance.gender],
  'address': ?instance.address,
  'photo_path': ?instance.photoPath,
  'emergency_contact_name': ?instance.emergencyContactName,
  'emergency_contact_phone': ?instance.emergencyContactPhone,
  'notes': ?instance.notes,
  'status': _$MemberStatusEnumMap[instance.status]!,
  'joined_on': const PlainDateConverter().toJson(instance.joinedOn),
  'left_on': ?const NullablePlainDateConverter().toJson(instance.leftOn),
  'left_reason': ?instance.leftReason,
  'invited_by': ?instance.invitedBy,
  'invited_at': ?instance.invitedAt?.toIso8601String(),
  'accepted_at': ?instance.acceptedAt?.toIso8601String(),
  'archived_at': ?instance.archivedAt?.toIso8601String(),
  'archived_reason': ?instance.archivedReason,
  'archived_by': ?instance.archivedBy,
  'notifications_opt_out': instance.notificationsOptOut,
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
