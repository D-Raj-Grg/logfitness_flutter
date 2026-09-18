// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_settings_controllers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The org whose settings are being edited, off the session's claims.
///
/// Null before the claims land, and for a session that is not staff. Every
/// provider below fails closed on it rather than guessing an org id -- the
/// alternative is a write aimed at whichever org the client last knew about.

@ProviderFor(notificationSettingsOrgId)
final notificationSettingsOrgIdProvider = NotificationSettingsOrgIdProvider._();

/// The org whose settings are being edited, off the session's claims.
///
/// Null before the claims land, and for a session that is not staff. Every
/// provider below fails closed on it rather than guessing an org id -- the
/// alternative is a write aimed at whichever org the client last knew about.

final class NotificationSettingsOrgIdProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// The org whose settings are being edited, off the session's claims.
  ///
  /// Null before the claims land, and for a session that is not staff. Every
  /// provider below fails closed on it rather than guessing an org id -- the
  /// alternative is a write aimed at whichever org the client last knew about.
  NotificationSettingsOrgIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationSettingsOrgIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationSettingsOrgIdHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return notificationSettingsOrgId(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$notificationSettingsOrgIdHash() =>
    r'b2fb99577fbf6d3c92ad9a0854ee0b4808988c96';

@ProviderFor(notificationGateways)
final notificationGatewaysProvider = NotificationGatewaysProvider._();

final class NotificationGatewaysProvider
    extends
        $FunctionalProvider<
          AsyncValue<GatewaySettings>,
          GatewaySettings,
          FutureOr<GatewaySettings>
        >
    with $FutureModifier<GatewaySettings>, $FutureProvider<GatewaySettings> {
  NotificationGatewaysProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationGatewaysProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationGatewaysHash();

  @$internal
  @override
  $FutureProviderElement<GatewaySettings> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<GatewaySettings> create(Ref ref) {
    return notificationGateways(ref);
  }
}

String _$notificationGatewaysHash() =>
    r'2f1174e474a0560ee8b3375b472ccbcd19cf9196';

/// The reminder schedule. Readable by any staff; writable by an owner only.

@ProviderFor(notificationRules)
final notificationRulesProvider = NotificationRulesProvider._();

/// The reminder schedule. Readable by any staff; writable by an owner only.

final class NotificationRulesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<NotificationRule>>,
          List<NotificationRule>,
          FutureOr<List<NotificationRule>>
        >
    with
        $FutureModifier<List<NotificationRule>>,
        $FutureProvider<List<NotificationRule>> {
  /// The reminder schedule. Readable by any staff; writable by an owner only.
  NotificationRulesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationRulesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationRulesHash();

  @$internal
  @override
  $FutureProviderElement<List<NotificationRule>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<NotificationRule>> create(Ref ref) {
    return notificationRules(ref);
  }
}

String _$notificationRulesHash() => r'f29e722733a704acea4928c809a0bdf422572d96';

/// `en` or `ne`, from the org's own settings.
///
/// Read through `org_notification_locale` rather than defaulted to `'en'` in
/// Dart. The fallback chain belongs in one place: a Nepali gym previewing
/// English while sending Nepali is a bug nobody reports, because the preview
/// looks right to whoever is reading it in English.

@ProviderFor(notificationLocale)
final notificationLocaleProvider = NotificationLocaleProvider._();

/// `en` or `ne`, from the org's own settings.
///
/// Read through `org_notification_locale` rather than defaulted to `'en'` in
/// Dart. The fallback chain belongs in one place: a Nepali gym previewing
/// English while sending Nepali is a bug nobody reports, because the preview
/// looks right to whoever is reading it in English.

final class NotificationLocaleProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// `en` or `ne`, from the org's own settings.
  ///
  /// Read through `org_notification_locale` rather than defaulted to `'en'` in
  /// Dart. The fallback chain belongs in one place: a Nepali gym previewing
  /// English while sending Nepali is a bug nobody reports, because the preview
  /// looks right to whoever is reading it in English.
  NotificationLocaleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationLocaleProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationLocaleHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return notificationLocale(ref);
  }
}

