// Everything the app asks the database about notifications.
//
// Mirrors `logfitness_saas/lib/db/notifications.ts` one method for one export,
// same names in the same order, so parity across the surface is mechanically
// auditable rather than a matter of reading two screens side by side. Where a
// signature deviates it says so and says why.
//
// A repository is the only thing that touches `supabase` (PLANNING.md §6).
// Controllers call repositories; widgets call controllers.
//
// Nothing here filters by `org_id`. RLS is the tenant boundary, and a query
// that returns the right rows only because of a client-side filter is a bug.
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:logfitness_flutter/data/notifications/notification_message.dart';
import 'package:logfitness_flutter/data/notifications/notification_previews.dart';
import 'package:logfitness_flutter/data/notifications/notification_provider.dart';
import 'package:logfitness_flutter/data/notifications/notification_queries.dart';
import 'package:logfitness_flutter/data/notifications/notification_rule.dart';
import 'package:logfitness_flutter/data/notifications/notification_template.dart';
import 'package:logfitness_flutter/data/repository_guard.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/supabase/supabase_providers.dart';

part 'notifications_repository.g.dart';

class NotificationsRepository {
  const NotificationsRepository(this._client);

  final SupabaseClient _client;

  static const String _messages = 'notification_messages';
  static const String _providers = 'notification_providers';
  static const String _rules = 'notification_rules';
  static const String _templates = 'notification_templates';

  // ------------------------------------------------------------------
  // the delivery log
  // ------------------------------------------------------------------

  /// The delivery log, newest first.
  Future<NotificationPage> listNotifications(
    NotificationListFilter filter,
  ) async {
    return guardFailures(() async {
      var request = _client.from(_messages).select();

      final String? branches = notificationBranchFilter(filter.branchIds);
      if (branches != null) {
        request = request.or(branches);
      }

      final NotificationStatus? status = filter.status;
      if (status != null) {
        request = request.eq('status', status.toDb());
      }
      final NotificationEvent? event = filter.event;
      if (event != null) {
        request = request.eq('event', event.toDb());
      }
      final NotificationChannel? channel = filter.channel;
      if (channel != null) {
        request = request.eq('channel', channel.toDb());
      }

      final String? search = notificationSearchFilter(filter.query);
      if (search != null) {
        request = request.or(search);
      }

      final int from = (filter.page - 1) * filter.pageSize;
      final response = await request
          .order('created_at', ascending: false)
          // Not optional. A sweep writes a whole batch in one transaction, so
          // `created_at` repeats; without a unique final sort key a row lands
          // on two pages while another lands on none.
          .order('id', ascending: false)
          .range(from, from + filter.pageSize - 1)
          .count(CountOption.exact);

      return NotificationPage(
        rows: response.data
            .map(NotificationMessage.fromJson)
            .toList(growable: false),
        total: response.count,
        page: filter.page,
        pageSize: filter.pageSize,
      );
    });
  }

  /// How many messages are sitting in each state, for the log's summary strip.
  ///
  /// One head-only count per state rather than selecting every row and counting
  /// in Dart: a chain sending thirty thousand messages a month would pull all
  /// of them across the wire to produce four integers, and any row cap would
  /// make the numbers quietly wrong rather than slow.
  Future<NotificationStatusCounts> notificationStatusCounts(
    List<String>? branchIds,
    List<NotificationStatus> statuses,
  ) async {
    return guardFailures(() async {
      final String? branches = notificationBranchFilter(branchIds);

      final List<int> counts = await Future.wait(
        statuses.map((NotificationStatus status) {
          var request = _client
              .from(_messages)
              .count(CountOption.exact)
              .eq('status', status.toDb());
          if (branches != null) {
            request = request.or(branches);
          }
          return request;
        }),
      );

      return NotificationStatusCounts(<NotificationStatus, int>{
        for (int i = 0; i < statuses.length; i++) statuses[i]: counts[i],
      });
    });
  }

