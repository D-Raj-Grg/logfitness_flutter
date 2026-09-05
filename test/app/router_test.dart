// One widget test per branch of the redirect guard in `lib/app/router.dart`,
// plus the /set-password carve-out and a sign-out integration test.
//
// `principalProvider` is a generated `FutureProvider`, so most tests
// override it directly with a fixed `AsyncValue` via `overrideWithValue` --
// no fake session/claims plumbing needed for those. The sign-out test is the
// exception: it exercises the real `principal()` resolution logic, so it
// overrides `sessionProvider`/`claimsProvider` with mutable holders instead
// and leaves `principalProvider` un-overridden.
//
// `Override` is not exported by flutter_riverpod 3.1.0, so every `overrides`
// list below stays an untyped literal.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/app/router.dart';
import 'package:logfitness_flutter/data/auth/auth_repository.dart';
import 'package:logfitness_flutter/data/auth/current_member.dart';
import 'package:logfitness_flutter/data/auth/current_staff.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/features/auth/auth_controller.dart';
import 'package:logfitness_flutter/supabase/app_claims.dart';
import 'package:logfitness_flutter/supabase/supabase_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A minimal, fake [Session] for tests that need a non-null session. Field
/// values other than [User.id] are irrelevant.
Session _fakeSession() {
  return Session(
    accessToken: 'fake-access-token',
    tokenType: 'bearer',
    user: const User(
      id: 'user-1',
      appMetadata: {},
      userMetadata: {},
      aud: 'authenticated',
      createdAt: '2026-01-01T00:00:00Z',
    ),
  );
}

const _memberClaims = AppClaims(
  orgId: 'org-1',
  memberId: 'member-1',
  branchIds: ['branch-1'],
);

const _staffClaims = AppClaims(
  orgId: 'org-1',
  staffId: 'staff-1',
  staffRole: StaffRole.frontDesk,
  branchIds: ['branch-1'],
);

const _currentStaff = CurrentStaff(
  staffId: 'staff-1',
  orgId: 'org-1',
  orgName: 'Lord of Gyms',
  fullName: 'Sita Staff',
  email: 'sita@example.com',
  role: StaffRole.frontDesk,
  branchIds: ['branch-1'],
);

const _currentMember = CurrentMember(
  memberId: 'member-1',
  orgId: 'org-1',
  orgName: 'Lord of Gyms',
  currency: 'NPR',
  timezone: 'Asia/Kathmandu',
  homeBranchId: 'branch-1',
  homeBranchName: 'Main branch',
  memberCode: 'M-001',
  fullName: 'Ram Member',
  phone: '9800000000',
  status: MemberStatus.active,
);

/// Pumps the app router with `principalProvider` fixed to [principalValue]
/// and returns the path it lands on, plus the [ProviderContainer] so a test
/// can drive further navigation (e.g. the /set-password carve-out).
Future<({String path, ProviderContainer container})> _landed(
  WidgetTester tester,
  AsyncValue<Principal> principalValue, {
  Session? session,
}) async {
  late final ProviderContainer container;

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        principalProvider.overrideWithValue(principalValue),
        // SetPasswordScreen reads sessionProvider directly (it renders
        // before a principal can be resolved from an invite-email
        // session), so every test provides a definite value for it too.
        sessionProvider.overrideWithValue(session),
      ],
      child: Consumer(
        builder: (context, ref, _) {
          container = ProviderScope.containerOf(context);
          final router = ref.watch(goRouterProvider);
          return MaterialApp.router(routerConfig: router);
        },
      ),
    ),
  );
  await tester.pumpAndSettle();

  final router = container.read(goRouterProvider);
  return (
    path: router.routerDelegate.currentConfiguration.uri.path,
    container: container,
  );
}

/// A mutable session holder so the sign-out test can flip `sessionProvider`
/// from a real session to `null` mid-test, the way `AuthController.signOut`
/// does via `ref.invalidate`.
class _SessionHolder extends Notifier<Session?> {
  @override
  Session? build() => _fakeSession();

  void clear() => state = null;
}

final _sessionHolderProvider = NotifierProvider<_SessionHolder, Session?>(
  _SessionHolder.new,
);

/// Fixed at `_staffClaims` for the duration of the sign-out test --
/// `principal()` checks `sessionProvider` for null before it ever reads
/// claims, so this does not need to change too.
class _ClaimsHolder extends Notifier<AppClaims?> {
  @override
  AppClaims? build() => _staffClaims;
}

