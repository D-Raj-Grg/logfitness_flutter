// `signupFeeSplit` decides what a counter is told about the joining fee, and
// `renew_membership` decides what is actually written. These pin the two
// together: every case below is the RPC's own arithmetic in
// `20260910130100_discount_reason_rpcs.sql`.
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/plans/membership_plan.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/format/plan_pricing.dart';

MembershipPlan _plan({
  PlanType type = PlanType.time,
  int? durationDays = 30,
  int? sessionCount,
}) => MembershipPlan(
  id: 'p-1',
  orgId: 'org-1',
  name: 'Gym Only',
  planType: type,
  durationDays: durationDays,
  sessionCount: sessionCount,
  pricePaisa: 300000,
  signupFeePaisa: 0,
  branchIds: const <String>[],
  isActive: true,
  sortOrder: 0,
  createdAt: DateTime.utc(2026, 1, 1),
  updatedAt: DateTime.utc(2026, 1, 1),
);

void main() {
  group('planTermLabel', () {
    test('a time plan is its days', () {
      expect(planTermLabel(_plan()), '30 days');
    });

    test('a session pack is its sessions', () {
      expect(
        planTermLabel(
          _plan(
            type: PlanType.sessionPack,
            durationDays: null,
            sessionCount: 10,
          ),
        ),
        '10 sessions',
      );
    });

    test('a plan missing its term says zero rather than throwing', () {
      expect(planTermLabel(_plan(durationDays: null)), '0 days');
    });
  });

  group('signupFeeSplit', () {
    test('a first membership pays the plan fee, and waives nothing', () {
      expect(
        signupFeeSplit(
          planSignupFeePaisa: 50000,
          orgStandardFeePaisa: 50000,
          isFirstMembership: true,
        ),
        (charged: 50000, waived: 0),
      );
    });

    test('a renewal pays nothing, and the plan fee is the waiver', () {
      // "The joining fee is charged once, on the member's first membership."
      expect(
        signupFeeSplit(
          planSignupFeePaisa: 50000,
          orgStandardFeePaisa: 20000,
          isFirstMembership: false,
        ),
        (charged: 0, waived: 50000),
      );
    });

    test('a plan with no fee of its own falls back to the gym list fee', () {
      // This is the case the memo exists for: a long-term tier sold as
      // "joining fee waived" has no fee to point at without the org's.
      expect(
        signupFeeSplit(
          planSignupFeePaisa: 0,
          orgStandardFeePaisa: 50000,
          isFirstMembership: true,
        ),
        (charged: 0, waived: 50000),
      );
    });

    test('no fee anywhere waives nothing, and never goes negative', () {
      expect(
        signupFeeSplit(
          planSignupFeePaisa: 0,
          orgStandardFeePaisa: 0,
          isFirstMembership: true,
        ),
        (charged: 0, waived: 0),
      );
      // A plan priced above the gym's list fee: the difference is not a
      // negative waiver, it is no waiver.
      expect(
        signupFeeSplit(
          planSignupFeePaisa: 80000,
          orgStandardFeePaisa: 20000,
          isFirstMembership: true,
        ),
        (charged: 80000, waived: 0),
      );
    });
  });
}
