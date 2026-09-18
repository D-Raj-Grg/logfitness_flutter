// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_live_refresh.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// How often the log re-reads itself while something is in flight.
///
/// A provider rather than a constant so a test can shrink it. Driving the
/// notifier's own clock is the alternative to `package:fake_async`, which is
/// only a transitive dependency here and may not be imported without adding it
/// to `pubspec.yaml` (`depend_on_referenced_packages`).

@ProviderFor(notificationPollInterval)
final notificationPollIntervalProvider = NotificationPollIntervalProvider._();

/// How often the log re-reads itself while something is in flight.
///
/// A provider rather than a constant so a test can shrink it. Driving the
/// notifier's own clock is the alternative to `package:fake_async`, which is
/// only a transitive dependency here and may not be imported without adding it
/// to `pubspec.yaml` (`depend_on_referenced_packages`).

final class NotificationPollIntervalProvider
    extends $FunctionalProvider<Duration, Duration, Duration>
    with $Provider<Duration> {
  /// How often the log re-reads itself while something is in flight.
  ///
  /// A provider rather than a constant so a test can shrink it. Driving the
  /// notifier's own clock is the alternative to `package:fake_async`, which is
  /// only a transitive dependency here and may not be imported without adding it
  /// to `pubspec.yaml` (`depend_on_referenced_packages`).
  NotificationPollIntervalProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationPollIntervalProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationPollIntervalHash();

  @$internal
  @override
  $ProviderElement<Duration> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Duration create(Ref ref) {
    return notificationPollInterval(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Duration value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Duration>(value),
    );
  }
}

String _$notificationPollIntervalHash() =>
    r'380496088d306e6a37788817a69de043ff400cf3';

/// How long the poller keeps trying before it gives up and says so.
///
/// Fifteen minutes, from the console. It exists for the message that is stuck
/// rather than slow: without it a forgotten screen polls all afternoon over a
/// row that is never going to move.

@ProviderFor(notificationPollGiveUp)
final notificationPollGiveUpProvider = NotificationPollGiveUpProvider._();

/// How long the poller keeps trying before it gives up and says so.
///
/// Fifteen minutes, from the console. It exists for the message that is stuck
/// rather than slow: without it a forgotten screen polls all afternoon over a
/// row that is never going to move.

final class NotificationPollGiveUpProvider
    extends $FunctionalProvider<Duration, Duration, Duration>
    with $Provider<Duration> {
  /// How long the poller keeps trying before it gives up and says so.
  ///
  /// Fifteen minutes, from the console. It exists for the message that is stuck
  /// rather than slow: without it a forgotten screen polls all afternoon over a
  /// row that is never going to move.
  NotificationPollGiveUpProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationPollGiveUpProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationPollGiveUpHash();

  @$internal
  @override
  $ProviderElement<Duration> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Duration create(Ref ref) {
    return notificationPollGiveUp(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Duration value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Duration>(value),
    );
  }
}

String _$notificationPollGiveUpHash() =>
    r'6a38528e592abad69a8164c38b8e33fc5871cbdf';

@ProviderFor(NotificationLiveRefresh)
final notificationLiveRefreshProvider = NotificationLiveRefreshProvider._();

final class NotificationLiveRefreshProvider
    extends
        $NotifierProvider<
          NotificationLiveRefresh,
          NotificationLiveRefreshState
        > {
  NotificationLiveRefreshProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationLiveRefreshProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationLiveRefreshHash();

  @$internal
  @override
  NotificationLiveRefresh create() => NotificationLiveRefresh();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationLiveRefreshState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationLiveRefreshState>(value),
    );
  }
}

String _$notificationLiveRefreshHash() =>
    r'57c49394fd806133dffdd66f4145469cb9412d67';

abstract class _$NotificationLiveRefresh
    extends $Notifier<NotificationLiveRefreshState> {
  NotificationLiveRefreshState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<NotificationLiveRefreshState, NotificationLiveRefreshState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                NotificationLiveRefreshState,
                NotificationLiveRefreshState
              >,
              NotificationLiveRefreshState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// How many rows on the loaded page are still moving.
///
/// A separate provider rather than a `select` on the log: a generated notifier
/// provider exposes no `select`, and this achieves the same narrowing -- an
/// `int`-valued provider notifies its listeners only when the int changes, so
/// the poller is not rebuilt by every appended page or every row whose status
/// text shifted.

@ProviderFor(notificationPendingCount)
final notificationPendingCountProvider = NotificationPendingCountProvider._();

/// How many rows on the loaded page are still moving.
///
/// A separate provider rather than a `select` on the log: a generated notifier
/// provider exposes no `select`, and this achieves the same narrowing -- an
/// `int`-valued provider notifies its listeners only when the int changes, so
/// the poller is not rebuilt by every appended page or every row whose status
/// text shifted.

final class NotificationPendingCountProvider
    extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// How many rows on the loaded page are still moving.
  ///
  /// A separate provider rather than a `select` on the log: a generated notifier
  /// provider exposes no `select`, and this achieves the same narrowing -- an
  /// `int`-valued provider notifies its listeners only when the int changes, so
  /// the poller is not rebuilt by every appended page or every row whose status
  /// text shifted.
  NotificationPendingCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationPendingCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationPendingCountHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return notificationPendingCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$notificationPendingCountHash() =>
    r'5164d0e992e2697443f7e3646515281ae702e333';
