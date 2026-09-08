// The switcher offers exactly the branches on the `branch_ids[]` claim --
// TASKS.md Phase 5 -- and the scope it derives is what a repository would
// filter on.
//
// `Override` is not exported by flutter_riverpod 3.1.0, so every `overrides`
// list below stays an untyped literal.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/app/theme.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/features/auth/auth_controller.dart';
import 'package:logfitness_flutter/features/staff/branch_scope.dart';
import 'package:logfitness_flutter/features/staff/branch_switcher.dart';
import 'package:logfitness_flutter/supabase/app_claims.dart';
import 'package:logfitness_flutter/supabase/supabase_providers.dart';

AppClaims _claims(StaffRole role, List<String> branchIds) => AppClaims(
  orgId: 'org-1',
  staffId: 'staff-1',
  staffRole: role,
  branchIds: branchIds,
);

// `Override` is not exported by flutter_riverpod 3.1.0, so the shared
// override list stays dynamic and is spread into an untyped literal.
List<dynamic> _overridesFor(StaffRole role, List<String> branchIds) {
  final claims = _claims(role, branchIds);
  return <dynamic>[
    // The switcher's options come off the claim, so that is what the test
    // fixes; `principalProvider` follows because the capability set (and so
    // "is this an owner") is derived from it.
    claimsProvider.overrideWithValue(claims),
    principalProvider.overrideWithValue(
      AsyncValue<Principal>.data(Principal.staff(claims)),
    ),
  ];
}

Future<ProviderContainer> _pumpSwitcher(
  WidgetTester tester,
  StaffRole role,
  List<String> branchIds, {
  Map<String, String> names = const <String, String>{},
}) async {
  late final ProviderContainer container;

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ..._overridesFor(role, branchIds),
        branchNamesProvider.overrideWithValue(names),
      ],
      child: MaterialApp(
        theme: appLightTheme,
        home: Consumer(
          builder: (context, ref, _) {
            container = ProviderScope.containerOf(context);
            return const Scaffold(
              appBar: null,
              body: Align(child: BranchSwitcher()),
            );
          },
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  return container;
}

void main() {
  testWidgets('offers only the branches on the claim', (tester) async {
    await _pumpSwitcher(
      tester,
      StaffRole.manager,
      const <String>['branch-a', 'branch-b'],
      names: const <String, String>{
        'branch-a': 'Thamel',
        'branch-b': 'Patan',
        // A branch the claim does NOT carry. A name in the lookup is not a
        // grant: if this ever appeared in the menu the switcher would be
        // sourcing its options from somewhere other than the claim.
        'branch-c': 'Bhaktapur',
      },
    );

    await tester.tap(find.byKey(branchSwitcherKey));
    await tester.pumpAndSettle();

    expect(find.text('Thamel'), findsOneWidget);
    expect(find.text('Patan'), findsOneWidget);
    expect(find.text('Bhaktapur'), findsNothing);
    // Scoped to the menu: the collapsed button carries the same label, so a
    // bare `find.text` would match twice.
    expect(
      find.descendant(
        of: find.byType(PopupMenuItem<String>),
        matching: find.text('All my branches'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('a single-branch front desk gets no switcher at all', (
    tester,
  ) async {
    await _pumpSwitcher(tester, StaffRole.frontDesk, const <String>[
      'branch-a',
    ]);

    expect(find.byKey(branchSwitcherKey), findsNothing);
  });

  testWidgets('an owner switches even with an empty claim', (tester) async {
    // Upstream, an owner's `staff.branch_ids` is empty *because* an empty
    // array means the whole org to the RLS policies. The switcher must read
    // that as org-wide, not as "assigned to nothing".
    await _pumpSwitcher(tester, StaffRole.owner, const <String>[]);

    expect(find.byKey(branchSwitcherKey), findsOneWidget);
    expect(find.text('All branches'), findsOneWidget);
  });

  testWidgets('selecting a branch narrows the scope repositories read', (
    tester,
  ) async {
    final container = await _pumpSwitcher(
      tester,
      StaffRole.manager,
      const <String>['branch-a', 'branch-b'],
      names: const <String, String>{'branch-a': 'Thamel', 'branch-b': 'Patan'},
    );

    expect(
      container.read(branchScopeProvider).effectiveBranchIds,
      const <String>['branch-a', 'branch-b'],
      reason: 'the aggregate for a manager is all of theirs, not null',
    );

    await tester.tap(find.byKey(branchSwitcherKey));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Patan'));
    await tester.pumpAndSettle();

    expect(
      container.read(branchScopeProvider).effectiveBranchIds,
      const <String>['branch-b'],
    );
  });

  group('BranchScope', () {
    test('an owner aggregate passes null so RLS alone bounds the query', () {
      const scope = BranchScope(
        options: <String>[],
        selectedBranchId: null,
        isOrgWide: true,
      );

      // Mirrors the console's `lib/scope.ts`: null also covers a branch
      // created after this token was minted, which a list would miss.
      expect(scope.effectiveBranchIds, isNull);
      expect(scope.canSwitch, isTrue);
    });

    test('a selection outside the claim falls back to the aggregate', () {
      final container = ProviderContainer(
        overrides: [
          ..._overridesFor(StaffRole.manager, const <String>['branch-a']),
        ],
      );
      addTearDown(container.dispose);

      container.read(selectedBranchProvider.notifier).select('branch-z');

      expect(container.read(branchScopeProvider).selectedBranchId, isNull);
      expect(
        container.read(branchScopeProvider).effectiveBranchIds,
        const <String>['branch-a'],
      );
    });
  });

  group('branchLabel', () {
    test('prefers a name, and degrades to a short id rather than a uuid', () {
      expect(
        branchLabel('b1', const <String, String>{'b1': 'Thamel'}),
        'Thamel',
      );
      expect(
        branchLabel(
          '3f2504e0-4f89-11d3-9a0c-0305e82c3301',
          const <String, String>{},
        ),
        'Branch 3f2504e0',
      );
    });
  });
}
