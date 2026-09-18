// The read side of Settings → Notifications.
//
// Three independent loads rather than one, mirroring the console page's three
// cards: the gateways (with a boolean per row saying whether a token is
// stored), the reminder rules, and one resolved template per editable event.
// Independent because saving a rule should not make the gateway tab flicker,
// and because a gym with no gateway still has rules and wording worth reading.
//
// Widgets call controllers; controllers call repositories (PLANNING.md §6).
//
// **Everything here is owner-only, and RLS says so without consulting this
// file.** `notification_providers` has an owner-only SELECT policy, so a
// manager's read comes back EMPTY rather than refused -- which is why the
// screen is gated on `StaffCapability.configureNotifications` at the entry
// point rather than inferring "no gateway" from an empty list.
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:logfitness_flutter/data/notifications/notification_provider.dart';
import 'package:logfitness_flutter/data/notifications/notification_rule.dart';
import 'package:logfitness_flutter/data/notifications/notification_template.dart';
import 'package:logfitness_flutter/data/notifications/notifications_repository.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/supabase/supabase_providers.dart';

part 'notification_settings_controllers.g.dart';

/// The org whose settings are being edited, off the session's claims.
///
/// Null before the claims land, and for a session that is not staff. Every
/// provider below fails closed on it rather than guessing an org id -- the
/// alternative is a write aimed at whichever org the client last knew about.
@riverpod
String? notificationSettingsOrgId(Ref ref) => ref.watch(claimsProvider)?.orgId;

/// Raised when a settings read or write is attempted with no org claim. Not a
/// user-facing state: the screen is only reachable from a staff shell, which
/// already has claims.
class MissingOrgClaim implements Exception {
  const MissingOrgClaim();

  @override
  String toString() => 'MissingOrgClaim: the session carries no org_id';
}

/// The org's gateways, plus whether each one holds a token.
///
/// The two travel together because neither is useful alone: a gateway row with
/// no credential is configured and mute, and that is exactly the state the
/// channel chip has to be able to say out loud.
class GatewaySettings {
  const GatewaySettings({required this.rows, required this.hasToken});

  final List<NotificationProvider> rows;

  /// Gateway id → whether a token is stored. **Never the token.**
  /// `notification_credential` is callable by no client role at all, so there
  /// is no path from this app to the value; the only three operations are "is
  /// one stored", "store this one" and "forget it".
  final Map<String, bool> hasToken;

  /// The row a message on [channel] would actually use.
  ///
  /// The active one wins. Only active rows are unique per channel, so a channel
  /// can hold a paused row alongside a live one, and editing the paused one
  /// while the live one keeps sending is the wrong surprise.
  NotificationProvider? forChannel(NotificationChannel channel) {
    final List<NotificationProvider> rows = this.rows
        .where((NotificationProvider row) => row.channel == channel)
        .toList(growable: false);
    if (rows.isEmpty) return null;
    for (final NotificationProvider row in rows) {
      if (row.isActive) return row;
    }
    return rows.first;
  }

  bool tokenFor(NotificationProvider? row) =>
      row == null ? false : (hasToken[row.id] ?? false);
}

@riverpod
Future<GatewaySettings> notificationGateways(Ref ref) async {
  final NotificationsRepository repository = ref.watch(
    notificationsRepositoryProvider,
  );
  final List<NotificationProvider> rows = await repository
      .listNotificationProviders();

  // One RPC per gateway, in parallel. There are at most three rows on this
  // screen (one channel each), so the fan-out is bounded by the schema rather
  // than by the gym's size.
  final List<bool> flags = await Future.wait(
    rows.map(
      (NotificationProvider row) =>
          repository.notificationHasCredential(row.id),
    ),
  );

  return GatewaySettings(
    rows: rows,
    hasToken: <String, bool>{
      for (int i = 0; i < rows.length; i++) rows[i].id: flags[i],
    },
  );
}

/// The reminder schedule. Readable by any staff; writable by an owner only.
@riverpod
Future<List<NotificationRule>> notificationRules(Ref ref) {
  return ref.watch(notificationsRepositoryProvider).listNotificationRules();
}

/// `en` or `ne`, from the org's own settings.
///
/// Read through `org_notification_locale` rather than defaulted to `'en'` in
/// Dart. The fallback chain belongs in one place: a Nepali gym previewing
/// English while sending Nepali is a bug nobody reports, because the preview
/// looks right to whoever is reading it in English.
@riverpod
Future<String> notificationLocale(Ref ref) async {
  final String? orgId = ref.watch(notificationSettingsOrgIdProvider);
  if (orgId == null) throw const MissingOrgClaim();
  return ref
      .watch(notificationsRepositoryProvider)
      .orgNotificationLocale(orgId);
}

/// What a message for [event] would actually say today: the gym's own wording
/// when it has edited one, and the built-in otherwise.
///
/// Resolved through the database rather than by duplicating the defaults in
/// Dart, which is what stops the preview and the send from drifting apart --
/// the real message is rendered in Postgres by `render_notification_template`.
///
/// SMS only, as on the console. Viber and email reuse the SMS wording until a
/// gym asks for a second draft, and offering three editors for one sentence is
/// how all three end up stale.
@riverpod
Future<NotificationTemplatePreview?> notificationTemplatePreview(
  Ref ref,
  NotificationEvent event,
) async {
  final String? orgId = ref.watch(notificationSettingsOrgIdProvider);
  if (orgId == null) throw const MissingOrgClaim();
  final String locale = await ref.watch(notificationLocaleProvider.future);

  return ref
      .watch(notificationsRepositoryProvider)
      .previewNotificationTemplate(
        orgId,
        event,
        NotificationChannel.sms,
        locale,
      );
}
