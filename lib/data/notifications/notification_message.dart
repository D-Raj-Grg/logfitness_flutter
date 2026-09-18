// Mirrors `public.notification_messages`. See
// `logfitness_saas/supabase/migrations/20260909140000_notification_schema.sql`,
// plus `20260912094100` (`created_by`) and `20260912100100` (`visitor_id`).
//
// The outbox *and* the delivery log, one table, so there is exactly one answer
// to "was this member told". A row is rendered at **enqueue** time, not send
// time: editing a template never retroactively changes what somebody was told,
// and the body stored here is the body that went out.
//
// `request_id bigint` is on the table and is deliberately **not** on this
// model: it is the pg_net request handle the response reaper joins on, and
// nothing on a screen can do anything with it. The omission is written down
// rather than left to be noticed, because json_serializable drops an unknown
// key silently and throws on a missing one -- so an absent field is either a
// decision or a bug, and there is no way to tell them apart from the code.
//
// Verified column-for-column against `logfitness_saas/lib/types/database.ts`.
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';

part 'notification_message.freezed.dart';
part 'notification_message.g.dart';

@freezed
abstract class NotificationMessage with _$NotificationMessage {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory NotificationMessage({
    required String id,
    required String orgId,

    /// Null means the message was raised for the whole org rather than for a
    /// branch -- and an org-wide message belongs to everyone who can see the
    /// org, not to nobody. Every branch filter has to say so explicitly.
    String? branchId,
    String? memberId,
    String? staffId,
    String? visitorId,
    required NotificationChannel channel,
    required NotificationEvent event,

    /// Resolved at send time from the org's active gateway, so a row that has
    /// not gone out yet carries none.
    NotificationProviderKind? provider,
    required String toAddress,
    String? subject,
    required String body,
    required NotificationStatus status,
    required int attempts,
    required DateTime scheduledFor,
    required DateTime nextAttemptAt,
    int? providerStatus,
    String? providerMessageId,
    String? lastError,
    DateTime? sentAt,
    required String dedupeKey,

    /// The staff member who pressed Send. Null for anything a nightly sweep
    /// raised, which is how the log tells the two apart.
    String? createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _NotificationMessage;

  const NotificationMessage._();

  factory NotificationMessage.fromJson(Map<String, dynamic> json) =>
      _$NotificationMessageFromJson(json);

  /// Still moving. What the log's live refresh polls on.
  bool get isPending =>
      status == NotificationStatus.queued ||
      status == NotificationStatus.sending;

  /// `retry_notification` accepts exactly these three states.
  bool get isResendable =>
      status == NotificationStatus.failed ||
      status == NotificationStatus.cancelled ||
      status == NotificationStatus.skipped;

  /// `cancel_notification` accepts only a row that has not been claimed yet.
  bool get isCancellable => status == NotificationStatus.queued;

  /// Whether a sweep raised this rather than a person.
  bool get isAutomatic => createdBy == null;
}
