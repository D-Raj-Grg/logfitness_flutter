// Reads for the printed documents, mirroring
// `logfitness_saas/lib/db/documents.ts`.
//
// One nested select per document so the member, the selling branch and the
// org letterhead arrive as one consistent snapshot. Every joined table is
// org-wide readable for staff except `payments`, whose select policy is
// branch-scoped: a manager outside the selling branch gets an empty payments
// list on an invoice that is genuinely paid. Never infer "unpaid" from it --
// the invoice's own paid and due columns are the truth.
//
// Any signed-in staff member may read these (the web print routes only
// `requireStaff`); RLS is the tenant boundary, not anything here.
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:logfitness_flutter/data/documents/document_models.dart';
import 'package:logfitness_flutter/data/repository_guard.dart';
import 'package:logfitness_flutter/supabase/supabase_providers.dart';

part 'documents_repository.g.dart';

const String _orgLetterhead =
    'name, legal_name, address, phone, email, '
    'pan_no, tax_note, invoice_terms, logo_path, currency, timezone';

const String _memberFields = 'member_code, full_name, phone, email, address';

const String _branchFields = 'name, address, phone';

const String _invoiceSelect =
    '''
      *,
      member:members!invoices_member_fkey($_memberFields),
      membership:memberships!invoices_membership_fkey(
        plan_name, plan_type, start_date, end_date, sessions_total,
        price_paisa, signup_fee_paisa, signup_fee_waived_paisa, discount_paisa,
        previous_membership_id,
        seller:staff!memberships_sold_by_fkey(full_name)
      ),
      branch:branches!invoices_branch_fkey($_branchFields),
      org:orgs!invoices_org_id_fkey($_orgLetterhead),
      payments:payments!payments_invoice_fkey(
        id, kind, amount_paisa, method, reference_no, paid_at,
        collector:staff!payments_collected_by_fkey(full_name)
      )
    ''';

const String _paymentSelect =
    '''
      *,
      collector:staff!payments_collected_by_fkey(full_name),
      member:members!payments_member_fkey($_memberFields),
      membership:memberships!payments_membership_fkey(
        plan_name, plan_type, start_date, end_date, signup_fee_waived_paisa
      ),
      invoice:invoices!payments_invoice_fkey(
        invoice_no, total_paisa, paid_paisa, due_paisa, status,
        discount_paisa, discount_reason, discount_note
      ),
      branch:branches!payments_branch_fkey($_branchFields),
      org:orgs!payments_org_id_fkey($_orgLetterhead)
    ''';

class DocumentsRepository {
  const DocumentsRepository(this._client);

  final SupabaseClient _client;

  /// The invoice with everything it prints, or null when RLS hides it.
  Future<InvoiceForPrint?> invoiceForPrint(String invoiceId) {
    return guardFailures(() async {
      final Map<String, dynamic>? row = await _client
          .from('invoices')
          .select(_invoiceSelect)
          .eq('id', invoiceId)
          .maybeSingle();
      return row == null ? null : InvoiceForPrint.fromRow(row);
    });
  }

  /// The payment (or refund, or reversal) with everything a receipt prints,
  /// or null when RLS hides it.
  Future<PaymentForPrint?> paymentForPrint(String paymentId) {
    return guardFailures(() async {
      final Map<String, dynamic>? row = await _client
          .from('payments')
          .select(_paymentSelect)
          .eq('id', paymentId)
          .maybeSingle();
      return row == null ? null : PaymentForPrint.fromRow(row);
    });
  }
}

@riverpod
DocumentsRepository documentsRepository(Ref ref) {
  return DocumentsRepository(ref.watch(supabaseClientProvider));
}
