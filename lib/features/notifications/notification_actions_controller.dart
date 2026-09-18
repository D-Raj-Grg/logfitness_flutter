// The delivery log's write side: the two things a reader may do to a row.
//
// Every action reports its outcome rather than returning void into a widget
// that assumes success. The console shipped a bug on 2026-09-07 where an
// authorization refusal was discarded and a manager could not tell a refused
// write from a completed one; `AppFailure` exists to carry that refusal, and
// this controller exists to make sure something is holding it when it arrives.
//
// There is no client write policy on `notification_messages` at all -- both of
// these are RPCs, and both refuse anyone who is not an owner or a manager of
// the row's branch with a `42501`. The overflow menu on the row is UX; this is
// where the database's answer is picked up.
//
// Widgets call controllers; controllers call repositories (PLANNING.md §6).
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:logfitness_flutter/data/notifications/notifications_repository.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/features/notifications/notification_log_controller.dart';

part 'notification_actions_controller.g.dart';

/// The result of one write. A screen either shows what changed or shows why
/// it did not; there is no third case.
sealed class NotificationActionResult {
  const NotificationActionResult();
}

class NotificationActionSucceeded extends NotificationActionResult {
  const NotificationActionSucceeded(this.message);

  /// What to say on the snackbar. Different per action, and worth saying:
  /// "queued again" and "cancelled" are the two opposite outcomes of the same
  /// menu.
  final String message;
}

class NotificationActionFailed extends NotificationActionResult {
  const NotificationActionFailed(this.failure);

  final AppFailure failure;

  /// The database refused this write. Worth distinguishing at the call site:
  /// role gating in this app is UX only (CLAUDE.md), so a refusal means the
  /// screen offered an action the caller was never allowed to take, and the
  /// message must say so rather than reading as a transient error.
  bool get isRefusal => failure.isRefusal;
}

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
class NotificationActions extends _$NotificationActions {
  @override
  bool build() => false; // true while a write is in flight

  /// Puts a failed, cancelled or not-sent message back in the queue.
  ///
  /// `skipped` is retryable upstream and the row menu offers it, which is a
  /// deliberate difference from the badge's colour: not a failure to look at,
  /// but still a thing an owner may want sent once the gateway is configured.
  Future<NotificationActionResult> retry(String notificationId) {
    return _run(
      () => ref
          .read(notificationsRepositoryProvider)
          .retryNotification(notificationId),
      'Queued again. It goes out within a minute.',
    );
  }

  /// Stops a message that has not been claimed by the outbox yet.
  ///
  /// A row that has moved to `sending` in the seconds since the list was drawn
  /// is refused by the RPC rather than by this controller. That refusal is the
  /// honest answer -- the message is already with the gateway -- and it is
  /// rendered as written.
  Future<NotificationActionResult> cancel(String notificationId) {
    return _run(
      () => ref
          .read(notificationsRepositoryProvider)
          .cancelNotification(notificationId),
      'Cancelled. It will not be sent.',
    );
  }

  Future<NotificationActionResult> _run(
    Future<void> Function() action,
    String successMessage,
  ) async {
    if (state) {
      // A double tap is not a second intent. Refusing here keeps a slow
      // network from queueing the same message twice.
      return const NotificationActionFailed(
        AppFailure(FailureKind.invalid, 'That is already being saved.'),
      );
    }

    state = true;
    try {
      await action();
      // The log is the screen behind both of these, so it is always stale
      // afterwards -- and the summary strip counts by status, which is exactly
      // what just changed.
      await ref.read(notificationLogProvider.notifier).refresh();
      ref.invalidate(notificationStatusCountsProvider);
      return NotificationActionSucceeded(successMessage);
    } catch (error, stackTrace) {
      return NotificationActionFailed(mapError(error, stackTrace));
    } finally {
      state = false;
    }
  }
}