final _claimsHolderProvider = NotifierProvider<_ClaimsHolder, AppClaims?>(
  _ClaimsHolder.new,
);

/// Only [signOut] is exercised by the test below; every other member throws
/// so an accidental call surfaces immediately instead of silently no-oping.
class _FakeAuthRepository implements AuthRepository {

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<UserResponse> updatePassword(String password) async =>
      UserResponse.fromJson(const <String, dynamic>{});
  _FakeAuthRepository(this.onSignOut);

  final void Function() onSignOut;

  @override
  Future<void> signOut() async => onSignOut();

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
  Future<CurrentMember?> currentMember() async => null;

  @override
  Future<CurrentStaff?> currentStaff() async => null;
}

void main() {
  testWidgets('signed out redirects to /login', (tester) async {
    final landed = await _landed(
      tester,
      const AsyncValue.data(Principal.signedOut()),
    );

    expect(landed.path, loginPath);
  });

  testWidgets(
    'still resolving parks on /splash, never flashing /login',
    (tester) async {
      final landed = await _landed(tester, const AsyncValue.loading());

      expect(landed.path, splashPath);
    },
  );

  testWidgets('staff claims redirect to /staff', (tester) async {
    final landed = await _landed(
      tester,
      const AsyncValue.data(Principal.staff(_staffClaims)),
    );

    expect(landed.path, staffPath);
  });

  testWidgets('member claims redirect to /member', (tester) async {
    final landed = await _landed(
      tester,
      const AsyncValue.data(Principal.member(_memberClaims)),
    );

    expect(landed.path, memberPath);
  });

  testWidgets(
    'staff pending refresh lands on the staff shell, not /link',
    (tester) async {
      final landed = await _landed(
        tester,
        const AsyncValue.data(
          Principal.staffPendingRefresh(_currentStaff),
        ),
      );

      expect(landed.path, staffPath);
    },
  );

  testWidgets(
    'member pending refresh lands on the member shell, not /link',
    (tester) async {
      final landed = await _landed(
        tester,
        const AsyncValue.data(
          Principal.memberPendingRefresh(_currentMember),
        ),
      );

      expect(landed.path, memberPath);
    },
  );

  testWidgets('not linked redirects to /link', (tester) async {
    final landed = await _landed(
      tester,
      const AsyncValue.data(Principal.notLinked()),
    );

    expect(landed.path, linkPath);
  });

  testWidgets(
    'a session on /set-password is left alone regardless of principal',
    (tester) async {
      // Start from a state that would otherwise bounce to /link, to prove
      // /set-password is respected over the principal state.
      final landed = await _landed(
        tester,
        const AsyncValue.data(Principal.notLinked()),
        session: _fakeSession(),
      );
      expect(landed.path, linkPath);

      landed.container.read(goRouterProvider).go(setPasswordPath);
      await tester.pumpAndSettle();

      final router = landed.container.read(goRouterProvider);
      expect(
        router.routerDelegate.currentConfiguration.uri.path,
        setPasswordPath,
      );
    },
  );

  testWidgets(
    'sign-out returns to /login and leaves no stale principal behind',
    (tester) async {
      late final ProviderContainer container;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionProvider.overrideWith(
              (ref) => ref.watch(_sessionHolderProvider),
            ),
            claimsProvider.overrideWith(
              (ref) => ref.watch(_claimsHolderProvider),
            ),
            authRepositoryProvider.overrideWithValue(
              _FakeAuthRepository(
                () => container.read(_sessionHolderProvider.notifier).clear(),
              ),
            ),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              container = ProviderScope.containerOf(context);
              final router = ref.watch(goRouterProvider);
              return MaterialApp.router(routerConfig: router);
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Starts out signed in as staff (claims resolve without a network
      // round trip).
      var router = container.read(goRouterProvider);
      expect(router.routerDelegate.currentConfiguration.uri.path, staffPath);

      await container.read(authControllerProvider.notifier).signOut();
      await tester.pumpAndSettle();

      router = container.read(goRouterProvider);
      expect(router.routerDelegate.currentConfiguration.uri.path, loginPath);
      expect(
        container.read(principalProvider).value,
        const Principal.signedOut(),
      );
    },
  );
}
