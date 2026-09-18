// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcement_audience_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// How long the composer waits after the last edit before asking the database
/// what the audience now is.
///
/// A provider rather than a constant so a test can shrink it, the pattern
/// `notificationPollInterval` set.

@ProviderFor(announcementCountDebounce)
final announcementCountDebounceProvider = AnnouncementCountDebounceProvider._();

/// How long the composer waits after the last edit before asking the database
/// what the audience now is.
///
/// A provider rather than a constant so a test can shrink it, the pattern
/// `notificationPollInterval` set.

final class AnnouncementCountDebounceProvider
    extends $FunctionalProvider<Duration, Duration, Duration>
    with $Provider<Duration> {
  /// How long the composer waits after the last edit before asking the database
  /// what the audience now is.
  ///
  /// A provider rather than a constant so a test can shrink it, the pattern
  /// `notificationPollInterval` set.
  AnnouncementCountDebounceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'announcementCountDebounceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$announcementCountDebounceHash();

  @$internal
  @override
  $ProviderElement<Duration> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Duration create(Ref ref) {
    return announcementCountDebounce(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Duration value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Duration>(value),
    );
  }
}

String _$announcementCountDebounceHash() =>
    r'18cca021f1e35e5f05667675e21161972478d7f3';

/// The audience the composer is currently describing.
///
/// Every setter writes to a pending value and restarts the timer; the state
/// itself only moves once the edits stop, which is what the count provider
/// watches. A second composer opened later starts from the default because the
/// screen invalidates this on the way in.

@ProviderFor(AnnouncementDraft)
final announcementDraftProvider = AnnouncementDraftProvider._();

/// The audience the composer is currently describing.
///
/// Every setter writes to a pending value and restarts the timer; the state
/// itself only moves once the edits stop, which is what the count provider
/// watches. A second composer opened later starts from the default because the
/// screen invalidates this on the way in.
final class AnnouncementDraftProvider
    extends $NotifierProvider<AnnouncementDraft, AnnouncementAudienceQuery> {
  /// The audience the composer is currently describing.
  ///
  /// Every setter writes to a pending value and restarts the timer; the state
  /// itself only moves once the edits stop, which is what the count provider
  /// watches. A second composer opened later starts from the default because the
  /// screen invalidates this on the way in.
  AnnouncementDraftProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'announcementDraftProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$announcementDraftHash();

  @$internal
  @override
  AnnouncementDraft create() => AnnouncementDraft();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnnouncementAudienceQuery value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnnouncementAudienceQuery>(value),
    );
  }
}

String _$announcementDraftHash() => r'7554fb3843afb802f1182c69865cbb0642aba813';

/// The audience the composer is currently describing.
///
/// Every setter writes to a pending value and restarts the timer; the state
/// itself only moves once the edits stop, which is what the count provider
/// watches. A second composer opened later starts from the default because the
/// screen invalidates this on the way in.

abstract class _$AnnouncementDraft
    extends $Notifier<AnnouncementAudienceQuery> {
  AnnouncementAudienceQuery build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AnnouncementAudienceQuery, AnnouncementAudienceQuery>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AnnouncementAudienceQuery, AnnouncementAudienceQuery>,
              AnnouncementAudienceQuery,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Who would get it, and therefore what it would cost.
///
/// The same function the send uses to build its audience, so the number above
/// the button is the number of messages that get written -- not a second query
/// that agrees with the first most of the time.

@ProviderFor(announcementAudienceCount)
final announcementAudienceCountProvider = AnnouncementAudienceCountProvider._();

/// Who would get it, and therefore what it would cost.
///
/// The same function the send uses to build its audience, so the number above
/// the button is the number of messages that get written -- not a second query
/// that agrees with the first most of the time.

final class AnnouncementAudienceCountProvider
    extends
        $FunctionalProvider<
          AsyncValue<AnnouncementAudienceCount>,
          AnnouncementAudienceCount,
          FutureOr<AnnouncementAudienceCount>
        >
    with
        $FutureModifier<AnnouncementAudienceCount>,
        $FutureProvider<AnnouncementAudienceCount> {
  /// Who would get it, and therefore what it would cost.
  ///
  /// The same function the send uses to build its audience, so the number above
  /// the button is the number of messages that get written -- not a second query
  /// that agrees with the first most of the time.
  AnnouncementAudienceCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'announcementAudienceCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$announcementAudienceCountHash();

  @$internal
  @override
  $FutureProviderElement<AnnouncementAudienceCount> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AnnouncementAudienceCount> create(Ref ref) {
    return announcementAudienceCount(ref);
  }
}

String _$announcementAudienceCountHash() =>
    r'd75ea5f2c77ac896b8def46046e6c257e36f773e';
