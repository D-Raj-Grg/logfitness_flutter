import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/memberships/membership.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';

Map<String, dynamic> _row(Map<String, dynamic> overrides) => <String, dynamic>{
  'id': '11111111-1111-4111-8111-111111111111',
  'org_id': '22222222-2222-4222-8222-222222222222',
  'branch_id': '33333333-3333-4333-8333-333333333333',
  'member_id': '44444444-4444-4444-8444-444444444444',
  'plan_id': '55555555-5555-4555-8555-555555555555',
  'plan_name': 'Monthly',
  'plan_type': 'time',
  'start_date': '2026-09-01',
  'end_date': '2026-09-30',
  'sessions_total': null,
  'sessions_remaining': null,
  'price_paisa': 250000,
  'discount_paisa': 25000,
  'signup_fee_paisa': 50000,
  'status': 'active',
  'frozen_on': null,
  'frozen_days': 0,
  'cancelled_at': null,
  'cancel_reason': null,
  'previous_membership_id': null,
  'sold_by': '66666666-6666-4666-8666-666666666666',
  'notes': null,
  'created_at': '2026-09-01T04:15:00+00:00',
  'updated_at': '2026-09-01T04:15:00+00:00',
  ...overrides,
};

void main() {
  test('maps a realistic PostgREST row for a time plan', () {
    final Membership membership = Membership.fromJson(_row(<String, dynamic>{}));

    expect(membership.planName, 'Monthly');
    expect(membership.planType, PlanType.time);
    expect(membership.status, MembershipStatus.active);
    // `start_date` and `end_date` are `date` columns. Pinned to UTC midnight,
    // they cannot drift by the org's offset the way DateTime.parse's local
    // midnight does.
    expect(membership.startDate, DateTime.utc(2026, 9, 1));
    expect(membership.startDate.isUtc, isTrue);
    expect(membership.endDate, DateTime.utc(2026, 9, 30));
    // Money is integer paisa throughout.
    expect(membership.pricePaisa, 250000);
    expect(membership.discountPaisa, 25000);
    expect(membership.signupFeePaisa, 50000);
    expect(membership.pricePaisa, isA<int>());
    expect(membership.sessionsTotal, isNull);
    expect(membership.frozenDays, 0);
  });

  test('maps a session pack with no validity window', () {
    final Membership membership = Membership.fromJson(
      _row(<String, dynamic>{
        'plan_name': '10 PT sessions',
        'plan_type': 'session_pack',
        'end_date': null,
        'sessions_total': 10,
        'sessions_remaining': 7,
        'signup_fee_paisa': 0,
      }),
    );

    expect(membership.planType, PlanType.sessionPack);
    expect(membership.endDate, isNull);
    expect(membership.sessionsTotal, 10);
    expect(membership.sessionsRemaining, 7);
    expect(membership.signupFeePaisa, 0);
  });

  test('maps a frozen membership', () {
    final Membership membership = Membership.fromJson(
      _row(<String, dynamic>{
        'status': 'frozen',
        'frozen_on': '2026-09-12',
        'frozen_days': 6,
      }),
    );

    expect(membership.status, MembershipStatus.frozen);
    expect(membership.frozenOn, DateTime.utc(2026, 9, 12));
    // The days already banked from earlier freezes, not this one.
    expect(membership.frozenDays, 6);
  });

  test('maps a cancelled membership with its reason', () {
    final Membership membership = Membership.fromJson(
      _row(<String, dynamic>{
        'status': 'cancelled',
        'cancelled_at': '2026-09-15T09:00:00+00:00',
        'cancel_reason': 'Moved abroad',
      }),
    );

    expect(membership.status, MembershipStatus.cancelled);
    // `cancelled_at` is a `timestamptz`, unlike the window dates around it.
    expect(
      membership.cancelledAt,
      DateTime.parse('2026-09-15T09:00:00+00:00'),
    );
    expect(membership.cancelReason, 'Moved abroad');
  });

  test('writes the date columns back date-only, never as a timestamp', () {
    final Membership membership = Membership.fromJson(
      _row(<String, dynamic>{'frozen_on': '2026-09-12'}),
    );

    final Map<String, dynamic> json = membership.toJson();

    expect(json['start_date'], '2026-09-01');
    expect(json['end_date'], '2026-09-30');
    expect(json['frozen_on'], '2026-09-12');
    // The failure this guards: a full ISO timestamp into a `date` column
    // shifts the stored day by the org's offset.
    expect(json['start_date'], isNot(contains('T')));
  });

  test('an unknown membership_status fails loudly rather than defaulting', () {
    expect(
      () => Membership.fromJson(_row(<String, dynamic>{'status': 'paused'})),
      throwsA(isA<ArgumentError>()),
    );
  });
}
