// Settings -> Plans: list, add, edit, and put on or off sale.
//
// `Override` is not exported by flutter_riverpod 3.1.0, so every overrides
// list stays an untyped literal.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/app/theme.dart';
import 'package:logfitness_flutter/data/branches/branch.dart';
import 'package:logfitness_flutter/data/branches/branches_repository.dart';
import 'package:logfitness_flutter/data/plans/membership_plan.dart';
import 'package:logfitness_flutter/data/plans/plans_repository.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/domain/validation/plan_form.dart';
import 'package:logfitness_flutter/features/auth/auth_controller.dart';
import 'package:logfitness_flutter/features/settings/catalogue/plan_form_screen.dart';
import 'package:logfitness_flutter/features/settings/catalogue/plans_screen.dart';
import 'package:logfitness_flutter/supabase/app_claims.dart';
import 'package:logfitness_flutter/supabase/supabase_providers.dart';

MembershipPlan _plan(
  String id,
  String name, {
  bool active = true,
  List<String> branches = const <String>[],
  int price = 150000,
  int fee = 0,
  PlanType type = PlanType.time,
}) => MembershipPlan(
  id: id,
  orgId: 'org-1',
  name: name,
  planType: type,
  durationDays: type == PlanType.time ? 30 : null,
  sessionCount: type == PlanType.sessionPack ? 10 : null,
  pricePaisa: price,
  signupFeePaisa: fee,
  branchIds: branches,
  isActive: active,
  sortOrder: 0,
  createdAt: DateTime.utc(2026, 9, 1),
  updatedAt: DateTime.utc(2026, 9, 1),
);

Branch _branch(String id, String name) => Branch(
  id: id,
  orgId: 'org-1',
  name: name,
  status: BranchStatus.active,
  createdAt: DateTime.utc(2026, 9, 1),
  updatedAt: DateTime.utc(2026, 9, 1),
);

class _FakePlans implements PlansRepository {
  _FakePlans(this.rows);

  List<MembershipPlan> rows;
  final List<PlanValues> created = <PlanValues>[];
  final List<(String, PlanValues)> updated = <(String, PlanValues)>[];
  final List<(String, bool)> toggled = <(String, bool)>[];
  String? createdOrg;
  Object? writeError;

  @override
  Future<List<MembershipPlan>> listPlans() async => rows;

  @override
  Future<String> createPlan({
    required String orgId,
    required PlanValues values,
  }) async {
    if (writeError != null) throw writeError!;
    createdOrg = orgId;
    created.add(values);
    return 'new';
  }

  @override
  Future<void> updatePlan(String planId, PlanValues values) async {
    if (writeError != null) throw writeError!;
    updated.add((planId, values));
  }

  @override
  Future<void> setPlanActive(String planId, bool isActive) async {
    if (writeError != null) throw writeError!;
    toggled.add((planId, isActive));
    rows = <MembershipPlan>[
      for (final MembershipPlan p in rows)
        if (p.id == planId)
          _plan(p.id, p.name, active: isActive, branches: p.branchIds)
        else
          p,
    ];
  }

  @override
  Never noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not faked');
}

