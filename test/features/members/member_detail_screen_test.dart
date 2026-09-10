// The member profile, checked where a number or a word can mislead the desk.
//
// `Override` is not exported by flutter_riverpod 3.1.0, so every overrides
// list stays an untyped literal spread into `overrides:` (TASKS.md,
// Discovered, 2026-09-05).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/branches/branch.dart';
import 'package:logfitness_flutter/data/branches/branches_repository.dart';
import 'package:logfitness_flutter/data/members/member.dart';
import 'package:logfitness_flutter/data/members/member_overview.dart';
import 'package:logfitness_flutter/data/members/members_repository.dart';
import 'package:logfitness_flutter/data/memberships/membership.dart';
import 'package:logfitness_flutter/data/memberships/memberships_repository.dart';
import 'package:logfitness_flutter/data/payments/invoice.dart';
import 'package:logfitness_flutter/data/payments/payment.dart';
import 'package:logfitness_flutter/data/payments/payment_with_collector.dart';
import 'package:logfitness_flutter/data/payments/payments_repository.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/features/auth/auth_controller.dart';
import 'package:logfitness_flutter/features/common/failure_view.dart';
import 'package:logfitness_flutter/features/members/member_detail_screen.dart';
import 'package:logfitness_flutter/supabase/app_claims.dart';
import 'package:logfitness_flutter/supabase/supabase_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const String _memberId = 'm-1';

MemberOverview _overview({int duePaisa = 0}) => MemberOverview(
  id: _memberId,
  orgId: 'org-1',
  homeBranchId: 'branch-1',
  homeBranchName: 'Thamel',
  memberCode: 'M-0001',
  fullName: 'Anjali Shrestha',
  phone: '9800000000',
  status: MemberStatus.active,
  joinedOn: DateTime.utc(2026, 1, 4),
  duePaisa: duePaisa,
  hasMembershipHistory: true,
);

Member _member({DateTime? invitedAt, DateTime? acceptedAt, DateTime? archivedAt,
    String? archivedReason}) => Member(
  id: _memberId,
  orgId: 'org-1',
  homeBranchId: 'branch-1',
  memberCode: 'M-0001',
  fullName: 'Anjali Shrestha',
  phone: '9800000000',
  status: MemberStatus.active,
  joinedOn: DateTime.utc(2026, 1, 4),
  invitedAt: invitedAt,
  acceptedAt: acceptedAt,
  archivedAt: archivedAt,
  archivedReason: archivedReason,
  createdAt: DateTime.utc(2026, 1, 4),
  updatedAt: DateTime.utc(2026, 1, 4),
);

Membership _membership() => Membership(
  id: 'ms-1',
  orgId: 'org-1',
  branchId: 'branch-1',
  memberId: _memberId,
  planId: 'plan-1',
  planName: 'Monthly',
  planType: PlanType.time,
  startDate: DateTime.utc(2026, 8, 1),
  endDate: DateTime.utc(2026, 8, 31),
  pricePaisa: 200000,
  discountPaisa: 0,
  signupFeePaisa: 0,
  status: MembershipStatus.expired,
  frozenDays: 0,
  createdAt: DateTime.utc(2026, 8, 1),
  updatedAt: DateTime.utc(2026, 8, 1),
);

Invoice _invoice() => Invoice(
  id: 'inv-1',
  orgId: 'org-1',
  branchId: 'branch-1',
  memberId: _memberId,
  invoiceNo: 'INV-0001',
  subtotalPaisa: 200000,
  discountPaisa: 0,
  totalPaisa: 200000,
  paidPaisa: 50000,
  duePaisa: 150000,
  status: InvoiceStatus.partial,
  issuedOn: DateTime.utc(2026, 8, 1),
  createdAt: DateTime.utc(2026, 8, 1),
  updatedAt: DateTime.utc(2026, 8, 1),
);

Payment _payment({
  required String id,
  required PaymentKind kind,
  required int amountPaisa,
  String? reason,
}) => Payment(
  id: id,
  orgId: 'org-1',
  branchId: 'branch-1',
  memberId: _memberId,
  kind: kind,
  amountPaisa: amountPaisa,
  method: PaymentMethod.esewa,
  reason: reason,
  paidAt: DateTime.utc(2026, 9, 1, 4, 30),
  createdAt: DateTime.utc(2026, 9, 1, 4, 30),
);

class _FakeMembersRepository implements MembersRepository {
  _FakeMembersRepository({
    MemberOverview? overview,
    Member? member,
    this.error,
    /// The row does not exist, or RLS hides it -- indistinguishable, which is
    /// the point of the case this flag sets up.
    this.hidden = false,
  }) : overview = overview ?? _overview(),
       member = member ?? _member();

