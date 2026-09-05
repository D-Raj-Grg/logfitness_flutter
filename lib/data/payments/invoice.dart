// Mirrors `public.invoices`. See
// `logfitness_saas/supabase/migrations/20260905120400_invoices_and_payments.sql`.
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';

part 'invoice.freezed.dart';
part 'invoice.g.dart';

@freezed
abstract class Invoice with _$Invoice {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Invoice({
    required String id,
    required String orgId,
    required String branchId,
    required String memberId,
    String? membershipId,
    required String invoiceNo,
    // Money is integer paisa end to end. Never a double, never converted here.
    required int subtotalPaisa,
    required int discountPaisa,
    required int totalPaisa,
    // Maintained by trigger from the payments rows. The app never writes
    // this field.
    required int paidPaisa,
    // Generated column (`total_paisa - paid_paisa`, stored). Read-only —
    // the app never writes this field.
    required int duePaisa,
    required InvoiceStatus status,
    required DateTime issuedOn,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Invoice;

  factory Invoice.fromJson(Map<String, dynamic> json) =>
      _$InvoiceFromJson(json);
}
