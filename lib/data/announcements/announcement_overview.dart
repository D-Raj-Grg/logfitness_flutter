// Mirrors `public.announcement_overview`. See
// `logfitness_saas/supabase/migrations/20260917100100_announcements.sql` and
// `20260917100200_announcement_state.sql`, which is the version this reads.
//
// The view rather than the `announcements` table, and that is the whole point
// of it: the delivery counts are read off the outbox every time it is queried
// rather than stored, so a send that is still going up-counts on refresh
// without anything having to write back to the announcement. The table alone
// would say "sending" forever.
//
// The console's twin is `AnnouncementOverviewRow` in
// `logfitness_saas/lib/db/announcements.ts`, and the derived wording in
// `components/announcements/announcements-table.tsx` is transcribed into
// `lib/features/announcements/announcement_labels.dart` rather than reinvented
// here.
//
// Verified column-for-column against the view definition; every column is on
// this model, so there is no omission to write down.
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';

part 'announcement_overview.freezed.dart';
part 'announcement_overview.g.dart';

/// What is *true now*, as opposed to [AnnouncementStatus], which is what was
/// asked for.
///
/// Not in `postgres_enums.dart` with the others, deliberately: this is not a
/// Postgres enum. It is a `case` expression in the view, computed from the
/// stored status, the scheduled hour and the outbox counts. It follows the same
/// throwing template anyway -- a string this does not know about means the view
/// has grown a state the app cannot render, and rendering it as "sent" would be
/// the log disagreeing with what members received.
enum AnnouncementState {
  @JsonValue('cancelled')
  cancelled('cancelled'),
  @JsonValue('scheduled')
  scheduled('scheduled'),
  @JsonValue('sending')
  sending('sending'),
  @JsonValue('sent')
  sent('sent');

  const AnnouncementState(this.wire);

  final String wire;

  static AnnouncementState fromDb(String value) =>
      AnnouncementState.values.firstWhere(
        (e) => e.wire == value,
        orElse: () => throw UnknownEnumValue('AnnouncementState', value),
      );

  String toDb() => wire;
}

@freezed
abstract class AnnouncementOverview with _$AnnouncementOverview {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory AnnouncementOverview({
    required String id,
    required String orgId,

    /// Null means every branch the sender covers, not "no branch". For an owner
    /// that is the chain; for anybody else it is their own `branch_ids`,
    /// resolved by `announcement_branch_scope` at send time rather than here.
    String? branchId,
    String? branchName,
    required String title,
    required String body,
    required NotificationChannel channel,
    required AnnouncementAudience audience,

    /// Null means the database's own default -- every status except `left`.
    /// An empty list would mean nobody, which is why the repository never
    /// sends one.
    List<MemberStatus>? memberStatuses,

    /// Null means every open walk-in, however long ago they came in.
    int? visitorDays,
    required AnnouncementStatus status,
    required AnnouncementState state,
    required DateTime scheduledFor,
    required DateTime createdAt,
    String? createdBy,
    String? createdByName,
    required int total,
    required int queued,
    required int sent,
    required int failed,
    required int skipped,
    required int cancelled,
    DateTime? lastSentAt,
  }) = _AnnouncementOverview;

  const AnnouncementOverview._();

  factory AnnouncementOverview.fromJson(Map<String, dynamic> json) =>
      _$AnnouncementOverviewFromJson(json);

  /// Still moving. What the announcements list's live refresh polls on.
  bool get isPending => queued > 0;

  /// Whether there is anything left to stop.
  ///
  /// Transcribes the console's `!cancelled && (row.queued ?? 0) > 0`, and it is
  /// the same fact `cancel_announcement` reports by returning 0: a broadcast
  /// whose messages have all left is history, and offering to stop it would be
  /// offering to un-send an SMS.
  bool get isCancellable =>
      state != AnnouncementState.cancelled && queued > 0;
}
