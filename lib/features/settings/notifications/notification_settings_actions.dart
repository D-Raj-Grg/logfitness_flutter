// The write side of Settings → Notifications.
//
// Dart twin of `logfitness_saas/app/(app)/settings/notifications/actions.ts`,
// one method per server action, with the success sentences copied rather than
// rewritten: an owner who configures the gym on a laptop and checks it on a
// phone should be told the same thing both times.
//
// Every action reports its outcome. A write that returns void into a widget
// which assumes success is the 2026-09-07 console bug, where an authorization
// refusal was discarded and a manager could not tell a refused write from a
// completed one. Every one of these surfaces is owner-only in RLS, so `42501`
// is a live possibility on every call here and must reach the screen as a
// sentence.
//
// Widgets call controllers; controllers call repositories (PLANNING.md §6).
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:logfitness_flutter/data/notifications/notification_provider.dart';
import 'package:logfitness_flutter/data/notifications/notifications_repository.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/features/settings/notifications/notification_settings_controllers.dart';
import 'package:logfitness_flutter/supabase/supabase_providers.dart';

part 'notification_settings_actions.g.dart';

/// The result of one settings write. A screen either says what changed or says
/// why it did not; there is no third case.
sealed class SettingsActionResult {
  const SettingsActionResult();
}

class SettingsActionSucceeded extends SettingsActionResult {
  const SettingsActionSucceeded(this.message);

  /// Shown as written, in the console's own words.
  final String message;
}

class SettingsActionFailed extends SettingsActionResult {
  const SettingsActionFailed(this.failure);

  final AppFailure failure;

  /// The database refused this write. Worth distinguishing at the call site:
  /// role gating in this app is UX only (CLAUDE.md), so a refusal means the
  /// screen offered something the caller was never allowed to do.
  bool get isRefusal => failure.isRefusal;
}

@riverpod
class NotificationSettingsActions extends _$NotificationSettingsActions {
  @override
  bool build() => false; // true while a write is in flight

  NotificationsRepository get _repository =>
      ref.read(notificationsRepositoryProvider);

  /// Connect a gateway, or save an edit to one.
  ///
  /// One method for both, as on the console, because the fields are the same
  /// and the only difference is whether an id already exists. [apiToken] null
  /// means **leave whatever is stored alone**: there is no way to read a token
  /// back to prefill it, so blank cannot be allowed to mean "clear it".
  /// Clearing is [forgetToken].
  Future<SettingsActionResult> saveGateway({
    required String? gatewayId,
    required NotificationChannel channel,
    required NotificationProviderKind provider,
    required String? senderId,
    required String? endpointUrl,
    required Map<String, dynamic> config,
    required bool isActive,
    String? apiToken,
  }) {
    return _run(() async {
      final String? orgId = ref.read(notificationSettingsOrgIdProvider);
      if (orgId == null) throw const MissingOrgClaim();

      String id;
      if (gatewayId != null) {
        await _repository.updateNotificationProvider(
          gatewayId,
          provider: provider,
          senderId: senderId,
          endpointUrl: endpointUrl,
          config: config,
          isActive: isActive,
        );
        id = gatewayId;
      } else {
        id = await _repository.insertNotificationProvider(
          orgId: orgId,
          channel: channel,
          provider: provider,
          senderId: senderId,
          endpointUrl: endpointUrl,
          config: config,
          isActive: isActive,
          createdBy: ref.read(claimsProvider)?.staffId,
        );
      }

      // Second, and only when there is one. The row has to exist before the
      // Vault secret can be named after it.
      if (apiToken != null) {
        await _repository.setNotificationCredential(id, apiToken);
      }

      return 'Gateway saved.';
    });
  }

  /// Remove a gateway. The `drop_notification_secret` trigger drops the Vault
  /// secret with the row, so this does not leave a live credential behind.
  Future<SettingsActionResult> removeGateway(String gatewayId) {
    return _run(() async {
      await _repository.deleteNotificationProvider(gatewayId);
      return 'Gateway removed.';
    });
  }

  Future<SettingsActionResult> forgetToken(String gatewayId) {
    return _run(() async {
      await _repository.clearNotificationCredential(gatewayId);
      return 'Token cleared. Nothing will be sent on that channel until a new one is set.';
    });
  }

