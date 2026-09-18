// The balance poller.
//
// NO `package:fake_async`: it is in `pubspec.lock` only as a transitive
// dependency of `flutter_test`, and importing it without adding it to
// `pubspec.yaml` trips `depend_on_referenced_packages` -- and an
// analyze-clean tree is a merge gate (PLANNING.md §2). The notifier's own
// clock is injected instead, exactly as the delivery log's poller does it,
// and these tests run it at milliseconds.
//
// `Override` is not exported by flutter_riverpod 3.1.0, so every overrides
// list stays an untyped literal (TASKS.md, Discovered, 2026-09-05).
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/notifications/notification_provider.dart';
import 'package:logfitness_flutter/data/notifications/notifications_repository.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/features/settings/notifications/gateway_balance_controller.dart';

/// Short enough that eight of them is still a fast test, long enough that one
/// certainly lands.
const Duration _interval = Duration(milliseconds: 20);

Future<void> _tick([int ticks = 1]) =>
    Future<void>.delayed(_interval * ticks + const Duration(milliseconds: 15));

/// Only the two balance methods are wired. `noSuchMethod` throws for anything
/// else rather than answering quietly: a test that reached a third method
/// would be testing something this file does not claim to cover.
class _FakeRepository implements NotificationsRepository {
  int requestCalls = 0;
  int readCalls = 0;

  /// Thrown by [requestGatewayBalance]. The throttle refusal arrives this way.
  Object? requestError;

  /// Answered by [readGatewayBalance] once the pending runs out. Null means
  /// "never stops being pending".
  GatewayBalance? answer;
  int pendingReads = 1000;

  @override
  Future<void> requestGatewayBalance(String providerId) async {
    requestCalls += 1;
    if (requestError != null) throw requestError!;
  }

  @override
  Future<GatewayBalance> readGatewayBalance(String providerId) async {
    readCalls += 1;
    if (readCalls <= pendingReads) {
      return const GatewayBalance(pending: true);
    }
    return answer ?? const GatewayBalance(pending: false);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError(
    '${invocation.memberName} is not part of the balance poller test',
  );
}

void main() {
  late _FakeRepository repository;
  late ProviderContainer container;
  late ProviderSubscription<GatewayBalanceState> subscription;
  bool disposed = false;

  void start() {
    disposed = false;
    repository = _FakeRepository();
    container = ProviderContainer(
      overrides: [
        notificationsRepositoryProvider.overrideWithValue(repository),
        gatewayBalancePollIntervalProvider.overrideWithValue(_interval),
      ],
    );
    // A notifier nobody listens to is disposed the moment it is read, taking
    // its timer with it. The screen's `ref.watch` is this subscription.
    subscription = container.listen<GatewayBalanceState>(
      gatewayBalanceCheckProvider('gateway-1'),
      (_, _) {},
      fireImmediately: true,
    );
  }

  void stop() {
    if (disposed) return;
    disposed = true;
    subscription.close();
    container.dispose();
  }

  tearDown(stop);

  GatewayBalanceCheck notifier() =>
      container.read(gatewayBalanceCheckProvider('gateway-1').notifier);

  test('gives up after eight tries and says so', () async {
    start();
    // Eight at 1.5s covers the 15s timeout the request itself carries. Past
    // that the gateway is not slow, it is not answering.
    unawaitedCheck(notifier());

    await _tick(kGatewayBalanceAttempts + 2);

    expect(repository.readCalls, kGatewayBalanceAttempts);
    expect(
      subscription.read().error,
      'The gateway has not answered yet. Try again in a moment.',
    );
    expect(subscription.read().checking, isFalse);
  });

  test('a second tap while a request is out is a no-op', () async {
    start();
    // The RPC throttles to one live request per gateway per twenty seconds, so
    // a second request inside that window would only re-read the first one's
    // answer -- and would look, to the person tapping, like nothing happened.
    unawaitedCheck(notifier());
    await Future<void>.delayed(Duration.zero);
    unawaitedCheck(notifier());

    await _tick(2);

    expect(repository.requestCalls, 1);
  });

  test('an answer stops the poll and carries the routes', () async {
    start();
    repository
      ..pendingReads = 2
      ..answer = const GatewayBalance(
        pending: false,
        routes: <GatewayBalanceRoute>[
          GatewayBalanceRoute(
            routeId: 10259,
            route: 'Transactional',
            balance: 4820,
          ),
        ],
      );

    unawaitedCheck(notifier());
    await _tick(kGatewayBalanceAttempts + 2);

    expect(repository.readCalls, 3, reason: 'it stops as soon as it is told');
    expect(subscription.read().routes, hasLength(1));
    // SMSPasal documents these as strings and answers with numbers; both have
    // to render.
    expect(subscription.read().routes!.single.balanceText, '4820');
    expect(subscription.read().error, isNull);
  });

  test('a throttle refusal is a sentence, not a spinner', () async {
    start();
    repository.requestError = const AppFailure(
      FailureKind.invalid,
      'A balance check for this gateway is already running.',
    );

    unawaitedCheck(notifier());
    await _tick();

    expect(
      subscription.read().error,
      'A balance check for this gateway is already running.',
    );
    expect(subscription.read().checking, isFalse);
    expect(
      repository.readCalls,
      0,
      reason: 'nothing was requested to poll for',
    );
  });

  test('disposing mid-poll cancels the timer', () async {
    start();
    unawaitedCheck(notifier());
    await _tick(2);

    final int readsBefore = repository.readCalls;
    expect(readsBefore, greaterThan(0));

    stop();
    await _tick(4);

    // A `Timer` left running after the screen is popped goes on issuing one
    // RPC every interval into nothing.
    expect(repository.readCalls, readsBefore);
  });
}

/// `unawaited_futures` is on, and every one of these is deliberately left to
/// run while the test advances the clock.
void unawaitedCheck(GatewayBalanceCheck notifier) {
  // ignore: unawaited_futures
  notifier.check();
}
