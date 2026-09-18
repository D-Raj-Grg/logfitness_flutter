// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcement_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AnnouncementList)
final announcementListProvider = AnnouncementListProvider._();

final class AnnouncementListProvider
    extends $AsyncNotifierProvider<AnnouncementList, AnnouncementListState> {
  AnnouncementListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'announcementListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$announcementListHash();

  @$internal
  @override
  AnnouncementList create() => AnnouncementList();
}

String _$announcementListHash() => r'dc8e3d018e1ac031d52dab28509871c7e582d339';

abstract class _$AnnouncementList
    extends $AsyncNotifier<AnnouncementListState> {
  FutureOr<AnnouncementListState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<AnnouncementListState>, AnnouncementListState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<AnnouncementListState>,
                AnnouncementListState
              >,
              AsyncValue<AnnouncementListState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// How many messages across the loaded announcements are still queued.
///
/// A separate `int`-valued provider rather than a `select` on the list, for the
/// same reason `notificationPendingCount` is one: a generated notifier provider
/// exposes no `select`, and the poller must not be rebuilt by every appended
/// page.

@ProviderFor(announcementPendingCount)
final announcementPendingCountProvider = AnnouncementPendingCountProvider._();

/// How many messages across the loaded announcements are still queued.
///
/// A separate `int`-valued provider rather than a `select` on the list, for the
/// same reason `notificationPendingCount` is one: a generated notifier provider
/// exposes no `select`, and the poller must not be rebuilt by every appended
/// page.

final class AnnouncementPendingCountProvider
    extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// How many messages across the loaded announcements are still queued.
  ///
  /// A separate `int`-valued provider rather than a `select` on the list, for the
  /// same reason `notificationPendingCount` is one: a generated notifier provider
  /// exposes no `select`, and the poller must not be rebuilt by every appended
  /// page.
  AnnouncementPendingCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'announcementPendingCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$announcementPendingCountHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return announcementPendingCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$announcementPendingCountHash() =>
    r'ed0797c5e4cdd0a47574ce1b113f0514a62d8ead';
