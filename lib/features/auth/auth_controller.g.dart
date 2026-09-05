// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Resolves [Principal] for the current session. The router and every
/// screen that needs to know "who is this" read this provider rather than
/// re-deriving it.

@ProviderFor(principal)
final principalProvider = PrincipalProvider._();

/// Resolves [Principal] for the current session. The router and every
/// screen that needs to know "who is this" read this provider rather than
/// re-deriving it.

final class PrincipalProvider
    extends
        $FunctionalProvider<
          AsyncValue<Principal>,
          Principal,
          FutureOr<Principal>
        >
    with $FutureModifier<Principal>, $FutureProvider<Principal> {
  /// Resolves [Principal] for the current session. The router and every
  /// screen that needs to know "who is this" read this provider rather than
  /// re-deriving it.
  PrincipalProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'principalProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$principalHash();

  @$internal
  @override
  $FutureProviderElement<Principal> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Principal> create(Ref ref) {
    return principal(ref);
  }
}

String _$principalHash() => r'ec91dc6f77295df49143baa72de5822468b9b854';

/// Sign-in, sign-out, and account-linking, as one `AsyncValue<LinkOutcome?>`
/// state: `null` before anything has been attempted, `loading` mid-call,
/// `data(LinkOutcome...)` after a [linkPrincipal] attempt settles, and
/// `error` only for a failure none of the above accounts for.

@ProviderFor(AuthController)
final authControllerProvider = AuthControllerProvider._();

/// Sign-in, sign-out, and account-linking, as one `AsyncValue<LinkOutcome?>`
/// state: `null` before anything has been attempted, `loading` mid-call,
/// `data(LinkOutcome...)` after a [linkPrincipal] attempt settles, and
/// `error` only for a failure none of the above accounts for.
final class AuthControllerProvider
    extends $AsyncNotifierProvider<AuthController, LinkOutcome?> {
  /// Sign-in, sign-out, and account-linking, as one `AsyncValue<LinkOutcome?>`
  /// state: `null` before anything has been attempted, `loading` mid-call,
  /// `data(LinkOutcome...)` after a [linkPrincipal] attempt settles, and
  /// `error` only for a failure none of the above accounts for.
  AuthControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authControllerHash();

  @$internal
  @override
  AuthController create() => AuthController();
}

String _$authControllerHash() => r'31971fde2bd43b2bb609d5b7672bb2ae10272f99';

/// Sign-in, sign-out, and account-linking, as one `AsyncValue<LinkOutcome?>`
/// state: `null` before anything has been attempted, `loading` mid-call,
/// `data(LinkOutcome...)` after a [linkPrincipal] attempt settles, and
/// `error` only for a failure none of the above accounts for.

abstract class _$AuthController extends $AsyncNotifier<LinkOutcome?> {
  FutureOr<LinkOutcome?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<LinkOutcome?>, LinkOutcome?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<LinkOutcome?>, LinkOutcome?>,
              AsyncValue<LinkOutcome?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
