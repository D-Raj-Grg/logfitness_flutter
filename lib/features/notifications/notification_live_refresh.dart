// Keeps the delivery log current while anything is still moving.
//
// The Dart translation of `logfitness_saas/components/notifications/live-refresh.tsx`,
// and the reasoning transfers unchanged: a message sits in `sending` for up to
// a minute -- the outbox cron hands it to the gateway on one tick and reads the
// reply on the next -- so the row that matters is precisely the one that is
// already wrong by the time the screen has finished painting. Rather than ask
// the desk to pull to refresh, the log re-fetches itself on a timer for as long
// as something is in flight, and stops the moment nothing is.
//
// Polling, not realtime, is the parity-correct choice: this app uses realtime
// nowhere and `notification_messages` is not in the realtime publication.
//
// TWO MOBILE-ONLY ADDITIONS to the web behaviour, both marked below:
//
//   1. The web listens for the window's `focus` event, because a tab that was
//      in the background is stale the moment it comes back. The phone's
//      equivalent is `AppLifecycleState.resumed`, which the screen delivers
//      through [NotificationLiveRefresh.onResumed] -- see
//      `notification_log_screen.dart`, which owns the `AppLifecycleListener`
//      (Flutter 3.13+; `WidgetsBindingObserver` is the pre-3.x idiom CLAUDE.md
//      warns about).
//   2. The poller *pauses* while the app is backgrounded. A browser tab left
//      open costs its owner nothing; a phone in a pocket burning one query
//      every eight seconds for fifteen minutes costs battery and a chain's
//      data plan, over a screen nobody is looking at.
import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:logfitness_flutter/features/notifications/notification_log_controller.dart';

part 'notification_live_refresh.g.dart';

/// How often the log re-reads itself while something is in flight.
///
/// A provider rather than a constant so a test can shrink it. Driving the
/// notifier's own clock is the alternative to `package:fake_async`, which is
/// only a transitive dependency here and may not be imported without adding it
/// to `pubspec.yaml` (`depend_on_referenced_packages`).
@riverpod
Duration notificationPollInterval(Ref ref) => const Duration(seconds: 8);

/// How long the poller keeps trying before it gives up and says so.
///
/// Fifteen minutes, from the console. It exists for the message that is stuck
/// rather than slow: without it a forgotten screen polls all afternoon over a
/// row that is never going to move.
@riverpod
Duration notificationPollGiveUp(Ref ref) => const Duration(minutes: 15);

/// What the live-refresh line on the log is rendering.
class NotificationLiveRefreshState {
  const NotificationLiveRefreshState({
    required this.pending,
    required this.polling,
    required this.gaveUp,
  });

  /// How many loaded rows are still `queued` or `sending`. Zero means the
  /// line is not rendered at all, exactly as the console returns `null`.
  final int pending;

  /// Whether a timer is actually running right now. False while backgrounded
  /// even though [pending] may be non-zero.
  final bool polling;

  /// The fifteen minutes elapsed. The line becomes "Stopped checking. Check
  /// again", and only [NotificationLiveRefresh.resume] undoes it -- never the
  /// notifier on its own, or a screen that rebuilt would quietly restart a
  /// poll the reader had been told had stopped.
  final bool gaveUp;

  NotificationLiveRefreshState copyWith({
    int? pending,
    bool? polling,
    bool? gaveUp,
  }) {
    return NotificationLiveRefreshState(
      pending: pending ?? this.pending,
      polling: polling ?? this.polling,
      gaveUp: gaveUp ?? this.gaveUp,
    );
  }
}

@riverpod
class NotificationLiveRefresh extends _$NotificationLiveRefresh {
  Timer? _timer;

  /// When the current run of polling started. Reset to null whenever polling
  /// stops for a reason other than backgrounding, so the next batch of
  /// messages gets a fresh fifteen minutes rather than inheriting the last
  /// batch's remainder.
  DateTime? _startedAt;

  bool _gaveUp = false;
  bool _backgrounded = false;

