import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/app/router.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/supabase/app_claims.dart';
import 'package:logfitness_flutter/supabase/supabase_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A minimal, fake [Session] for redirect tests. Field values other than
/// [User.id] are irrelevant — the redirect only checks nullability of
/// [sessionProvider] and the overridden [claimsProvider].
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
  role: 'member',
  branchIds: ['branch-1'],
);

const _staffClaims = AppClaims(
  orgId: 'org-1',
  role: 'front_desk',
  branchIds: ['branch-1'],
);

Future<String?> _landedPath(
  WidgetTester tester, {
  required Session? session,
  required AppClaims? claims,
}) async {
  late final ProviderContainer container;

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sessionProvider.overrideWithValue(session),
        claimsProvider.overrideWithValue(claims),
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
  return router.routerDelegate.currentConfiguration.uri.path;
}

void main() {
  testWidgets('no session redirects to /login', (tester) async {
    final path = await _landedPath(tester, session: null, claims: null);

    expect(path, loginPath);
  });

  testWidgets(
    'session without claims redirects to /link and stays there',
    (tester) async {
      final path = await _landedPath(
        tester,
        session: _fakeSession(),
        claims: null,
      );

      expect(path, linkPath);
    },
  );

  testWidgets('member claims redirect to /member', (tester) async {
    final path = await _landedPath(
      tester,
      session: _fakeSession(),
      claims: _memberClaims,
    );

    expect(path, memberPath);
  });

  testWidgets('staff claims redirect to /staff', (tester) async {
    final path = await _landedPath(
      tester,
      session: _fakeSession(),
      claims: _staffClaims,
    );

    expect(path, staffPath);
  });

  test('AppClaims.staffRole resolves the enum for a staff role', () {
    expect(_staffClaims.staffRole, StaffRole.frontDesk);
    expect(_memberClaims.isMember, isTrue);
  });
}
