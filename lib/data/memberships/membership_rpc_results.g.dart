// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership_rpc_results.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RenewMembershipResult _$RenewMembershipResultFromJson(
  Map<String, dynamic> json,
) => _RenewMembershipResult(
  membershipId: json['membership_id'] as String,
  invoiceId: json['invoice_id'] as String,
  invoiceNo: json['invoice_no'] as String,
  paymentId: json['payment_id'] as String?,
  startDate: const PlainDateConverter().fromJson(json['start_date'] as String),
  endDate: const NullablePlainDateConverter().fromJson(
    json['end_date'] as String?,
  ),
  totalPaisa: (json['total_paisa'] as num).toInt(),
  duePaisa: (json['due_paisa'] as num).toInt(),
);

Map<String, dynamic> _$RenewMembershipResultToJson(
  _RenewMembershipResult instance,
) => <String, dynamic>{
  'membership_id': instance.membershipId,
  'invoice_id': instance.invoiceId,
  'invoice_no': instance.invoiceNo,
  'payment_id': ?instance.paymentId,
  'start_date': const PlainDateConverter().toJson(instance.startDate),
  'end_date': ?const NullablePlainDateConverter().toJson(instance.endDate),
  'total_paisa': instance.totalPaisa,
  'due_paisa': instance.duePaisa,
};

_FreezeMembershipResult _$FreezeMembershipResultFromJson(
  Map<String, dynamic> json,
) => _FreezeMembershipResult(
  membershipId: json['membership_id'] as String,
  frozenOn: const PlainDateConverter().fromJson(json['frozen_on'] as String),
);

Map<String, dynamic> _$FreezeMembershipResultToJson(
  _FreezeMembershipResult instance,
) => <String, dynamic>{
  'membership_id': instance.membershipId,
  'frozen_on': const PlainDateConverter().toJson(instance.frozenOn),
};

_UnfreezeMembershipResult _$UnfreezeMembershipResultFromJson(
  Map<String, dynamic> json,
) => _UnfreezeMembershipResult(
  membershipId: json['membership_id'] as String,
  pausedDays: (json['paused_days'] as num).toInt(),
  endDate: const NullablePlainDateConverter().fromJson(
    json['end_date'] as String?,
  ),
);

Map<String, dynamic> _$UnfreezeMembershipResultToJson(
  _UnfreezeMembershipResult instance,
) => <String, dynamic>{
  'membership_id': instance.membershipId,
  'paused_days': instance.pausedDays,
  'end_date': ?const NullablePlainDateConverter().toJson(instance.endDate),
};

_MembershipStatusResult _$MembershipStatusResultFromJson(
  Map<String, dynamic> json,
) => _MembershipStatusResult(
  membershipId: json['membership_id'] as String,
  status: $enumDecode(_$MembershipStatusEnumMap, json['status']),
);

Map<String, dynamic> _$MembershipStatusResultToJson(
  _MembershipStatusResult instance,
) => <String, dynamic>{
  'membership_id': instance.membershipId,
  'status': _$MembershipStatusEnumMap[instance.status]!,
};

const _$MembershipStatusEnumMap = {
  MembershipStatus.upcoming: 'upcoming',
  MembershipStatus.active: 'active',
  MembershipStatus.frozen: 'frozen',
  MembershipStatus.expired: 'expired',
  MembershipStatus.cancelled: 'cancelled',
};

_AdjustMembershipDatesResult _$AdjustMembershipDatesResultFromJson(
  Map<String, dynamic> json,
) => _AdjustMembershipDatesResult(
  membershipId: json['membership_id'] as String,
  memberId: json['member_id'] as String,
  previousStartDate: const PlainDateConverter().fromJson(
    json['previous_start_date'] as String,
  ),
  previousEndDate: const NullablePlainDateConverter().fromJson(
    json['previous_end_date'] as String?,
  ),
  startDate: const PlainDateConverter().fromJson(json['start_date'] as String),
  endDate: const NullablePlainDateConverter().fromJson(
    json['end_date'] as String?,
  ),
  daysMoved: (json['days_moved'] as num).toInt(),
  daysChanged: (json['days_changed'] as num).toInt(),
  status: $enumDecode(_$MembershipStatusEnumMap, json['status']),
);

Map<String, dynamic> _$AdjustMembershipDatesResultToJson(
  _AdjustMembershipDatesResult instance,
) => <String, dynamic>{
  'membership_id': instance.membershipId,
  'member_id': instance.memberId,
  'previous_start_date': const PlainDateConverter().toJson(
    instance.previousStartDate,
  ),
  'previous_end_date': ?const NullablePlainDateConverter().toJson(
    instance.previousEndDate,
  ),
  'start_date': const PlainDateConverter().toJson(instance.startDate),
  'end_date': ?const NullablePlainDateConverter().toJson(instance.endDate),
  'days_moved': instance.daysMoved,
  'days_changed': instance.daysChanged,
  'status': _$MembershipStatusEnumMap[instance.status]!,
};
