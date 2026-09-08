// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visitor_actions_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(VisitorActions)
final visitorActionsProvider = VisitorActionsProvider._();

final class VisitorActionsProvider
    extends $NotifierProvider<VisitorActions, bool> {
  VisitorActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'visitorActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$visitorActionsHash();

  @$internal
  @override
  VisitorActions create() => VisitorActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$visitorActionsHash() => r'4cb8db295537a4fcaae1d5e66afb25c24f9d3926';

abstract class _$VisitorActions extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
