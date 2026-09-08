// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_rpc_results.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RegisterMemberResult _$RegisterMemberResultFromJson(
  Map<String, dynamic> json,
) => _RegisterMemberResult(
  memberId: json['member_id'] as String,
  memberCode: json['member_code'] as String,
  sold: json['sold'] as bool,
  membershipId: json['membership_id'] as String?,
  invoiceId: json['invoice_id'] as String?,
  invoiceNo: json['invoice_no'] as String?,
  paymentId: json['payment_id'] as String?,
  startDate: const NullablePlainDateConverter().fromJson(
    json['start_date'] as String?,
  ),
  endDate: const NullablePlainDateConverter().fromJson(
    json['end_date'] as String?,
  ),
  totalPaisa: (json['total_paisa'] as num?)?.toInt(),
  duePaisa: (json['due_paisa'] as num?)?.toInt(),
);

Map<String, dynamic> _$RegisterMemberResultToJson(
  _RegisterMemberResult instance,
) => <String, dynamic>{
  'member_id': instance.memberId,
  'member_code': instance.memberCode,
  'sold': instance.sold,
  'membership_id': ?instance.membershipId,
  'invoice_id': ?instance.invoiceId,
  'invoice_no': ?instance.invoiceNo,
  'payment_id': ?instance.paymentId,
  'start_date': ?const NullablePlainDateConverter().toJson(instance.startDate),
  'end_date': ?const NullablePlainDateConverter().toJson(instance.endDate),
  'total_paisa': ?instance.totalPaisa,
  'due_paisa': ?instance.duePaisa,
};

_ArchiveMemberResult _$ArchiveMemberResultFromJson(Map<String, dynamic> json) =>
    _ArchiveMemberResult(
      memberId: json['member_id'] as String,
      archivedAt: DateTime.parse(json['archived_at'] as String),
    );

Map<String, dynamic> _$ArchiveMemberResultToJson(
  _ArchiveMemberResult instance,
) => <String, dynamic>{
  'member_id': instance.memberId,
  'archived_at': instance.archivedAt.toIso8601String(),
};

_MemberStatusResult _$MemberStatusResultFromJson(Map<String, dynamic> json) =>
    _MemberStatusResult(
      memberId: json['member_id'] as String,
      status: $enumDecode(_$MemberStatusEnumMap, json['status']),
    );

Map<String, dynamic> _$MemberStatusResultToJson(_MemberStatusResult instance) =>
    <String, dynamic>{
      'member_id': instance.memberId,
      'status': _$MemberStatusEnumMap[instance.status]!,
    };

const _$MemberStatusEnumMap = {
  MemberStatus.active: 'active',
  MemberStatus.expired: 'expired',
  MemberStatus.frozen: 'frozen',
  MemberStatus.left: 'left',
};