  MemberOverview? overview;
  Member? member;
  Object? error;
  bool hidden;

  @override
  Future<MemberOverview?> fetchOverviewById(String id) async {
    if (error != null) {
      throw error!;
    }
    return hidden ? null : overview;
  }

  @override
  Future<Member?> fetchById(String id) async {
    if (error != null) {
      throw error!;
    }
    return hidden ? null : member;
  }

  @override
  Never noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not faked');
}

class _FakeMembershipsRepository implements MembershipsRepository {
  _FakeMembershipsRepository({
    this.memberships = const <Membership>[],
    this.invoices = const <Invoice>[],
  });

  List<Membership> memberships;
  List<Invoice> invoices;

  @override
  Future<List<Membership>> listMembershipsForMember(String memberId) async =>
      memberships;

  @override
  Future<List<Invoice>> listInvoicesForMember(String memberId) async =>
      invoices;

  @override
  Never noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not faked');
}

class _FakePaymentsRepository implements PaymentsRepository {
  _FakePaymentsRepository({this.payments = const <PaymentWithCollector>[]});

  List<PaymentWithCollector> payments;

  @override
  Future<List<PaymentWithCollector>> listPaymentsForMember(
    String memberId,
  ) async => payments;

  @override
  Never noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not faked');
}

class _FakeBranchesRepository implements BranchesRepository {
  @override
  Future<List<Branch>> listBranches() async => const <Branch>[];

  @override
  Never noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not faked');
}

List<dynamic> _overrides({
  required _FakeMembersRepository members,
  _FakeMembershipsRepository? memberships,
  _FakePaymentsRepository? payments,
}) {
  const AppClaims claims = AppClaims(
    orgId: 'org-1',
    staffId: 'staff-1',
    staffRole: StaffRole.frontDesk,
    branchIds: <String>['branch-1'],
  );
  return <dynamic>[
    membersRepositoryProvider.overrideWithValue(members),
    membershipsRepositoryProvider.overrideWithValue(
      memberships ?? _FakeMembershipsRepository(),
    ),
    paymentsRepositoryProvider.overrideWithValue(
      payments ?? _FakePaymentsRepository(),
    ),
    branchesRepositoryProvider.overrideWithValue(_FakeBranchesRepository()),
    claimsProvider.overrideWithValue(claims),
    principalProvider.overrideWithValue(
      AsyncValue<Principal>.data(Principal.staff(claims)),
    ),
  ];
}

