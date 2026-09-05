// Exercises AuthController against a fake AuthRepository -- no network, no
// real Supabase client. sessionProvider/claimsProvider are overridden with
// fixed values so ref.invalidate(...) inside the controller never reaches
// the real (uninitialized) Supabase.instance.client.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/auth/auth_repository.dart';
import 'package:logfitness_flutter/data/auth/current_member.dart';
import 'package:logfitness_flutter/data/auth/current_staff.dart';
import 'package:logfitness_flutter/features/auth/auth_controller.dart';
import 'package:logfitness_flutter/supabase/supabase_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeAuthRepository implements AuthRepository {

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<UserResponse> updatePassword(String password) async =>
      UserResponse.fromJson(const <String, dynamic>{});
  Object? signInError;
  Object? linkError;
  String linkedPrincipalId = 'member-1';
  int refreshSessionCallCount = 0;
  int signOutCallCount = 0;

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    if (signInError != null) {
      throw signInError!;
    }
    return AuthResponse();
  }

  @override
  Future<void> signOut() async {
    signOutCallCount++;
  }

  @override
  Future<Session?> refreshSession() async {
    refreshSessionCallCount++;
    return null;
  }

  @override
  Future<String> linkMemberAccount() async {
    if (linkError != null) {
      throw linkError!;
    }
    return linkedPrincipalId;
  }

  @override
  Future<CurrentMember?> currentMember() async => null;

  @override
  Future<CurrentStaff?> currentStaff() async => null;
}

void main() {
  late FakeAuthRepository fakeRepository;
  late ProviderContainer container;

  setUp(() {
    fakeRepository = FakeAuthRepository();
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(fakeRepository),
        sessionProvider.overrideWithValue(null),
        claimsProvider.overrideWithValue(null),
      ],
    );
    addTearDown(container.dispose);
  });

  test('sign-in failure surfaces an error', () async {
    fakeRepository.signInError = Exception('invalid credentials');

    await container
        .read(authControllerProvider.notifier)
        .signIn(email: 'a@b.com', password: 'wrong');

    final state = container.read(authControllerProvider);
    expect(state.hasError, isTrue);
  });

  test('sign-in success settles with no error', () async {
    await container
        .read(authControllerProvider.notifier)
        .signIn(email: 'a@b.com', password: 'correct');

    final state = container.read(authControllerProvider);
    expect(state.hasError, isFalse);
    expect(state.value, isNull);
  });

  test('link with no invitation maps to LinkFailure.noInvitation', () async {
    fakeRepository.linkError = const LinkException(LinkFailure.noInvitation);

    await container.read(authControllerProvider.notifier).linkPrincipal();

    final state = container.read(authControllerProvider);
    expect(state.hasError, isFalse);
    expect(
      state.value,
      const LinkOutcome.notLinked(LinkFailure.noInvitation),
    );
    expect(fakeRepository.refreshSessionCallCount, 0);
  });

  test('an ambiguous invitation maps to its own case', () async {
    fakeRepository.linkError = const LinkException(
      LinkFailure.ambiguousInvitation,
    );

    await container.read(authControllerProvider.notifier).linkPrincipal();

    final state = container.read(authControllerProvider);
    expect(state.hasError, isFalse);
    expect(
      state.value,
      const LinkOutcome.notLinked(LinkFailure.ambiguousInvitation),
    );
  });

  test('a successful link refreshes the session exactly once', () async {
    fakeRepository.linkedPrincipalId = 'member-42';

    await container.read(authControllerProvider.notifier).linkPrincipal();

    final state = container.read(authControllerProvider);
    expect(state.hasError, isFalse);
    expect(state.value, const LinkOutcome.linked('member-42'));
    expect(fakeRepository.refreshSessionCallCount, 1);
  });

  test('an unexpected link failure surfaces as an error, not notLinked', () async {
    fakeRepository.linkError = Exception('network down');

    await container.read(authControllerProvider.notifier).linkPrincipal();

    final state = container.read(authControllerProvider);
    expect(state.hasError, isTrue);
  });

  // Named for what it actually proves. Whether the session, claims and
  // principal are really cleared is verified in test/app/router_test.dart
  // ('sign-out returns to /login and leaves no stale principal behind'),
  // which drives mutable holders rather than the constant overrides used
  // here -- an invalidate against a constant override cannot be observed.
  test('sign-out reaches the repository and settles without error', () async {
    await container.read(authControllerProvider.notifier).signOut();

    expect(fakeRepository.signOutCallCount, 1);
    final state = container.read(authControllerProvider);
    expect(state.hasError, isFalse);
  });
}
