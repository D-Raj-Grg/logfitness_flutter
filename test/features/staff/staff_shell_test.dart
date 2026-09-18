// Each of the four staff roles sees exactly the destinations PLANNING.md §4
// grants it, and none it does not.
//
// The negative half is the point: a nav filter that is too generous is
// invisible in a screenshot and only shows up as a refusal at the counter.
//
// `principalProvider` is overridden with a fixed `AsyncValue` per role, the
// same way `test/app/router_test.dart` does it, so the real
// staffRole -> capabilities -> destinations chain is exercised. Only
// `authRepositoryProvider` is faked, because the app bar reads the staff
// display name through it and there is no Supabase client in a widget test.
//
// `Override` is not exported by flutter_riverpod 3.1.0, so every `overrides`
// list below stays an untyped literal.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/app/theme.dart';
import 'package:logfitness_flutter/data/auth/auth_repository.dart';
import 'package:logfitness_flutter/data/auth/current_member.dart';
import 'package:logfitness_flutter/data/auth/current_staff.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/features/auth/auth_controller.dart';
import 'package:logfitness_flutter/features/staff/staff_capabilities.dart';
import 'package:logfitness_flutter/features/staff/staff_destinations.dart';
import 'package:logfitness_flutter/features/staff/staff_shell.dart';
import 'package:logfitness_flutter/supabase/app_claims.dart';
import 'package:logfitness_flutter/supabase/supabase_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Every member throws except the two the shell actually calls, so an
/// unexpected network read surfaces immediately instead of hanging.
class _FakeAuthRepository implements AuthRepository {
  @override
  Future<CurrentStaff?> currentStaff() async => null;

  @override
  Future<CurrentMember?> currentMember() async => null;

  @override
  Future<void> signOut() async {}

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<Session?> refreshSession() => throw UnimplementedError();

  @override
  Future<String> linkMemberAccount() => throw UnimplementedError();

  @override
  Future<void> sendPasswordReset(String email) => throw UnimplementedError();

  @override
  Future<UserResponse> updatePassword(String password) =>
      throw UnimplementedError();
}

AppClaims _claimsFor(StaffRole role) => AppClaims(
  orgId: 'org-1',
  staffId: 'staff-1',
  staffRole: role,
  branchIds: const <String>['branch-1'],
);

Future<void> _pumpShell(WidgetTester tester, StaffRole role) async {
  final claims = _claimsFor(role);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        principalProvider.overrideWithValue(
          AsyncValue<Principal>.data(Principal.staff(claims)),
        ),
        // The branch switcher reads the claims straight off the session, and
        // there is no Supabase client in a widget test.
        claimsProvider.overrideWithValue(claims),
        authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
      ],
      child: MaterialApp(theme: appLightTheme, home: const StaffShell()),
    ),
  );
  await tester.pumpAndSettle();
}

/// Every destination the shell offers this role: the bottom bar entries plus,
/// when More is present, the rows behind it. Opening the sheet is part of the
/// assertion -- a destination that is unreachable is not "offered".
Future<Set<String>> _offeredDestinations(WidgetTester tester) async {
  final found = <String>{};

  for (final destination in staffDestinations) {
    if (tester.any(find.byKey(staffDestinationKey(destination.id)))) {
      found.add(destination.id);
    }
  }

  if (tester.any(find.byKey(staffMoreButtonKey))) {
    await tester.tap(find.byKey(staffMoreButtonKey));
    await tester.pumpAndSettle();
    expect(find.byKey(staffMoreSheetKey), findsOneWidget);

    for (final destination in staffDestinations) {
      if (tester.any(find.byKey(staffDestinationKey(destination.id)))) {
        found.add(destination.id);
      }
    }
  }

  return found;
}