  @override
  NotificationLiveRefreshState build() {
    // Not optional, and the reason this is a notifier rather than a widget's
    // `initState`: a leaked `Timer.periodic` keeps a disposed provider's
    // closure alive and keeps hitting the database from a screen that is gone.
    ref.onDispose(_cancelTimer);

    // Read through [notificationPendingCount], not the log itself, and that is
    // load-bearing rather than tidy.
    // `ref.onDispose` above runs on every *recompute*, not only on destruction,
    // so each rebuild cancels the timer and `_syncTimer` makes a new one --
    // restarting the eight seconds. Watching the whole log would rebuild this
    // on every refresh, every appended page and every row that changed, and the
    // interval would drift by a round trip each time. Narrowed to the count,
    // the timer is rebuilt only when the number of moving rows actually
    // changes, which is exactly when the poller should be reconsidered anyway.
    final int pending = ref.watch(notificationPendingCountProvider);

    // `refresh()` below feeds straight back into this watch, which is what
    // makes the poller stop by itself once the last row lands.
    _syncTimer(pending);

    return NotificationLiveRefreshState(
      pending: pending,
      polling: _timer != null,
      gaveUp: _gaveUp,
    );
  }

  /// The screen calls this from `AppLifecycleState.resumed`.
  ///
  /// MOBILE-ONLY (1): the web's `window.addEventListener('focus', ...)`. One
  /// refresh immediately, because whatever is on screen was painted before the
  /// phone went into a pocket, then the timer picks up again.
  void onResumed() {
    if (!_backgrounded) return;
    _backgrounded = false;
    _syncTimer(state.pending);
    state = state.copyWith(polling: _timer != null);
    unawaited(_refreshLog());
  }

  /// The screen calls this from `AppLifecycleState.inactive` and `.paused`.
  ///
  /// MOBILE-ONLY (2): the give-up clock keeps running across the pause on
  /// purpose. Fifteen minutes is a statement about how long a message is worth
  /// watching, not about how much work the phone has done.
  void onBackgrounded() {
    if (_backgrounded) return;
    _backgrounded = true;
    _cancelTimer();
    state = state.copyWith(polling: false);
  }

  /// Starts the poller again after it gave up, and re-reads once immediately —
  /// the "Stopped checking. Check again" button.
  void resume() {
    _gaveUp = false;
    _startedAt = null;
    _syncTimer(state.pending);
    state = state.copyWith(polling: _timer != null, gaveUp: false);
    unawaited(_refreshLog());
  }

  void _syncTimer(int pending) {
    final bool shouldPoll = pending > 0 && !_gaveUp && !_backgrounded;
    if (!shouldPoll) {
      _cancelTimer();
      // Nothing in flight means the next batch starts its own fifteen
      // minutes. Backgrounding does not, which is why this is here and not in
      // `_cancelTimer`.
      if (!_backgrounded) _startedAt = null;
      return;
    }
    // Already running. Reached only within one build -- a rebuild has always
    // just cancelled the timer through `onDispose` -- but it keeps a second
    // call inside the same build from stacking two timers.
    if (_timer != null) return;

    _startedAt ??= DateTime.now();
    _timer = Timer.periodic(
      ref.read(notificationPollIntervalProvider),
      (_) => _tick(),
    );
  }

  void _tick() {
    final DateTime started = _startedAt ?? DateTime.now();
    if (DateTime.now().difference(started) >=
        ref.read(notificationPollGiveUpProvider)) {
      _gaveUp = true;
      _cancelTimer();
      state = state.copyWith(polling: false, gaveUp: true);
      return;
    }
    unawaited(_refreshLog());
  }

  /// The failure is not swallowed -- `refresh()` puts it on
  /// `notificationLogProvider` as an `AsyncValue.error`, which the screen
  /// renders through `AsyncValueView`/`FailureView`. What is caught here is
  /// only the rethrow off the awaited future, which would otherwise arrive as
  /// an unhandled error from a timer with nobody to hand it to.
  Future<void> _refreshLog() async {
    try {
      await ref.read(notificationLogProvider.notifier).refresh();
    } catch (_) {
      // Already on the provider. See above.
    }
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }
}

/// How many rows on the loaded page are still moving.
///
/// A separate provider rather than a `select` on the log: a generated notifier
/// provider exposes no `select`, and this achieves the same narrowing -- an
/// `int`-valued provider notifies its listeners only when the int changes, so
/// the poller is not rebuilt by every appended page or every row whose status
/// text shifted.
@riverpod
int notificationPendingCount(Ref ref) =>
    ref.watch(notificationLogProvider).value?.pendingCount ?? 0;
