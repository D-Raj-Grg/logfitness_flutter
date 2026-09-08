import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/plans/membership_plan.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';

Map<String, dynamic> _row(Map<String, dynamic> overrides) => <String, dynamic>{
  'id': '11111111-1111-4111-8111-111111111111',
  'org_id': '22222222-2222-4222-8222-222222222222',
  'name': 'Monthly',
  'description': 'Full gym access',
  'plan_type': 'time',
  'duration_days': 30,
  'session_count': null,
  'price_paisa': 250000,
  'signup_fee_paisa': 50000,
  'branch_ids': <String>[],
  'is_active': true,
  'sort_order': 10,
  'created_at': '2026-01-01T00:00:00+00:00',
  'updated_at': '2026-01-01T00:00:00+00:00',
  ...overrides,
};

void main() {
  test('maps a time plan sold org-wide', () {
    final MembershipPlan plan = MembershipPlan.fromJson(_row(<String, dynamic>{}));

    expect(plan.planType, PlanType.time);
    expect(plan.durationDays, 30);
    expect(plan.sessionCount, isNull);
    // Money is integer paisa: NPR 2,500.00 plus a NPR 500.00 joining fee.
    expect(plan.pricePaisa, 250000);
    expect(plan.signupFeePaisa, 50000);
    expect(plan.pricePaisa, isA<int>());
    // An empty `branch_ids` means every branch, which is why the branch
    // filter is two clauses and not just a containment test.
    expect(plan.branchIds, isEmpty);
    expect(plan.isActive, isTrue);
  });

  test('maps a session pack scoped to two branches', () {
    final MembershipPlan plan = MembershipPlan.fromJson(
      _row(<String, dynamic>{
        'name': '10 PT sessions',
        'plan_type': 'session_pack',
        'duration_days': null,
        'session_count': 10,
        'signup_fee_paisa': 0,
        'branch_ids': <String>[
          '33333333-3333-4333-8333-333333333333',
          '44444444-4444-4444-8444-444444444444',
        ],
      }),
    );

    expect(plan.planType, PlanType.sessionPack);
    expect(plan.durationDays, isNull);
    expect(plan.sessionCount, 10);
    expect(plan.signupFeePaisa, 0);
    expect(plan.branchIds, hasLength(2));
  });

  test('maps a retired plan -- still readable, so old sales stay legible', () {
    final MembershipPlan plan = MembershipPlan.fromJson(
      _row(<String, dynamic>{'is_active': false, 'description': null}),
    );

    expect(plan.isActive, isFalse);
    expect(plan.description, isNull);
  });

  test('an unknown plan_type fails loudly rather than defaulting', () {
    expect(
      () => MembershipPlan.fromJson(
        _row(<String, dynamic>{'plan_type': 'punch_card'}),
      ),
      throwsA(isA<ArgumentError>()),
    );
  });
}
