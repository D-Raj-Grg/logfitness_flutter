// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Invoice _$InvoiceFromJson(Map<String, dynamic> json) => _Invoice(
  id: json['id'] as String,
  orgId: json['org_id'] as String,
  branchId: json['branch_id'] as String,
  memberId: json['member_id'] as String,
  membershipId: json['membership_id'] as String?,
  invoiceNo: json['invoice_no'] as String,
  subtotalPaisa: (json['subtotal_paisa'] as num).toInt(),
  discountPaisa: (json['discount_paisa'] as num).toInt(),
  totalPaisa: (json['total_paisa'] as num).toInt(),
  paidPaisa: (json['paid_paisa'] as num).toInt(),
  duePaisa: (json['due_paisa'] as num).toInt(),
  status: $enumDecode(_$InvoiceStatusEnumMap, json['status']),
  issuedOn: DateTime.parse(json['issued_on'] as String),
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$InvoiceToJson(_Invoice instance) => <String, dynamic>{
  'id': instance.id,
  'org_id': instance.orgId,
  'branch_id': instance.branchId,
  'member_id': instance.memberId,
  'membership_id': ?instance.membershipId,
  'invoice_no': instance.invoiceNo,
  'subtotal_paisa': instance.subtotalPaisa,
  'discount_paisa': instance.discountPaisa,
  'total_paisa': instance.totalPaisa,
  'paid_paisa': instance.paidPaisa,
  'due_paisa': instance.duePaisa,
  'status': _$InvoiceStatusEnumMap[instance.status]!,
  'issued_on': instance.issuedOn.toIso8601String(),
  'notes': ?instance.notes,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

const _$InvoiceStatusEnumMap = {
  InvoiceStatus.unpaid: 'unpaid',
  InvoiceStatus.partial: 'partial',
  InvoiceStatus.paid: 'paid',
  InvoiceStatus.voided: 'void',
};
