// The walk-in log. Mirrors the web console's `logfitness_saas/lib/db/visitors.ts`
// function for function, against the same table and the same RPC --
// `logfitness_saas/supabase/migrations/20260908110100_visitors.sql`.
//
// Parity is the point, not a coincidence: the desk staff who log a walk-in on
// a phone and the manager who works the callback list on the console are
// looking at one log. If the two clients disagree about what "open" means, or
// about which write moves a visitor to `converted`, the log stops being a
// single record of who came in. Every deviation from the TypeScript is
// commented where it happens.
//
// A repository is the only thing that touches `supabase` (PLANNING.md §6).
// Controllers call repositories; widgets call controllers.
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:logfitness_flutter/data/visitors/visitor.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/domain/format/plain_date.dart';
import 'package:logfitness_flutter/supabase/supabase_providers.dart';

part 'visitors_repository.g.dart';

/// The status filter the list offers. Mirrors the console's
/// `status?: VisitorStatus | 'open'`.
///
/// [open] is the working view -- everyone the desk still owes a callback --
/// and it must expand to exactly the two statuses carried by the partial
/// index `visitors_open_idx` upstream, or the query stops using it.
enum VisitorStatusFilter {
  open(<VisitorStatus>[VisitorStatus.isNew, VisitorStatus.contacted]),
  isNew(<VisitorStatus>[VisitorStatus.isNew]),
  contacted(<VisitorStatus>[VisitorStatus.contacted]),
  converted(<VisitorStatus>[VisitorStatus.converted]),
  lost(<VisitorStatus>[VisitorStatus.lost]);

  const VisitorStatusFilter(this.statuses);

  /// The `visitor_status` values this filter selects, in wire form.
  final List<VisitorStatus> statuses;

  List<String> toDb() =>
      statuses.map((status) => status.toDb()).toList(growable: false);
}

/// What the list is narrowed to. Mirrors `VisitorListFilter` in
/// `logfitness_saas/lib/db/visitors.ts`.
///
/// None of these are a security boundary. RLS already bounds the rows to the
/// caller's org before any of this is applied -- see [VisitorsRepository].
class VisitorListFilter {
  const VisitorListFilter({
    this.branchIds,
    this.status,
    this.kind,
    this.query,
    this.visitedFrom,
    this.visitedTo,
    this.page = 1,
    this.pageSize = 20,
  });

  /// `null` = every branch RLS allows, which is what an owner sees by
  /// default. An empty list is a real filter that matches nothing, so it is
  /// not treated as "all" -- the branch switcher must never silently widen.
  final List<String>? branchIds;

  final VisitorStatusFilter? status;
  final VisitorKind? kind;

  /// Free text over name and phone.
  final String? query;

  /// Date-only bounds on `visited_on`, inclusive.
  ///
  /// Not in the console's filter: the phone list is a day's work at a
  /// counter ("who walked in this week"), where the console pages a whole
  /// log. Both go over the wire through [plainDateToWire], never as an
  /// instant -- `visited_on` is a `date` and an offset would move the day.
  final DateTime? visitedFrom;
  final DateTime? visitedTo;

  final int page;
  final int pageSize;
}