  /// Everything one member has been told, newest first, for the profile's own
  /// log. RLS bounds it exactly as the delivery log is bounded.
  Future<List<NotificationMessage>> listNotificationsForMember(
    String memberId, {
    int limit = 25,
  }) async {
    return guardFailures(() async {
      final List<Map<String, dynamic>> rows = await _client
          .from(_messages)
          .select()
          .eq('member_id', memberId)
          .order('created_at', ascending: false)
          .order('id', ascending: false)
          .limit(limit);

      return rows.map(NotificationMessage.fromJson).toList(growable: false);
    });
  }

  // ------------------------------------------------------------------
  // gateways -- owner only, and the refusal comes from RLS
  // ------------------------------------------------------------------

  /// The org's gateways.
  ///
  /// **A non-owner gets an empty list, not a refusal.** The SELECT policy is
  /// owner-only, so RLS filters the rows away rather than raising; every caller
  /// has to gate on the capability instead of inferring "no gateway" from an
  /// empty answer, or a manager is told a gym with three gateways has none.
  Future<List<NotificationProvider>> listNotificationProviders() async {
    return guardFailures(() async {
      final List<Map<String, dynamic>> rows = await _client
          .from(_providers)
          .select()
          // `ascending: true` is not decoration: postgrest-dart's `order`
          // defaults to **descending**, unlike PostgREST's own default and
          // unlike the console's `.order(col, { ascending: true })`. A bare
          // `.order(col)` here would silently reverse the list.
          .order('channel', ascending: true)
          .order('id', ascending: true);

      return rows.map(NotificationProvider.fromJson).toList(growable: false);
    });
  }

  /// Whether a gateway holds a token. Deliberately a boolean and not the token:
  /// `notification_credential` is callable by no client role at all, so there
  /// is no path from this app to the secret itself.
  Future<bool> notificationHasCredential(String providerId) async {
    return guardFailures(() async {
      final Object? value = await _client.rpc<Object?>(
        'notification_has_credential',
        params: <String, dynamic>{'p_provider_id': providerId},
      );
      return value == true;
    });
  }

  Future<String> insertNotificationProvider({
    required String orgId,
    required NotificationChannel channel,
    required NotificationProviderKind provider,
    String? senderId,
    String? endpointUrl,
    Map<String, dynamic> config = const <String, dynamic>{},
    bool isActive = true,
    String? createdBy,
  }) async {
    return guardFailures(() async {
      final Map<String, dynamic> row = await _client
          .from(_providers)
          .insert(<String, dynamic>{
            // Sent, not enforced: `jwt_is_owner()` in the insert policy is what
            // makes a foreign org_id a 42501 rather than a cross-tenant write.
            'org_id': orgId,
            'channel': channel.toDb(),
            'provider': provider.toDb(),
            'sender_id': senderId,
            'endpoint_url': endpointUrl,
            'config': config,
            'is_active': isActive,
            'created_by': createdBy,
          })
          .select('id')
          .single();

      return row['id'] as String;
    });
  }

  Future<void> updateNotificationProvider(
    String providerId, {
    required NotificationProviderKind provider,
    required String? senderId,
    required String? endpointUrl,
    required Map<String, dynamic> config,
    required bool isActive,
  }) async {
    return guardFailures(() async {
      // Every field is required and nulls are sent, not stripped: this is a
      // whole-form save, and "the owner cleared the sender ID" has to reach the
      // column. `rpcParams` is for RPC defaults, not for column writes.
      await _client
          .from(_providers)
          .update(<String, dynamic>{
            'provider': provider.toDb(),
            'sender_id': senderId,
            'endpoint_url': endpointUrl,
            'config': config,
            'is_active': isActive,
          })
          .eq('id', providerId);
    });
  }

