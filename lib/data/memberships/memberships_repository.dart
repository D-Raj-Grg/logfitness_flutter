// Everything that changes a membership, mirroring the web console's
// `logfitness_saas/lib/db/memberships.ts` function for function.
//
// Every write below is a single Postgres RPC, so the membership, its invoice
// and any payment either all land or none do (CLAUDE.md: "Multi-table writes
// go through the existing Postgres RPCs"). These are thin, typed wrappers --
// the selling rules, the freeze arithmetic and the immutability guards live in
// `logfitness_saas/supabase/migrations/20260905120700_membership_rpcs.sql` and
// are not restated here.
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:logfitness_flutter/data/members/member_rpc_results.dart';
import 'package:logfitness_flutter/data/memberships/membership.dart';
import 'package:logfitness_flutter/data/memberships/membership_rpc_results.dart';
import 'package:logfitness_flutter/data/payments/invoice.dart';
import 'package:logfitness_flutter/data/repository_guard.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/format/plain_date.dart';
import 'package:logfitness_flutter/supabase/supabase_providers.dart';

part 'memberships_repository.g.dart';

/// A repository is the only thing that touches `supabase` (PLANNING.md §6).
///
/// RLS is the tenant boundary. The reads below filter by `member_id` because
/// that is what the caller asked for, never as an isolation measure.
class MembershipsRepository {
  const MembershipsRepository(this._client);

  final SupabaseClient _client;

  /// Newest first. This is the history strip on the member profile. Mirrors
  /// the console's `listMembershipsForMember`.
  ///
  /// Financial history is append-only: a renewal inserts a new row rather than
  /// extending the old one, so this list is the record of what was sold and
  /// when, not a mutable current state.
  Future<List<Membership>> listMembershipsForMember(String memberId) {
    return guardFailures(() async {
      final PostgrestList rows = await _client
          .from('memberships')
          .select('*')
          .eq('member_id', memberId)
          .order('start_date', ascending: false)
          // Two memberships can share a start date -- a same-day correction,
          // or a pack sold beside a time plan. `created_at` is the tiebreak
          // that keeps the strip in the order things actually happened.
          .order('created_at', ascending: false);
      return rows
          .map((Map<String, dynamic> row) => Membership.fromJson(row))
          .toList();
    });
  }

  /// Mirrors the console's `listInvoicesForMember`. Lives here rather than in
  /// the payments repository because the console puts it here: invoices are
  /// raised by the membership RPCs, and the profile reads them beside the
  /// membership strip.
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

  /// Sells a plan: a new membership row, its invoice, and a payment if money
  /// changed hands. Mirrors the console's `renewMembership`.
  ///
  /// One RPC because it is one transaction. `renew_membership` owns the
  /// joining-fee rule, the active-plan check, the discount and payment
  /// ceilings, invoice numbering and the payment row; `register_member`
  /// delegates to this same function rather than keeping a second copy of the
  /// selling rules.
  ///
  /// A null [startDate] lets the RPC resolve it -- which is the day after the
  /// current membership expires, or the org's today for a member with none.
  /// That is a decision the database makes with `org_today`, and the device
  /// clock has no business overriding it.
  Future<RenewMembershipResult> renewMembership({
    required String memberId,
    required String planId,
    required String branchId,
    DateTime? startDate,
    int discountPaisa = 0,
    int amountPaidPaisa = 0,
    PaymentMethod method = PaymentMethod.cash,
    String? referenceNo,
    String? notes,
    /// Required by the RPC whenever [discountPaisa] is above zero, and refused
    /// when it is zero -- see `20260910130100_discount_reason_rpcs.sql`.
    /// Sending a discount without one raises `check_violation`.
    DiscountReason? discountReason,
    /// Required when [discountReason] is `other`, meaningless otherwise.
    /// Capped at 120 characters by the column.
    String? discountNote,
  }) {
    return guardFailures(() async {
      final Map<String, dynamic> result =
          await _client.rpc<Map<String, dynamic>>(
        'renew_membership',
        params: rpcParams(<String, dynamic>{
          'p_member_id': memberId,
          'p_plan_id': planId,
          'p_branch_id': branchId,
          // `date`, not `timestamptz` -- see plain_date.dart.
          'p_start_date': startDate == null
              ? null
              : plainDateToWire(startDate),
          'p_discount_paisa': discountPaisa,
          'p_amount_paid_paisa': amountPaidPaisa,
          'p_method': method.toDb(),
          'p_reference_no': referenceNo,
          'p_notes': notes,
          'p_discount_reason': discountReason?.toDb(),
          'p_discount_note': discountNote,
        }),
      );
      return RenewMembershipResult.fromJson(result);
    });
  }

