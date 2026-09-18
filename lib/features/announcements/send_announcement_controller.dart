// The write half of announcements: send, proof, stop.
//
// Dart twin of `logfitness_saas/app/(app)/announcements/actions.ts`. The shape
// is `send_message_controller.dart`'s, deliberately: a sealed result, a
// `keepAlive` bool notifier, and a `_run` guard that refuses a second press
// while the first is still in flight.
//
// The sentences on the results are the console's, returned from here rather
// than composed in the widget, so the two clients say the same thing about the
// same outcome. Refusals are never re-worded at all: `send_announcement` and
// friends raise whole sentences -- "Nobody matches that audience", "That time
// has already passed", "That test has just been sent. Give it a minute." --
// and `mapError` passes them through verbatim.
//
// Widgets call controllers; controllers call repositories (PLANNING.md §6).
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:logfitness_flutter/data/announcements/announcements_repository.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/features/announcements/announcement_list_controller.dart';

part 'send_announcement_controller.g.dart';

/// The result of one composer action. A screen either says what happened or
/// says why nothing did; there is no third case.
sealed class AnnouncementActionResult {
  const AnnouncementActionResult();
}

class AnnouncementSent extends AnnouncementActionResult {
  const AnnouncementSent(this.announcementId, {required this.scheduled});

  final String announcementId;

  /// Whether it is waiting for an hour that has not arrived. The two outcomes
  /// need different words: one thing has happened, the other is going to.
  final bool scheduled;

  String get message => scheduled
      ? 'Scheduled. Nothing goes out until then, and you can still stop it.'
      : 'Queued. It starts going out within a minute.';
}

class AnnouncementTested extends AnnouncementActionResult {
  const AnnouncementTested(this.messageId, this.to);

  final String messageId;
  final String to;

  String get message => 'Test queued to $to. It arrives within a minute.';
}

class AnnouncementCancelled extends AnnouncementActionResult {
  const AnnouncementCancelled(this.stopped);

  /// How many messages were actually stopped. Zero is a real answer and has to
  /// read as one: the broadcast had already left, and an SMS cannot be
  /// recalled.
  final int stopped;

  String get message => stopped == 0
      ? 'Nothing was left to stop — it had already gone out.'
      : 'Stopped $stopped ${stopped == 1 ? 'message' : 'messages'} that had not gone yet.';
}

class AnnouncementFailed extends AnnouncementActionResult {
  const AnnouncementFailed(this.failure);

  final AppFailure failure;

  /// The database refused. Role gating in this app is UX only (CLAUDE.md), so
  /// a refusal means a button was offered that the caller was never allowed to
  /// press, and the sentence has to say so rather than read as a hiccup.
  bool get isRefusal => failure.isRefusal;
}

/// One broadcast at a time.
///
// Deliberately **not** auto-disposed, for the reason written out in
// `send_message_controller.dart`: an RPC outlives a frame, and a write notifier
// nobody watches is disposed after one -- the awaited call then resumes on a
// dead `Ref` and the `finally { state = false; }` throws `UnmountedRefException`
// instead of clearing the in-flight flag. It matters more here than there: a
// broadcast is the most expensive write in the product, and "nothing was sent"
// about a send that did happen would be a four-hundred-message mistake.
@Riverpod(keepAlive: true)
class SendAnnouncement extends _$SendAnnouncement {
  @override
  bool build() => false; // true while something is in flight

  /// Compose and fan out. Returns the announcement id.
  Future<AnnouncementActionResult> send({
    required String title,
    required String body,
    required AnnouncementAudience audience,
    String? branchId,
    List<MemberStatus>? memberStatuses,
    int? visitorDays,
    DateTime? scheduledFor,
  }) async {
    return _run(() async {
      final String id = await ref
          .read(announcementsRepositoryProvider)
          .sendAnnouncement(
            title: title.trim(),
            body: body.trim(),
            audience: audience,
            branchId: branchId,
            memberStatuses: memberStatuses,
            visitorDays: visitorDays,
            scheduledFor: scheduledFor,
          );
      // The list has a row it does not know about, and it is the row the desk
      // is about to look for.
      ref.invalidate(announcementListProvider);
      return AnnouncementSent(id, scheduled: scheduledFor != null);
    });
  }

  /// One message, to a number typed by hand.
  ///
  /// Nothing is invalidated afterwards: a test writes no announcement row, and
  /// the delivery log belongs to another sub-project — naming its providers
  /// here would couple the two, and it polls itself while anything is in
  /// flight, which is exactly the state a test creates.
  Future<AnnouncementActionResult> test({
    required String body,
    required String to,
    String? title,
  }) async {
    return _run(() async {
      final String id = await ref
          .read(announcementsRepositoryProvider)
          .sendAnnouncementTest(
            body: body.trim(),
            to: to.trim(),
            title: _trimmedOrNull(title),
          );
      return AnnouncementTested(id, to.trim());
    });
  }

  /// Stops what has not left yet.
  Future<AnnouncementActionResult> cancel(String announcementId) async {
    return _run(() async {
      final int stopped = await ref
          .read(announcementsRepositoryProvider)
          .cancelAnnouncement(announcementId);
      ref.invalidate(announcementListProvider);
      return AnnouncementCancelled(stopped);
    });
  }

  static String? _trimmedOrNull(String? value) {
    if (value == null) return null;
    final String trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<AnnouncementActionResult> _run(
    Future<AnnouncementActionResult> Function() action,
  ) async {
    // A double tap on a broadcast is four hundred more messages, or a second
    // test that the database refuses as a duplicate anyway. Neither leaves the
    // phone.
    if (state) {
      return const AnnouncementFailed(
        AppFailure(FailureKind.invalid, 'That announcement is already sending.'),
      );
    }

    state = true;
    try {
      return await action();
    } catch (error, stackTrace) {
      // Never a silent catch: the RPCs raise whole sentences and `mapError`
      // passes them through verbatim.
      return AnnouncementFailed(mapError(error, stackTrace));
    } finally {
      state = false;
    }
  }
}