  Future<void> deleteNotificationProvider(String providerId) async {
    return guardFailures(() async {
      // The `drop_notification_secret` trigger drops the Vault secret with the
      // row, so there is nothing left behind to forget separately.
      await _client.from(_providers).delete().eq('id', providerId);
    });
  }

  Future<void> setNotificationCredential(
    String providerId,
    String secret,
  ) async {
    return guardFailures(() async {
      await _client.rpc<void>(
        'set_notification_credential',
        params: <String, dynamic>{
          'p_provider_id': providerId,
          'p_secret': secret,
        },
      );
    });
  }

  Future<void> clearNotificationCredential(String providerId) async {
    return guardFailures(() async {
      await _client.rpc<void>(
        'clear_notification_credential',
        params: <String, dynamic>{'p_provider_id': providerId},
      );
    });
  }

  /// Ask the gateway how many credits are left.
  ///
  /// The answer does not come back here: the API key lives in Vault, so the
  /// request is made by the database with pg_net and
  /// [readGatewayBalance] collects the reply a moment later. Throttled upstream
  /// to one live request per gateway per twenty seconds.
  Future<void> requestGatewayBalance(String providerId) async {
    return guardFailures(() async {
      await _client.rpc<void>(
        'request_notification_gateway_balance',
        params: <String, dynamic>{'p_provider_id': providerId},
      );
    });
  }

  Future<GatewayBalance> readGatewayBalance(String providerId) async {
    return guardFailures(() async {
      final Map<String, dynamic> value = await _client
          .rpc<Map<String, dynamic>>(
            'read_notification_gateway_balance',
            params: <String, dynamic>{'p_provider_id': providerId},
          );
      return GatewayBalance.fromJson(value);
    });
  }

  // ------------------------------------------------------------------
  // rules -- any staff reads, an owner writes
  // ------------------------------------------------------------------

  Future<List<NotificationRule>> listNotificationRules() async {
    return guardFailures(() async {
      final List<Map<String, dynamic>> rows = await _client
          .from(_rules)
          .select()
          // Ascending is explicit for the same reason it is on the gateways:
          // postgrest-dart's `order` defaults to descending. Getting this wrong
          // is visible -- the rules list is six checkboxes an owner reads in
          // the order the console lists them (renewal T-7, T-1, dues,
          // birthday, visitor welcome, visitor follow-up), and a reversed
          // enum sort turns that upside down.
          .order('event', ascending: true)
          .order('offset_days', ascending: false)
          .order('id', ascending: true);

      return rows.map(NotificationRule.fromJson).toList(growable: false);
    });
  }

  Future<void> updateNotificationRule(
    String ruleId, {
    required bool enabled,
    required int minAmountPaisa,
    required int repeatAfterDays,
    required String sendAtLocal,
  }) async {
    return guardFailures(() async {
      await _client
          .from(_rules)
          .update(<String, dynamic>{
            'enabled': enabled,
            'min_amount_paisa': minAmountPaisa,
            'repeat_after_days': repeatAfterDays,
            'send_at_local': sendAtLocal,
          })
          .eq('id', ruleId);
    });
  }

  // ------------------------------------------------------------------
  // templates
  // ------------------------------------------------------------------

  Future<List<NotificationTemplate>> listNotificationTemplates() async {
    return guardFailures(() async {
      final List<Map<String, dynamic>> rows = await _client
          .from(_templates)
          .select()
          .order('event', ascending: true)
          .order('channel', ascending: true)
          .order('locale', ascending: true);

      return rows.map(NotificationTemplate.fromJson).toList(growable: false);
    });
  }