  /// Pauses an active membership. Mirrors the console's `freezeMembership`.
  ///
  /// The RPC refuses anything that is not `active`, and stamps `frozen_on`
  /// from `org_today(org_id)` -- the freeze starts on the gym's day, not the
  /// phone's.
  Future<FreezeMembershipResult> freezeMembership(
    String membershipId, {
    String? notes,
  }) {
    return guardFailures(() async {
      final Map<String, dynamic> result =
          await _client.rpc<Map<String, dynamic>>(
        'freeze_membership',
        params: rpcParams(<String, dynamic>{
          'p_membership_id': membershipId,
          'p_notes': notes,
        }),
      );
      return FreezeMembershipResult.fromJson(result);
    });
  }

  /// Resumes a frozen membership and pushes the end date out by however long
  /// the freeze lasted. Mirrors the console's `unfreezeMembership`.
  Future<UnfreezeMembershipResult> unfreezeMembership(String membershipId) {
    return guardFailures(() async {
      final Map<String, dynamic> result =
          await _client.rpc<Map<String, dynamic>>(
        'unfreeze_membership',
        params: <String, dynamic>{'p_membership_id': membershipId},
      );
      return UnfreezeMembershipResult.fromJson(result);
    });
  }

  /// Ends a membership early, with a reason. Mirrors the console's
  /// `cancelMembership`.
  ///
  /// The reason is required by the function, not just by the form: a
  /// cancellation with no recorded reason is refused with `check_violation`.
  /// Nothing financial is deleted -- the invoice and its payments stay, and a
  /// refund is a separate, additive act.
  Future<MembershipStatusResult> cancelMembership(
    String membershipId,
    String reason,
  ) {
    return guardFailures(() async {
      final Map<String, dynamic> result =
          await _client.rpc<Map<String, dynamic>>(
        'cancel_membership',
        params: <String, dynamic>{
          'p_membership_id': membershipId,
          'p_reason': reason,
        },
      );
      return MembershipStatusResult.fromJson(result);
    });
  }

  /// Moves a membership's window. Mirrors the console's
  /// `adjustMembershipDates`.
  ///
  /// [endDate] is the one RPC argument that is passed as an explicit null
  /// rather than omitted: a session pack sold without a validity window
  /// genuinely has no end date, and omitting the key would mean "keep what is
  /// there" instead of "there is none". Both dates go over the wire date-only.
  ///
  /// See
  /// `logfitness_saas/supabase/migrations/20260907120400_adjust_membership_dates.sql`.
  Future<AdjustMembershipDatesResult> adjustMembershipDates({
    required String membershipId,
    required DateTime startDate,
    required DateTime? endDate,
    required String reason,
  }) {
    return guardFailures(() async {
      final Map<String, dynamic> result =
          await _client.rpc<Map<String, dynamic>>(
        'adjust_membership_dates',
        params: <String, dynamic>{
          'p_membership_id': membershipId,
          'p_start_date': plainDateToWire(startDate),
          'p_end_date': endDate == null ? null : plainDateToWire(endDate),
          'p_reason': reason,
        },
      );
      return AdjustMembershipDatesResult.fromJson(result);
    });
  }

  /// Marks the member as having left. Mirrors the console's `setMemberLeft`.
  ///
  /// This writes `left_on` and `left_reason`; the `left` status follows from
  /// the derivation trigger, which is why the RPC echoes the status back
  /// rather than the caller assuming it. `members.status` is never written
  /// from here (CLAUDE.md).
  ///
  /// [leftOn] is an argument the console does not pass. The live function
  /// takes `p_left_on date default null` and falls back to
  /// `org_today(org_id)`, so omitting it behaves exactly as the console does
  /// while still letting the desk record a departure it is logging late.
  Future<MemberStatusResult> setMemberLeft(
    String memberId, {
    String? reason,
    DateTime? leftOn,
  }) {
    return guardFailures(() async {
      final Map<String, dynamic> result =
          await _client.rpc<Map<String, dynamic>>(
        'set_member_left',
        params: rpcParams(<String, dynamic>{
          'p_member_id': memberId,
          'p_reason': reason,
          'p_left_on': leftOn == null ? null : plainDateToWire(leftOn),
        }),
      );
      return MemberStatusResult.fromJson(result);
    });
  }

  /// Clears `left_on` and `left_reason` so the derivation trigger can put the
  /// member back to whatever their memberships say they are. Mirrors the
  /// console's `reactivateMember`.
  Future<MemberStatusResult> reactivateMember(String memberId) {
    return guardFailures(() async {
      final Map<String, dynamic> result =
          await _client.rpc<Map<String, dynamic>>(
        'reactivate_member',
        params: <String, dynamic>{'p_member_id': memberId},
      );
      return MemberStatusResult.fromJson(result);
    });
  }
}

@riverpod
MembershipsRepository membershipsRepository(Ref ref) {
  return MembershipsRepository(ref.watch(supabaseClientProvider));
}
