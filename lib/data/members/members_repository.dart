// The member half of the staff data layer, mirroring the web console's
// `logfitness_saas/lib/db/members.ts` function for function so the two
// surfaces cannot drift into disagreeing about what a member list means.
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:logfitness_flutter/data/members/member.dart';
import 'package:logfitness_flutter/data/members/member_list_query.dart';
import 'package:logfitness_flutter/data/members/member_overview.dart';
import 'package:logfitness_flutter/data/members/member_rpc_results.dart';
import 'package:logfitness_flutter/data/repository_guard.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/format/plain_date.dart';
import 'package:logfitness_flutter/supabase/supabase_providers.dart';

part 'members_repository.g.dart';

/// Counts behind the dashboard tiles. Mirrors the console's
/// `memberStatusCounts` return shape.
class MemberStatusCounts {
  const MemberStatusCounts({
    required this.active,
    required this.expiring,
    required this.expired,
    required this.frozen,
    required this.withDues,
  });

  final int active;

  /// Active *and* within seven days of expiry -- a subset of [active], not a
  /// sixth disjoint bucket. Summing these five double-counts on purpose.
  final int expiring;
  final int expired;
  final int frozen;
  final int withDues;
}

/// Strips the characters PostgREST reads as structure out of a search term.
///
/// `%` and `_` are `ilike` wildcards; `,`, `(` and `)` separate and group the
/// clauses inside an `or()`. A member called "Ram (Sr)" typed into the box
/// would otherwise be a malformed filter, not a failed search. Mirrors the
/// console's `term.replace(/[%_,()]/g, ' ').trim()`.
String sanitizeSearchTerm(String term) =>
    term.trim().replaceAll(RegExp(r'[%_,()]'), ' ').trim();

/// The `or()` clause the desk's single search box expands to: a phone prefix,
/// a member-code prefix, or any part of the name. Anchored for the first two
/// because a phone number is read left to right and a prefix match can use the
/// index; unanchored for the name because people are told surnames.
String _searchFilter(String cleaned) =>
    'phone.ilike.$cleaned%,'
    'member_code.ilike.$cleaned%,'
    'full_name.ilike.%$cleaned%';

/// A repository is the only thing that touches `supabase` (PLANNING.md §6).
/// Controllers call repositories; widgets call controllers.
///
/// RLS is the tenant boundary, not this class. Every query here relies on
/// the session's Postgres policies to scope rows to the caller's org; this
/// repository never adds a client-side `org_id` filter. A query that would
/// return rows across tenants if a client-side filter were removed is a
/// policy bug to fix upstream, not something to patch here.
///
/// The `branchIds` argument that several methods take is **not** that. It is
/// the branch *picker* -- null means "every branch RLS already allows", which
/// for an owner is the whole chain; a list is a narrowing the user asked for.
/// Removing it would widen the view to what the policy permits, never past it.
class MembersRepository {
  const MembersRepository(this._client);

  final SupabaseClient _client;

  static const String _table = 'members';
  static const String _overview = 'member_overview';

