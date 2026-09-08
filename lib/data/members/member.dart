// Mirrors `public.members`. See
// `logfitness_saas/supabase/migrations/20260905120100_members.sql`, plus
// `20260905150100_member_app_auth.sql` (invite columns),
// `20260907120000_member_archive.sql` (archive columns) and
// `20260909140000_notification_schema.sql` (`notifications_opt_out`).
//
// Verified field-for-field against the live schema on 2026-09-09.
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/format/plain_date.dart';

part 'member.freezed.dart';
part 'member.g.dart';

@freezed
abstract class Member with _$Member {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Member({
    required String id,
    required String orgId,
    required String homeBranchId,
    String? authUserId,
    required String memberCode,
    required String fullName,
    required String phone,
    String? email,
    // `date`, not `timestamptz` -- see plain_date.dart.
    @NullablePlainDateConverter() DateTime? dateOfBirth,
    MemberGender? gender,
    String? address,
    String? photoPath,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? notes,
    // Trigger-derived in Postgres (see the `members_left_on_requires_left_status`
    // constraint and the status trigger upstream). The app reads this field
    // and never writes it.
    required MemberStatus status,
    @PlainDateConverter() required DateTime joinedOn,
    @NullablePlainDateConverter() DateTime? leftOn,
    String? leftReason,
    // Member-app invitation. Set by `invite_member` / `link_member_account`;
    // the app reads these to say whether an invite is outstanding.
    String? invitedBy,
    DateTime? invitedAt,
    DateTime? acceptedAt,
    // Archive. A member with `archived_at` set is hidden from the working
    // list -- a staff search that ignores this column shows people the desk
    // has deliberately put away.
    DateTime? archivedAt,
    String? archivedReason,
    String? archivedBy,
    // Consent. Every notification enqueue job checks this before sending.
    @Default(false) bool notificationsOptOut,
    String? createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Member;

  const Member._();

  factory Member.fromJson(Map<String, dynamic> json) =>
      _$MemberFromJson(json);

  /// True when the desk has archived this member. Archived members stay
  /// readable (nothing financial is deleted) but are excluded from the
  /// working list unless explicitly asked for.
  bool get isArchived => archivedAt != null;

  /// True when a member-app invitation is outstanding: sent, never accepted.
  bool get hasPendingInvite => invitedAt != null && acceptedAt == null;
}
