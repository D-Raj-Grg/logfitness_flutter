// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_message_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// What this member would be told for [event], and every reason they would
/// not be.
///
/// Null means the database would not disclose the member at all -- another
/// gym's, archived, or outside the caller's branches. RLS does not distinguish
/// "absent" from "hidden", and neither does this.

@ProviderFor(memberMessagePreview)
final memberMessagePreviewProvider = MemberMessagePreviewFamily._();

/// What this member would be told for [event], and every reason they would
/// not be.
///
/// Null means the database would not disclose the member at all -- another
/// gym's, archived, or outside the caller's branches. RLS does not distinguish
/// "absent" from "hidden", and neither does this.

final class MemberMessagePreviewProvider
    extends
        $FunctionalProvider<
          AsyncValue<MemberMessagePreview?>,
          MemberMessagePreview?,
          FutureOr<MemberMessagePreview?>
        >
    with
        $FutureModifier<MemberMessagePreview?>,
        $FutureProvider<MemberMessagePreview?> {
  /// What this member would be told for [event], and every reason they would
  /// not be.
  ///
  /// Null means the database would not disclose the member at all -- another
  /// gym's, archived, or outside the caller's branches. RLS does not distinguish
  /// "absent" from "hidden", and neither does this.
  MemberMessagePreviewProvider._({
    required MemberMessagePreviewFamily super.from,
    required (String, NotificationEvent) super.argument,
  }) : super(
         retry: null,
         name: r'memberMessagePreviewProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$memberMessagePreviewHash();

  @override
  String toString() {
    return r'memberMessagePreviewProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<MemberMessagePreview?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MemberMessagePreview?> create(Ref ref) {
    final argument = this.argument as (String, NotificationEvent);
    return memberMessagePreview(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is MemberMessagePreviewProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$memberMessagePreviewHash() =>
    r'd467fad3fbd8df49f3dc661d6863847f6bed729e';

/// What this member would be told for [event], and every reason they would
/// not be.
///
/// Null means the database would not disclose the member at all -- another
/// gym's, archived, or outside the caller's branches. RLS does not distinguish
/// "absent" from "hidden", and neither does this.

final class MemberMessagePreviewFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<MemberMessagePreview?>,
          (String, NotificationEvent)
        > {
  MemberMessagePreviewFamily._()
    : super(
        retry: null,
        name: r'memberMessagePreviewProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// What this member would be told for [event], and every reason they would
  /// not be.
  ///
  /// Null means the database would not disclose the member at all -- another
  /// gym's, archived, or outside the caller's branches. RLS does not distinguish
  /// "absent" from "hidden", and neither does this.

  MemberMessagePreviewProvider call(String memberId, NotificationEvent event) =>
      MemberMessagePreviewProvider._(argument: (memberId, event), from: this);

  @override
  String toString() => r'memberMessagePreviewProvider';
}

/// The walk-in twin. Same shape, one field fewer: a visitor has no
/// `notifications_opt_out` column, because they have no standing instruction
/// to honour yet.

@ProviderFor(visitorMessagePreview)
final visitorMessagePreviewProvider = VisitorMessagePreviewFamily._();

/// The walk-in twin. Same shape, one field fewer: a visitor has no
/// `notifications_opt_out` column, because they have no standing instruction
/// to honour yet.

final class VisitorMessagePreviewProvider
    extends
        $FunctionalProvider<
          AsyncValue<VisitorMessagePreview?>,
          VisitorMessagePreview?,
          FutureOr<VisitorMessagePreview?>
        >
    with
        $FutureModifier<VisitorMessagePreview?>,
        $FutureProvider<VisitorMessagePreview?> {
  /// The walk-in twin. Same shape, one field fewer: a visitor has no
  /// `notifications_opt_out` column, because they have no standing instruction
  /// to honour yet.
  VisitorMessagePreviewProvider._({
    required VisitorMessagePreviewFamily super.from,
    required (String, NotificationEvent) super.argument,
  }) : super(
         retry: null,
         name: r'visitorMessagePreviewProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$visitorMessagePreviewHash();

  @override
  String toString() {
    return r'visitorMessagePreviewProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<VisitorMessagePreview?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<VisitorMessagePreview?> create(Ref ref) {
    final argument = this.argument as (String, NotificationEvent);
    return visitorMessagePreview(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is VisitorMessagePreviewProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$visitorMessagePreviewHash() =>
    r'c73921e110643eadfafe64befe94e69e69dc4f30';

/// The walk-in twin. Same shape, one field fewer: a visitor has no
/// `notifications_opt_out` column, because they have no standing instruction
/// to honour yet.

final class VisitorMessagePreviewFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<VisitorMessagePreview?>,
          (String, NotificationEvent)
        > {
  VisitorMessagePreviewFamily._()
    : super(
        retry: null,
        name: r'visitorMessagePreviewProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The walk-in twin. Same shape, one field fewer: a visitor has no
  /// `notifications_opt_out` column, because they have no standing instruction
  /// to honour yet.

  VisitorMessagePreviewProvider call(
    String visitorId,
    NotificationEvent event,
  ) =>
      VisitorMessagePreviewProvider._(argument: (visitorId, event), from: this);

  @override
  String toString() => r'visitorMessagePreviewProvider';
}

/// Everything this member has been told, newest first.
///
/// The member profile's Messages tab. A history, not a queue: the rows are
/// bounded by the same RLS that bounds the delivery log, and nothing on this
/// list is acted on.

@ProviderFor(memberMessages)
final memberMessagesProvider = MemberMessagesFamily._();

/// Everything this member has been told, newest first.
///
/// The member profile's Messages tab. A history, not a queue: the rows are
/// bounded by the same RLS that bounds the delivery log, and nothing on this
/// list is acted on.

final class MemberMessagesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<NotificationMessage>>,
          List<NotificationMessage>,
          FutureOr<List<NotificationMessage>>
        >
    with
        $FutureModifier<List<NotificationMessage>>,
        $FutureProvider<List<NotificationMessage>> {
  /// Everything this member has been told, newest first.
  ///
  /// The member profile's Messages tab. A history, not a queue: the rows are
  /// bounded by the same RLS that bounds the delivery log, and nothing on this
  /// list is acted on.
  MemberMessagesProvider._({
    required MemberMessagesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'memberMessagesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$memberMessagesHash();

  @override
  String toString() {
    return r'memberMessagesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<NotificationMessage>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<NotificationMessage>> create(Ref ref) {
    final argument = this.argument as String;
    return memberMessages(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MemberMessagesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$memberMessagesHash() => r'a08f2f4231320d5c348dcdbcb69c5fa2c2496123';

/// Everything this member has been told, newest first.
///
/// The member profile's Messages tab. A history, not a queue: the rows are
/// bounded by the same RLS that bounds the delivery log, and nothing on this
/// list is acted on.

final class MemberMessagesFamily extends $Family
    with
        $FunctionalFamilyOverride<FutureOr<List<NotificationMessage>>, String> {
  MemberMessagesFamily._()
    : super(
        retry: null,
        name: r'memberMessagesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Everything this member has been told, newest first.
  ///
  /// The member profile's Messages tab. A history, not a queue: the rows are
  /// bounded by the same RLS that bounds the delivery log, and nothing on this
  /// list is acted on.

  MemberMessagesProvider call(String memberId) =>
      MemberMessagesProvider._(argument: memberId, from: this);

  @override
  String toString() => r'memberMessagesProvider';
}

/// The write half: one message, now.
///
/// Two facts this controller exists to keep true.
///
/// **What is sent is what the log stores.** The body travels with the send
/// rather than being re-rendered in Postgres afterwards, so the message the
/// member receives and the record the gym keeps cannot disagree. That is why
/// [toMember] and [toVisitor] take the text off the screen rather than a flag
/// saying "use the template": a blank body means "the gym's own wording", and
/// anything else is exactly what goes out.
///
/// **Opt-out is not overridable.** `send_member_notification` raises a
/// `check_violation` for an opted-out member and there is no argument that
/// suppresses it. Consent is not something a button overrides, so the sheet
/// disables Send and this controller does not offer a way round it either.
// Deliberately **not** auto-disposed.
//
// A write notifier that nobody watches is disposed after a single frame, and an
// RPC takes far longer than a frame. The awaited call then resumes on a dead
// `Ref`: `ref.read`, `ref.invalidate` and even the `finally { state = false; }`
// throw `UnmountedRefException`, the future completes with an error nobody is
// listening to, and the desk is told nothing at all about a write that did
// happen -- or, worse, is told "nothing was saved" about one that did. That is
// precisely the class of bug `app_failure.dart` exists to prevent, arriving
// through the back door of provider lifetime rather than through a swallowed
// catch.
//
// Some call sites do watch this (the message sheets); the ones that matter most
// do not -- a row's overflow menu and a one-tap Send welcome, both of which
// are fire-and-report. Keeping it alive is one line and makes every call site
// behave the same; the state is a single bool.

@ProviderFor(SendMessage)
final sendMessageProvider = SendMessageProvider._();

/// The write half: one message, now.
///
/// Two facts this controller exists to keep true.
///
/// **What is sent is what the log stores.** The body travels with the send
/// rather than being re-rendered in Postgres afterwards, so the message the
/// member receives and the record the gym keeps cannot disagree. That is why
/// [toMember] and [toVisitor] take the text off the screen rather than a flag
/// saying "use the template": a blank body means "the gym's own wording", and
/// anything else is exactly what goes out.
///
/// **Opt-out is not overridable.** `send_member_notification` raises a
/// `check_violation` for an opted-out member and there is no argument that
/// suppresses it. Consent is not something a button overrides, so the sheet
/// disables Send and this controller does not offer a way round it either.
// Deliberately **not** auto-disposed.
//
// A write notifier that nobody watches is disposed after a single frame, and an
// RPC takes far longer than a frame. The awaited call then resumes on a dead
// `Ref`: `ref.read`, `ref.invalidate` and even the `finally { state = false; }`
// throw `UnmountedRefException`, the future completes with an error nobody is
// listening to, and the desk is told nothing at all about a write that did
// happen -- or, worse, is told "nothing was saved" about one that did. That is
// precisely the class of bug `app_failure.dart` exists to prevent, arriving
// through the back door of provider lifetime rather than through a swallowed
// catch.
//
// Some call sites do watch this (the message sheets); the ones that matter most
// do not -- a row's overflow menu and a one-tap Send welcome, both of which
// are fire-and-report. Keeping it alive is one line and makes every call site
// behave the same; the state is a single bool.
final class SendMessageProvider extends $NotifierProvider<SendMessage, bool> {
  /// The write half: one message, now.
  ///
  /// Two facts this controller exists to keep true.
  ///
  /// **What is sent is what the log stores.** The body travels with the send
  /// rather than being re-rendered in Postgres afterwards, so the message the
  /// member receives and the record the gym keeps cannot disagree. That is why
  /// [toMember] and [toVisitor] take the text off the screen rather than a flag
  /// saying "use the template": a blank body means "the gym's own wording", and
  /// anything else is exactly what goes out.
  ///
  /// **Opt-out is not overridable.** `send_member_notification` raises a
  /// `check_violation` for an opted-out member and there is no argument that
  /// suppresses it. Consent is not something a button overrides, so the sheet
  /// disables Send and this controller does not offer a way round it either.
  // Deliberately **not** auto-disposed.
  //
  // A write notifier that nobody watches is disposed after a single frame, and an
  // RPC takes far longer than a frame. The awaited call then resumes on a dead
  // `Ref`: `ref.read`, `ref.invalidate` and even the `finally { state = false; }`
  // throw `UnmountedRefException`, the future completes with an error nobody is
  // listening to, and the desk is told nothing at all about a write that did
  // happen -- or, worse, is told "nothing was saved" about one that did. That is
  // precisely the class of bug `app_failure.dart` exists to prevent, arriving
  // through the back door of provider lifetime rather than through a swallowed
  // catch.
  //
  // Some call sites do watch this (the message sheets); the ones that matter most
  // do not -- a row's overflow menu and a one-tap Send welcome, both of which
  // are fire-and-report. Keeping it alive is one line and makes every call site
  // behave the same; the state is a single bool.
  SendMessageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sendMessageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sendMessageHash();

  @$internal
  @override
  SendMessage create() => SendMessage();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$sendMessageHash() => r'9a96d5e1c646239ede041e35e1bd4bba0a2bce5e';

/// The write half: one message, now.
///
/// Two facts this controller exists to keep true.
///
/// **What is sent is what the log stores.** The body travels with the send
/// rather than being re-rendered in Postgres afterwards, so the message the
/// member receives and the record the gym keeps cannot disagree. That is why
/// [toMember] and [toVisitor] take the text off the screen rather than a flag
/// saying "use the template": a blank body means "the gym's own wording", and
/// anything else is exactly what goes out.
///
/// **Opt-out is not overridable.** `send_member_notification` raises a
/// `check_violation` for an opted-out member and there is no argument that
/// suppresses it. Consent is not something a button overrides, so the sheet
/// disables Send and this controller does not offer a way round it either.
// Deliberately **not** auto-disposed.
//
// A write notifier that nobody watches is disposed after a single frame, and an
// RPC takes far longer than a frame. The awaited call then resumes on a dead
// `Ref`: `ref.read`, `ref.invalidate` and even the `finally { state = false; }`
// throw `UnmountedRefException`, the future completes with an error nobody is
// listening to, and the desk is told nothing at all about a write that did
// happen -- or, worse, is told "nothing was saved" about one that did. That is
// precisely the class of bug `app_failure.dart` exists to prevent, arriving
// through the back door of provider lifetime rather than through a swallowed
// catch.
//
// Some call sites do watch this (the message sheets); the ones that matter most
// do not -- a row's overflow menu and a one-tap Send welcome, both of which
// are fire-and-report. Keeping it alive is one line and makes every call site
// behave the same; the state is a single bool.

abstract class _$SendMessage extends $Notifier<bool> {
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