  /// Server-side search, filter and pagination over `member_overview`.
  /// Mirrors the console's `listMembers`.
  ///
  /// Archived members are excluded unless [MemberListFilter.archived] asks
  /// for them. That default is the point of the archive: the rows stay
  /// readable and restorable, but a search that ignored `archived_at` would
  /// hand the desk back the people it deliberately put away. Callers wanting
  /// them alongside everyone else do not get to opt in half way -- the
  /// console has exactly one archived view and so does this.
  Future<MemberListResult> listMembers(
    MemberListQuery query, {
    List<String>? branchIds,
  }) {
    return guardFailures(() async {
      PostgrestFilterBuilder<PostgrestList> request = _client
          .from(_overview)
          .select('*');

      request = query.status == MemberListFilter.archived
          ? request.not('archived_at', 'is', null)
          : request.isFilter('archived_at', null);

      final String cleaned = sanitizeSearchTerm(query.q);
      if (cleaned.isNotEmpty) {
        request = request.or(_searchFilter(cleaned));
      }

      if (branchIds != null) {
        request = request.inFilter('home_branch_id', branchIds);
      }

      switch (query.status) {
        case null:
        case MemberListFilter.archived:
          break;
        case MemberListFilter.active:
        case MemberListFilter.expired:
        case MemberListFilter.frozen:
        case MemberListFilter.left:
          request = request.eq('status', query.status!.wire);
        case MemberListFilter.expiring:
          request = request.eq('status', 'active').lte('days_to_expiry', 7);
        case MemberListFilter.dues:
          request = request.gt('due_paisa', 0);
      }

      final int from = (query.page - 1) * query.pageSize;
      final int to = from + query.pageSize - 1;

      final PostgrestResponse<PostgrestList> response = await request
          .order('full_name')
          // Names repeat -- duplicates, and common names in this market.
          // Without a unique final sort key the page boundary is undefined,
          // so a member can appear on two pages while another appears on
          // none.
          .order('id')
          .range(from, to)
          .count(CountOption.exact);

      return MemberListResult(
        rows: response.data
            .map((Map<String, dynamic> row) => MemberOverview.fromJson(row))
            .toList(),
        total: response.count,
        page: query.page,
        pageSize: query.pageSize,
      );
    });
  }

  /// The check-in box. Deliberately not [listMembers]: the desk types a phone
  /// number and wants a handful of hits back in one round trip, not a
  /// paginated page with a count query attached to it.
  Future<List<MemberOverview>> searchMembersForCheckIn(
    String term, {
    int limit = 8,
  }) {
    return guardFailures(() async {
      final String cleaned = sanitizeSearchTerm(term);
      if (cleaned.isEmpty) {
        return const <MemberOverview>[];
      }

      final PostgrestList rows = await _client
          .from(_overview)
          .select('*')
          .isFilter('archived_at', null)
          .or(_searchFilter(cleaned))
          .order('full_name')
          .limit(limit);

      return rows
          .map((Map<String, dynamic> row) => MemberOverview.fromJson(row))
          .toList();
    });
  }

  /// Fetches one member by primary key, or `null` if RLS hides it or it
  /// does not exist. The two cases are indistinguishable by design — that
  /// is what row-level security means. Mirrors the console's `getMember`.
  Future<Member?> fetchById(String id) {
    return guardFailures(() async {
      final Map<String, dynamic>? row = await _client
          .from(_table)
          .select()
          .eq('id', id)
          .maybeSingle();
      if (row == null) {
        return null;
      }
      return Member.fromJson(row);
    });
  }

  /// The same member, read through the view -- plan, expiry and dues
  /// included. Mirrors the console's `getMemberOverview`.
  Future<MemberOverview?> fetchOverviewById(String id) {
    return guardFailures(() async {
      final Map<String, dynamic>? row = await _client
          .from(_overview)
          .select('*')
          .eq('id', id)
          .maybeSingle();
      if (row == null) {
        return null;
      }
      return MemberOverview.fromJson(row);
    });
  }

  /// Searches members by phone (the identity anchor — see PLANNING.md §5).
  ///
  /// The `ilike` filter below is presentation-side narrowing only: it never
  /// substitutes for tenant isolation. The set of rows Postgres is willing
  /// to return is already bounded by RLS before this filter is applied.
  Future<List<Member>> searchByPhone(String phone) {
    return guardFailures(() async {
      final PostgrestList rows = await _client
          .from(_table)
          .select()
          .ilike('phone', '%${sanitizeSearchTerm(phone)}%');
      return rows
          .map((Map<String, dynamic> row) => Member.fromJson(row))
          .toList();
    });
  }

