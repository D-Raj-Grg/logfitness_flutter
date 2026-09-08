// Money in and money back out, mirroring the web console's
// `logfitness_saas/lib/db/payments.ts` function for function.
//
// Nothing here inserts into `payments` directly. Every write is an RPC that
// also moves the invoice totals in the same transaction, and financial history
// is append-only: a refund is a negative row with a reason, never an edit or a
// delete (CLAUDE.md).
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:logfitness_flutter/data/payments/invoice.dart';
import 'package:logfitness_flutter/data/payments/payment_rpc_results.dart';
import 'package:logfitness_flutter/data/payments/payment_with_collector.dart';
import 'package:logfitness_flutter/data/repository_guard.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/format/plain_date.dart';
import 'package:logfitness_flutter/supabase/supabase_providers.dart';

part 'payments_repository.g.dart';

/// A repository is the only thing that touches `supabase` (PLANNING.md §6).
///
/// RLS is the tenant boundary. The `branchIds` arguments below are the branch
/// picker, not an isolation measure: null means "every branch the policy
/// already allows", and a list narrows that further at the user's request.
class PaymentsRepository {
  const PaymentsRepository(this._client);

  final SupabaseClient _client;

  /// Payments and refunds for one member, newest first. Mirrors the console's
  /// `listPaymentsForMember`.
  ///
  /// The embedded `collector` is the desk's audit question -- "who took this?"
  /// -- answered in the same round trip rather than as a second query per row.
  Future<List<PaymentWithCollector>> listPaymentsForMember(String memberId) {
    return guardFailures(() async {
      final PostgrestList rows = await _client
          .from('payments')
          .select('*, collector:staff!payments_collected_by_fkey(full_name)')
          .eq('member_id', memberId)
          .order('paid_at', ascending: false);
      return rows.map(PaymentWithCollector.fromRow).toList();
    });
  }

  /// One member's invoices, newest first.
  ///
  /// The console keeps this in `memberships.ts` (`listInvoicesForMember`)
  /// because invoices are raised by the membership RPCs; it is offered here
  /// too because the payment screen needs an invoice to collect against and
  /// should not have to reach into another repository for it. Same query,
  /// same order -- see `MembershipsRepository.listInvoicesForMember`.
  Future<List<Invoice>> listInvoicesForMember(String memberId) {
    return guardFailures(() async {
      final PostgrestList rows = await _client
          .from('invoices')
          .select('*')
          .eq('member_id', memberId)
          .order('issued_on', ascending: false)
          .order('created_at', ascending: false);
      return rows
          .map((Map<String, dynamic> row) => Invoice.fromJson(row))
          .toList();
    });
  }

  /// Takes money against an invoice. Mirrors the console's `recordPayment`.
  ///
  /// An RPC, not an insert: the function reads the invoice's org, branch,
  /// member and membership so the payment cannot be filed against the wrong
  /// one, refuses an overpayment, and stamps the collector from the caller's
  /// own claims. The invoice's `paid_paisa`, `due_paisa` and `status` follow
  /// by trigger and come back in the result.
  Future<RecordPaymentResult> recordPayment({
    required String invoiceId,
    required int amountPaisa,
    PaymentMethod method = PaymentMethod.cash,
    String? referenceNo,
    String? notes,
  }) {
    return guardFailures(() async {
      final Map<String, dynamic> result =
          await _client.rpc<Map<String, dynamic>>(
        'record_payment',
        params: rpcParams(<String, dynamic>{
          'p_invoice_id': invoiceId,
          // Integer paisa. A rupee amount typed at the desk is converted once,
          // by `toPaisa`, before it ever reaches this method.
          'p_amount_paisa': amountPaisa,
          'p_method': method.toDb(),
          'p_reference_no': referenceNo,
          'p_notes': notes,
        }),
      );
      return RecordPaymentResult.fromJson(result);
    });
  }

  /// Gives money back. Mirrors the console's `refundPayment`.
  ///
  /// The reason is required by the function. A null [method] means "back the
  /// way it came" -- the RPC defaults to the original payment's method, which
  /// is why it is omitted rather than defaulted to cash here.
  Future<RefundPaymentResult> refundPayment({
    required String paymentId,
    required int amountPaisa,
    required String reason,
    PaymentMethod? method,
    String? referenceNo,
  }) {
    return guardFailures(() async {
      final Map<String, dynamic> result =
          await _client.rpc<Map<String, dynamic>>(
        'refund_payment',
        params: rpcParams(<String, dynamic>{
          'p_payment_id': paymentId,
          // Passed positive; the function writes the row negative.
          'p_amount_paisa': amountPaisa,
          'p_reason': reason,
          'p_method': method?.toDb(),
          'p_reference_no': referenceNo,
        }),
      );
      return RefundPaymentResult.fromJson(result);
    });
  }

  /// A payment that was recorded but never received. Mirrors the console's
  /// `reversePayment`.
  ///
  /// Mechanically a refund -- a negative row the invoice totals follow
  /// straight back into a due -- but its own `payment_kind`, so the collection
  /// sheet can tell money given back from money that never arrived. Owner and
  /// manager only; the RPC enforces that and a front desk gets a `42501` that
  /// this layer surfaces rather than swallows.
  ///
  /// A null [amountPaisa] takes the whole entry back
  /// (`20260908110000_reverse_payment_in_part.sql` added the partial case).
  Future<ReversePaymentResult> reversePayment({
    required String paymentId,
    required String reason,
    int? amountPaisa,
  }) {
    return guardFailures(() async {
      final Map<String, dynamic> result =
          await _client.rpc<Map<String, dynamic>>(
        'reverse_payment',
        params: rpcParams(<String, dynamic>{
          'p_payment_id': paymentId,
          'p_reason': reason,
          'p_amount_paisa': amountPaisa,
        }),
      );
      return ReversePaymentResult.fromJson(result);
    });
  }

  /// The drawer sheet: one row per branch, collector, method and kind.
  /// Mirrors the console's `dailyCollection`.
  ///
  /// [on] is a `date` and defaults, inside the function, to the org's today.
  /// Omitting it is deliberately not the same as sending the device's date:
  /// a phone in the wrong timezone would otherwise close the wrong day.
  Future<List<DailyCollectionRow>> dailyCollection({
    DateTime? on,
    List<String>? branchIds,
  }) {
    return guardFailures(() async {
      final List<dynamic> rows = await _client.rpc<List<dynamic>>(
        'daily_collection',
        params: rpcParams(<String, dynamic>{
          'p_on': on == null ? null : plainDateToWire(on),
          'p_branch_ids': branchIds,
        }),
      );
      return rows
          .map((dynamic row) =>
              DailyCollectionRow.fromJson(row as Map<String, dynamic>))
          .toList();
    });
  }

  /// Members with money outstanding, aged. Mirrors the console's
  /// `arrearsReport`.
  Future<List<ArrearsRow>> arrearsReport({List<String>? branchIds}) {
    return guardFailures(() async {
      final List<dynamic> rows = await _client.rpc<List<dynamic>>(
        'arrears_report',
        params: rpcParams(<String, dynamic>{'p_branch_ids': branchIds}),
      );
      return rows
          .map((dynamic row) => ArrearsRow.fromJson(row as Map<String, dynamic>))
          .toList();
    });
  }
}

@riverpod
PaymentsRepository paymentsRepository(Ref ref) {
  return PaymentsRepository(ref.watch(supabaseClientProvider));
}
