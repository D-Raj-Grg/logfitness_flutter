// The poller that keeps the delivery log current while something is moving.
//
// NO `package:fake_async`. It is in `pubspec.lock` only as a transitive
// dependency of `flutter_test`, and importing it without adding it to
// `pubspec.yaml` trips `depend_on_referenced_packages` -- and `flutter analyze`
// clean is a merge gate (PLANNING.md §2). Adding the dependency is not this
// sub-project's to make, so the notifier's own clock is injected instead:
// `notificationPollIntervalProvider` and `notificationPollGiveUpProvider` exist
// for exactly this, and these tests run them at milliseconds.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/notifications/notifications_repository.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/features/notifications/notification_live_refresh.dart';
import 'package:logfitness_flutter/features/notifications/notification_log_controller.dart';
import 'package:logfitness_flutter/features/staff/branch_scope.dart';

import 'notification_log_controller_test.dart' show FakeNotificationsRepository;

/// Long enough for several ticks, short enough that the suite does not crawl.
const Duration _interval = Duration(milliseconds: 20);
const Duration _giveUp = Duration(milliseconds: 120);

/// A little over [_interval], so exactly one tick has certainly landed.
Future<void> _tick([int ticks = 1]) =>
    Future<void>.delayed(_interval * ticks + const Duration(milliseconds: 15));

void main() {
  late FakeNotificationsRepository repository;
  late ProviderContainer container;
  late ProviderSubscription<NotificationLiveRefreshState> subscription;
  bool disposed = false;

  Future<void> start({
    NotificationStatus rowStatus = NotificationStatus.queued,
  }) async {
    disposed = false;
    repository = FakeNotificationsRepository()..rowStatus = rowStatus;
    container = ProviderContainer(
      // Untyped literal on purpose: `Override` is not exported by
      // flutter_riverpod 3.1.0 (TASKS.md, Discovered, 2026-09-05).
      overrides: [
        notificationsRepositoryProvider.overrideWithValue(repository),
        branchScopeProvider.overrideWithValue(
          const BranchScope(
            options: <String>['branch-1'],
            selectedBranchId: 'branch-1',
            isOrgWide: false,
          ),
        ),
        notificationPollIntervalProvider.overrideWithValue(_interval),
        notificationPollGiveUpProvider.overrideWithValue(_giveUp),
      ],
    );
    // A notifier nobody listens to is disposed again the moment it is read,
    // taking its timer with it. The screen's `ref.watch` is this subscription.
    subscription = container.listen<NotificationLiveRefreshState>(
      notificationLiveRefreshProvider,
      (_, _) {},
      fireImmediately: true,
    );
    // The log has to have *loaded* before the poller can see a pending count:
    // while it is loading the count is zero and the poller is correctly idle.
    await container.read(notificationLogProvider.future);
    await Future<void>.delayed(Duration.zero);
  }

  tearDown(() {
    if (!disposed) container.dispose();
  });

  test('polls while something is still in flight', () async {
    await start();
    expect(subscription.read().pending, 1);
    expect(subscription.read().polling, isTrue);

    final int before = repository.listCalls.length;
    await _tick(2);
    expect(
      repository.listCalls.length,
      greaterThan(before),
      reason: 'a queued row is the one that is wrong by the time it is drawn',
    );
  });

  test('does not poll at all when nothing is in flight', () async {
    await start(rowStatus: NotificationStatus.sent);
    expect(subscription.read().pending, 0);
    expect(subscription.read().polling, isFalse);

    final int before = repository.listCalls.length;
    await _tick(3);
    expect(repository.listCalls.length, before);
  });

  test('stops the moment the last row lands', () async {
    await start();
    expect(subscription.read().polling, isTrue);

    // The next read reports the message as delivered, which is what the sweep
    // would have written between two ticks.
    repository.rowStatus = NotificationStatus.sent;
    await _tick(2);

    expect(subscription.read().pending, 0);
    expect(subscription.read().polling, isFalse);

    final int before = repository.listCalls.length;
    await _tick(3);
    expect(repository.listCalls.length, before);
  });

  test('gives up after the give-up window, and resume restarts it', () async {
    await start();

    // Well past `_giveUp`, with the row still queued: this is the message that
    // is stuck rather than slow, and the console's fifteen minutes exist for it.
    await Future<void>.delayed(_giveUp + _interval * 3);

    expect(subscription.read().gaveUp, isTrue);
    expect(subscription.read().polling, isFalse);

    final int afterGivingUp = repository.listCalls.length;
    await _tick(3);
    expect(repository.listCalls.length, afterGivingUp);

    // "Stopped checking. Check again" -- only this undoes it, never a rebuild.
    container.read(notificationLiveRefreshProvider.notifier).resume();
    expect(subscription.read().gaveUp, isFalse);
    expect(subscription.read().polling, isTrue);

    await _tick(2);
    expect(repository.listCalls.length, greaterThan(afterGivingUp));
  });

  test('backgrounding pauses the timer and resuming re-reads once', () async {
    await start();

    // MOBILE-ONLY: a phone in a pocket must not burn a query every interval.
    container.read(notificationLiveRefreshProvider.notifier).onBackgrounded();
    expect(subscription.read().polling, isFalse);

    final int backgrounded = repository.listCalls.length;
    await _tick(3);
    expect(repository.listCalls.length, backgrounded);

    container.read(notificationLiveRefreshProvider.notifier).onResumed();
    await _tick();
    expect(
      repository.listCalls.length,
      greaterThan(backgrounded),
      reason: 'what is on screen was painted before the phone went away',
    );
  });

  test('the timer is cancelled on dispose', () async {
    await start();
    expect(subscription.read().polling, isTrue);

    container.dispose();
    disposed = true;
    final int atDispose = repository.listCalls.length;
    await _tick(4);

    // A leaked `Timer.periodic` keeps hitting the database from a screen that
    // is gone. `ref.onDispose(timer.cancel)` is what stops it.
    expect(repository.listCalls.length, atDispose);
  });
}
