// The member screens' words, pinned to the console's.
//
// Every expectation here is a string copied out of
// `logfitness_saas/lib/members.ts` or
// `components/members/member-status-badge.tsx`. If one of them changes on one
// surface and not the other, the two clients start describing the same row
// differently and this test is what says so.
//
// Each label function is also checked across the *whole* enum, not a hand-
// written subset. `PaymentKind.reversal` existed in Postgres for two days
// before the Dart enum carried it, and the enum's own test passed throughout
// because it had hardcoded a two-value list (TASKS.md, Discovered,
// 2026-09-09). A missing value has to fail here, not hide.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/members/member_list_query.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/features/members/member_labels.dart';

void main() {
  group('labels match the console', () {
    test('member status — MEMBER_STATUS_LABELS', () {
      expect(
        <MemberStatus, String>{
          for (final MemberStatus status in MemberStatus.values)
            status: memberStatusText(status),
        },
        <MemberStatus, String>{
          MemberStatus.active: 'Active',
          MemberStatus.expired: 'Expired',
          MemberStatus.frozen: 'Frozen',
          MemberStatus.left: 'Left',
        },
      );
    });

    test('membership status — MEMBERSHIP_STATUS_LABELS', () {
      expect(
        <MembershipStatus, String>{
          for (final MembershipStatus status in MembershipStatus.values)
            status: membershipStatusLabel(status),
        },
        <MembershipStatus, String>{
          MembershipStatus.upcoming: 'Starts later',
          MembershipStatus.active: 'Active',
          MembershipStatus.frozen: 'Frozen',
          MembershipStatus.expired: 'Expired',
          MembershipStatus.cancelled: 'Cancelled',
        },
      );
    });

    test('payment method — PAYMENT_METHOD_LABELS', () {
      expect(
        <PaymentMethod, String>{
          for (final PaymentMethod method in PaymentMethod.values)
            method: paymentMethodLabel(method),
        },
        <PaymentMethod, String>{
          PaymentMethod.cash: 'Cash',
          PaymentMethod.esewa: 'eSewa',
          PaymentMethod.khalti: 'Khalti',
          PaymentMethod.fonepay: 'FonePay',
          PaymentMethod.bank: 'Bank transfer',
          PaymentMethod.card: 'Card',
        },
      );
    });

    test('payment kind — PAYMENT_KIND_LABELS, reversal included', () {
      expect(
        <PaymentKind, String>{
          for (final PaymentKind kind in PaymentKind.values)
            kind: paymentKindLabel(kind),
        },
        <PaymentKind, String>{
          PaymentKind.payment: 'Payment',
          PaymentKind.refund: 'Refund',
          // Money that never arrived, as against money handed back.
          PaymentKind.reversal: 'Never received',
        },
      );
    });

    test('invoice status — INVOICE_STATUS_LABELS', () {
      expect(
        <InvoiceStatus, String>{
          for (final InvoiceStatus status in InvoiceStatus.values)
            status: invoiceStatusLabel(status),
        },
        <InvoiceStatus, String>{
          InvoiceStatus.unpaid: 'Unpaid',
          InvoiceStatus.partial: 'Part paid',
          InvoiceStatus.paid: 'Paid',
          InvoiceStatus.voided: 'Void',
        },
      );
    });

    test('plan type — PLAN_TYPE_LABELS', () {
      expect(
        <PlanType, String>{
          for (final PlanType type in PlanType.values)
            type: planTypeLabel(type),
        },
        <PlanType, String>{
          PlanType.time: 'Time-based',
          PlanType.sessionPack: 'Session pack',
        },
      );
    });

    test('filter chips — STATUS_OPTIONS in member-search.tsx', () {
      expect(
        <MemberListFilter?, String>{
          null: memberListFilterLabel(null),
          for (final MemberListFilter filter in MemberListFilter.values)
            filter: memberListFilterLabel(filter),
        },
        <MemberListFilter?, String>{
          null: 'All statuses',
          MemberListFilter.active: 'Active',
          MemberListFilter.expiring: 'Expiring in 7 days',
          MemberListFilter.expired: 'Expired',
          MemberListFilter.frozen: 'Frozen',
          MemberListFilter.dues: 'Dues outstanding',
          MemberListFilter.left: 'Left',
          MemberListFilter.archived: 'Archived',
        },
      );
    });
  });

  group('memberStatusLabel narrows what the status column cannot say', () {
    test('a member with nothing ever sold reads as New, not Expired', () {
      expect(
        memberStatusLabel(MemberStatus.expired, hasMembershipHistory: false),
        'New',
      );
    });

    test('a plan sold for a future date reads as Starts later', () {
      expect(
        memberStatusLabel(
          MemberStatus.expired,
          membershipStatus: MembershipStatus.upcoming,
        ),
        'Starts later',
      );
    });

    test('the seven-day window is the renewal conversation', () {
      expect(
        memberStatusLabel(MemberStatus.active, daysToExpiry: 7),
        'Expiring in 7 days',
      );
      expect(
        memberStatusLabel(MemberStatus.active, daysToExpiry: 1),
        'Expiring in 1 day',
      );
      expect(
        memberStatusLabel(MemberStatus.active, daysToExpiry: 0),
        'Expires today',
      );
      // Eight days out is simply active; the console draws the line at seven.
      expect(memberStatusLabel(MemberStatus.active, daysToExpiry: 8), 'Active');
    });

    test('an expired member with history still reads as Expired', () {
      expect(memberStatusLabel(MemberStatus.expired), 'Expired');
    });
  });

  testWidgets('MemberStatusBadge renders the narrowed label', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MemberStatusBadge(
            status: MemberStatus.expired,
            hasMembershipHistory: false,
          ),
        ),
      ),
    );

    expect(find.text('New'), findsOneWidget);
    // Announced, so the badge is not colour-only.
    expect(
      tester.getSemantics(find.byType(MemberStatusBadge)).label,
      contains('Status: New'),
    );
  });
}