  /// What a message would actually say: the org's own wording when it has
  /// edited one, and the built-in otherwise.
  ///
  /// Reading it through the database rather than duplicating the defaults in
  /// Dart is what keeps the preview honest. This is the caller-side half of a
  /// deliberate split upstream: the sweeps use `resolve_notification_template`,
  /// which is SECURITY DEFINER and callable by no client role because cron
  /// holds no claims; this one is SECURITY INVOKER and org-guarded.
  Future<NotificationTemplatePreview?> previewNotificationTemplate(
    String orgId,
    NotificationEvent event,
    NotificationChannel channel,
    String locale,
  ) async {
    return guardFailures(() async {
      final List<dynamic> rows = await _client.rpc<List<dynamic>>(
        'notification_template_preview',
        params: <String, dynamic>{
          'p_org_id': orgId,
          'p_event': event.toDb(),
          'p_channel': channel.toDb(),
          'p_locale': locale,
        },
      );
      if (rows.isEmpty) return null;
      return NotificationTemplatePreview.fromJson(
        rows.first as Map<String, dynamic>,
      );
    });
  }

  /// [updatedBy] records who reworded it, and [isActive] is sent explicitly.
  ///
  /// Both matter on the *conflict* half of the upsert. PostgREST only sets the
  /// keys present, so omitting `is_active` leaves a row someone had deactivated
  /// deactivated -- while a console save, which does send it, would switch it
  /// back on. Two clients writing the same row have to write the same columns
  /// or the row means something different depending on who touched it last.
  Future<void> upsertNotificationTemplate({
    required String orgId,
    required NotificationEvent event,
    required NotificationChannel channel,
    required String locale,
    required String body,
    String? subject,
    String? updatedBy,
  }) async {
    return guardFailures(() async {
      await _client
          .from(_templates)
          .upsert(<String, dynamic>{
            'org_id': orgId,
            'event': event.toDb(),
            'channel': channel.toDb(),
            'locale': locale,
            'subject': subject,
            'body': body,
            'is_active': true,
            'updated_by': updatedBy,
          }, onConflict: 'org_id,event,channel,locale');
    });
  }

  /// Drop an org's wording so the built-in takes over again.
  Future<void> deleteNotificationTemplate(String templateId) async {
    return guardFailures(() async {
      await _client.from(_templates).delete().eq('id', templateId);
    });
  }

  /// `en` or `ne`, from the org's own settings.
  ///
  /// Read through the RPC rather than defaulted to `'en'` in Dart: the fallback
  /// chain belongs in one place, and a Nepali gym previewing English while
  /// sending Nepali is exactly the bug that split causes.
  Future<String> orgNotificationLocale(String orgId) async {
    return guardFailures(() async {
      final Object? value = await _client.rpc<Object?>(
        'org_notification_locale',
        params: <String, dynamic>{'p_org_id': orgId},
      );
      return (value as String?) ?? 'en';
    });
  }

  // ------------------------------------------------------------------
  // one message
  // ------------------------------------------------------------------

  /// The single INSERT into the outbox.
  ///
  /// Ten arguments, not the nine the console's wrapper passes: `p_visitor_id`
  /// was added by `20260912100100_visitor_messages.sql`, after
  /// `lib/db/notifications.ts` was written, and the TypeScript twin has never
  /// been updated. Carried here because the visitor surfaces need it.
  ///
  /// Raises `unique_violation` -- "That message has already been queued" --
  /// when the dedupe key is already in the outbox. That is an answer, not a
  /// crash, and has to reach the screen as written.
  Future<String> enqueueNotification({
    required NotificationChannel channel,
    required NotificationEvent event,
    required String to,
    required String body,
    String? subject,
    String? memberId,
    String? staffId,
    String? branchId,
    String? dedupeKey,
    String? visitorId,
  }) async {
    return guardFailures(() async {
      final Object? id = await _client.rpc<Object?>(
        'enqueue_notification',
        params: rpcParams(<String, dynamic>{
          'p_channel': channel.toDb(),
          'p_event': event.toDb(),
          'p_to': to,
          'p_body': body,
          'p_subject': subject,
          'p_member_id': memberId,
          'p_staff_id': staffId,
          'p_branch_id': branchId,
          'p_dedupe_key': dedupeKey,
          'p_visitor_id': visitorId,
        }),
      );
      return id as String;
    });
  }

