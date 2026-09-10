// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_rpc_results.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CheckInMemberSummary _$CheckInMemberSummaryFromJson(
  Map<String, dynamic> json,
) => _CheckInMemberSummary(
  id: json['id'] as String,
  fullName: json['full_name'] as String,
  memberCode: json['member_code'] as String?,
  phone: json['phone'] as String?,
  photoPath: json['photo_path'] as String?,
  status: $enumDecodeNullable(_$MemberStatusEnumMap, json['status']),
);

Map<String, dynamic> _$CheckInMemberSummaryToJson(
  _CheckInMemberSummary instance,
) => <String, dynamic>{
  'id': instance.id,
  'full_name': instance.fullName,
  'member_code': ?instance.memberCode,
  'phone': ?instance.phone,
  'photo_path': ?instance.photoPath,
  'status': ?_$MemberStatusEnumMap[instance.status],
};

const _$MemberStatusEnumMap = {
  MemberStatus.active: 'active',
  MemberStatus.expired: 'expired',
  MemberStatus.frozen: 'frozen',
  MemberStatus.left: 'left',
};

_CheckInBranchSummary _$CheckInBranchSummaryFromJson(
  Map<String, dynamic> json,
) => _CheckInBranchSummary(
  id: json['id'] as String,
  name: json['name'] as String,
);

Map<String, dynamic> _$CheckInBranchSummaryToJson(
  _CheckInBranchSummary instance,
) => <String, dynamic>{'id': instance.id, 'name': instance.name};

_CheckInResult _$CheckInResultFromJson(
  Map<String, dynamic> json,
) => _CheckInResult(
  ok: json['ok'] as bool,
  reason: $enumDecodeNullable(_$CheckInRefusalEnumMap, json['reason']),
  banner: $enumDecodeNullable(_$CheckInBannerEnumMap, json['banner']),
  member: json['member'] == null
      ? null
      : CheckInMemberSummary.fromJson(json['member'] as Map<String, dynamic>),
  branch: json['branch'] == null
      ? null
      : CheckInBranchSummary.fromJson(json['branch'] as Map<String, dynamic>),
  duePaisa: (json['due_paisa'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$CheckInResultToJson(_CheckInResult instance) =>
    <String, dynamic>{
      'ok': instance.ok,
      'reason': ?_$CheckInRefusalEnumMap[instance.reason],
      'banner': ?_$CheckInBannerEnumMap[instance.banner],
      'member': ?instance.member?.toJson(),
      'branch': ?instance.branch?.toJson(),
      'due_paisa': instance.duePaisa,
    };

const _$CheckInRefusalEnumMap = {
  CheckInRefusal.alreadyCheckedIn: 'already_checked_in',
};

const _$CheckInBannerEnumMap = {
  CheckInBanner.active: 'active',
  CheckInBanner.expiring: 'expiring',
  CheckInBanner.upcoming: 'upcoming',
  CheckInBanner.frozen: 'frozen',
  CheckInBanner.expired: 'expired',
  CheckInBanner.none: 'none',
  CheckInBanner.left: 'left',
};

_QrVerifyResult _$QrVerifyResultFromJson(Map<String, dynamic> json) =>
    _QrVerifyResult(
      valid: json['valid'] as bool,
      reason: $enumDecodeNullable(_$QrRefusalEnumMap, json['reason']),
      memberId: json['member_id'] as String?,
      orgId: json['org_id'] as String?,
      memberCode: json['member_code'] as String?,
      fullName: json['full_name'] as String?,
      homeBranchId: json['home_branch_id'] as String?,
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.parse(json['expires_at'] as String),
    );

Map<String, dynamic> _$QrVerifyResultToJson(_QrVerifyResult instance) =>
    <String, dynamic>{
      'valid': instance.valid,
      'reason': ?_$QrRefusalEnumMap[instance.reason],
      'member_id': ?instance.memberId,
      'org_id': ?instance.orgId,
      'member_code': ?instance.memberCode,
      'full_name': ?instance.fullName,
      'home_branch_id': ?instance.homeBranchId,
      'expires_at': ?instance.expiresAt?.toIso8601String(),
    };

const _$QrRefusalEnumMap = {
  QrRefusal.malformed: 'malformed',
  QrRefusal.badSignature: 'bad_signature',
  QrRefusal.expired: 'expired',
  QrRefusal.notVisible: 'not_visible',
};
