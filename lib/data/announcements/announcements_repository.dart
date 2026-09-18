// Everything the app asks the database about announcements.
//
// Mirrors `logfitness_saas/lib/db/announcements.ts` one method for one export,
// same names in the same order, so parity across the surface is mechanically
// auditable rather than a matter of reading two screens side by side.
//
// A repository is the only thing that touches `supabase` (PLANNING.md §6).
// Controllers call repositories; widgets call controllers.
//
// Nothing here filters by `org_id`, and nothing here checks a role. RLS is the
// tenant boundary and `jwt_can_announce()` is the role boundary; both live in
// the database, where the refusal is a sentence this app renders rather than a
// rule it re-implements.
//
// `announcement_audience` is deliberately absent. EXECUTE on it is revoked from
// `authenticated` upstream -- it takes an org id as an argument and would hand
// any caller another gym's phone numbers -- so the only way to it is through
// the four definer functions below. Do not add it.
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:logfitness_flutter/data/announcements/announcement_audience_count.dart';
import 'package:logfitness_flutter/data/announcements/announcement_overview.dart';
import 'package:logfitness_flutter/data/announcements/announcement_queries.dart';
import 'package:logfitness_flutter/data/repository_guard.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/supabase/supabase_providers.dart';

part 'announcements_repository.g.dart';

class AnnouncementsRepository {
  const AnnouncementsRepository(this._client);

  final SupabaseClient _client;

  static const String _overview = 'announcement_overview';

  /// The list, newest first.
  ///
  /// The counts on each row are read off the outbox by the view rather than
  /// stored, so a send that is still going up-counts on refresh without
  /// anything having to write to the announcement.
  Future<AnnouncementPage> listAnnouncements(
    AnnouncementListFilter filter,
  ) async {
    return guardFailures(() async {
      final int from = (filter.page - 1) * filter.pageSize;
      final response = await _client
          .from(_overview)
          .select()
          .order('created_at', ascending: false)
          // Not optional, twice over. postgrest-dart's `order` defaults to
          // descending, so the direction is always written out; and two
          // announcements sent in the same second would otherwise be able to
          // swap places between pages, putting one on both and another on
          // neither.
          .order('id', ascending: false)
          .range(from, from + filter.pageSize - 1)
          .count(CountOption.exact);

      return AnnouncementPage(
        rows: response.data
            .map(AnnouncementOverview.fromJson)
            .toList(growable: false),
        total: response.count,
        page: filter.page,
        pageSize: filter.pageSize,
      );
    });
  }

  /// One announcement. Currently uncalled: the console has no detail route
  /// either, and the list row carries everything either of them shows. It is
  /// here because this file is one method per export of `announcements.ts`, and
  /// a gap in that mapping is harder to read than an unused method.
  Future<AnnouncementOverview?> getAnnouncement(String id) async {
    return guardFailures(() async {
      final Map<String, dynamic>? row = await _client
          .from(_overview)
          .select()
          .eq('id', id)
          .maybeSingle();
      if (row == null) return null;
      return AnnouncementOverview.fromJson(row);
    });
  }

  /// Who would get it, and what that would cost.
  ///
  /// A plain read with no side effects, called as the composer's filters move.
  Future<AnnouncementAudienceCount> countAnnouncementAudience(
    AnnouncementAudienceQuery query,
  ) async {
    return guardFailures(() async {
      final AnnouncementAudienceQuery q = query.normalised();
      final List<dynamic> rows = await _client.rpc<List<dynamic>>(
        'announcement_audience_count',
        params: rpcParams(<String, dynamic>{
          'p_audience': q.audience.toDb(),
          'p_branch_id': q.branchId,
          'p_member_statuses': announcementStatusFilter(q.memberStatuses),
          'p_visitor_days': q.visitorDays,
          'p_channel': q.channel.toDb(),
        }),
      );
      if (rows.isEmpty) return AnnouncementAudienceCount.empty;
      return AnnouncementAudienceCount.fromJson(
        rows.first as Map<String, dynamic>,
      );
    });
  }

  /// Compose and fan out in one call. Returns the announcement id.
  ///
  /// Refuses a trainer, a front desk with no branch of its own, a branch
  /// outside the sender's access, a blank title or body, a time already gone,
  /// and an audience that matches nobody. Every one of those comes back as a
  /// written sentence, which `mapError` passes through untouched.
  Future<String> sendAnnouncement({
    required String title,
    required String body,
    required AnnouncementAudience audience,
    NotificationChannel channel = NotificationChannel.sms,
    String? branchId,
    List<MemberStatus>? memberStatuses,
    int? visitorDays,
    DateTime? scheduledFor,
  }) async {
    return guardFailures(() async {
      final Object? id = await _client.rpc<Object?>(
        'send_announcement',
        params: rpcParams(<String, dynamic>{
          'p_title': title,
          'p_body': body,
          'p_audience': audience.toDb(),
          'p_channel': channel.toDb(),
          'p_branch_id': branchId,
          'p_member_statuses': announcementStatusFilter(memberStatuses),
          'p_visitor_days': visitorDays,
          // The pickers hand back a device-local `DateTime`; `scheduled_for` is
          // `timestamptz`, so the instant is what travels. `dates.dart` models
          // the org's timezone as a fixed offset for *display* and must not be
          // used here -- the console has the same note against its
          // `datetime-local` conversion, for the same 5h45m reason.
          'p_scheduled_for': scheduledFor?.toUtc().toIso8601String(),
        }),
      );
      return id as String;
    });
  }

  /// One message, to a number typed by hand, rendered exactly as the real send
  /// would render it. No announcement row: nothing has been announced yet.
  Future<String> sendAnnouncementTest({
    required String body,
    required String to,
    String? title,
    NotificationChannel channel = NotificationChannel.sms,
  }) async {
    return guardFailures(() async {
      final Object? id = await _client.rpc<Object?>(
        'send_announcement_test',
        params: rpcParams(<String, dynamic>{
          'p_body': body,
          'p_to': to,
          'p_channel': channel.toDb(),
          'p_title': title,
        }),
      );
      return id as String;
    });
  }

  /// Stops what has not left yet, and returns how many that was.
  ///
  /// The number is the answer, not a formality: zero means the whole thing had
  /// already gone out, and the screen has to say so rather than claim a
  /// cancellation that cancelled nothing.
  Future<int> cancelAnnouncement(String id) async {
    return guardFailures(() async {
      final Object? stopped = await _client.rpc<Object?>(
        'cancel_announcement',
        params: <String, dynamic>{'p_id': id},
      );
      return (stopped as num?)?.toInt() ?? 0;
    });
  }
}

@riverpod
AnnouncementsRepository announcementsRepository(Ref ref) {
  return AnnouncementsRepository(ref.watch(supabaseClientProvider));
}