  /// Registration and the optional first sale, in one transaction. Mirrors
  /// the console's `registerMember`.
  ///
  /// One RPC, never an insert followed by a renewal: `register_member`
  /// delegates the sale to `renew_membership` inside the same transaction and
  /// re-raises anything it throws, so a refused sale registers nobody. Two
  /// client calls would leave a member row behind whenever the second failed
  /// -- a person in the system who was never actually signed up.
  ///
  /// `org_id`, `member_code`, `joined_on`, `created_by` and `status` are all
  /// set by the function and its triggers. None of them is an argument, and
  /// `status` in particular is trigger-derived and must never be written.
  ///
  /// The raised error carries a `hint` of `'member'` or `'sale'` saying which
  /// half refused. PostgREST does not surface `hint` on a `PostgrestException`,
  /// so a caller that needs to land the message on the right field must match
  /// on the message text -- noted here rather than silently lost.
  ///
  /// See
  /// `logfitness_saas/supabase/migrations/20260907120100_register_member_start_date.sql`;
  /// that migration dropped the 15-argument signature rather than leaving it
  /// beside the 16-argument one, because two overloads differing only by a
  /// defaulted trailing argument make a named PostgREST call ambiguous.
  Future<RegisterMemberResult> registerMember({
    required String fullName,
    required String phone,
    required String homeBranchId,
    String? email,
    DateTime? dateOfBirth,
    MemberGender? gender,
    String? address,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? notes,
    // Everything below is the optional sale. A null plan registers only, and
    // the RPC refuses money or a start date without one.
    String? planId,
    int discountPaisa = 0,
    int amountPaidPaisa = 0,
    PaymentMethod method = PaymentMethod.cash,
    String? referenceNo,
    /// Sale only. Null lets the RPC resolve it, which for a member with no
    /// prior membership is the org's today -- not the device's.
    DateTime? startDate,
  }) {
    return guardFailures(() async {
      final Map<String, dynamic> result = await _client.rpc<Map<String, dynamic>>(
        'register_member',
        params: rpcParams(<String, dynamic>{
          'p_full_name': fullName,
          'p_phone': phone,
          'p_home_branch_id': homeBranchId,
          'p_email': email,
          // `date`, not `timestamptz`. A full ISO timestamp here shifts the
          // stored day by the org's offset -- see plain_date.dart.
          'p_date_of_birth': dateOfBirth == null
              ? null
              : plainDateToWire(dateOfBirth),
          'p_gender': gender?.toDb(),
          'p_address': address,
          'p_emergency_contact_name': emergencyContactName,
          'p_emergency_contact_phone': emergencyContactPhone,
          'p_notes': notes,
          'p_plan_id': planId,
          'p_discount_paisa': discountPaisa,
          'p_amount_paid_paisa': amountPaidPaisa,
          'p_method': method.toDb(),
          'p_reference_no': referenceNo,
          'p_start_date': startDate == null
              ? null
              : plainDateToWire(startDate),
        }),
      );
      return RegisterMemberResult.fromJson(result);
    });
  }

  /// Edits the member's own details. Mirrors the console's `updateMember`.
  ///
  /// A plain single-table update, not an RPC, because nothing else moves with
  /// it -- the multi-table rule in CLAUDE.md is about writes that span
  /// memberships, invoices and payments.
  ///
  /// The argument list is the console's `memberSchema` and nothing more. In
  /// particular there is no `status`: it is trigger-derived, and so are
  /// `member_code`, `joined_on` and `left_on` (the last moves only through
  /// `set_member_left` / `reactivate_member`). Passing an explicit null for
  /// an optional field clears it, which is why they are all sent rather than
  /// compacted away.
  Future<void> updateMember({
    required String memberId,
    required String fullName,
    required String phone,
    required String homeBranchId,
    String? email,
    DateTime? dateOfBirth,
    MemberGender? gender,
    String? address,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? notes,
    required bool notificationsOptOut,
  }) {
    return guardFailures(() async {
      await _client
          .from(_table)
          .update(<String, dynamic>{
            'full_name': fullName,
            'phone': phone,
            'home_branch_id': homeBranchId,
            'email': email,
            'date_of_birth': dateOfBirth == null
                ? null
                : plainDateToWire(dateOfBirth),
            'gender': gender?.toDb(),
            'address': address,
            'emergency_contact_name': emergencyContactName,
            'emergency_contact_phone': emergencyContactPhone,
            'notes': notes,
            'notifications_opt_out': notificationsOptOut,
          })
          .eq('id', memberId);
    });
  }