void main() {
  testWidgets('front_desk is offered the counter, and no reports', (
    tester,
  ) async {
    await _pumpShell(tester, StaffRole.frontDesk);

    // Messages is here from 2026-09-18. The desk does not hold
    // `viewNotificationLog`, so the destination is offered on
    // `sendAnnouncement` alone (`requiresAny`) and the screen behind it shows
    // the announcements tab only -- see `messages_screen.dart`.
    expect(await _offeredDestinations(tester), <String>{
      'check-in',
      'members',
      'visitors',
      'collection',
      'notifications',
      'settings',
    });
  });

  testWidgets('trainer is offered classes only -- not the cash drawer', (
    tester,
  ) async {
    await _pumpShell(tester, StaffRole.trainer);

    expect(await _offeredDestinations(tester), <String>{'classes', 'settings'});
    // Two destinations fit in the bar, so there is nothing behind More.
    expect(find.byKey(staffMoreButtonKey), findsNothing);
  });

  testWidgets('manager gets the front desk plus reports, but not classes', (
    tester,
  ) async {
    await _pumpShell(tester, StaffRole.manager);

    // `notifications` joined this set on 2026-09-12: the delivery log is
    // owner-and-manager, matching the console's requireRole on /notifications.
    // A front desk's set below is deliberately unchanged by it.
    expect(await _offeredDestinations(tester), <String>{
      'check-in',
      'members',
      'visitors',
      'collection',
      'reports',
      'notifications',
      'settings',
    });
  });

  testWidgets('owner sees the manager surface -- reach is the difference', (
    tester,
  ) async {
    await _pumpShell(tester, StaffRole.owner);

    // `notifications` joined this set on 2026-09-12: the delivery log is
    // owner-and-manager, matching the console's requireRole on /notifications.
    // A front desk's set below is deliberately unchanged by it.
    expect(await _offeredDestinations(tester), <String>{
      'check-in',
      'members',
      'visitors',
      'collection',
      'reports',
      'notifications',
      'settings',
    });
  });

  testWidgets('a front desk spends no bar slot on check-in', (tester) async {
    await _pumpShell(tester, StaffRole.frontDesk);

    // Check-in is `alwaysOverflow`, so the desk's four remaining screens all
    // fit on the bar and check-in is the only thing behind More.
    expect(find.byKey(staffDestinationKey('check-in')), findsNothing);
    expect(find.byKey(staffDestinationKey('collection')), findsOneWidget);
    expect(find.byKey(staffMoreButtonKey), findsOneWidget);
  });

  testWidgets('every role lands on a screen, never on the check-in keypad', (
    tester,
  ) async {
    for (final role in StaffRole.values) {
      await _pumpShell(tester, role);

      // Members for everyone who has it; a trainer has no member access at
      // all, so their first destination is Classes. What matters for both is
      // that the shell never opens on check-in -- that is what put an owner
      // in front of a keypad they never asked for.
      final expected = role == StaffRole.trainer ? 'Classes' : 'Members';
      expect(
        find.widgetWithText(AppBar, expected),
        findsOneWidget,
        reason: '${role.wire} landed somewhere else',
      );
    }
  });

  testWidgets('check-in is still reachable, from More', (tester) async {
    await _pumpShell(tester, StaffRole.owner);

    await tester.tap(find.byKey(staffMoreButtonKey));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(staffDestinationKey('check-in')));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Check-in'), findsOneWidget);
  });

  testWidgets('the overflow sheet actually navigates', (tester) async {
    await _pumpShell(tester, StaffRole.owner);

    // An owner still overflows -- six destinations, five slots -- so this
    // proves the long tail is reachable rather than merely listed.
    await tester.tap(find.byKey(staffMoreButtonKey));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(staffDestinationKey('settings')));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Settings'), findsOneWidget);
  });

  testWidgets('the bar never offers more destinations than it has slots', (
    tester,
  ) async {
    for (final role in StaffRole.values) {
      await _pumpShell(tester, role);

      final bar = tester.widget<NavigationBar>(
        find.byKey(staffNavigationBarKey),
      );
      expect(
        bar.destinations.length,
        lessThanOrEqualTo(maxPrimaryDestinations),
        reason: '${role.wire} would crowd the bar',
      );
    }
  });

  testWidgets('a session with no staff role is offered nothing at all', (
    tester,
  ) async {
    // Fails closed on the role, not on the destination list. Settings
    // requires no capability, so gating on capabilities alone would show an
    // unresolved (or misrouted non-staff) session a one-item shell as though
    // it belonged here.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          principalProvider.overrideWithValue(
            const AsyncValue<Principal>.data(Principal.notLinked()),
          ),
          claimsProvider.overrideWithValue(null),
          authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
        ],
        child: MaterialApp(theme: appLightTheme, home: const StaffShell()),
      ),
    );
    await tester.pump();

    expect(find.byKey(staffNavigationBarKey), findsNothing);
    expect(find.byKey(staffDestinationKey('settings')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the role is named in the chrome so a missing button explains '
      'itself', (tester) async {
    await _pumpShell(tester, StaffRole.manager);

    expect(find.text('Branch manager'), findsOneWidget);
  });

  test('every staff role reaches at least one destination', () {
    // The shell's own invariant, rather than any one role's: a role whose
    // capabilities match no destination renders an empty bar, which is how
    // the trainer row would have shipped before Classes was declared.
    for (final role in StaffRole.values) {
      expect(
        destinationsFor(capabilitiesFor(role)),
        isNotEmpty,
        reason: '${role.wire} would get an empty navigation bar',
      );
    }
  });

  testWidgets('two mounted destinations with default-tagged FABs do not '
      'collide', (WidgetTester tester) async {
    // The shell keeps every destination mounted, so without HeroMode two
    // Scaffolds carrying a default-tagged FloatingActionButton land in one
    // route subtree and Flutter asserts "multiple heroes share the same tag".
    // That throws in the running app, not only here.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: IndexedStack(
            index: 0,
            children: <Widget>[
              for (final (int i, String label)
                  in <String>['one', 'two'].indexed)
                HeroMode(
                  enabled: i == 0,
                  child: Scaffold(
                    floatingActionButton: FloatingActionButton(
                      onPressed: () {},
                      child: Text(label),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // No assert thrown is the whole assertion; the count confirms both are
    // genuinely mounted rather than one having been culled (IndexedStack keeps
    // the unselected child offstage, so the finder has to look there).
    expect(tester.takeException(), isNull);
    expect(
      find.byType(FloatingActionButton, skipOffstage: false),
      findsNWidgets(2),
    );
  });
}