String _$notificationLocaleHash() =>
    r'e4e4e2b57354ceb750308587ef9d32748f543883';

/// What a message for [event] would actually say today: the gym's own wording
/// when it has edited one, and the built-in otherwise.
///
/// Resolved through the database rather than by duplicating the defaults in
/// Dart, which is what stops the preview and the send from drifting apart --
/// the real message is rendered in Postgres by `render_notification_template`.
///
/// SMS only, as on the console. Viber and email reuse the SMS wording until a
/// gym asks for a second draft, and offering three editors for one sentence is
/// how all three end up stale.

@ProviderFor(notificationTemplatePreview)
final notificationTemplatePreviewProvider =
    NotificationTemplatePreviewFamily._();

/// What a message for [event] would actually say today: the gym's own wording
/// when it has edited one, and the built-in otherwise.
///
/// Resolved through the database rather than by duplicating the defaults in
/// Dart, which is what stops the preview and the send from drifting apart --
/// the real message is rendered in Postgres by `render_notification_template`.
///
/// SMS only, as on the console. Viber and email reuse the SMS wording until a
/// gym asks for a second draft, and offering three editors for one sentence is
/// how all three end up stale.

final class NotificationTemplatePreviewProvider
    extends
        $FunctionalProvider<
          AsyncValue<NotificationTemplatePreview?>,
          NotificationTemplatePreview?,
          FutureOr<NotificationTemplatePreview?>
        >
    with
        $FutureModifier<NotificationTemplatePreview?>,
        $FutureProvider<NotificationTemplatePreview?> {
  /// What a message for [event] would actually say today: the gym's own wording
  /// when it has edited one, and the built-in otherwise.
  ///
  /// Resolved through the database rather than by duplicating the defaults in
  /// Dart, which is what stops the preview and the send from drifting apart --
  /// the real message is rendered in Postgres by `render_notification_template`.
  ///
  /// SMS only, as on the console. Viber and email reuse the SMS wording until a
  /// gym asks for a second draft, and offering three editors for one sentence is
  /// how all three end up stale.
  NotificationTemplatePreviewProvider._({
    required NotificationTemplatePreviewFamily super.from,
    required NotificationEvent super.argument,
  }) : super(
         retry: null,
         name: r'notificationTemplatePreviewProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$notificationTemplatePreviewHash();

  @override
  String toString() {
    return r'notificationTemplatePreviewProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<NotificationTemplatePreview?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<NotificationTemplatePreview?> create(Ref ref) {
    final argument = this.argument as NotificationEvent;
    return notificationTemplatePreview(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is NotificationTemplatePreviewProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$notificationTemplatePreviewHash() =>
    r'd167edf967d05726a2955a52f557bfe5887222e7';

/// What a message for [event] would actually say today: the gym's own wording
/// when it has edited one, and the built-in otherwise.
///
/// Resolved through the database rather than by duplicating the defaults in
/// Dart, which is what stops the preview and the send from drifting apart --
/// the real message is rendered in Postgres by `render_notification_template`.
///
/// SMS only, as on the console. Viber and email reuse the SMS wording until a
/// gym asks for a second draft, and offering three editors for one sentence is
/// how all three end up stale.

final class NotificationTemplatePreviewFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<NotificationTemplatePreview?>,
          NotificationEvent
        > {
  NotificationTemplatePreviewFamily._()
    : super(
        retry: null,
        name: r'notificationTemplatePreviewProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// What a message for [event] would actually say today: the gym's own wording
  /// when it has edited one, and the built-in otherwise.
  ///
  /// Resolved through the database rather than by duplicating the defaults in
  /// Dart, which is what stops the preview and the send from drifting apart --
  /// the real message is rendered in Postgres by `render_notification_template`.
  ///
  /// SMS only, as on the console. Viber and email reuse the SMS wording until a
  /// gym asks for a second draft, and offering three editors for one sentence is
  /// how all three end up stale.

  NotificationTemplatePreviewProvider call(NotificationEvent event) =>
      NotificationTemplatePreviewProvider._(argument: event, from: this);

  @override
  String toString() => r'notificationTemplatePreviewProvider';
}
