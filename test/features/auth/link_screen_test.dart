// Exercises LinkScreen against a fake AuthRepository -- no network, no
// real Supabase client. Verifies each LinkFailure renders its own copy and
// that the screen tries linkPrincipal() exactly once on its own.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:logfitness_flutter/app/router.dart';
import 'package:logfitness_flutter/data/auth/auth_repository.dart';
import 'package:logfitness_flutter/data/auth/current_member.dart';
import 'package:logfitness_flutter/data/auth/current_staff.dart';
import 'package:logfitness_flutter/features/auth/link_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _FakeAuthRepository implements AuthRepository {

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<UserResponse> updatePassword(String password) async =>
      UserResponse.fromJson(const <String, dynamic>{});
  LinkFailure? failure;
  int linkCallCount = 0;

  @override
  Future<String> linkMemberAccount() async {
    linkCallCount++;
    if (failure != null) {
      throw LinkException(failure!);
    }
    return 'member-1';
  }

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async => AuthResponse();

  @override
  Future<void> signOut() async {}

  @override
  Future<Session?> refreshSession() async => null;

  @override
  Future<CurrentMember?> currentMember() async => null;

  @override
  Future<CurrentStaff?> currentStaff() async => null;
}

/// Wraps [LinkScreen] in a real (minimal) GoRouter so the `notAuthenticated`
/// branch's `context.go(loginPath)` has somewhere to land.
Widget _app(AuthRepository repository) {
  final router = GoRouter(
    initialLocation: linkPath,
    routes: [
      GoRoute(path: linkPath, builder: (context, state) => const LinkScreen()),
      GoRoute(
        path: loginPath,
        builder: (context, state) => const Scaffold(body: Text('Login')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [authRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  testWidgets('noInvitation tells the member to check the front desk', (
    tester,
  ) async {
    final repository = _FakeAuthRepository()..failure = LinkFailure.noInvitation;

    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();

    expect(find.textContaining('front desk'), findsOneWidget);
  });

  testWidgets(
    'ambiguousInvitation tells the member staff must resolve it',
    (tester) async {
      final repository = _FakeAuthRepository()
        ..failure = LinkFailure.ambiguousInvitation;

      await tester.pumpWidget(_app(repository));
      await tester.pumpAndSettle();

      expect(find.textContaining('invited at two gyms'), findsOneWidget);
    },
  );

  testWidgets('unknown failure shows a generic retry message', (
    tester,
  ) async {
    final repository = _FakeAuthRepository()..failure = LinkFailure.unknown;

    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();

    expect(find.text('Something went wrong. Please try again.'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Try again'), findsOneWidget);
  });

  testWidgets('notAuthenticated sends the user back to login', (
    tester,
  ) async {
    final repository = _FakeAuthRepository()
      ..failure = LinkFailure.notAuthenticated;

    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('the screen never retries more than once on its own', (
    tester,
  ) async {
    final repository = _FakeAuthRepository()..failure = LinkFailure.noInvitation;

    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();
    expect(repository.linkCallCount, 1);

    // Pump several more frames with no user interaction: the automatic
    // attempt must not fire again.
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(repository.linkCallCount, 1);

    // A user-initiated retry is allowed and is not "auto-looping".
    await tester.tap(find.widgetWithText(FilledButton, 'Try again'));
    await tester.pumpAndSettle();
    expect(repository.linkCallCount, 2);
  });
}
