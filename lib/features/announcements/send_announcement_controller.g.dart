// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_announcement_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// One broadcast at a time.
///
// Deliberately **not** auto-disposed, for the reason written out in
// `send_message_controller.dart`: an RPC outlives a frame, and a write notifier
// nobody watches is disposed after one -- the awaited call then resumes on a
// dead `Ref` and the `finally { state = false; }` throws `UnmountedRefException`
// instead of clearing the in-flight flag. It matters more here than there: a
// broadcast is the most expensive write in the product, and "nothing was sent"
// about a send that did happen would be a four-hundred-message mistake.

@ProviderFor(SendAnnouncement)
final sendAnnouncementProvider = SendAnnouncementProvider._();

/// One broadcast at a time.
///
// Deliberately **not** auto-disposed, for the reason written out in
// `send_message_controller.dart`: an RPC outlives a frame, and a write notifier
// nobody watches is disposed after one -- the awaited call then resumes on a
// dead `Ref` and the `finally { state = false; }` throws `UnmountedRefException`
// instead of clearing the in-flight flag. It matters more here than there: a
// broadcast is the most expensive write in the product, and "nothing was sent"
// about a send that did happen would be a four-hundred-message mistake.
final class SendAnnouncementProvider
    extends $NotifierProvider<SendAnnouncement, bool> {
  /// One broadcast at a time.
  ///
  // Deliberately **not** auto-disposed, for the reason written out in
  // `send_message_controller.dart`: an RPC outlives a frame, and a write notifier
  // nobody watches is disposed after one -- the awaited call then resumes on a
  // dead `Ref` and the `finally { state = false; }` throws `UnmountedRefException`
  // instead of clearing the in-flight flag. It matters more here than there: a
  // broadcast is the most expensive write in the product, and "nothing was sent"
  // about a send that did happen would be a four-hundred-message mistake.
  SendAnnouncementProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sendAnnouncementProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sendAnnouncementHash();

  @$internal
  @override
  SendAnnouncement create() => SendAnnouncement();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$sendAnnouncementHash() => r'820fb815005674cb575ab83249ec5a381c4a2111';

/// One broadcast at a time.
///
// Deliberately **not** auto-disposed, for the reason written out in
// `send_message_controller.dart`: an RPC outlives a frame, and a write notifier
// nobody watches is disposed after one -- the awaited call then resumes on a
// dead `Ref` and the `finally { state = false; }` throws `UnmountedRefException`
// instead of clearing the in-flight flag. It matters more here than there: a
// broadcast is the most expensive write in the product, and "nothing was sent"
// about a send that did happen would be a four-hundred-message mistake.

abstract class _$SendAnnouncement extends $Notifier<bool> {
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
