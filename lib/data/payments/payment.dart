// Mirrors `public.payments`. See
// `logfitness_saas/supabase/migrations/20260905120400_invoices_and_payments.sql`.
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';

part 'payment.freezed.dart';
part 'payment.g.dart';

@freezed
abstract class Payment with _$Payment {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Payment({
    required String id,
    required String orgId,
    required String branchId,
    required String memberId,
    String? membershipId,
    String? invoiceId,
    required PaymentKind kind,
    // Money is integer paisa end to end. Never a double, never converted
    // here. Negative for refunds — summing this column gives net cash.
    required int amountPaisa,
    required PaymentMethod method,
    String? referenceNo,
    String? reason,
    String? collectedBy,
    required DateTime paidAt,
    String? notes,
    required DateTime createdAt,
  }) = _Payment;

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);
}