  /// Send one real message to one number the owner chooses.
  ///
  /// This is the only way to find out whether a token, a sender ID and a route
  /// actually work -- every gateway accepts a plausible-looking request and
  /// only tells the truth when a handset lights up.
  ///
  /// Refused up front when the channel has no active gateway: the send would
  /// otherwise land in the log as `skipped` a minute later, which is an answer
  /// nobody is still watching for.
  Future<SettingsActionResult> sendTest({
    required NotificationChannel channel,
    required String to,
  }) {
    return _run(() async {
      final String trimmed = to.trim();
      if (trimmed.length < 3) {
        throw const AppFailure(FailureKind.invalid, 'Who should this go to?');
      }

      final GatewaySettings gateways = await ref.read(
        notificationGatewaysProvider.future,
      );
      NotificationProvider? gateway;
      for (final NotificationProvider row in gateways.rows) {
        if (row.channel == channel && row.isActive) {
          gateway = row;
          break;
        }
      }
      if (gateway == null) {
        throw const AppFailure(
          FailureKind.invalid,
          'There is no gateway on that channel yet, so nothing would go out.',
        );
      }

      await _repository.enqueueNotification(
        channel: channel,
        event: NotificationEvent.testMessage,
        to: trimmed,
        // The console interpolates the gym's name here, which it has on its
        // staff session. This app's claims carry `org_id` and no org name, and
        // fetching one to decorate a test message is a query for nothing --
        // the point of the test is that a handset lights up at all.
        body:
            'Test message from your gym. If you are reading it, the gateway works.',
        staffId: ref.read(claimsProvider)?.staffId,
      );

      // "the Notifications log" upstream. This app calls that screen Messages.
      return 'Queued. It goes out within a minute — watch Messages for what the gateway said.';
    });
  }

  /// Save one reminder row. [minAmountPaisa] is integer paisa, converted from
  /// rupees at the form's render boundary and nowhere else (CLAUDE.md).
  Future<SettingsActionResult> saveRule({
    required String ruleId,
    required bool enabled,
    required int minAmountPaisa,
    required int repeatAfterDays,
    required String sendAtLocal,
  }) {
    return _run(() async {
      await _repository.updateNotificationRule(
        ruleId,
        enabled: enabled,
        minAmountPaisa: minAmountPaisa,
        repeatAfterDays: repeatAfterDays,
        sendAtLocal: sendAtLocal,
      );
      return 'Reminder saved.';
    });
  }

  /// Save the gym's own wording for one event. Upserts on
  /// `org_id,event,channel,locale`, so the second save edits the first row
  /// rather than racing the unique index.
  Future<SettingsActionResult> saveTemplate({
    required NotificationEvent event,
    required NotificationChannel channel,
    required String locale,
    required String body,
    String? subject,
  }) {
    return _run(() async {
      final String? orgId = ref.read(notificationSettingsOrgIdProvider);
      if (orgId == null) throw const MissingOrgClaim();

      final String trimmed = body.trim();
      if (trimmed.isEmpty) {
        throw const AppFailure(
          FailureKind.invalid,
          'The message cannot be empty',
        );
      }

      await _repository.upsertNotificationTemplate(
        orgId: orgId,
        event: event,
        channel: channel,
        locale: locale,
        body: trimmed,
        subject: subject,
        // Who reworded it. The console records this; without it, "who last
        // changed the dues reminder" has no answer for an edit made on a phone.
        updatedBy: ref.read(claimsProvider)?.staffId,
      );
      return 'Wording saved. It applies to messages queued from now on.';
    });
  }

  /// Drop the gym's own wording so the built-in takes over again.
  Future<SettingsActionResult> resetTemplate(String templateId) {
    return _run(() async {
      await _repository.deleteNotificationTemplate(templateId);
      return 'Reset to the standard wording.';
    });
  }

  Future<SettingsActionResult> _run(Future<String> Function() action) async {
    if (state) {
      // A double tap is not a second intent.
      return const SettingsActionFailed(
        AppFailure(FailureKind.invalid, 'That is already being saved.'),
      );
    }

    state = true;
    try {
      final String message = await action();
      // Everything on this screen is derived from what was just written, so
      // all three reads are stale afterwards. Invalidating rather than
      // patching keeps the screen agreeing with the database, including about
      // the fields a trigger filled in.
      ref.invalidate(notificationGatewaysProvider);
      ref.invalidate(notificationRulesProvider);
      ref.invalidate(notificationTemplatePreviewProvider);
      return SettingsActionSucceeded(message);
    } catch (error, stackTrace) {
      return SettingsActionFailed(mapError(error, stackTrace));
    } finally {
      state = false;
    }
  }
}
