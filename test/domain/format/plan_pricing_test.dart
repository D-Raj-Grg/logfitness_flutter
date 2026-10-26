// `signupFeeSplit` decides what a counter is told about the joining fee, and
// `renew_membership` decides what is actually written. These pin the two
// together: every case below is the RPC's own arithmetic in
// `20260910130100_discount_reason_rpcs.sql`.
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/fees/fee.dart';
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

  group('saleFees', () {
    // The same cases the SQL test (supabase/tests/fees.sql) and the console
    // run, so a change to the arithmetic in one place fails in the other two.
    Fee fee(
      String id,
      String name,
      FeeChargeRule rule,
      int amount, {
      bool allPlans = false,
      List<String> plans = const <String>[],
      bool active = true,
      int sort = 0,
    }) => Fee(
      id: id,
      orgId: 'org-1',
      name: name,
      chargeRule: rule,
      amountPaisa: amount,
      allPlans: allPlans,
      planIds: plans,
      isActive: active,
      sortOrder: sort,
    );

    final List<Fee> catalogue = <Fee>[
      fee('f-reg', 'Registration fee', FeeChargeRule.once, 50000,
          plans: <String>['p-1'], sort: 0),
      fee('f-card', 'Card fee', FeeChargeRule.once, 20000,
          allPlans: true, sort: 1),
      fee('f-locker', 'Locker', FeeChargeRule.everySale, 10000,
          plans: <String>['p-1'], sort: 2),
      fee('f-old', 'Retired', FeeChargeRule.once, 99900,
          allPlans: true, active: false, sort: 3),
    ];

    test('a first sale charges every fee the plan carries, in order', () {
      final List<SaleFee> rows = saleFees(
        fees: catalogue,
        planId: 'p-1',
        isFirstMembership: true,
      );
      expect(rows.map((SaleFee r) => r.name), <String>[
        'Registration fee',
        'Card fee',
        'Locker',
      ]);
      expect(rows.map((SaleFee r) => r.chargedPaisa), <int>[
        50000,
        20000,
        10000,
      ]);
      expect(rows.every((SaleFee r) => r.waivedPaisa == 0), isTrue);
    });

    test('a renewal takes the once-fees back off and repeats the every-sale one', () {
      final List<SaleFee> rows = saleFees(
        fees: catalogue,
        planId: 'p-1',
        isFirstMembership: false,
      );
      expect(rows.map((SaleFee r) => r.chargedPaisa), <int>[0, 0, 10000]);
      expect(rows.map((SaleFee r) => r.waivedPaisa), <int>[50000, 20000, 0]);
    });

    test('a plan carries only the fees assigned to it, or on for all plans', () {
      final List<SaleFee> rows = saleFees(
        fees: catalogue,
        planId: 'p-2',
        isFirstMembership: true,
      );
      expect(rows.map((SaleFee r) => r.name), <String>['Card fee']);
    });

    test('an inactive fee is neither charged nor shown', () {
      final List<SaleFee> rows = saleFees(
        fees: catalogue,
        planId: 'p-2',
        isFirstMembership: false,
      );
      expect(rows.map((SaleFee r) => r.name), isNot(contains('Retired')));
    });

    test('equal sort orders fall back to the name', () {
      final List<SaleFee> rows = saleFees(
        fees: <Fee>[
          fee('b', 'Beta', FeeChargeRule.once, 100, allPlans: true),
          fee('a', 'Alpha', FeeChargeRule.once, 100, allPlans: true),
        ],
        planId: 'p-1',
        isFirstMembership: true,
      );
      expect(rows.map((SaleFee r) => r.name), <String>['Alpha', 'Beta']);
    });

    test('a catalogue with nothing for the plan quotes nothing', () {
      final FeeQuote quote = feeQuote(
        plan: _plan(),
        fees: const <Fee>[],
        catalogueEnabled: true,
        standardSignupFeePaisa: 50000,
        isFirstMembership: true,
      );
      // The org list fee is a legacy reference: the catalogue never invents a
      // line for a fee the plan does not carry.
      expect(quote.rows, isEmpty);
      expect(quote.chargedPaisa, 0);
    });
  });

  group('feeQuote', () {
    test('no plan chosen is no fees', () {
      final FeeQuote quote = feeQuote(
        plan: null,
        fees: const <Fee>[],
        catalogueEnabled: false,
        standardSignupFeePaisa: 0,
        isFirstMembership: true,
      );
      expect(quote.rows, isEmpty);
      expect(quote.chargedPaisa, 0);
    });

    test('the catalogue total is the sum of what was charged', () {
      final FeeQuote quote = feeQuote(
        plan: _plan(),
        fees: <Fee>[
          const Fee(
            id: 'f1',
            orgId: 'org-1',
            name: 'Registration fee',
            chargeRule: FeeChargeRule.once,
            amountPaisa: 50000,
            allPlans: true,
            planIds: <String>[],
            isActive: true,
            sortOrder: 0,
          ),
          const Fee(
            id: 'f2',
            orgId: 'org-1',
            name: 'Card fee',
            chargeRule: FeeChargeRule.once,
            amountPaisa: 20000,
            allPlans: true,
            planIds: <String>[],
            isActive: true,
            sortOrder: 1,
          ),
        ],
        catalogueEnabled: true,
        standardSignupFeePaisa: 0,
        isFirstMembership: true,
      );
      expect(quote.chargedPaisa, 70000);
    });

    test('before the switch it is the one legacy joining fee', () {
      final MembershipPlan plan = _plan().copyWith(signupFeePaisa: 70000);
      final FeeQuote first = feeQuote(
        plan: plan,
        fees: const <Fee>[],
        catalogueEnabled: false,
        standardSignupFeePaisa: 70000,
        isFirstMembership: true,
      );
      expect(first.rows.single.name, 'Registration fee');
      expect(first.rows.single.chargedPaisa, 70000);
      expect(first.chargedPaisa, 70000);

      final FeeQuote renewal = feeQuote(
        plan: plan,
        fees: const <Fee>[],
        catalogueEnabled: false,
        standardSignupFeePaisa: 70000,
        isFirstMembership: false,
      );
      expect(renewal.rows.single.chargedPaisa, 0);
      expect(renewal.rows.single.waivedPaisa, 70000);
      expect(renewal.chargedPaisa, 0);
    });

    test('a legacy plan with no fee and no list fee has no fee line', () {
      final FeeQuote quote = feeQuote(
        plan: _plan(),
        fees: const <Fee>[],
        catalogueEnabled: false,
        standardSignupFeePaisa: 0,
        isFirstMembership: true,
      );
      expect(quote.rows, isEmpty);
    });
  });
}
