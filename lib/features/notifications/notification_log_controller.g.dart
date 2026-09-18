// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_log_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The slice of the log the screen is currently showing.
///
/// Opens unfiltered, unlike the visitor log: a delivery log is read to find
/// out what happened last night, and "last night" includes the messages that
/// went out fine. Narrowing to failures by default would answer a question
/// nobody asked and hide the denominator.

@ProviderFor(NotificationFilter)
final notificationFilterProvider = NotificationFilterProvider._();

/// The slice of the log the screen is currently showing.
///
/// Opens unfiltered, unlike the visitor log: a delivery log is read to find
/// out what happened last night, and "last night" includes the messages that
/// went out fine. Narrowing to failures by default would answer a question
/// nobody asked and hide the denominator.
final class NotificationFilterProvider
    extends $NotifierProvider<NotificationFilter, NotificationListFilter> {
  /// The slice of the log the screen is currently showing.
  ///
  /// Opens unfiltered, unlike the visitor log: a delivery log is read to find
  /// out what happened last night, and "last night" includes the messages that
  /// went out fine. Narrowing to failures by default would answer a question
  /// nobody asked and hide the denominator.
  NotificationFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationFilterHash();

  @$internal
  @override
  NotificationFilter create() => NotificationFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationListFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationListFilter>(value),
    );
  }
}

String _$notificationFilterHash() =>
    r'f8a04a4442e969c388126f800093d09b0dd5e4be';

/// The slice of the log the screen is currently showing.
///
/// Opens unfiltered, unlike the visitor log: a delivery log is read to find
/// out what happened last night, and "last night" includes the messages that
/// went out fine. Narrowing to failures by default would answer a question
/// nobody asked and hide the denominator.

abstract class _$NotificationFilter extends $Notifier<NotificationListFilter> {
  NotificationListFilter build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<NotificationListFilter, NotificationListFilter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<NotificationListFilter, NotificationListFilter>,
              NotificationListFilter,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(NotificationLog)
final notificationLogProvider = NotificationLogProvider._();

final class NotificationLogProvider
    extends $AsyncNotifierProvider<NotificationLog, NotificationLogState> {
  NotificationLogProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationLogProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationLogHash();

  @$internal
  @override
  NotificationLog create() => NotificationLog();
}

String _$notificationLogHash() => r'c6fff15ec782c2c2b9ac6076399279f72e317f4a';

abstract class _$NotificationLog extends $AsyncNotifier<NotificationLogState> {
  FutureOr<NotificationLogState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<NotificationLogState>, NotificationLogState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<NotificationLogState>,
                NotificationLogState
              >,
              AsyncValue<NotificationLogState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// How many messages are sitting in each of the four states the summary strip
/// shows.
///
/// Watches the branch scope rather than the filter: the strip is the
/// denominator the filter is read against, so narrowing to "Failed" must not
/// also change the number beside "Failed".

@ProviderFor(notificationStatusCounts)
final notificationStatusCountsProvider = NotificationStatusCountsProvider._();

/// How many messages are sitting in each of the four states the summary strip
/// shows.
///
/// Watches the branch scope rather than the filter: the strip is the
/// denominator the filter is read against, so narrowing to "Failed" must not
/// also change the number beside "Failed".

final class NotificationStatusCountsProvider
    extends
        $FunctionalProvider<
          AsyncValue<NotificationStatusCounts>,
          NotificationStatusCounts,
          FutureOr<NotificationStatusCounts>
        >
    with
        $FutureModifier<NotificationStatusCounts>,
        $FutureProvider<NotificationStatusCounts> {
  /// How many messages are sitting in each of the four states the summary strip
  /// shows.
  ///
  /// Watches the branch scope rather than the filter: the strip is the
  /// denominator the filter is read against, so narrowing to "Failed" must not
  /// also change the number beside "Failed".
  NotificationStatusCountsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationStatusCountsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationStatusCountsHash();

  @$internal
  @override
  $FutureProviderElement<NotificationStatusCounts> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<NotificationStatusCounts> create(Ref ref) {
    return notificationStatusCounts(ref);
  }
}

String _$notificationStatusCountsHash() =>
    r'f31e6ff1195a64a421244aa404af5e9879b21dc6';
