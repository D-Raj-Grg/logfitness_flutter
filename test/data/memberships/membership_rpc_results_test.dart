// The exact `jsonb` objects the membership RPCs build. Read off the function
// bodies in
// `logfitness_saas/supabase/migrations/20260905120700_membership_rpcs.sql` and
// `20260907120400_adjust_membership_dates.sql`.
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/memberships/membership_rpc_results.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';

void main() {
  group('RenewMembershipResult', () {
    test('maps a renewal that was part-paid', () {
      final RenewMembershipResult result = RenewMembershipResult.fromJson(
        <String, dynamic>{
          'membership_id': '11111111-1111-4111-8111-111111111111',
          'invoice_id': '22222222-2222-4222-8222-222222222222',
          'invoice_no': 'INV-2026-000200',
          'payment_id': '33333333-3333-4333-8333-333333333333',
          'start_date': '2026-10-01',
          'end_date': '2026-10-31',
          'total_paisa': 250000,
          'due_paisa': 100000,
        },
      );

      expect(result.invoiceNo, 'INV-2026-000200');
      expect(result.startDate, DateTime.utc(2026, 10, 1));
      expect(result.endDate, DateTime.utc(2026, 10, 31));
      // `(subtotal - discount) - amount_paid`, computed in Postgres because
      // the subtotal includes a joining fee the caller does not know about.
      expect(result.totalPaisa, 250000);
      expect(result.duePaisa, 100000);
      expect(result.duePaisa, isA<int>());
    });

    test('maps a renewal invoiced but not paid', () {
      final RenewMembershipResult result = RenewMembershipResult.fromJson(
        <String, dynamic>{
          'membership_id': '11111111-1111-4111-8111-111111111111',
          'invoice_id': '22222222-2222-4222-8222-222222222222',
          'invoice_no': 'INV-2026-000201',
          'payment_id': null,
          'start_date': '2026-10-01',
          'end_date': null,
          'total_paisa': 250000,
          'due_paisa': 250000,
        },
      );

      // No payment row is a legitimate outcome, not a failure.
      expect(result.paymentId, isNull);
      expect(result.endDate, isNull);
      expect(result.duePaisa, result.totalPaisa);
    });
  });

  test('FreezeMembershipResult maps the org-day the freeze began', () {
    final FreezeMembershipResult result = FreezeMembershipResult.fromJson(
      <String, dynamic>{
        'membership_id': '11111111-1111-4111-8111-111111111111',
        'frozen_on': '2026-09-12',
      },
    );

    // `org_today(org_id)`, sent as a `date`. Never the device's today.
    expect(result.frozenOn, DateTime.utc(2026, 9, 12));
    expect(result.frozenOn.isUtc, isTrue);
  });

  group('UnfreezeMembershipResult', () {
    test('maps the paused days and the end date they pushed out', () {
      final UnfreezeMembershipResult result =
          UnfreezeMembershipResult.fromJson(<String, dynamic>{
        'membership_id': '11111111-1111-4111-8111-111111111111',
        'paused_days': 6,
        'end_date': '2026-10-06',
      });

      expect(result.pausedDays, 6);
      expect(result.endDate, DateTime.utc(2026, 10, 6));
    });

    test('a pack with no window unfreezes to a null end date', () {
      final UnfreezeMembershipResult result =
          UnfreezeMembershipResult.fromJson(<String, dynamic>{
        'membership_id': '11111111-1111-4111-8111-111111111111',
        'paused_days': 0,
        'end_date': null,
      });

      expect(result.pausedDays, 0);
      expect(result.endDate, isNull);
    });
  });

  test('MembershipStatusResult maps what cancel_membership left behind', () {
    final MembershipStatusResult result = MembershipStatusResult.fromJson(
      <String, dynamic>{
        'membership_id': '11111111-1111-4111-8111-111111111111',
        'status': 'cancelled',
      },
    );

    expect(result.status, MembershipStatus.cancelled);
  });

  group('AdjustMembershipDatesResult', () {
    test('maps a window pushed forward a week', () {
      final AdjustMembershipDatesResult result =
          AdjustMembershipDatesResult.fromJson(<String, dynamic>{
        'membership_id': '11111111-1111-4111-8111-111111111111',
        'member_id': '22222222-2222-4222-8222-222222222222',
        'previous_start_date': '2026-09-01',
        'previous_end_date': '2026-09-30',
        'start_date': '2026-09-08',
        'end_date': '2026-10-07',
        'days_moved': 7,
        'days_changed': 7,
        'status': 'upcoming',
      });

      expect(result.previousStartDate, DateTime.utc(2026, 9, 1));
      expect(result.previousEndDate, DateTime.utc(2026, 9, 30));
      expect(result.startDate, DateTime.utc(2026, 9, 8));
      expect(result.endDate, DateTime.utc(2026, 10, 7));
      expect(result.daysMoved, 7);
      expect(result.status, MembershipStatus.upcoming);
    });

    test('a window pulled earlier reports negative day counts', () {
      final AdjustMembershipDatesResult result =
          AdjustMembershipDatesResult.fromJson(<String, dynamic>{
        'membership_id': '11111111-1111-4111-8111-111111111111',
        'member_id': '22222222-2222-4222-8222-222222222222',
        'previous_start_date': '2026-09-08',
        'previous_end_date': '2026-10-07',
        'start_date': '2026-09-01',
        'end_date': '2026-09-30',
        'days_moved': -7,
        'days_changed': -7,
        'status': 'active',
      });

      // `date - date` in Postgres is signed. Clamping it here would hide a
      // correction that shortened someone's plan.
      expect(result.daysMoved, -7);
      expect(result.daysChanged, -7);
    });

    test('a session pack keeps a null end date on both sides', () {
      final AdjustMembershipDatesResult result =
          AdjustMembershipDatesResult.fromJson(<String, dynamic>{
        'membership_id': '11111111-1111-4111-8111-111111111111',
        'member_id': '22222222-2222-4222-8222-222222222222',
        'previous_start_date': '2026-09-01',
        'previous_end_date': null,
        'start_date': '2026-09-08',
        'end_date': null,
        'days_moved': 7,
        // `coalesce(p_end_date - previous_end, 0)` -- no window, no change.
        'days_changed': 0,
        'status': 'active',
      });

      expect(result.previousEndDate, isNull);
      expect(result.endDate, isNull);
      expect(result.daysChanged, 0);
    });
  });
}
