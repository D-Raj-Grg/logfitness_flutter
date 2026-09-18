// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcement_live_refresh.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// How often the list re-reads itself while a send is still going.
///
/// A provider rather than a constant so a test can shrink it -- the alternative
/// to `package:fake_async`, which is only a transitive dependency here.

@ProviderFor(announcementPollInterval)
final announcementPollIntervalProvider = AnnouncementPollIntervalProvider._();

/// How often the list re-reads itself while a send is still going.
///
/// A provider rather than a constant so a test can shrink it -- the alternative
/// to `package:fake_async`, which is only a transitive dependency here.

final class AnnouncementPollIntervalProvider
    extends $FunctionalProvider<Duration, Duration, Duration>
    with $Provider<Duration> {
  /// How often the list re-reads itself while a send is still going.
  ///
  /// A provider rather than a constant so a test can shrink it -- the alternative
  /// to `package:fake_async`, which is only a transitive dependency here.
  AnnouncementPollIntervalProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'announcementPollIntervalProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$announcementPollIntervalHash();

  @$internal
  @override
  $ProviderElement<Duration> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Duration create(Ref ref) {
    return announcementPollInterval(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Duration value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Duration>(value),
    );
  }
}

String _$announcementPollIntervalHash() =>
    r'062ce3eb49aef62ee957e29646ca74fb13a738d8';

/// How long the poller keeps trying before it gives up and says so.

@ProviderFor(announcementPollGiveUp)
final announcementPollGiveUpProvider = AnnouncementPollGiveUpProvider._();

/// How long the poller keeps trying before it gives up and says so.

final class AnnouncementPollGiveUpProvider
    extends $FunctionalProvider<Duration, Duration, Duration>
    with $Provider<Duration> {
  /// How long the poller keeps trying before it gives up and says so.
  AnnouncementPollGiveUpProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'announcementPollGiveUpProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$announcementPollGiveUpHash();

  @$internal
  @override
  $ProviderElement<Duration> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Duration create(Ref ref) {
    return announcementPollGiveUp(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Duration value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Duration>(value),
    );
  }
}

String _$announcementPollGiveUpHash() =>
    r'474dba367e23a4e1bbb9964c6df129791a391731';

@ProviderFor(AnnouncementLiveRefresh)
final announcementLiveRefreshProvider = AnnouncementLiveRefreshProvider._();

final class AnnouncementLiveRefreshProvider
    extends
        $NotifierProvider<
          AnnouncementLiveRefresh,
          AnnouncementLiveRefreshState
        > {
  AnnouncementLiveRefreshProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'announcementLiveRefreshProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$announcementLiveRefreshHash();

  @$internal
  @override
  AnnouncementLiveRefresh create() => AnnouncementLiveRefresh();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnnouncementLiveRefreshState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnnouncementLiveRefreshState>(value),
    );
  }
}

String _$announcementLiveRefreshHash() =>
    r'9aa4b9a9ca41fa7fe9e0be67d376357fe75f1e25';

abstract class _$AnnouncementLiveRefresh
    extends $Notifier<AnnouncementLiveRefreshState> {
  AnnouncementLiveRefreshState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AnnouncementLiveRefreshState, AnnouncementLiveRefreshState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AnnouncementLiveRefreshState,
                AnnouncementLiveRefreshState
              >,
              AnnouncementLiveRefreshState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