/// One page of the log. Mirrors `VisitorListResult`.
///
/// [total] counts the whole filtered set, not the page, so the footer can say
/// what is being left out.
class VisitorPage {
  const VisitorPage({
    required this.rows,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  final List<Visitor> rows;
  final int total;
  final int page;
  final int pageSize;

  bool get hasMore => page * pageSize < total;
}

/// Sentinel for "do not touch this column", so that passing `null` to
/// [VisitorsRepository.updateVisitor] can mean "clear it" -- a note the desk
/// deleted and a note it did not edit are different writes, and Dart's
/// optional-null idiom cannot tell them apart on its own.
const Object visitorFieldUnchanged = Object();

/// Builds the PostgREST `or` filter for the free-text search, or `null` when
/// there is nothing to search for.
///
/// Kept as a pure function so it can be tested without a client, and written
/// character-for-character like the console's: name matches anywhere, phone
/// matches from the start, because a partial phone is typed left to right.
///
/// `%`, `_`, `,` and the parentheses are stripped rather than escaped: they
/// are the syntax of the `or` expression itself, and none of them is a
/// meaningful character in a Nepali name or a phone number.
String? visitorSearchFilter(String? term) {
  final trimmed = term?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  final escaped = trimmed.replaceAll(RegExp(r'[%_,()]'), ' ').trim();
  if (escaped.isEmpty) {
    return null;
  }
  return 'full_name.ilike.%$escaped%,phone.ilike.$escaped%';
}

/// The row a walk-in insert sends.
///
/// `visited_on` is optional although the column is not null: the
/// `set_visitor_defaults` trigger fills it from `org_today(org_id)` when it is
/// absent, which is the right answer at a counter in Kathmandu, where the
/// device clock's idea of "today" is not the org's. Sending one explicitly is
/// how the desk backdates yesterday's walk-in.
///
/// `created_by` is never sent: the same trigger takes it from
/// `jwt_staff_id()`. `status` is never sent either -- a new visitor is `new`
/// by column default, and the only other status this repository can reach is
/// through [VisitorsRepository.convertVisitor].
Map<String, dynamic> visitorInsertValues({
  required String orgId,
  required String branchId,
  required String fullName,
  required String phone,
  VisitorKind kind = VisitorKind.enquiry,
  DateTime? visitedOn,
  String? note,
  String? interestedPlanId,
}) {
  return <String, dynamic>{
    // Sent, not enforced. `is_org_member(org_id)` in the insert policy is
    // what makes a foreign org_id a `42501` instead of a cross-tenant write.
    'org_id': orgId,
    'branch_id': branchId,
    'kind': kind.toDb(),
    'full_name': fullName.trim(),
    'phone': phone.trim(),
    'note': note,
    'interested_plan_id': interestedPlanId,
    if (visitedOn != null) 'visited_on': plainDateToWire(visitedOn),
  };
}

/// The patch an edit sends. Only the columns actually passed appear in it, so
/// a screen that edits one field does not rewrite the rest of the row.
///
/// Setting `status` to [VisitorStatus.converted] throws rather than sending:
/// `visitors_converted_shape` requires `converted_member_id` and
/// `converted_at` to move with the status, and `convert_visitor` is the only
/// write that moves all three. A plain update that tried would be rejected by
/// the constraint as a `23514` -- this turns a database round trip into a
/// programming error caught at the call site, and keeps the app from ever
/// offering a half-conversion.
Map<String, dynamic> visitorUpdateValues({
  Object? fullName = visitorFieldUnchanged,
  Object? phone = visitorFieldUnchanged,
  Object? kind = visitorFieldUnchanged,
  Object? visitedOn = visitorFieldUnchanged,
  Object? note = visitorFieldUnchanged,
  Object? interestedPlanId = visitorFieldUnchanged,
  Object? status = visitorFieldUnchanged,
}) {
  if (status == VisitorStatus.converted) {
    throw const AppFailure(
      FailureKind.invalid,
      'A visitor becomes a member by registering them, not by changing their '
      'status.',
    );
  }

  final values = <String, dynamic>{};
  if (!identical(fullName, visitorFieldUnchanged)) {
    values['full_name'] = (fullName as String).trim();
  }
  if (!identical(phone, visitorFieldUnchanged)) {
    values['phone'] = (phone as String).trim();
  }
  if (!identical(kind, visitorFieldUnchanged)) {
    values['kind'] = (kind as VisitorKind).toDb();
  }
  if (!identical(visitedOn, visitorFieldUnchanged)) {
    // A `date`, never an instant: see lib/domain/format/plain_date.dart.
    values['visited_on'] = plainDateToWire(visitedOn as DateTime);
  }
  if (!identical(note, visitorFieldUnchanged)) {
    values['note'] = note as String?;
  }
  if (!identical(interestedPlanId, visitorFieldUnchanged)) {
    values['interested_plan_id'] = interestedPlanId as String?;
  }
  if (!identical(status, visitorFieldUnchanged)) {
    // Only the three non-converted statuses reach here; converted threw
    // above, and clearing the status is not a thing the column allows.
    values['status'] = (status! as VisitorStatus).toDb();
  }
  return values;
}

/// Reads and writes `public.visitors`.
///
/// **RLS is the tenant boundary, not this class.** Read is org-wide by policy
/// -- someone who enquired at one branch and walks into another must be
/// found, not logged twice -- and writes are branch-scoped by policy to the
/// branches the signed-in staff member works at. This repository therefore
/// never adds an `org_id` filter: a query that returned the right rows only
/// because of a client-side filter would be a policy bug to fix upstream
/// (CLAUDE.md, PLANNING.md §3). The `branch_id` filter in [listVisitors] is
/// the branch switcher narrowing what is shown, and nothing more.
///
/// Every method funnels its errors through [mapError] and rethrows the
/// [AppFailure]. Nothing is caught and discarded: a `42501` refusal -- staff
/// editing a visitor logged at a branch they do not cover -- must reach the
/// screen, because the alternative is the console bug of 2026-09-07 where a
/// refusal looked exactly like success.
class VisitorsRepository {
  const VisitorsRepository(this._client);

  final SupabaseClient _client;

  static const _table = 'visitors';

  /// The log, newest visit first.
  ///
  /// Branch and plan names are resolved by the caller from the lists it
  /// already holds rather than through an embed, exactly as the console does
  /// it: two composite foreign keys point at the same rows, and the join hint
  /// is a worse thing to maintain than a map.
  Future<VisitorPage> listVisitors(VisitorListFilter filter) async {
    try {
      var request = _client.from(_table).select();

      final branchIds = filter.branchIds;
      if (branchIds != null) {
        request = request.inFilter('branch_id', branchIds);
      }

      final status = filter.status;
      if (status != null) {
        // `open` expands to two statuses, so even the single-status case goes
        // through `in` -- one code path, and it matches `visitors_open_idx`.
        request = request.inFilter('status', status.toDb());
      }

      final kind = filter.kind;
      if (kind != null) {
        request = request.eq('kind', kind.toDb());
      }

      final visitedFrom = filter.visitedFrom;
      if (visitedFrom != null) {
        request = request.gte('visited_on', plainDateToWire(visitedFrom));
      }
      final visitedTo = filter.visitedTo;
      if (visitedTo != null) {
        request = request.lte('visited_on', plainDateToWire(visitedTo));
      }

      final search = visitorSearchFilter(filter.query);
      if (search != null) {
        request = request.or(search);
      }

      final from = (filter.page - 1) * filter.pageSize;
      final response = await request
          .order('visited_on', ascending: false)
          .order('created_at', ascending: false)
          // The last tiebreak is what makes paging safe: rows written in one
          // transaction share created_at, and without a unique final sort key
          // a row can land on two pages while another lands on none.
          .order('id', ascending: false)
          .range(from, from + filter.pageSize - 1)
          .count(CountOption.exact);

      return VisitorPage(
        rows: response.data
            .map((row) => Visitor.fromJson(row))
            .toList(growable: false),
        total: response.count,
        page: filter.page,
        pageSize: filter.pageSize,
      );
    } catch (error, stackTrace) {
      throw mapError(error, stackTrace);
    }
  }

  /// One visitor by primary key, or `null` if the row does not exist -- or if
  /// RLS hides it, which is indistinguishable by design.
  Future<Visitor?> getVisitor(String visitorId) async {
    try {
      final row = await _client
          .from(_table)
          .select()
          .eq('id', visitorId)
          .maybeSingle();
      if (row == null) {
        return null;
      }
      return Visitor.fromJson(row);
    } catch (error, stackTrace) {
      throw mapError(error, stackTrace);
    }
  }

  /// Logs a walk-in and returns its id.
  ///
  /// The id is what the caller needs next: the walk-in flow registers the
  /// member and then calls [convertVisitor] with both ids.
  ///
  /// [branchId] must be a branch the staff member works at -- the insert
  /// policy's `has_branch_access(branch_id)` decides that, and refusing here
  /// in Dart would only duplicate it less reliably.
  Future<String> insertVisitor({
    required String orgId,
    required String branchId,
    required String fullName,
    required String phone,
    VisitorKind kind = VisitorKind.enquiry,
    DateTime? visitedOn,
    String? note,
    String? interestedPlanId,
  }) async {
    try {
      final row = await _client
          .from(_table)
          .insert(
            visitorInsertValues(
              orgId: orgId,
              branchId: branchId,
              fullName: fullName,
              phone: phone,
              kind: kind,
              visitedOn: visitedOn,
              note: note,
              interestedPlanId: interestedPlanId,
            ),
          )
          .select('id')
          .single();
      return row['id'] as String;
    } catch (error, stackTrace) {
      throw mapError(error, stackTrace);
    }
  }

  /// Edits an existing visitor. Every parameter defaults to
  /// [visitorFieldUnchanged]; passing `null` to a nullable one clears it.
  ///
  /// `status` accepts `new`, `contacted` and `lost`. It cannot be used to
  /// convert -- see [visitorUpdateValues] for why, and [convertVisitor] for
  /// the write that does it.
  ///
  /// The update policy is branch-scoped, so editing a visitor logged at
  /// another branch comes back as a `42501` and surfaces as
  /// [FailureKind.refused]. That is a real answer for the desk, not an error
  /// to swallow.
  Future<void> updateVisitor(
    String visitorId, {
    Object? fullName = visitorFieldUnchanged,
    Object? phone = visitorFieldUnchanged,
    Object? kind = visitorFieldUnchanged,
    Object? visitedOn = visitorFieldUnchanged,
    Object? note = visitorFieldUnchanged,
    Object? interestedPlanId = visitorFieldUnchanged,
    Object? status = visitorFieldUnchanged,
  }) async {
    try {
      final values = visitorUpdateValues(
        fullName: fullName,
        phone: phone,
        kind: kind,
        visitedOn: visitedOn,
        note: note,
        interestedPlanId: interestedPlanId,
        status: status,
      );
      if (values.isEmpty) {
        // Nothing was passed. Sending an empty patch would still bump
        // `updated_at` through the trigger and write an audit row for a
        // change nobody made.
        return;
      }
      await _client.from(_table).update(values).eq('id', visitorId);
    } catch (error, stackTrace) {
      throw mapError(error, stackTrace);
    }
  }

  /// Deletes a visitor. Owners only, by policy: nothing financial hangs off a
  /// visitor so no trail is destroyed, but it is still someone else's record
  /// of a conversation. Anyone else gets a `42501`.
  Future<void> deleteVisitor(String visitorId) async {
    try {
      await _client.from(_table).delete().eq('id', visitorId);
    } catch (error, stackTrace) {
      throw mapError(error, stackTrace);
    }
  }

  /// Marks a visitor as the member they became.
  ///
  /// Called after the member already exists -- `register_member` returns the
  /// id this takes. A failure here does not undo the registration: the member
  /// is real either way, and the worst case is a visitor row still sitting in
  /// the callback list, which is visible and fixable. The reverse (a
  /// conversion recorded against a member that was never created) is not.
  ///
  /// This is the one write that must move `status`, `converted_member_id` and
  /// `converted_at` together, which is why it is an RPC and not an update:
  /// `visitors_converted_shape` rejects any two of the three
  /// (`20260908110100_visitors.sql`). The RPC is `security invoker`, so the
  /// same branch-scoped update policy still applies -- converting a visitor
  /// logged at another branch raises `insufficient_privilege` and arrives as
  /// [FailureKind.refused]. An already-converted visitor raises
  /// `check_violation` with a sentence written for a person, which
  /// [mapError] passes through unaltered.
  Future<void> convertVisitor(String visitorId, String memberId) async {
    try {
      await _client.rpc<void>(
        'convert_visitor',
        params: <String, dynamic>{
          'p_visitor_id': visitorId,
          'p_member_id': memberId,
        },
      );
    } catch (error, stackTrace) {
      throw mapError(error, stackTrace);
    }
  }
}

@riverpod
VisitorsRepository visitorsRepository(Ref ref) {
  return VisitorsRepository(ref.watch(supabaseClientProvider));
}
