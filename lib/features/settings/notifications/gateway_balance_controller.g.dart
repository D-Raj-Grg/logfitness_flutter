// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gateway_balance_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The poll interval, injectable so the loop can be tested at milliseconds.
///
/// `package:fake_async` is deliberately not used anywhere in this suite: it is
/// in `pubspec.lock` only as a transitive dependency of `flutter_test`, and
/// importing it without adding it to `pubspec.yaml` trips
/// `depend_on_referenced_packages` -- and an analyze-clean tree is a merge
/// gate (PLANNING.md §2). Same trick, and the same reason, as
/// `notificationPollIntervalProvider`.

@ProviderFor(gatewayBalancePollInterval)
final gatewayBalancePollIntervalProvider =
    GatewayBalancePollIntervalProvider._();

/// The poll interval, injectable so the loop can be tested at milliseconds.
///
/// `package:fake_async` is deliberately not used anywhere in this suite: it is
/// in `pubspec.lock` only as a transitive dependency of `flutter_test`, and
/// importing it without adding it to `pubspec.yaml` trips
/// `depend_on_referenced_packages` -- and an analyze-clean tree is a merge
/// gate (PLANNING.md §2). Same trick, and the same reason, as
/// `notificationPollIntervalProvider`.

final class GatewayBalancePollIntervalProvider
    extends $FunctionalProvider<Duration, Duration, Duration>
    with $Provider<Duration> {
  /// The poll interval, injectable so the loop can be tested at milliseconds.
  ///
  /// `package:fake_async` is deliberately not used anywhere in this suite: it is
  /// in `pubspec.lock` only as a transitive dependency of `flutter_test`, and
  /// importing it without adding it to `pubspec.yaml` trips
  /// `depend_on_referenced_packages` -- and an analyze-clean tree is a merge
  /// gate (PLANNING.md §2). Same trick, and the same reason, as
  /// `notificationPollIntervalProvider`.
  GatewayBalancePollIntervalProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gatewayBalancePollIntervalProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gatewayBalancePollIntervalHash();

  @$internal
  @override
  $ProviderElement<Duration> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Duration create(Ref ref) {
    return gatewayBalancePollInterval(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Duration value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Duration>(value),
    );
  }
}

String _$gatewayBalancePollIntervalHash() =>
    r'60f2a4758b48b2ef627d9be6b85f90336de096e3';

@ProviderFor(GatewayBalanceCheck)
final gatewayBalanceCheckProvider = GatewayBalanceCheckFamily._();

final class GatewayBalanceCheckProvider
    extends $NotifierProvider<GatewayBalanceCheck, GatewayBalanceState> {
  GatewayBalanceCheckProvider._({
    required GatewayBalanceCheckFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'gatewayBalanceCheckProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$gatewayBalanceCheckHash();

  @override
  String toString() {
    return r'gatewayBalanceCheckProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  GatewayBalanceCheck create() => GatewayBalanceCheck();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GatewayBalanceState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GatewayBalanceState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GatewayBalanceCheckProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$gatewayBalanceCheckHash() =>
    r'9caf3b6536e5bd940547345b373e629312b3d418';

final class GatewayBalanceCheckFamily extends $Family
    with
        $ClassFamilyOverride<
          GatewayBalanceCheck,
          GatewayBalanceState,
          GatewayBalanceState,
          GatewayBalanceState,
          String
        > {
  GatewayBalanceCheckFamily._()
    : super(
        retry: null,
        name: r'gatewayBalanceCheckProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GatewayBalanceCheckProvider call(String gatewayId) =>
      GatewayBalanceCheckProvider._(argument: gatewayId, from: this);

  @override
  String toString() => r'gatewayBalanceCheckProvider';
}

abstract class _$GatewayBalanceCheck extends $Notifier<GatewayBalanceState> {
  late final _$args = ref.$arg as String;
  String get gatewayId => _$args;

  GatewayBalanceState build(String gatewayId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<GatewayBalanceState, GatewayBalanceState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<GatewayBalanceState, GatewayBalanceState>,
              GatewayBalanceState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
