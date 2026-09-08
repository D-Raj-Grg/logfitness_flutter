// `member_overview` is a view, so PostgREST sends every column and Postgres
// can prove none of them non-null. These rows are shaped the way the view
// actually answers: a member mid-plan, a member who was never sold to, and an
// archived one.
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/members/member_overview.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';

Map<String, dynamic> _row(Map<String, dynamic> overrides) => <String, dynamic>{
  'id': '11111111-1111-4111-8111-111111111111',
  'org_id': '22222222-2222-4222-8222-222222222222',
  'home_branch_id': '33333333-3333-4333-8333-333333333333',
  'home_branch_name': 'Thamel',
  'member_code': 'M00042',
  'full_name': 'Anjali Shrestha',
  'phone': '9800000000',
  'email': null,
  'photo_path': null,
  'status': 'active',
  'joined_on': '2024-01-15',
  'left_on': null,
  'current_membership_id': null,
  'current_plan_id': null,
  'current_plan_name': null,
  'current_plan_type': null,
  'membership_status': null,
  'membership_start_date': null,
  'membership_end_date': null,
  'sessions_remaining': null,
  'days_to_expiry': null,
  'due_paisa': 0,
  'oldest_due_on': null,
  'has_membership_history': false,
  'archived_at': null,
  ...overrides,
};

void main() {
  test('maps a member mid-plan with dues outstanding', () {
    final MemberOverview row = MemberOverview.fromJson(
      _row(<String, dynamic>{
        'current_membership_id': '44444444-4444-4444-8444-444444444444',
        'current_plan_id': '55555555-5555-4555-8555-555555555555',
        'current_plan_name': 'Monthly',
        'current_plan_type': 'time',
        'membership_status': 'active',
        'membership_start_date': '2026-09-01',
        'membership_end_date': '2026-09-30',
        'days_to_expiry': 21,
        'due_paisa': 150000,
        'oldest_due_on': '2026-09-01',
        'has_membership_history': true,
      }),
    );

    expect(row.homeBranchName, 'Thamel');
    expect(row.status, MemberStatus.active);
    expect(row.currentPlanType, PlanType.time);
    expect(row.membershipStatus, MembershipStatus.active);
    // Date-only columns are pinned to UTC midnight so no offset can move the
    // day -- see lib/domain/format/plain_date.dart.
    expect(row.joinedOn, DateTime.utc(2024, 1, 15));
    expect(row.membershipStartDate, DateTime.utc(2026, 9, 1));
    expect(row.membershipEndDate, DateTime.utc(2026, 9, 30));
    expect(row.oldestDueOn, DateTime.utc(2026, 9, 1));
    expect(row.daysToExpiry, 21);
    // Money is integer paisa: NPR 1,500.00 is 150000, never 1500.0.
    expect(row.duePaisa, 150000);
    expect(row.duePaisa, isA<int>());
    expect(row.hasDues, isTrue);
    expect(row.hasMembershipHistory, isTrue);
    expect(row.isArchived, isFalse);
  });

  test('maps a member who has never been sold a plan', () {
    final MemberOverview row = MemberOverview.fromJson(_row(<String, dynamic>{}));

    expect(row.currentMembershipId, isNull);
    expect(row.currentPlanType, isNull);
    expect(row.membershipStatus, isNull);
    expect(row.membershipEndDate, isNull);
    expect(row.daysToExpiry, isNull);
    expect(row.duePaisa, 0);
    expect(row.hasDues, isFalse);
    // The column that tells "never sold to" apart from "had one, it lapsed".
    expect(row.hasMembershipHistory, isFalse);
  });

  test('maps an archived member and reports it as archived', () {
    final MemberOverview row = MemberOverview.fromJson(
      _row(<String, dynamic>{
        'status': 'expired',
        'archived_at': '2026-09-07T05:15:00+00:00',
      }),
    );

    expect(row.status, MemberStatus.expired);
    expect(row.archivedAt, DateTime.parse('2026-09-07T05:15:00+00:00'));
    expect(row.isArchived, isTrue);
  });

  test('a negative days_to_expiry survives -- an expired plan is not clamped',
      () {
    final MemberOverview row = MemberOverview.fromJson(
      _row(<String, dynamic>{'status': 'expired', 'days_to_expiry': -12}),
    );

    expect(row.daysToExpiry, -12);
  });

  group('paisaFromJson', () {
    // `sum(bigint)` is `numeric` in Postgres, and PostgREST may render that
    // either way. Money stays an int on both paths.
    test('accepts an integer', () => expect(paisaFromJson(150000), 150000));

    test('accepts a numeric rendered with a fractional part', () {
      expect(paisaFromJson(150000.0), 150000);
      expect(paisaFromJson(150000.0), isA<int>());
    });

    test('accepts a numeric rendered as a string', () {
      expect(paisaFromJson('150000'), 150000);
    });

    test('reads the view coalesce of no invoices as zero', () {
      expect(paisaFromJson(null), 0);
    });

    test('refuses anything else rather than defaulting to zero', () {
      expect(() => paisaFromJson(<String>['nope']), throwsFormatException);
    });
  });
}
