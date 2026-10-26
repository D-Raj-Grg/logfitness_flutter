// What a plan buys, in words. Mirrors `logfitness_saas/lib/plan-pricing.ts`.
//
// The fee maths mirrors the console's `logfitness_saas/lib/plan-pricing.ts` and
// the database's `sale_fees()` (`20261027100000_fee_catalogue.sql`) and
// `renew_membership`: the counter must not promise a number the RPC then writes
// differently.
import 'package:flutter/foundation.dart';

import 'package:logfitness_flutter/data/fees/fee.dart';
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

/// One fee line of one sale: what it charges, and what it takes back off.
@immutable
class SaleFee {
  const SaleFee({
    required this.name,
    required this.chargeRule,
    required this.chargedPaisa,
    required this.waivedPaisa,
    this.feeId,
  });

  /// Null for the legacy joining fee, which is not a catalogue row.
  final String? feeId;
  final String name;
  final FeeChargeRule chargeRule;
  final int chargedPaisa;

  /// A once-fee the member already paid: shown taken back off. A memo, outside
  /// the subtotal and the total.
  final int waivedPaisa;
}

/// The fee lines and the fee total for one sale of one plan.
@immutable
class FeeQuote {
  const FeeQuote({required this.rows, required this.chargedPaisa});

  static const FeeQuote none = FeeQuote(rows: <SaleFee>[], chargedPaisa: 0);

  final List<SaleFee> rows;

  /// What the fees add to the plan price.
  final int chargedPaisa;
}

/// The fees one plan carries on one sale, from the catalogue.
///
/// Mirrors `sale_fees()` exactly. A fee reaches a plan when it is on for all
/// plans or lists the plan. A `once` fee is charged on the member's first
/// membership and shown taken back off on every later one; an `every_sale` fee
/// is charged every time and has nothing to take off. Order is sort order, then
/// name, as in the database. Inactive fees are not charged and not shown, as in
/// the database.
List<SaleFee> saleFees({
  required List<Fee> fees,
  required String planId,
  required bool isFirstMembership,
}) {
  final List<Fee> applicable =
      fees.where((Fee f) => f.isActive && f.appliesTo(planId)).toList()
        ..sort((Fee a, Fee b) {
          final int bySort = a.sortOrder.compareTo(b.sortOrder);
          return bySort != 0 ? bySort : a.name.compareTo(b.name);
        });
  return <SaleFee>[
    for (final Fee f in applicable)
      SaleFee(
        feeId: f.id,
        name: f.name,
        chargeRule: f.chargeRule,
        chargedPaisa:
            f.chargeRule == FeeChargeRule.everySale || isFirstMembership
            ? f.amountPaisa
            : 0,
        waivedPaisa: f.chargeRule == FeeChargeRule.once && !isFirstMembership
            ? f.amountPaisa
            : 0,
      ),
  ];
}

/// The fee lines and the fee total for one sale of [plan], whichever way the
/// org charges. While `fee_catalogue_enabled` is false the one fee is the
/// plan's legacy joining fee ([signupFeeSplit]), presented as a single
/// "Registration fee" row so every sale screen renders the same shape.
FeeQuote feeQuote({
  required MembershipPlan? plan,
  required List<Fee> fees,
  required bool catalogueEnabled,
  required int standardSignupFeePaisa,
  required bool isFirstMembership,
}) {
  if (plan == null) {
    return FeeQuote.none;
  }

  final List<SaleFee> rows;
  if (catalogueEnabled) {
    rows = saleFees(
      fees: fees,
      planId: plan.id,
      isFirstMembership: isFirstMembership,
    );
  } else {
    final ({int charged, int waived}) split = signupFeeSplit(
      planSignupFeePaisa: plan.signupFeePaisa,
      orgStandardFeePaisa: standardSignupFeePaisa,
      isFirstMembership: isFirstMembership,
    );
    rows = split.charged > 0 || split.waived > 0
        ? <SaleFee>[
            SaleFee(
              name: 'Registration fee',
              chargeRule: FeeChargeRule.once,
              chargedPaisa: split.charged,
              waivedPaisa: split.waived,
            ),
          ]
        : const <SaleFee>[];
  }

  return FeeQuote(
    rows: rows,
    chargedPaisa: rows.fold<int>(0, (int sum, SaleFee r) => sum + r.chargedPaisa),
  );
}
