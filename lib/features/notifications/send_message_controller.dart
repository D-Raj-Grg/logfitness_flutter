// Sending one message to one person, by hand.
//
// Dart twin of the console's two server-action files --
// `app/(app)/members/[id]/message-actions.ts` and
// `app/(app)/visitors/message-actions.ts` -- folded into one controller
// because on a phone the member sheet and the visitor sheet are the same
// screen with a different list of reasons.
//
// The read half is three futures: what would be said to this member, what
// would be said to this walk-in, and what has already been said to this
// member. Each is a family, and the preview families take the chosen reason as
// an argument on purpose -- changing the reason in the picker is a different
// question to the database, not a mutation of an answer already given, so it
// is a different provider and Riverpod re-runs it for free.
//
// Widgets call controllers; controllers call repositories (PLANNING.md §6).
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:logfitness_flutter/data/notifications/notification_message.dart';
import 'package:logfitness_flutter/data/notifications/notification_previews.dart';
import 'package:logfitness_flutter/data/notifications/notifications_repository.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';

part 'send_message_controller.g.dart';

/// What this member would be told for [event], and every reason they would
/// not be.
///
/// Null means the database would not disclose the member at all -- another
/// gym's, archived, or outside the caller's branches. RLS does not distinguish
/// "absent" from "hidden", and neither does this.
@riverpod
Future<MemberMessagePreview?> memberMessagePreview(
  Ref ref,
  String memberId,
  NotificationEvent event,
) {
  return ref
      .watch(notificationsRepositoryProvider)
      .previewMemberNotification(memberId, event);
}

/// The walk-in twin. Same shape, one field fewer: a visitor has no
/// `notifications_opt_out` column, because they have no standing instruction
/// to honour yet.
@riverpod
Future<VisitorMessagePreview?> visitorMessagePreview(
  Ref ref,
  String visitorId,
  NotificationEvent event,
) {
  return ref
      .watch(notificationsRepositoryProvider)
      .previewVisitorNotification(visitorId, event);
}

/// Everything this member has been told, newest first.
///
/// The member profile's Messages tab. A history, not a queue: the rows are
/// bounded by the same RLS that bounds the delivery log, and nothing on this
/// list is acted on.
@riverpod
Future<List<NotificationMessage>> memberMessages(Ref ref, String memberId) {
  return ref
      .watch(notificationsRepositoryProvider)
      .listNotificationsForMember(memberId);
}

/// The result of one manual send. A screen either says what went out or says
/// why nothing did; there is no third case.
sealed class SendMessageResult {
  const SendMessageResult();
}

class SendMessageSucceeded extends SendMessageResult {
  const SendMessageSucceeded(this.messageId);

  /// The `notification_messages` row the RPC created. Held rather than
  /// discarded because it is the one handle that ties what the desk pressed to
  /// what the delivery log shows a minute later.
  final String messageId;
}

class SendMessageFailed extends SendMessageResult {
  const SendMessageFailed(this.failure);

  final AppFailure failure;

  /// The database refused. Role gating in this app is UX only (CLAUDE.md), so
  /// a refusal means a button was offered that the caller was never allowed to
  /// press -- and the sentence has to say so rather than read as a hiccup.
  bool get isRefusal => failure.isRefusal;
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
@Riverpod(keepAlive: true)
class SendMessage extends _$SendMessage {
  @override
  bool build() => false; // true while a send is in flight

  /// One message to one member.
  ///
  /// A blank [body] means the gym's own wording, rendered in Postgres.
  Future<SendMessageResult> toMember({
    required String memberId,
    required NotificationEvent event,
    String? body,
  }) {
    return _run(() async {
      final String id = await ref
          .read(notificationsRepositoryProvider)
          .sendMemberNotification(
            memberId: memberId,
            event: event,
            body: _trimmedOrNull(body),
          );
      // The profile's Messages tab now has a row it does not know about.
      ref.invalidate(memberMessagesProvider(memberId));
      return id;
    });
  }

  /// One message to one walk-in.
  ///
  /// The one-tap welcome from a row passes no [body] at all, which is what
  /// keeps a welcome sent by hand identical to the one the insert trigger
  /// would have sent.
  Future<SendMessageResult> toVisitor({
    required String visitorId,
    required NotificationEvent event,
    String? body,
  }) {
    // Nothing to invalidate afterwards: a visitor has no Messages tab. The
    // delivery log is not invalidated from this file either -- it belongs to
    // another sub-project and naming its providers here would couple the two.
    // It refreshes itself by polling while anything is in flight, which is
    // precisely the state a fresh send creates.
    return _run(() async {
      return ref
          .read(notificationsRepositoryProvider)
          .sendVisitorNotification(
            visitorId: visitorId,
            event: event,
            body: _trimmedOrNull(body),
          );
    });
  }

  /// An empty editor means "use the template", not "send an empty message".
  /// The database applies `left(btrim(body), 1000)`, so a body of spaces would
  /// otherwise arrive as an empty SMS rather than as the gym's wording.
  static String? _trimmedOrNull(String? body) {
    if (body == null) return null;
    final String trimmed = body.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<SendMessageResult> _run(Future<String> Function() action) async {
    // A double tap costs money and, inside two minutes, gets refused by the
    // guard upstream anyway -- so the second press never leaves the phone.
    if (state) {
      return const SendMessageFailed(
        AppFailure(FailureKind.invalid, 'That message is already sending.'),
      );
    }

    state = true;
    try {
      return SendMessageSucceeded(await action());
    } catch (error, stackTrace) {
      // Never a silent catch. The RPCs raise whole sentences -- "This member
      // has asked not to receive messages", "That message is already queued
      // for this member" -- and `mapError` passes them through verbatim.
      return SendMessageFailed(mapError(error, stackTrace));
    } finally {
      state = false;
    }
  }
}