  /// Invites a member to the mobile app. Mirrors the console's
  /// `inviteMemberToApp`.
  ///
  /// A single RPC, not a column update, because `invite_member()` also decides
  /// -- under the caller's own RLS -- whether this member may still be invited
  /// and who gets credited as the inviter. It reads the staff id off the
  /// claims (`20260905150500_invite_member_reads_the_staff_id_claim.sql`) and
  /// returns the member id it invited.
  Future<String> inviteMemberToApp({
    required String memberId,
    required String email,
  }) {
    return guardFailures(() async {
      final String invited = await _client.rpc<String>(
        'invite_member',
        params: <String, dynamic>{
          'p_member_id': memberId,
          'p_email': email,
        },
      );
      return invited;
    });
  }

  /// Hides a member from every default list without touching a single
  /// membership, invoice or payment. Mirrors the console's `archiveMember`.
  ///
  /// An RPC because the audit trail (`archived_by` off the caller's claims)
  /// and the "already archived" rule belong next to the write. The function
  /// also raises `insufficient_privilege` explicitly when RLS matched nothing,
  /// rather than reporting an empty update as success -- see
  /// `20260907120000_member_archive.sql`.
  Future<ArchiveMemberResult> archiveMember(String memberId, {String? reason}) {
    return guardFailures(() async {
      final Map<String, dynamic> result =
          await _client.rpc<Map<String, dynamic>>(
        'archive_member',
        params: rpcParams(<String, dynamic>{
          'p_member_id': memberId,
          'p_reason': reason,
        }),
      );
      return ArchiveMemberResult.fromJson(result);
    });
  }

  /// Puts an archived member back in the working list. Mirrors the console's
  /// `restoreMember`.
  Future<MemberStatusResult> restoreMember(String memberId) {
    return guardFailures(() async {
      final Map<String, dynamic> result =
          await _client.rpc<Map<String, dynamic>>(
        'restore_member',
        params: <String, dynamic>{'p_member_id': memberId},
      );
      return MemberStatusResult.fromJson(result);
    });
  }

  /// The real delete, and the reason archiving exists. The row goes, and the
  /// cascade takes its memberships, invoices and payments with it. Mirrors the
  /// console's `deleteMember`.
  ///
  /// No RPC: the "owners delete members" policy is the whole rule, so a
  /// non-owner's delete simply matches nothing. That is why this returns
  /// whether a row came back rather than trusting a silent success -- an empty
  /// delete and a permitted one are the same HTTP 200.
  Future<bool> deleteMember(String memberId) {
    return guardFailures(() async {
      final PostgrestList deleted = await _client
          .from(_table)
          .delete()
          .eq('id', memberId)
          .select('id');
      return deleted.isNotEmpty;
    });
  }

  /// Counts for the dashboard tiles. Mirrors the console's
  /// `memberStatusCounts`.
  ///
  /// Five head requests rather than one grouped query, run concurrently: the
  /// buckets overlap (`expiring` is a subset of `active`) so no single
  /// `group by` produces them, and a `head: true` count moves no rows.
  Future<MemberStatusCounts> memberStatusCounts({List<String>? branchIds}) {
    return guardFailures(() async {
      PostgrestFilterBuilder<int> base() {
        PostgrestFilterBuilder<int> request = _client
            .from(_overview)
            .count(CountOption.exact)
            .isFilter('archived_at', null);
        if (branchIds != null) {
          request = request.inFilter('home_branch_id', branchIds);
        }
        return request;
      }

      final List<int> counts = await Future.wait(<Future<int>>[
        base().eq('status', 'active'),
        base().eq('status', 'active').lte('days_to_expiry', 7),
        base().eq('status', 'expired'),
        base().eq('status', 'frozen'),
        base().gt('due_paisa', 0),
      ]);

      return MemberStatusCounts(
        active: counts[0],
        expiring: counts[1],
        expired: counts[2],
        frozen: counts[3],
        withDues: counts[4],
      );
    });
  }
}

@riverpod
MembersRepository membersRepository(Ref ref) {
  return MembersRepository(ref.watch(supabaseClientProvider));
}
