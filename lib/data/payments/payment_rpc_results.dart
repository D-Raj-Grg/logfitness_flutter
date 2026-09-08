// The `jsonb` shapes the payment RPCs return, plus the two report rows. See
// `logfitness_saas/supabase/migrations/20260905120700_membership_rpcs.sql`
// (`record_payment`, `refund_payment`),
// `20260907120600_reverse_payment_rpc.sql` with
// `20260908110000_reverse_payment_in_part.sql`, and
// `20260908100000_reports_take_branch_lists.sql` (`daily_collection`,
// `arrears_report`).
//
// Money is integer paisa in `int` throughout -- never a double, never a
// formatted string. Every `*_paisa` field below arrives from Postgres as a
// `bigint`.
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/format/plain_date.dart';

part 'payment_rpc_results.freezed.dart';
part 'payment_rpc_results.g.dart';

/// What `record_payment` returns: the new payment, and the invoice as the
/// trigger left it.
///
/// `paid_paisa`, `due_paisa` and `status` are re-read from the invoice *after*
/// the insert, because a trigger maintains them. The caller must render these
/// rather than adding the amount to whatever it was holding -- a concurrent
/// collection at another counter makes the local sum wrong.
@freezed
abstract class RecordPaymentResult with _$RecordPaymentResult {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory RecordPaymentResult({
    required String paymentId,
    required String invoiceId,
    required int paidPaisa,
    required int duePaisa,
    required InvoiceStatus status,
  }) = _RecordPaymentResult;

  factory RecordPaymentResult.fromJson(Map<String, dynamic> json) =>
      _$RecordPaymentResultFromJson(json);
}

/// What `refund_payment` returns.
///
/// [amountPaisa] comes back **negative**: a refund is an additive negative
/// `payments` row, not an edit of the original (CLAUDE.md, "financial history
/// is append-only"). Summing the column therefore gives net cash without any
/// sign handling at the call site.
@freezed
abstract class RefundPaymentResult with _$RefundPaymentResult {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory RefundPaymentResult({
    required String refundId,
    required int amountPaisa,
  }) = _RefundPaymentResult;

  factory RefundPaymentResult.fromJson(Map<String, dynamic> json) =>
      _$RefundPaymentResultFromJson(json);
}

/// What `reverse_payment` returns.
///
/// A reversal is mechanically a refund -- a negative row the invoice totals
/// follow straight back into a due -- but carries its own `payment_kind`, so
/// the collection sheet can tell money given back from money that never
/// arrived. The invoice fields are all nullable because a payment need not
/// have been raised against an invoice.
@freezed
abstract class ReversePaymentResult with _$ReversePaymentResult {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory ReversePaymentResult({
    required String reversalId,

    /// The entry that was reversed, not the reversal itself.
    required String paymentId,

    /// Negative, like a refund.
    required int amountPaisa,
    String? invoiceId,
    String? invoiceNo,
    int? duePaisa,
    InvoiceStatus? status,
  }) = _ReversePaymentResult;

  factory ReversePaymentResult.fromJson(Map<String, dynamic> json) =>
      _$ReversePaymentResultFromJson(json);
}

/// One row of `daily_collection` -- the drawer sheet, grouped by branch,
/// collector, method and kind.
///
/// It returns a `TABLE`, not a `jsonb` object, so PostgREST sends a list of
/// rows and this is a row model rather than a result wrapper.
@freezed
abstract class DailyCollectionRow with _$DailyCollectionRow {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory DailyCollectionRow({
    required String branchId,
    required String branchName,

    /// Null for a payment whose collector has since been removed, or one
    /// taken by a function rather than a person.
    String? staffId,
    String? staffName,
    required PaymentMethod method,
    required PaymentKind kind,

    /// `bigint` from `count(*)`.
    required int txnCount,

    /// Signed: negative for the refund and reversal rows. Summing the whole
    /// sheet gives net cash, which is the number the drawer has to match.
    required int amountPaisa,
  }) = _DailyCollectionRow;

  factory DailyCollectionRow.fromJson(Map<String, dynamic> json) =>
      _$DailyCollectionRowFromJson(json);
}

/// One row of `arrears_report` -- a member with money outstanding.
@freezed
abstract class ArrearsRow with _$ArrearsRow {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory ArrearsRow({
    required String memberId,
    required String memberCode,
    required String fullName,
    required String phone,
    required String homeBranchId,
    required String homeBranchName,
    required int duePaisa,

    /// The `issued_on` of the oldest unsettled invoice. A `date`.
    @NullablePlainDateConverter() DateTime? oldestDueOn,

    /// Days since [oldestDueOn], measured in Postgres against the org's own
    /// today. Not recomputed on the device.
    int? ageDays,

    /// The ageing bucket the report assigned. Free text from the function,
    /// not a Postgres enum, so it is carried as a string rather than
    /// pretending to be one.
    String? bucket,
  }) = _ArrearsRow;

  factory ArrearsRow.fromJson(Map<String, dynamic> json) =>
      _$ArrearsRowFromJson(json);
}
