// Keeps the announcements list current while a broadcast is still going out.
//
// A DELIBERATE NEAR-COPY of `notification_live_refresh.dart`, not a shared
// abstraction. What the two have in common is a `Timer`; what differs is which
// provider is polled, which count decides whether to poll at all, and which
// clock gives up -- which is all of it. Factoring that out produces a generic
// poller parameterised by three things, read at two call sites, which is harder
// to follow than the duplicate and couples two sub-projects at the one point
// where a change to one must not silently change the other.
//
// The reasoning behind the behaviour is written out in full in that file and is
// not repeated here: the `resumed`/`backgrounded` pair is the phone's answer to
// the web's `window.focus`, the pause is because a phone in a pocket polling
// every eight seconds costs battery and a chain's data plan, and the give-up
// clock keeps running across a pause on purpose.
//
// One difference worth naming: a broadcast's rows are written all at once and
// leave over the following minutes, so the count this polls on is the sum of
// `queued` across the loaded announcements rather than a row's own status.
import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:logfitness_flutter/features/announcements/announcement_list_controller.dart';

part 'announcement_live_refresh.g.dart';

/// How often the list re-reads itself while a send is still going.
///
/// A provider rather than a constant so a test can shrink it -- the alternative
/// to `package:fake_async`, which is only a transitive dependency here.
@riverpod
Duration announcementPollInterval(Ref ref) => const Duration(seconds: 8);

/// How long the poller keeps trying before it gives up and says so.
@riverpod
Duration announcementPollGiveUp(Ref ref) => const Duration(minutes: 15);

/// What the live-refresh line on the announcements tab is rendering.
class AnnouncementLiveRefreshState {
  const AnnouncementLiveRefreshState({
    required this.pending,
    required this.polling,
    required this.gaveUp,
  });

  /// Messages still queued across the loaded announcements. Zero means the line
  /// is not rendered at all.
  final int pending;

  /// Whether a timer is actually running. False while backgrounded even when
  /// [pending] is not zero.
  final bool polling;

  /// The fifteen minutes elapsed. Only [AnnouncementLiveRefresh.resume] undoes
  /// it, never a rebuild — a screen that quietly restarted a poll the reader
  /// was told had stopped would be lying twice.
  final bool gaveUp;

  AnnouncementLiveRefreshState copyWith({
    int? pending,
    bool? polling,
    bool? gaveUp,
  }) {
    return AnnouncementLiveRefreshState(
      pending: pending ?? this.pending,
      polling: polling ?? this.polling,
      gaveUp: gaveUp ?? this.gaveUp,
    );
  }
}

@riverpod
class AnnouncementLiveRefresh extends _$AnnouncementLiveRefresh {
  Timer? _timer;
  DateTime? _startedAt;
  bool _gaveUp = false;
  bool _backgrounded = false;

  @override
  AnnouncementLiveRefreshState build() {
    // A leaked `Timer.periodic` keeps a disposed provider's closure alive and
    // keeps hitting the database from a screen that is gone.
    ref.onDispose(_cancelTimer);

    // Narrowed to the count, not the list: `onDispose` runs on every recompute,
    // so watching the whole list would rebuild the timer on every refresh and
    // the interval would drift by a round trip each time.
    final int pending = ref.watch(announcementPendingCountProvider);
    _syncTimer(pending);

    return AnnouncementLiveRefreshState(
      pending: pending,
      polling: _timer != null,
      gaveUp: _gaveUp,
    );
  }

  /// Called from `AppLifecycleState.resumed`, by the screen that owns the
  /// lifecycle listener.
  void onResumed() {
    if (!_backgrounded) return;
    _backgrounded = false;
    _syncTimer(state.pending);
    state = state.copyWith(polling: _timer != null);
    unawaited(_refreshList());
  }

  /// Called from `AppLifecycleState.inactive` and `.paused`.
  void onBackgrounded() {
    if (_backgrounded) return;
    _backgrounded = true;
    _cancelTimer();
    state = state.copyWith(polling: false);
  }

  /// The "Stopped checking. Check again" button.
  void resume() {
    _gaveUp = false;
    _startedAt = null;
    _syncTimer(state.pending);
    state = state.copyWith(polling: _timer != null, gaveUp: false);
    unawaited(_refreshList());
  }

  void _syncTimer(int pending) {
    final bool shouldPoll = pending > 0 && !_gaveUp && !_backgrounded;
    if (!shouldPoll) {
      _cancelTimer();
      if (!_backgrounded) _startedAt = null;
      return;
    }
    if (_timer != null) return;

    _startedAt ??= DateTime.now();
    _timer = Timer.periodic(
      ref.read(announcementPollIntervalProvider),
      (_) => _tick(),
    );
  }

  void _tick() {
    final DateTime started = _startedAt ?? DateTime.now();
    if (DateTime.now().difference(started) >=
        ref.read(announcementPollGiveUpProvider)) {
      _gaveUp = true;
      _cancelTimer();
      state = state.copyWith(polling: false, gaveUp: true);
      return;
    }
    unawaited(_refreshList());
  }

  /// The failure is not swallowed: `refresh()` puts it on the list provider,
  /// which the tab renders. What is caught here is the rethrow off the awaited
  /// future, which would otherwise arrive as an unhandled timer error.
  Future<void> _refreshList() async {
    try {
      await ref.read(announcementListProvider.notifier).refresh();
    } catch (_) {
      // Already on the provider. See above.
    }
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }
}