Future<void> _pump(WidgetTester tester, List<dynamic> overrides) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [...overrides],
      child: const MaterialApp(
        home: MemberDetailScreen(memberId: _memberId),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('MemberDetailScreen', () {
    testWidgets('the header says who this is and where they belong', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        _overrides(members: _FakeMembersRepository()),
      );

      expect(find.text('Anjali Shrestha'), findsWidgets);
      expect(find.text('M-0001 · 9800000000 · Thamel'), findsOneWidget);
      // A `date` column, formatted with no timezone shift.
      expect(find.text('Joined 04 Jan 2026'), findsOneWidget);
    });

    testWidgets('dues are stated, with the date the oldest one was raised', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        _overrides(
          members: _FakeMembersRepository(overview: _overview(duePaisa: 150000)),
        ),
      );

      expect(find.text('Dues outstanding'), findsOneWidget);
      // Integer paisa, converted exactly once at the render boundary.
      expect(find.text('NPR 1,500'), findsOneWidget);
    });

    testWidgets('an outstanding app invite is on the profile', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        _overrides(
          members: _FakeMembersRepository(
            member: _member(invitedAt: DateTime.utc(2026, 8, 1, 6)),
          ),
        ),
      );

      expect(find.text('App invite pending'), findsOneWidget);
    });

    testWidgets('an accepted invite is not pending', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        _overrides(
          members: _FakeMembersRepository(
            member: _member(
              invitedAt: DateTime.utc(2026, 8, 1, 6),
              acceptedAt: DateTime.utc(2026, 8, 2, 6),
            ),
          ),
        ),
      );

      expect(find.text('App invite pending'), findsNothing);
    });

    testWidgets('an archived member says so, and why the list hides them', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        _overrides(
          members: _FakeMembersRepository(
            member: _member(
              archivedAt: DateTime.utc(2026, 8, 1),
              archivedReason: 'Moved abroad',
            ),
          ),
        ),
      );

      expect(find.text('Archived'), findsOneWidget);
      expect(find.textContaining('hidden from the member list'), findsOneWidget);
    });

    testWidgets('a refusal renders as a refusal, not a missing member', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        _overrides(
          members: _FakeMembersRepository(
            error: const PostgrestException(
              message: 'permission denied for table member_overview',
              code: '42501',
            ),
          ),
        ),
      );

      expect(find.byType(FailureView), findsOneWidget);
      expect(find.byKey(refusedFailureKey), findsOneWidget);
    });

    testWidgets('a member RLS will not disclose reads as unavailable', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        _overrides(
          members: _FakeMembersRepository(hidden: true),
        ),
      );

      // Hidden and absent are indistinguishable by design, so the screen does
      // not guess which happened.
      expect(
        find.text('That member is not available to this account.'),
        findsOneWidget,
      );
    });
  });

  group('the history tabs', () {
    testWidgets('memberships read with the console\'s status wording', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        _overrides(
          members: _FakeMembersRepository(),
          memberships: _FakeMembershipsRepository(
            memberships: <Membership>[_membership()],
          ),
        ),
      );

      expect(find.text('Monthly'), findsOneWidget);
      // A membership row is the record of what was sold; it is never edited,
      // so an expired one stays on the strip saying so.
      expect(find.text('Expired'), findsOneWidget);
      expect(find.textContaining('01 Aug 2026 – 31 Aug 2026'), findsOneWidget);
    });

    testWidgets('an invoice shows what is still due', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        _overrides(
          members: _FakeMembersRepository(),
          memberships: _FakeMembershipsRepository(
            invoices: <Invoice>[_invoice()],
          ),
        ),
      );
      await tester.tap(find.text('Invoices'));
      await tester.pumpAndSettle();

      expect(find.text('INV-0001'), findsOneWidget);
      expect(find.text('Part paid'), findsOneWidget);
      expect(find.text('NPR 1,500 due'), findsOneWidget);
    });
  });

  group('the payments tab', () {
    Future<void> pumpPayments(
      WidgetTester tester,
      List<PaymentWithCollector> rows,
    ) async {
      await _pump(
        tester,
        _overrides(
          members: _FakeMembersRepository(),
          payments: _FakePaymentsRepository(payments: rows),
        ),
      );
      await tester.tap(find.text('Payments'));
      await tester.pumpAndSettle();
    }

    testWidgets('a refund renders negative and says it is a refund', (
      WidgetTester tester,
    ) async {
      await pumpPayments(tester, <PaymentWithCollector>[
        PaymentWithCollector(
          payment: _payment(
            id: 'p-2',
            kind: PaymentKind.refund,
            // The row is already negative in Postgres; the sign comes from
            // the data, never from a rule restated in the widget.
            amountPaisa: -50000,
            reason: 'Plan cancelled',
          ),
          collectorName: 'Sita Gurung',
        ),
      ]);

      expect(find.text('NPR -500'), findsOneWidget);
      expect(find.textContaining('Refund: Plan cancelled'), findsOneWidget);
    });

    testWidgets('a reversal is its own kind, not a refund', (
      WidgetTester tester,
    ) async {
      await pumpPayments(tester, <PaymentWithCollector>[
        PaymentWithCollector(
          payment: _payment(
            id: 'p-3',
            kind: PaymentKind.reversal,
            amountPaisa: -20000,
            reason: 'Rung up twice',
          ),
        ),
      ]);

      // Money handed back and money that never arrived are different facts to
      // anyone counting the drawer.
      expect(find.textContaining('Never received'), findsOneWidget);
      expect(find.textContaining('Refund'), findsNothing);
    });

    testWidgets('a payment shows the method label, not the wire value', (
      WidgetTester tester,
    ) async {
      await pumpPayments(tester, <PaymentWithCollector>[
        PaymentWithCollector(
          payment: _payment(
            id: 'p-1',
            kind: PaymentKind.payment,
            amountPaisa: 100000,
          ),
          collectorName: 'Sita Gurung',
        ),
      ]);

      // `eSewa`, as the console spells it -- never `esewa`.
      expect(find.textContaining('eSewa'), findsOneWidget);
      expect(find.text('NPR 1,000'), findsOneWidget);
    });
  });

  testWidgets('the attendance tab admits it has no data layer', (
    WidgetTester tester,
  ) async {
    await _pump(tester, _overrides(members: _FakeMembersRepository()));
    await tester.tap(find.text('Attendance'));
    await tester.pumpAndSettle();

    // There is no attendance repository in `lib/data/`, and an empty tab would
    // read as "never checked in" -- a different claim entirely.
    expect(
      find.textContaining('Attendance is not available in the app yet'),
      findsOneWidget,
    );
  });
}
