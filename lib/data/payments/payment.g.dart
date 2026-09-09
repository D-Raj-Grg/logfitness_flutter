// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Payment _$PaymentFromJson(Map<String, dynamic> json) => _Payment(
  id: json['id'] as String,
  orgId: json['org_id'] as String,
  branchId: json['branch_id'] as String,
  memberId: json['member_id'] as String,
  membershipId: json['membership_id'] as String?,
  invoiceId: json['invoice_id'] as String?,
  kind: $enumDecode(_$PaymentKindEnumMap, json['kind']),
  amountPaisa: (json['amount_paisa'] as num).toInt(),
  method: $enumDecode(_$PaymentMethodEnumMap, json['method']),
  referenceNo: json['reference_no'] as String?,
  reason: json['reason'] as String?,
  collectedBy: json['collected_by'] as String?,
  paidAt: DateTime.parse(json['paid_at'] as String),
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$PaymentToJson(_Payment instance) => <String, dynamic>{
  'id': instance.id,
  'org_id': instance.orgId,
  'branch_id': instance.branchId,
  'member_id': instance.memberId,
  'membership_id': ?instance.membershipId,
  'invoice_id': ?instance.invoiceId,
  'kind': _$PaymentKindEnumMap[instance.kind]!,
  'amount_paisa': instance.amountPaisa,
  'method': _$PaymentMethodEnumMap[instance.method]!,
  'reference_no': ?instance.referenceNo,
  'reason': ?instance.reason,
  'collected_by': ?instance.collectedBy,
  'paid_at': instance.paidAt.toIso8601String(),
  'notes': ?instance.notes,
  'created_at': instance.createdAt.toIso8601String(),
};

const _$PaymentKindEnumMap = {
  PaymentKind.payment: 'payment',
  PaymentKind.refund: 'refund',
  PaymentKind.reversal: 'reversal',
};

const _$PaymentMethodEnumMap = {
  PaymentMethod.cash: 'cash',
  PaymentMethod.esewa: 'esewa',
  PaymentMethod.khalti: 'khalti',
  PaymentMethod.fonepay: 'fonepay',
  PaymentMethod.bank: 'bank',
  PaymentMethod.card: 'card',
};
