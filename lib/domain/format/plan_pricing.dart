// What a plan buys, in words. Mirrors `logfitness_saas/lib/plan-pricing.ts`.
//
// The joining-fee split from that file is deliberately not here yet: it needs
// the org's standard signup fee, which the console gets from
// `loadPlansForBranch` and this app has no query for. Until it does, the app
// shows the plan's own fee and nothing about a waiver -- see TASKS.md.
import 'package:logfitness_flutter/data/plans/membership_plan.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';

/// "30 days" or "10 sessions" -- what the plan actually buys.
String planTermLabel(MembershipPlan plan) =>
    plan.planType == PlanType.sessionPack
    ? '${plan.sessionCount ?? 0} sessions'
    : '${plan.durationDays ?? 0} days';

/// The joining fee split for one sale: what is charged, and what is waived.
///
/// Mirrors `renew_membership` clause for clause
/// (`20260906120100_membership_signup_fee.sql`) and the console's
/// `signupFeeSplit` — the counter must not promise a number the RPC then
/// writes differently. The fee is charged once, on a member's first
/// membership. The reference is the plan's own fee, or the gym's list fee when
/// the plan carries none, which is what lets a long-term tier sold as "joining
/// fee waived" show the amount it waived.
///
/// The waiver is a memo. It is outside the subtotal and outside the total.
({int charged, int waived}) signupFeeSplit({
  required int planSignupFeePaisa,
  required int orgStandardFeePaisa,
  required bool isFirstMembership,
}) {
  final int charged = isFirstMembership ? planSignupFeePaisa : 0;
  final int reference = planSignupFeePaisa > 0
      ? planSignupFeePaisa
      : orgStandardFeePaisa;
  final int waived = reference - charged;
  return (charged: charged, waived: waived < 0 ? 0 : waived);
}
