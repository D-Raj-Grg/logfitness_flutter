// Exercises SetPasswordScreen's session-gating: no session means the
// deep-link session was never established (expired/used link), and the
// screen must say so rather than show a form with nothing to submit
// against.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:logfitness_flutter/app/router.dart';
import 'package:logfitness_flutter/features/auth/set_password_screen.dart'
    hide setPasswordPath;
import 'package:logfitness_flutter/supabase/supabase_providers.dart';

Widget _appWithNoSession() {
  final router = GoRouter(
    initialLocation: setPasswordPath,
    routes: [
      GoRoute(
        path: setPasswordPath,
        builder: (context, state) => const SetPasswordScreen(),
      ),
      GoRoute(
        path: loginPath,
        builder: (context, state) => const Scaffold(body: Text('Login')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      // sessionProvider is a plain Provider<Session?>; overriding it with
      // null exercises the "link expired" branch without a real Supabase
      // client. The signed-in/form path is exercised at the AuthController
      // layer instead, since it would otherwise require faking the whole
      // GoTrue `updateUser` call chain.
      sessionProvider.overrideWithValue(null),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  testWidgets('no session shows the expired-link message and a way back', (
    tester,
  ) async {
    await tester.pumpWidget(_appWithNoSession());
    await tester.pumpAndSettle();

    expect(find.text('This link has expired'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Back to login'));
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsOneWidget);
  });
}
