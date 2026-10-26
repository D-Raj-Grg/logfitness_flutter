// Settings -> Fees: list, add, edit, and put on or off. Owner only.
//
// `Override` is not exported by flutter_riverpod 3.1.0, so every overrides
// list stays an untyped literal.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/app/theme.dart';
import 'package:logfitness_flutter/data/fees/fee.dart';
import 'package:logfitness_flutter/data/fees/fees_repository.dart';
import 'package:logfitness_flutter/data/plans/membership_plan.dart';
import 'package:logfitness_flutter/data/plans/plans_repository.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/domain/validation/fee_form.dart';
import 'package:logfitness_flutter/features/auth/auth_controller.dart';
import 'package:logfitness_flutter/features/settings/catalogue/fees_screen.dart';
import 'package:logfitness_flutter/supabase/app_claims.dart';
import 'package:logfitness_flutter/supabase/supabase_providers.dart';

Fee _fee(
  String id,
  String name, {
  FeeChargeRule rule = FeeChargeRule.once,
  int amount = 50000,
  bool allPlans = true,
  List<String> plans = const <String>[],
  bool active = true,
}) => Fee(
  id: id,
  orgId: 'org-1',
  name: name,
  chargeRule: rule,
  amountPaisa: amount,
  allPlans: allPlans,
  planIds: plans,
  isActive: active,
  sortOrder: 0,
);

MembershipPlan _plan(String id, String name) => MembershipPlan(
  id: id,
  orgId: 'org-1',
  name: name,
  planType: PlanType.time,
  durationDays: 30,
  pricePaisa: 150000,
  signupFeePaisa: 0,
  branchIds: const <String>[],
  isActive: true,
  sortOrder: 0,
  createdAt: DateTime.utc(2026, 9, 1),
  updatedAt: DateTime.utc(2026, 9, 1),
);

class _FakeFees implements FeesRepository {
  _FakeFees(this.rows, {this.enabled = true});

  List<Fee> rows;
  bool enabled;
  final List<FeeValues> created = <FeeValues>[];
  final List<(String, FeeValues)> updated = <(String, FeeValues)>[];
  final List<(String, bool)> toggled = <(String, bool)>[];
  String? createdOrg;
  Object? writeError;

  @override
  Future<List<Fee>> listFees() async => rows;

  @override
  Future<FeeSetup> feeSetup(String orgId) async => FeeSetup(
    fees: rows.where((Fee f) => f.isActive).toList(),
    catalogueEnabled: enabled,
    standardSignupFeePaisa: 0,
  );

  @override
  Future<String> createFee({
    required String orgId,
    required FeeValues values,
  }) async {
    if (writeError != null) throw writeError!;
    createdOrg = orgId;
    created.add(values);
    return 'new';
  }

  @override
  Future<void> updateFee(String feeId, FeeValues values) async {
    if (writeError != null) throw writeError!;
    updated.add((feeId, values));
  }

  @override
  Future<void> setFeeActive(String feeId, bool isActive) async {
    if (writeError != null) throw writeError!;
    toggled.add((feeId, isActive));
    rows = <Fee>[
      for (final Fee f in rows)
        if (f.id == feeId) _fee(f.id, f.name, active: isActive) else f,
    ];
  }

  @override
  Never noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not faked');
}

class _FakePlans implements PlansRepository {
  @override
  Future<List<MembershipPlan>> listPlans() async => <MembershipPlan>[
    _plan('p-1', 'Gym - 1 Month'),
    _plan('p-2', 'Gym - 3 Months'),
  ];

  @override
  Never noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not faked');
}

