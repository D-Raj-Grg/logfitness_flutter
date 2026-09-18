// "How many credits are left?", asked on demand.
//
// A two-step, and it has to be. The API key lives in Vault, so this app cannot
// call the gateway itself: `request_notification_gateway_balance` makes the
// call from inside the database with pg_net, and the reply arrives out of band
// and is parked on the provider row for
// `read_notification_gateway_balance` to collect a moment later. The button
// therefore fires the first and polls the second, exactly as
// `BalanceCheck` does in `logfitness_saas/components/notifications/provider-form.tsx`.
//
// The loop lives in a notifier and not in a widget for the reason every timer
// in this app does: a `Timer` started in a `State` that is popped mid-poll
// keeps firing into a dead tree. `ref.onDispose` cancels it here.
import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:logfitness_flutter/data/notifications/notification_provider.dart';
import 'package:logfitness_flutter/data/notifications/notifications_repository.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';

part 'gateway_balance_controller.g.dart';

/// Which gateways publish a credit balance at all.
///
/// `notification_balance_url()` has one arm, so this has one member. A gateway
/// that grows one upstream (docs/notifications.md §3, step "a gateway that
/// publishes a credit balance gets one more arm") is added here in the same
/// change, and nowhere else.
const Set<NotificationProviderKind> kBalanceCapableGateways =
    <NotificationProviderKind>{NotificationProviderKind.smspasalSms};

/// Eight tries at 1.5s ≈ 12s, which covers the 15s timeout the pg_net request
/// itself carries. Beyond that the gateway is not slow, it is not answering.
const int kGatewayBalanceAttempts = 8;
const Duration kGatewayBalancePollInterval = Duration(milliseconds: 1500);

/// The poll interval, injectable so the loop can be tested at milliseconds.
///
/// `package:fake_async` is deliberately not used anywhere in this suite: it is
/// in `pubspec.lock` only as a transitive dependency of `flutter_test`, and
/// importing it without adding it to `pubspec.yaml` trips
/// `depend_on_referenced_packages` -- and an analyze-clean tree is a merge
/// gate (PLANNING.md §2). Same trick, and the same reason, as
/// `notificationPollIntervalProvider`.
@riverpod
Duration gatewayBalancePollInterval(Ref ref) => kGatewayBalancePollInterval;

/// What the balance strip is showing.
class GatewayBalanceState {
  const GatewayBalanceState({
    this.checking = false,
    this.asked = false,
    this.routes,
    this.error,
    this.checkedAt,
  });

  /// A request is out. The button is disabled while this is true: the RPC
  /// throttles to one live request per gateway per twenty seconds, so a second
  /// tap inside that window would only re-read the first request's answer --
  /// and would look, to the person tapping, like the first tap did nothing.
  final bool checking;

  /// Whether anything has been asked yet, which is what separates "no routes
  /// on this account" from "nobody has asked".
  final bool asked;

  final List<GatewayBalanceRoute>? routes;

  /// The gateway's own refusal, or the throttle's, as a sentence. A refusal
  /// rendered as a spinner is a screen that never finishes.
  final String? error;

  final DateTime? checkedAt;

  /// The gateway answered, and had nothing to report.
  bool get answeredWithNothing =>
      asked &&
      !checking &&
      error == null &&
      (routes == null || routes!.isEmpty);
}

@riverpod
class GatewayBalanceCheck extends _$GatewayBalanceCheck {
  Timer? _timer;
  Completer<bool>? _sleep;
  bool _disposed = false;

  @override
  GatewayBalanceState build(String gatewayId) {
    // One registration, in build, rather than one per poll: `ref.onDispose`
    // throws if it is called after the notifier is gone, and a loop that
    // registered its own callback every 1.5s would be the call site most
    // likely to do exactly that.
    ref.onDispose(() {
      _disposed = true;
      _timer?.cancel();
      _timer = null;
      final Completer<bool>? sleeping = _sleep;
      if (sleeping != null && !sleeping.isCompleted) sleeping.complete(false);
    });
    return const GatewayBalanceState();
  }

  /// Ask the gateway, then wait for the database to hear back.
  Future<void> check() async {
    if (state.checking) return;

    state = const GatewayBalanceState(checking: true, asked: true);

    final NotificationsRepository repository = ref.read(
      notificationsRepositoryProvider,
    );

    try {
      await repository.requestGatewayBalance(gatewayId);
    } catch (error, stackTrace) {
      // Includes the throttle refusal. It is an answer -- "you asked twenty
      // seconds ago" -- and is rendered as one.
      _settle(error: mapError(error, stackTrace).message);
      return;
    }
    if (_disposed) return;

    final Duration interval = ref.read(gatewayBalancePollIntervalProvider);

    for (int attempt = 0; attempt < kGatewayBalanceAttempts; attempt++) {
      final bool waited = await _wait(interval);
      if (!waited || _disposed) return;

      final GatewayBalance answer;
      try {
        answer = await repository.readGatewayBalance(gatewayId);
      } catch (error, stackTrace) {
        _settle(error: mapError(error, stackTrace).message);
        return;
      }
      if (_disposed) return;

      if (!answer.pending) {
        _settle(
          routes: answer.routes,
          error: answer.error,
          checkedAt: answer.checkedAt,
        );
        return;
      }
    }

    _settle(error: 'The gateway has not answered yet. Try again in a moment.');
  }

  void _settle({
    List<GatewayBalanceRoute>? routes,
    String? error,
    DateTime? checkedAt,
  }) {
    if (_disposed) return;
    state = GatewayBalanceState(
      asked: true,
      routes: routes,
      error: error,
      checkedAt: checkedAt,
    );
  }

  /// Sleeps [duration], and answers false if the notifier was disposed while
  /// it slept. A bare `Future.delayed` cannot be cancelled, so the poll would
  /// otherwise outlive the screen it was started from and go on issuing one
  /// RPC every 1.5s into nothing.
  Future<bool> _wait(Duration duration) {
    if (_disposed) return Future<bool>.value(false);

    final Completer<bool> completer = Completer<bool>();
    _sleep = completer;
    _timer?.cancel();
    _timer = Timer(duration, () {
      if (!completer.isCompleted) completer.complete(true);
    });
    return completer.future;
  }
}
