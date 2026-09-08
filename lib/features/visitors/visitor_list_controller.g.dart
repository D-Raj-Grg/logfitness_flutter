// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visitor_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The filter the log is currently showing.
///
/// Defaults to the callbacks the desk still owes -- `open` is
/// `new` + `contacted`, matching the `visitors_open_idx` partial index
/// upstream. A log opens on the work, not on the archive.

@ProviderFor(VisitorFilter)
final visitorFilterProvider = VisitorFilterProvider._();

/// The filter the log is currently showing.
///
/// Defaults to the callbacks the desk still owes -- `open` is
/// `new` + `contacted`, matching the `visitors_open_idx` partial index
/// upstream. A log opens on the work, not on the archive.
final class VisitorFilterProvider
    extends $NotifierProvider<VisitorFilter, VisitorListFilter> {
  /// The filter the log is currently showing.
  ///
  /// Defaults to the callbacks the desk still owes -- `open` is
  /// `new` + `contacted`, matching the `visitors_open_idx` partial index
  /// upstream. A log opens on the work, not on the archive.
  VisitorFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'visitorFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$visitorFilterHash();

  @$internal
  @override
  VisitorFilter create() => VisitorFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VisitorListFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VisitorListFilter>(value),
    );
  }
}

String _$visitorFilterHash() => r'537830948aa2d3bc311857b271895b6fa8d2efbd';

/// The filter the log is currently showing.
///
/// Defaults to the callbacks the desk still owes -- `open` is
/// `new` + `contacted`, matching the `visitors_open_idx` partial index
/// upstream. A log opens on the work, not on the archive.

abstract class _$VisitorFilter extends $Notifier<VisitorListFilter> {
  VisitorListFilter build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<VisitorListFilter, VisitorListFilter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<VisitorListFilter, VisitorListFilter>,
              VisitorListFilter,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(VisitorList)
final visitorListProvider = VisitorListProvider._();

final class VisitorListProvider
    extends $AsyncNotifierProvider<VisitorList, VisitorListState> {
  VisitorListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'visitorListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$visitorListHash();

  @$internal
  @override
  VisitorList create() => VisitorList();
}

String _$visitorListHash() => r'78e693d2838d5b6a7d6765a1b1b30d2488f9fec1';

abstract class _$VisitorList extends $AsyncNotifier<VisitorListState> {
  FutureOr<VisitorListState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<VisitorListState>, VisitorListState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<VisitorListState>, VisitorListState>,
              AsyncValue<VisitorListState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
