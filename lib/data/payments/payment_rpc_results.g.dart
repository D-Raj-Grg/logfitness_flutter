// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_rpc_results.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RecordPaymentResult _$RecordPaymentResultFromJson(Map<String, dynamic> json) =>
    _RecordPaymentResult(
      paymentId: json['payment_id'] as String,
      invoiceId: json['invoice_id'] as String,
      paidPaisa: (json['paid_paisa'] as num).toInt(),
      duePaisa: (json['due_paisa'] as num).toInt(),
      status: $enumDecode(_$InvoiceStatusEnumMap, json['status']),
    );

Map<String, dynamic> _$RecordPaymentResultToJson(
  _RecordPaymentResult instance,
) => <String, dynamic>{
  'payment_id': instance.paymentId,
  'invoice_id': instance.invoiceId,
  'paid_paisa': instance.paidPaisa,
  'due_paisa': instance.duePaisa,
  'status': _$InvoiceStatusEnumMap[instance.status]!,
};

const _$InvoiceStatusEnumMap = {
  InvoiceStatus.unpaid: 'unpaid',
  InvoiceStatus.partial: 'partial',
  InvoiceStatus.paid: 'paid',
  InvoiceStatus.voided: 'void',
};

_RefundPaymentResult _$RefundPaymentResultFromJson(Map<String, dynamic> json) =>
    _RefundPaymentResult(
      refundId: json['refund_id'] as String,
      amountPaisa: (json['amount_paisa'] as num).toInt(),
    );

Map<String, dynamic> _$RefundPaymentResultToJson(
  _RefundPaymentResult instance,
) => <String, dynamic>{
  'refund_id': instance.refundId,
  'amount_paisa': instance.amountPaisa,
};

_ReversePaymentResult _$ReversePaymentResultFromJson(
  Map<String, dynamic> json,
) => _ReversePaymentResult(
  reversalId: json['reversal_id'] as String,
  paymentId: json['payment_id'] as String,
  amountPaisa: (json['amount_paisa'] as num).toInt(),
  invoiceId: json['invoice_id'] as String?,
  invoiceNo: json['invoice_no'] as String?,
  duePaisa: (json['due_paisa'] as num?)?.toInt(),
  status: $enumDecodeNullable(_$InvoiceStatusEnumMap, json['status']),
);

Map<String, dynamic> _$ReversePaymentResultToJson(
  _ReversePaymentResult instance,
) => <String, dynamic>{
  'reversal_id': instance.reversalId,
  'payment_id': instance.paymentId,
  'amount_paisa': instance.amountPaisa,
  'invoice_id': ?instance.invoiceId,
  'invoice_no': ?instance.invoiceNo,
  'due_paisa': ?instance.duePaisa,
  'status': ?_$InvoiceStatusEnumMap[instance.status],
};

_DailyCollectionRow _$DailyCollectionRowFromJson(Map<String, dynamic> json) =>
    _DailyCollectionRow(
      branchId: json['branch_id'] as String,
      branchName: json['branch_name'] as String,
      staffId: json['staff_id'] as String?,
      staffName: json['staff_name'] as String?,
      method: $enumDecode(_$PaymentMethodEnumMap, json['method']),
      kind: $enumDecode(_$PaymentKindEnumMap, json['kind']),
      txnCount: (json['txn_count'] as num).toInt(),
      amountPaisa: (json['amount_paisa'] as num).toInt(),
    );

Map<String, dynamic> _$DailyCollectionRowToJson(_DailyCollectionRow instance) =>
    <String, dynamic>{
      'branch_id': instance.branchId,
      'branch_name': instance.branchName,
      'staff_id': ?instance.staffId,
      'staff_name': ?instance.staffName,
      'method': _$PaymentMethodEnumMap[instance.method]!,
      'kind': _$PaymentKindEnumMap[instance.kind]!,
      'txn_count': instance.txnCount,
      'amount_paisa': instance.amountPaisa,
    };

const _$PaymentMethodEnumMap = {
  PaymentMethod.cash: 'cash',
  PaymentMethod.esewa: 'esewa',
  PaymentMethod.khalti: 'khalti',
  PaymentMethod.fonepay: 'fonepay',
  PaymentMethod.bank: 'bank',
  PaymentMethod.card: 'card',
};

const _$PaymentKindEnumMap = {
  PaymentKind.payment: 'payment',
  PaymentKind.refund: 'refund',
};

_ArrearsRow _$ArrearsRowFromJson(Map<String, dynamic> json) => _ArrearsRow(
  memberId: json['member_id'] as String,
  memberCode: json['member_code'] as String,
  fullName: json['full_name'] as String,
  phone: json['phone'] as String,
  homeBranchId: json['home_branch_id'] as String,
  homeBranchName: json['home_branch_name'] as String,
  duePaisa: (json['due_paisa'] as num).toInt(),
  oldestDueOn: const NullablePlainDateConverter().fromJson(
    json['oldest_due_on'] as String?,
  ),
  ageDays: (json['age_days'] as num?)?.toInt(),
  bucket: json['bucket'] as String?,
);

Map<String, dynamic> _$ArrearsRowToJson(_ArrearsRow instance) =>
    <String, dynamic>{
      'member_id': instance.memberId,
      'member_code': instance.memberCode,
      'full_name': instance.fullName,
      'phone': instance.phone,
      'home_branch_id': instance.homeBranchId,
      'home_branch_name': instance.homeBranchName,
      'due_paisa': instance.duePaisa,
      'oldest_due_on': ?const NullablePlainDateConverter().toJson(
        instance.oldestDueOn,
      ),
      'age_days': ?instance.ageDays,
      'bucket': ?instance.bucket,
    };