Future<void> _pump(
  WidgetTester tester,
  _FakePlans plans, {
  StaffRole role = StaffRole.owner,
  List<String> mine = const <String>[],
  double width = 360,
  double textScale = 1,
}) async {
  final AppClaims claims = AppClaims(
    orgId: 'org-1',
    staffId: 'staff-1',
    staffRole: role,
    branchIds: mine,
  );
  tester.view.physicalSize = Size(width * 3, 800 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        plansRepositoryProvider.overrideWithValue(plans),
        claimsProvider.overrideWithValue(claims),
        principalProvider.overrideWithValue(
          AsyncValue<Principal>.data(Principal.staff(claims)),
        ),
        branchesProvider.overrideWith(
          (ref) async => <Branch>[
            _branch('branch-a', 'Baneshwor'),
            _branch('branch-b', 'Lalitpur'),
          ],
        ),
      ],
      child: MaterialApp(
        theme: appLightTheme,
        builder: (BuildContext context, Widget? child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: const PlansScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('lists plans with a clear Active / Inactive mark', (
    tester,
  ) async {
    await _pump(
      tester,
      _FakePlans(<MembershipPlan>[
        _plan('1', 'Monthly', fee: 50000),
        _plan(
          '2',
          'Old quarterly',
          active: false,
          branches: <String>['branch-a'],
        ),
      ]),
    );
    expect(find.text('Monthly'), findsOneWidget);
    expect(find.text('NPR 1,500'), findsNWidgets(2));
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Inactive'), findsOneWidget);
    expect(find.text('Joining fee NPR 500'), findsOneWidget);
    expect(find.text('Sold at: Every branch'), findsOneWidget);
    expect(find.text('Sold at: Baneshwor'), findsOneWidget);
    expect(find.textContaining('web console'), findsNothing);
    expect(find.text('Add plan'), findsOneWidget);
  });

  testWidgets('empty catalogue invites the first plan', (tester) async {
    await _pump(tester, _FakePlans(<MembershipPlan>[]));
    expect(find.textContaining('Add the first one'), findsOneWidget);
    expect(find.text('Add plan'), findsOneWidget);
  });

  testWidgets('does not overflow at 320 wide and 2x text', (tester) async {
    await _pump(
      tester,
      _FakePlans(<MembershipPlan>[
        _plan(
          '1',
          'Twelve month all branches unlimited access premium plan',
          fee: 50000,
          branches: <String>['branch-a', 'branch-b'],
        ),
      ]),
      width: 320,
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Add plan'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      find.text('Where it is sold'),
      200,
      scrollable: find
          .descendant(
            of: find.byType(PlanFormScreen),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('add plan: validates, then writes integer paisa for this org', (
    tester,
  ) async {
    final plans = _FakePlans(<MembershipPlan>[]);
    await _pump(tester, plans);

    await tester.tap(find.text('Add plan'));
    await tester.pumpAndSettle();
    expect(find.text('New plan'), findsOneWidget);
    for (final String title in <String>['Basics', 'Price', 'Term']) {
      expect(find.text(title), findsWidgets);
    }

    // Nothing filled in: refused in words, nothing written.
    await tester.tap(find.byKey(const ValueKey<String>('plan-form-save')));
    await tester.pumpAndSettle();
    expect(find.text('Name is required'), findsOneWidget);
    expect(find.text('Enter an amount'), findsOneWidget);
    expect(find.text('A time plan needs a duration in days'), findsOneWidget);
    expect(plans.created, isEmpty);

    await tester.enterText(
      find.byKey(const ValueKey<String>('plan-name')),
      'Monthly',
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('plan-price')),
      '1500.50',
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('plan-days')),
      '30',
    );
    await tester.tap(find.byKey(const ValueKey<String>('plan-form-save')));
    await tester.pumpAndSettle();

    expect(plans.createdOrg, 'org-1');
    expect(plans.created.single.pricePaisa, 150050);
    expect(plans.created.single.durationDays, 30);
    expect(plans.created.single.branchIds, isEmpty);
    // Back on the list.
    expect(find.text('New plan'), findsNothing);
    expect(find.textContaining('was added to the catalogue'), findsOneWidget);
  });

  testWidgets('a duplicate name is said plainly on the name field', (
    tester,
  ) async {
    final plans = _FakePlans(
      <MembershipPlan>[],
    )..writeError = const AppFailure(FailureKind.duplicate, kPlanDuplicateName);
    await _pump(tester, plans);
    await tester.tap(find.text('Add plan'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey<String>('plan-name')),
      'Monthly',
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('plan-price')),
      '100',
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('plan-days')),
      '30',
    );
    await tester.tap(find.byKey(const ValueKey<String>('plan-form-save')));
    await tester.pumpAndSettle();

    expect(find.text('New plan'), findsOneWidget, reason: 'stays open');
    expect(find.text(kPlanDuplicateName), findsWidgets);
  });

  testWidgets('tapping a plan opens it for editing, prefilled', (tester) async {
    final plans = _FakePlans(<MembershipPlan>[
      _plan('1', 'Monthly', price: 150050),
    ]);
    await _pump(tester, plans);

    await tester.tap(find.byKey(const ValueKey<String>('plan-row-1')));
    await tester.pumpAndSettle();
    expect(find.text('Edit plan'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Monthly'), findsOneWidget);
    expect(find.widgetWithText(TextField, '1500.5'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey<String>('plan-price')),
      '1600',
    );
    await tester.tap(find.byKey(const ValueKey<String>('plan-form-save')));
    await tester.pumpAndSettle();
    expect(plans.updated.single.$1, '1');
    expect(plans.updated.single.$2.pricePaisa, 160000);
  });

  testWidgets('deactivate asks first, and Cancel changes nothing', (
    tester,
  ) async {
    final plans = _FakePlans(<MembershipPlan>[_plan('1', 'Monthly')]);
    await _pump(tester, plans);

    await tester.tap(find.byKey(const ValueKey<String>('plan-menu-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Deactivate'));
    await tester.pumpAndSettle();
    expect(find.text('Deactivate Monthly?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(plans.toggled, isEmpty);

    await tester.tap(find.byKey(const ValueKey<String>('plan-menu-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Deactivate'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('plan-toggle-confirm')));
    await tester.pumpAndSettle();

    expect(plans.toggled.single, ('1', false));
    // The list refreshed from the repository.
    expect(find.text('Inactive'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey<String>('plan-menu-1')));
    await tester.pumpAndSettle();
    expect(find.text('Activate'), findsOneWidget);
  });

  testWidgets('a manager cannot change a plan sold outside their branches', (
    tester,
  ) async {
    final plans = _FakePlans(<MembershipPlan>[
      _plan('1', 'Monthly'),
    ]); // org-wide
    await _pump(
      tester,
      plans,
      role: StaffRole.manager,
      mine: <String>['branch-a'],
    );

    await tester.tap(find.byKey(const ValueKey<String>('plan-menu-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Deactivate'));
    await tester.pumpAndSettle();
    expect(find.text(kPlanEditOutOfScope), findsOneWidget);
    expect(plans.toggled, isEmpty);

    await tester.tap(find.byKey(const ValueKey<String>('plan-row-1')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey<String>('plan-scope-notice')),
      findsOneWidget,
    );
    final FilledButton save = tester.widget(
      find.byKey(const ValueKey<String>('plan-form-save')),
    );
    expect(save.onPressed, isNull);
  });

  testWidgets('a manager is offered only their own branches', (tester) async {
    await _pump(
      tester,
      _FakePlans(<MembershipPlan>[]),
      role: StaffRole.manager,
      mine: <String>['branch-a'],
    );
    await tester.tap(find.text('Add plan'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('plan-branch-branch-a')),
      200,
      scrollable: find
          .descendant(
            of: find.byType(PlanFormScreen),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.text('Baneshwor'), findsOneWidget);
    expect(find.text('Lalitpur'), findsNothing);
    expect(find.text('Pick at least one of your branches.'), findsOneWidget);
    expect(planTypeName(PlanType.sessionPack), 'Session pack');
  });
}