  /// Put a failed, cancelled or not-sent message back in the queue. Owner or
  /// branch manager; anyone else is refused `42501`.
  Future<void> retryNotification(String notificationId) async {
    return guardFailures(() async {
      await _client.rpc<void>(
        'retry_notification',
        params: <String, dynamic>{'p_id': notificationId},
      );
    });
  }

  /// Stop a message that has not gone out yet.
  Future<void> cancelNotification(String notificationId) async {
    return guardFailures(() async {
      await _client.rpc<void>(
        'cancel_notification',
        params: <String, dynamic>{'p_id': notificationId},
      );
    });
  }

  // ------------------------------------------------------------------
  // one member, by hand
  // ------------------------------------------------------------------

  /// What this member would be told, and every reason they would not be.
  Future<MemberMessagePreview?> previewMemberNotification(
    String memberId,
    NotificationEvent event, {
    NotificationChannel channel = NotificationChannel.sms,
  }) async {
    return guardFailures(() async {
      final List<dynamic> rows = await _client.rpc<List<dynamic>>(
        'member_notification_preview',
        params: <String, dynamic>{
          'p_member_id': memberId,
          'p_event': event.toDb(),
          'p_channel': channel.toDb(),
        },
      );
      if (rows.isEmpty) return null;
      return MemberMessagePreview.fromJson(rows.first as Map<String, dynamic>);
    });
  }

  /// Send one message to one member, now. Returns the message id.
  ///
  /// A blank [body] means "use the gym's own wording". Anything else is what
  /// the log stores: the body travels with the send rather than being
  /// re-rendered, so the message and the record cannot disagree.
  ///
  /// Refuses an opted-out member, a channel with no gateway, a trainer, another
  /// gym's member, an archived member, a branch the sender does not cover, and
  /// the same reason to the same member inside two minutes.
  Future<String> sendMemberNotification({
    required String memberId,
    required NotificationEvent event,
    NotificationChannel channel = NotificationChannel.sms,
    String? body,
    String? subject,
  }) async {
    return guardFailures(() async {
      final Object? id = await _client.rpc<Object?>(
        'send_member_notification',
        params: rpcParams(<String, dynamic>{
          'p_member_id': memberId,
          'p_event': event.toDb(),
          'p_channel': channel.toDb(),
          'p_body': body,
          'p_subject': subject,
        }),
      );
      return id as String;
    });
  }

  // ------------------------------------------------------------------
  // one visitor, by hand
  // ------------------------------------------------------------------

  Future<VisitorMessagePreview?> previewVisitorNotification(
    String visitorId,
    NotificationEvent event, {
    NotificationChannel channel = NotificationChannel.sms,
  }) async {
    return guardFailures(() async {
      final List<dynamic> rows = await _client.rpc<List<dynamic>>(
        'visitor_notification_preview',
        params: <String, dynamic>{
          'p_visitor_id': visitorId,
          'p_event': event.toDb(),
          'p_channel': channel.toDb(),
        },
      );
      if (rows.isEmpty) return null;
      return VisitorMessagePreview.fromJson(rows.first as Map<String, dynamic>);
    });
  }

  Future<String> sendVisitorNotification({
    required String visitorId,
    required NotificationEvent event,
    NotificationChannel channel = NotificationChannel.sms,
    String? body,
    String? subject,
  }) async {
    return guardFailures(() async {
      final Object? id = await _client.rpc<Object?>(
        'send_visitor_notification',
        params: rpcParams(<String, dynamic>{
          'p_visitor_id': visitorId,
          'p_event': event.toDb(),
          'p_channel': channel.toDb(),
          'p_body': body,
          'p_subject': subject,
        }),
      );
      return id as String;
    });
  }
}

@riverpod
NotificationsRepository notificationsRepository(Ref ref) {
  return NotificationsRepository(ref.watch(supabaseClientProvider));
}