Future<void> _pump(
  WidgetTester tester,
  _FakeFees fees, {
  StaffRole role = StaffRole.owner,
}) async {
  final AppClaims claims = AppClaims(
    orgId: 'org-1',
    staffId: 'staff-1',
    staffRole: role,
    branchIds: const <String>[],
  );
  tester.view.physicalSize = const Size(360 * 3, 1400 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        feesRepositoryProvider.overrideWithValue(fees),
        plansRepositoryProvider.overrideWithValue(_FakePlans()),
        claimsProvider.overrideWithValue(claims),
        principalProvider.overrideWithValue(
          AsyncValue<Principal>.data(Principal.staff(claims)),
        ),
      ],
      child: MaterialApp(theme: appLightTheme, home: const FeesScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('lists fees with their rule, amount and the plans they cover', (
    tester,
  ) async {
    await _pump(
      tester,
      _FakeFees(<Fee>[
        _fee('1', 'Registration fee'),
        _fee('2', 'Locker', rule: FeeChargeRule.everySale, amount: 10000,
            allPlans: false, plans: <String>['p-1']),
        _fee('3', 'Old fee', active: false),
      ]),
    );
    expect(find.text('Registration fee'), findsOneWidget);
    expect(find.text('Locker'), findsOneWidget);
    expect(find.text('Once, on the first membership'), findsNWidgets(2));
    expect(find.text('On every sale'), findsOneWidget);
    expect(find.text('Applies to: All plans'), findsNWidgets(2));
    expect(find.text('Applies to: Gym - 1 Month'), findsOneWidget);
    expect(find.text('Inactive'), findsOneWidget);
  });

  testWidgets('says plainly when nothing is being charged yet', (tester) async {
    await _pump(tester, _FakeFees(<Fee>[_fee('1', 'Registration fee')], enabled: false));
    expect(find.byKey(const ValueKey<String>('fees-not-charging')), findsOneWidget);
  });

  testWidgets('says nothing about "not charging" once the catalogue is on', (
    tester,
  ) async {
    await _pump(tester, _FakeFees(<Fee>[_fee('1', 'Registration fee')]));
    expect(find.byKey(const ValueKey<String>('fees-not-charging')), findsNothing);
  });

  testWidgets('a manager is not offered Add fee', (tester) async {
    await _pump(
      tester,
      _FakeFees(<Fee>[_fee('1', 'Registration fee')]),
      role: StaffRole.manager,
    );
    expect(find.text('Add fee'), findsNothing);
    expect(find.byKey(const ValueKey<String>('fee-menu-1')), findsNothing);
  });

  testWidgets('add fee: validates, then writes integer paisa for this org', (
    tester,
  ) async {
    final _FakeFees fees = _FakeFees(<Fee>[]);
    await _pump(tester, fees);

    await tester.tap(find.text('Add fee'));
    await tester.pumpAndSettle();

    // Nothing filled in: refused in words, nothing written.
    await tester.tap(find.byKey(const ValueKey<String>('fee-form-save')));
    await tester.pumpAndSettle();
    expect(find.text('Name is required'), findsOneWidget);
    expect(find.text('Enter an amount'), findsOneWidget);
    expect(fees.created, isEmpty);

    await tester.enterText(
      find.byKey(const ValueKey<String>('fee-name')),
      'Card fee',
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('fee-amount')),
      '200',
    );
    await tester.tap(find.byKey(const ValueKey<String>('fee-form-save')));
    await tester.pumpAndSettle();

    expect(fees.createdOrg, 'org-1');
    expect(fees.created.single.name, 'Card fee');
    expect(fees.created.single.amountPaisa, 20000);
    expect(fees.created.single.allPlans, isTrue);
    expect(fees.created.single.chargeRule, FeeChargeRule.once);
    expect(find.text('New fee'), findsNothing);
  });

  testWidgets('a fee on chosen plans needs a plan ticked', (tester) async {
    final _FakeFees fees = _FakeFees(<Fee>[]);
    await _pump(tester, fees);
    await tester.tap(find.text('Add fee'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey<String>('fee-name')),
      'Locker',
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('fee-amount')),
      '100',
    );
    await tester.tap(find.byKey(const ValueKey<String>('fee-all-plans')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('fee-form-save')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('fee-plans-error')), findsOneWidget);
    expect(fees.created, isEmpty);

    await tester.tap(find.byKey(const ValueKey<String>('fee-plan-p-2')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('fee-form-save')));
    await tester.pumpAndSettle();
    expect(fees.created.single.allPlans, isFalse);
    expect(fees.created.single.planIds, <String>['p-2']);
  });

  testWidgets('a duplicate name is said plainly on the name field', (
    tester,
  ) async {
    final _FakeFees fees = _FakeFees(<Fee>[])
      ..writeError = const AppFailure(FailureKind.duplicate, kFeeDuplicateName);
    await _pump(tester, fees);
    await tester.tap(find.text('Add fee'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey<String>('fee-name')),
      'Card fee',
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('fee-amount')),
      '200',
    );
    await tester.tap(find.byKey(const ValueKey<String>('fee-form-save')));
    await tester.pumpAndSettle();
    expect(find.text(kFeeDuplicateName), findsWidgets);
  });

  testWidgets('deactivating asks first, then writes', (tester) async {
    final _FakeFees fees = _FakeFees(<Fee>[_fee('1', 'Registration fee')]);
    await _pump(tester, fees);

    await tester.tap(find.byKey(const ValueKey<String>('fee-menu-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Deactivate'));
    await tester.pumpAndSettle();
    expect(find.text('Deactivate Registration fee?'), findsOneWidget);
    expect(fees.toggled, isEmpty);

    await tester.tap(find.byKey(const ValueKey<String>('fee-toggle-confirm')));
    await tester.pumpAndSettle();
    expect(fees.toggled.single, ('1', false));
  });
}
