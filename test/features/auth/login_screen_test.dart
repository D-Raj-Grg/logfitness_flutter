// Exercises LoginScreen against a fake AuthRepository -- no network, no
// real Supabase client. Mirrors the fake in
// test/features/auth/auth_controller_test.dart.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/auth/auth_repository.dart';
import 'package:logfitness_flutter/data/auth/current_member.dart';
import 'package:logfitness_flutter/data/auth/current_staff.dart';
import 'package:logfitness_flutter/features/auth/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _FakeAuthRepository implements AuthRepository {

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<UserResponse> updatePassword(String password) async =>
      UserResponse.fromJson(const <String, dynamic>{});
  Object? signInError;
  Completer<void>? signInGate;

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    if (signInGate != null) {
      await signInGate!.future;
    }
    if (signInError != null) {
      throw signInError!;
    }
    return AuthResponse();
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<Session?> refreshSession() async => null;

  @override
  Future<String> linkMemberAccount() async => 'member-1';

  @override
  Future<CurrentMember?> currentMember() async => null;

  @override
  Future<CurrentStaff?> currentStaff() async => null;
}

Widget _app(Widget child, AuthRepository repository) {
  return ProviderScope(
    overrides: [authRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp(home: child),
  );
}

void main() {
  testWidgets(
    'invalid credentials shows the mapped "wrong email or password" message',
    (tester) async {
      final repository = _FakeAuthRepository()
        ..signInError = const AuthApiException(
          'Invalid login credentials',
          code: 'invalid_credentials',
        );

      await tester.pumpWidget(_app(const LoginScreen(), repository));

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'member@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'wrongpass');
      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pumpAndSettle();

      expect(find.text('Wrong email or password.'), findsOneWidget);
      // The raw Supabase message must never reach the screen.
      expect(find.textContaining('Invalid login credentials'), findsNothing);
    },
  );

  testWidgets('a loading sign-in disables the submit button', (
    tester,
  ) async {
    final gate = Completer<void>();
    final repository = _FakeAuthRepository()..signInGate = gate;

    await tester.pumpWidget(_app(const LoginScreen(), repository));

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'member@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'correctpass');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pump();

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    gate.complete();
    await tester.pumpAndSettle();

    final settledButton = tester.widget<FilledButton>(
      find.byType(FilledButton),
    );
    expect(settledButton.onPressed, isNotNull);
  });
}
