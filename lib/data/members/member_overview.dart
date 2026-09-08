// Mirrors the `public.member_overview` view -- one row per member with the
// current membership and the outstanding dues already joined on. See
// `logfitness_saas/supabase/migrations/20260905120800_member_spine_views_and_reports.sql`
// and `20260905190000_member_overview_knows_a_new_member.sql`.
//
// This, not `members`, is what the staff list reads: the desk needs the plan,
// the expiry and the dues in the same round trip, and doing that as three
// queries per row is how a member list becomes unusable at 400 members. The
// Dart counterpart of the console's `MemberOverviewRow`
// (`logfitness_saas/lib/db/members.ts`).
//
// Verified column-for-column against the live view on 2026-09-09.
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/format/plain_date.dart';

part 'member_overview.freezed.dart';
part 'member_overview.g.dart';

/// `due_paisa` is `sum(invoices.due_paisa)`, and Postgres widens a sum over
/// `bigint` to `numeric`. PostgREST may therefore send it as `150000` or as
/// `150000.0`, and the view coalesces the no-invoices case to `0`. Money is
/// integer paisa (CLAUDE.md), so the widening is undone here, at the wire
/// edge, rather than allowed to become a `double` that some later total
/// rounds differently.
int paisaFromJson(Object? value) {
  if (value == null) {
    return 0;
  }
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.round();
  }
  if (value is String) {
    return num.parse(value).round();
  }
  throw FormatException('Not a paisa amount: $value');
}

@freezed
abstract class MemberOverview with _$MemberOverview {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory MemberOverview({
    // Postgres cannot prove a view column non-null, so the generated console
    // types make every one of these nullable and then narrow the ones the
    // view structurally guarantees. The same narrowing is applied here: `id`
    // through `joined_on` come from `members` joined to `branches`, so a row
    // that reached the client has them.
    required String id,
    required String orgId,
    required String homeBranchId,
    required String homeBranchName,
    required String memberCode,
    required String fullName,
    required String phone,
    String? email,
    String? photoPath,
    // Trigger-derived. Read, never written -- CLAUDE.md.
    required MemberStatus status,
    @PlainDateConverter() required DateTime joinedOn,
    @NullablePlainDateConverter() DateTime? leftOn,
    // The lateral pick of the one membership that matters right now: active,
    // upcoming or frozen, latest expiry first. All null for a member who has
    // never been sold to.
    String? currentMembershipId,
    String? currentPlanId,
    String? currentPlanName,
    PlanType? currentPlanType,
    MembershipStatus? membershipStatus,
    @NullablePlainDateConverter() DateTime? membershipStartDate,
    @NullablePlainDateConverter() DateTime? membershipEndDate,
    int? sessionsRemaining,
    // `end_date - org_today(org_id)`. Negative once expired, null for a
    // session pack with no window. Computed against the *org's* today, which
    // is why the client must never recompute it from the device clock.
    int? daysToExpiry,
    @JsonKey(fromJson: paisaFromJson) required int duePaisa,
    @NullablePlainDateConverter() DateTime? oldestDueOn,
    // Distinguishes "never sold a plan" from "had one, it lapsed" -- the two
    // read identically off the current-membership columns alone.
    required bool hasMembershipHistory,
    DateTime? archivedAt,
  }) = _MemberOverview;

  const MemberOverview._();

  factory MemberOverview.fromJson(Map<String, dynamic> json) =>
      _$MemberOverviewFromJson(json);

  /// True when the desk has archived this member. Archived rows stay readable
  /// and restorable; they are just kept out of the list worked from all day.
  bool get isArchived => archivedAt != null;

  /// True when money is outstanding. Kept as a comparison on paisa rather
  /// than on a formatted string.
  bool get hasDues => duePaisa > 0;
}
