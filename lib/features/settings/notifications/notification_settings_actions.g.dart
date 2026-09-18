// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_settings_actions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NotificationSettingsActions)
final notificationSettingsActionsProvider =
    NotificationSettingsActionsProvider._();

final class NotificationSettingsActionsProvider
    extends $NotifierProvider<NotificationSettingsActions, bool> {
  NotificationSettingsActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationSettingsActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationSettingsActionsHash();

  @$internal
  @override
  NotificationSettingsActions create() => NotificationSettingsActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$notificationSettingsActionsHash() =>
    r'1afafa70f9c23b3902243fc958caea3a4618e65d';

abstract class _$NotificationSettingsActions extends $Notifier<bool> {
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
