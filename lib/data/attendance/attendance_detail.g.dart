// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AttendanceDetail _$AttendanceDetailFromJson(Map<String, dynamic> json) =>
    _AttendanceDetail(
      id: json['id'] as String,
      memberId: json['member_id'] as String,
      orgId: json['org_id'] as String,
      branchId: json['branch_id'] as String?,
      branchName: json['branch_name'] as String?,
      memberCode: json['member_code'] as String?,
      fullName: json['full_name'] as String?,
      phone: json['phone'] as String?,
      photoPath: json['photo_path'] as String?,
      attendedOn: const NullablePlainDateConverter().fromJson(
        json['attended_on'] as String?,
      ),
      checkedInAt: json['checked_in_at'] == null
          ? null
          : DateTime.parse(json['checked_in_at'] as String),
      checkedOutAt: json['checked_out_at'] == null
          ? null
          : DateTime.parse(json['checked_out_at'] as String),
      checkedInBy: json['checked_in_by'] as String?,
      checkedInByName: json['checked_in_by_name'] as String?,
      membershipId: json['membership_id'] as String?,
      membershipStatusAtCheckin: $enumDecodeNullable(
        _$MembershipStatusEnumMap,
        json['membership_status_at_checkin'],
      ),
      duePaisaAtCheckin: (json['due_paisa_at_checkin'] as num?)?.toInt(),
      daysToExpiryAtCheckin: (json['days_to_expiry_at_checkin'] as num?)
          ?.toInt(),
      method: $enumDecodeNullable(_$AttendanceMethodEnumMap, json['method']),
      isOverride: json['is_override'] as bool? ?? false,
      overrideReason: json['override_reason'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$AttendanceDetailToJson(_AttendanceDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'member_id': instance.memberId,
      'org_id': instance.orgId,
      'branch_id': ?instance.branchId,
      'branch_name': ?instance.branchName,
      'member_code': ?instance.memberCode,
      'full_name': ?instance.fullName,
      'phone': ?instance.phone,
      'photo_path': ?instance.photoPath,
      'attended_on': ?const NullablePlainDateConverter().toJson(
        instance.attendedOn,
      ),
      'checked_in_at': ?instance.checkedInAt?.toIso8601String(),
      'checked_out_at': ?instance.checkedOutAt?.toIso8601String(),
      'checked_in_by': ?instance.checkedInBy,
      'checked_in_by_name': ?instance.checkedInByName,
      'membership_id': ?instance.membershipId,
      'membership_status_at_checkin':
          ?_$MembershipStatusEnumMap[instance.membershipStatusAtCheckin],
      'due_paisa_at_checkin': ?instance.duePaisaAtCheckin,
      'days_to_expiry_at_checkin': ?instance.daysToExpiryAtCheckin,
      'method': ?_$AttendanceMethodEnumMap[instance.method],
      'is_override': instance.isOverride,
      'override_reason': ?instance.overrideReason,
      'notes': ?instance.notes,
    };

const _$MembershipStatusEnumMap = {
  MembershipStatus.upcoming: 'upcoming',
  MembershipStatus.active: 'active',
  MembershipStatus.frozen: 'frozen',
  MembershipStatus.expired: 'expired',
  MembershipStatus.cancelled: 'cancelled',
};

const _$AttendanceMethodEnumMap = {
  AttendanceMethod.manual: 'manual',
  AttendanceMethod.qr: 'qr',
  AttendanceMethod.card: 'card',
  AttendanceMethod.biometric: 'biometric',
};
