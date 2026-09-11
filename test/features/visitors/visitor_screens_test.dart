// The visitor log's screens, checked where they can fail silently.
//
// `Override` is not exported by flutter_riverpod 3.1.0, so every overrides
// list stays an untyped literal (TASKS.md, Discovered, 2026-09-05).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/visitors/visitor.dart';
import 'package:logfitness_flutter/data/visitors/visitors_repository.dart';
import 'package:logfitness_flutter/data/plans/membership_plan.dart';
import 'package:logfitness_flutter/data/plans/plans_repository.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/format/dates.dart';
import 'package:logfitness_flutter/features/auth/auth_controller.dart';
import 'package:logfitness_flutter/features/common/failure_view.dart';
import 'package:logfitness_flutter/features/visitors/visitor_form_screen.dart';
import 'package:logfitness_flutter/features/visitors/visitor_log_screen.dart';
import 'package:logfitness_flutter/features/visitors/widgets/visitor_tile.dart';
import 'package:logfitness_flutter/supabase/app_claims.dart';
import 'package:logfitness_flutter/supabase/supabase_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Visitor _visitor(String id, {String name = 'Anjali Shrestha'}) => Visitor(
      id: id,
      orgId: 'org-1',
      branchId: 'branch-1',
      kind: VisitorKind.enquiry,
      fullName: name,
      phone: '9800000000',
      visitedOn: DateTime.utc(2026, 9, 9),
      status: VisitorStatus.isNew,
      createdAt: DateTime.utc(2026, 9, 9, 4, 30),
      updatedAt: DateTime.utc(2026, 9, 9, 4, 30),
    );

class _FakeVisitorsRepository implements VisitorsRepository {
  _FakeVisitorsRepository({this.rows = const <Visitor>[], this.error});

  List<Visitor> rows;
  Object? error;

  VisitorListFilter? lastFilter;
  Map<String, Object?>? lastInsert;

  @override
  Future<VisitorPage> listVisitors(VisitorListFilter filter) async {
    lastFilter = filter;
    if (error != null) {
      throw error!;
    }
    return VisitorPage(
      rows: rows,
      total: rows.length,
      page: filter.page,
      pageSize: filter.pageSize,
    );
  }

  @override
  Future<Visitor?> getVisitor(String visitorId) async => _visitor(visitorId);

  @override
  Future<String> insertVisitor({
    required String orgId,
    required String branchId,
    required String fullName,
    required String phone,
    VisitorKind kind = VisitorKind.enquiry,
    DateTime? visitedOn,
    String? note,
    String? interestedPlanId,
  }) async {
    lastInsert = <String, Object?>{
      'fullName': fullName,
      'phone': phone,
      'kind': kind,
      'visitedOn': visitedOn,
      'note': note,
      'interestedPlanId': interestedPlanId,
    };
    return 'v-new';
  }

  @override
  Future<void> updateVisitor(
    String visitorId, {
    Object? fullName = visitorFieldUnchanged,
    Object? phone = visitorFieldUnchanged,
    Object? kind = visitorFieldUnchanged,
    Object? visitedOn = visitorFieldUnchanged,
    Object? note = visitorFieldUnchanged,
    Object? interestedPlanId = visitorFieldUnchanged,
    Object? status = visitorFieldUnchanged,
  }) async {}

  @override
  Future<void> deleteVisitor(String visitorId) async {}

  @override
  Future<void> convertVisitor(String visitorId, String memberId) async {}
}

AppClaims _claims() => const AppClaims(
      orgId: 'org-1',
      staffId: 'staff-1',
      staffRole: StaffRole.frontDesk,
      branchIds: <String>['branch-1'],
    );

class _FakePlansRepository implements PlansRepository {
  _FakePlansRepository({this.plans = const <MembershipPlan>[]});

  final List<MembershipPlan> plans;
  String? lastBranchId;

  @override
  Future<List<MembershipPlan>> listPlansForBranch(String branchId) async {
    lastBranchId = branchId;
    return plans;
  }

  @override
  Never noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not faked');
}

MembershipPlan _plan(String id, String name) => MembershipPlan(
      id: id,
      orgId: 'org-1',
      name: name,
      planType: PlanType.time,
      pricePaisa: 700000,
      signupFeePaisa: 0,
      branchIds: const <String>[],
      isActive: true,
      sortOrder: 0,
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );

List<dynamic> _overrides(
  _FakeVisitorsRepository repository, {
  _FakePlansRepository? plans,
}) {
  final claims = _claims();
  return <dynamic>[
    visitorsRepositoryProvider.overrideWithValue(repository),
    plansRepositoryProvider.overrideWithValue(
      plans ?? _FakePlansRepository(),
    ),
    claimsProvider.overrideWithValue(claims),
    principalProvider.overrideWithValue(
      AsyncValue<Principal>.data(Principal.staff(claims)),
    ),
  ];
}

/// The form is a ListView and the submit button sits below the fold once the
/// plan picker is in play; a ListView does not build what is off screen, so it
/// has to be scrolled into existence before it can be tapped.
Future<void> _submitForm(WidgetTester tester) async {
  final submit = find.byKey(const ValueKey<String>('visitor-form-submit'));
  await tester.scrollUntilVisible(submit, 200, scrollable: find.byType(Scrollable).first);
  await tester.pumpAndSettle();
  await tester.tap(submit);
  await tester.pumpAndSettle();
}

Future<void> _pump(
  WidgetTester tester,
  Widget child,
  _FakeVisitorsRepository repository, {
  _FakePlansRepository? plans,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      // Spread into an untyped literal so inference supplies `Override`,
      // which flutter_riverpod 3.1.0 does not export (TASKS.md, Discovered).
      overrides: [..._overrides(repository, plans: plans)],
      child: MaterialApp(home: child),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('VisitorLogScreen', () {
    testWidgets('renders a row per walk-in', (WidgetTester tester) async {
      final repository = _FakeVisitorsRepository(
        rows: <Visitor>[_visitor('v-1'), _visitor('v-2', name: 'Bikash Rai')],
      );
      await _pump(tester, const VisitorLogScreen(), repository);

      expect(find.byType(VisitorTile), findsNWidgets(2));
      expect(find.text('Anjali Shrestha'), findsOneWidget);
      expect(find.text('Bikash Rai'), findsOneWidget);
    });

    testWidgets('opens on the callbacks still owed, not the whole log',
        (WidgetTester tester) async {
      final repository = _FakeVisitorsRepository(rows: <Visitor>[_visitor('v-1')]);
      await _pump(tester, const VisitorLogScreen(), repository);

      // `open` is new + contacted, matching `visitors_open_idx` upstream.
      expect(repository.lastFilter?.status, VisitorStatusFilter.open);
    });

    testWidgets('an empty log says so and offers the way out of it',
        (WidgetTester tester) async {
      final repository = _FakeVisitorsRepository();
      await _pump(tester, const VisitorLogScreen(), repository);

      expect(find.text('No callbacks outstanding.'), findsOneWidget);
      expect(find.text('Log a walk-in'), findsOneWidget);
    });

    testWidgets('a refusal renders as a refusal, not an empty log',
        (WidgetTester tester) async {
      final repository = _FakeVisitorsRepository(
        error: const PostgrestException(
          message: 'permission denied for table visitors',
          code: '42501',
        ),
      );
      await _pump(tester, const VisitorLogScreen(), repository);

      // The distinction this whole surface exists for: refused is not empty,
      // and it is not a generic error either.
      expect(find.byType(FailureView), findsOneWidget);
      expect(find.textContaining('refused'), findsWidgets);
    });

    testWidgets('a filter chip changes what is asked for',
        (WidgetTester tester) async {
      final repository = _FakeVisitorsRepository(rows: <Visitor>[_visitor('v-1')]);
      await _pump(tester, const VisitorLogScreen(), repository);

      await tester.tap(find.byKey(const ValueKey<String>('visitor-filter-lost')));
      await tester.pumpAndSettle();

      expect(repository.lastFilter?.status, VisitorStatusFilter.lost);
    });
  });

  group('VisitorFormScreen', () {
    testWidgets('refuses a blank name and a blank phone',
        (WidgetTester tester) async {
      final repository = _FakeVisitorsRepository();
      await _pump(tester, const VisitorFormScreen(), repository);

      await _submitForm(tester);

      expect(find.text('A name is required.'), findsOneWidget);
      expect(find.text('A phone number is required.'), findsOneWidget);
      expect(repository.lastInsert, isNull);
    });

    testWidgets('sends the gym\'s today, not the device\'s', (
      WidgetTester tester,
    ) async {
      final repository = _FakeVisitorsRepository();
      await _pump(tester, const VisitorFormScreen(), repository);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Full name'),
        'Anjali Shrestha',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Phone'),
        '9800000000',
      );
      await _submitForm(tester);

      // Prefilled and sent, matching the console -- but resolved through the
      // org's offset, never `DateTime.now()`. At 00:30 in Kathmandu the
      // device's UTC date is still yesterday, and a walk-in logged then would
      // land on the wrong calendar day.
      expect(repository.lastInsert, isNotNull);
      final sent = repository.lastInsert!['visitedOn'] as DateTime?;
      expect(sent, isNotNull);
      expect(sent, todayInOrgTimezone());
      // A date-only value: UTC midnight, so no offset can move the day.
      expect(sent!.isUtc, isTrue);
      expect(sent.hour, 0);
      expect(repository.lastInsert!['fullName'], 'Anjali Shrestha');
    });

    testWidgets('offers the plans sold at that branch, and sends the choice', (
      WidgetTester tester,
    ) async {
      final repository = _FakeVisitorsRepository();
      final plans = _FakePlansRepository(
        plans: <MembershipPlan>[
          _plan('p-1', 'Gym Only'),
          _plan('p-2', 'Gym + Cardio'),
        ],
      );
      await _pump(tester, const VisitorFormScreen(), repository, plans: plans);

      // Per branch, not per org: a plan not on sale where they walked in is not
      // a thing they can be sold.
      expect(plans.lastBranchId, 'branch-1');

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Full name'),
        'Anjali Shrestha',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Phone'),
        '9800000000',
      );

      final picker = find.byKey(
        const ValueKey<String>('visitor-interested-plan'),
      );
      await tester.scrollUntilVisible(picker, 200,
          scrollable: find.byType(Scrollable).first);
      await tester.tap(picker);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Gym + Cardio').last);
      await tester.pumpAndSettle();

      await _submitForm(tester);

      expect(repository.lastInsert!['interestedPlanId'], 'p-2');
    });

    testWidgets('a walk-in who did not say sends no plan', (
      WidgetTester tester,
    ) async {
      final repository = _FakeVisitorsRepository();
      final plans = _FakePlansRepository(
        plans: <MembershipPlan>[_plan('p-1', 'Gym Only')],
      );
      await _pump(tester, const VisitorFormScreen(), repository, plans: plans);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Full name'),
        'Anjali Shrestha',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Phone'),
        '9800000000',
      );
      await _submitForm(tester);

      // "Not said" is an answer, and it is the default -- the field is optional
      // and nobody should have to dismiss it.
      expect(repository.lastInsert!['interestedPlanId'], isNull);
    });

    testWidgets('a single-branch gym is not asked which branch', (
      WidgetTester tester,
    ) async {
      final repository = _FakeVisitorsRepository();
      await _pump(tester, const VisitorFormScreen(), repository);

      // One branch is a question with one answer. It is still sent.
      expect(find.widgetWithText(DropdownButtonFormField<String>, 'Branch'),
          findsNothing);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Full name'),
        'Anjali Shrestha',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Phone'),
        '9800000000',
      );
      await _submitForm(tester);

      expect(repository.lastInsert, isNotNull);
    });

    testWidgets('the form explains the two kinds, as the console does', (
      WidgetTester tester,
    ) async {
      await _pump(tester, const VisitorFormScreen(), _FakeVisitorsRepository());

      // One word does not say how an enquiry differs from a guest.
      expect(find.text('Enquiry — asked about joining'), findsOneWidget);
      expect(find.text('Guest — trained for the day'), findsOneWidget);
    });

    testWidgets('says out loud that blank means today',
        (WidgetTester tester) async {
      final repository = _FakeVisitorsRepository();
      await _pump(tester, const VisitorFormScreen(), repository);

      expect(find.textContaining("this gym's own reckoning"), findsOneWidget);
    });
  });
}
