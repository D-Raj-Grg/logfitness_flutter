// Mirrors `public.memberships`. See
// `logfitness_saas/supabase/migrations/20260905120300_memberships.sql`, plus
// `20260906120100_membership_signup_fee.sql` (`signup_fee_paisa`).
//
// Verified column-for-column against the live schema on 2026-09-09.
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/format/plain_date.dart';

part 'membership.freezed.dart';
part 'membership.g.dart';

@freezed
abstract class Membership with _$Membership {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Membership({
    required String id,
    required String orgId,
    required String branchId,
    required String memberId,
    required String planId,
    // Snapshot of the plan as sold at the time of sale.
    required String planName,
    required PlanType planType,
    // `date`, not `timestamptz` -- a membership window is calendar days. Left
    // on the default converter these decoded to *local* midnight, so once the
    // value reached `formatPlainDate` the day drifted for any org east of
    // UTC. TASKS.md Discovered 2026-09-05 called this out for exactly these
    // columns; see lib/domain/format/plain_date.dart.
    @PlainDateConverter() required DateTime startDate,
    // Null for a session pack sold with no validity window -- the shape
    // `adjust_membership_dates` explicitly accepts a null end date for.
    @NullablePlainDateConverter() DateTime? endDate,
    int? sessionsTotal,
    int? sessionsRemaining,
    // Money is integer paisa end to end. Never a double, never converted here.
    required int pricePaisa,
    required int discountPaisa,
    // The joining fee this sale charged, kept apart from the plan price so a
    // renewal that waives it stays legible on the invoice.
    required int signupFeePaisa,
    // Written by the RPCs (`renew_membership`, `freeze_membership`,
    // `cancel_membership`) and by the status derivation trigger, never by the
    // app.
    required MembershipStatus status,
    @NullablePlainDateConverter() DateTime? frozenOn,
    required int frozenDays,
    DateTime? cancelledAt,
    String? cancelReason,
    String? previousMembershipId,
    String? soldBy,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Membership;

  factory Membership.fromJson(Map<String, dynamic> json) =>
      _$MembershipFromJson(json);
}
