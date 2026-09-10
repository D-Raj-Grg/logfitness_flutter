// What `check_in_member` and `check_out_member` hand back.
//
// Both return `jsonb` rather than a table row, so these mirror the shape the
// function builds rather than a schema table. Read
// `logfitness_saas/supabase/migrations/20260905140100_attendance_rpcs.sql`
// before changing anything here.
//
// The important thing the contract says: **check-in does not refuse.** An
// expired member, a frozen membership, someone who owes money -- all of them
// are recorded, and the function returns a `banner` describing what the desk
// is looking at. That is deliberate. A gym's door is staffed by a person, and
// the software's job is to tell them what is true, not to bar someone in front
// of a queue. The only `ok: false` is a duplicate check-in on the same day,
// which an override with a reason can force through.
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';

part 'attendance_rpc_results.freezed.dart';
part 'attendance_rpc_results.g.dart';

/// What the desk should be told when this member walks in.
///
/// Mirrors `public.attendance_banner`. Ordered here roughly by how much it
/// should interrupt someone.
enum CheckInBanner {
  /// Membership is current and not near its end.
  @JsonValue('active')
  active('active'),

  /// Within seven days of expiry, or down to the last three sessions of a
  /// pack. The renewal conversation happens here or it happens late.
  @JsonValue('expiring')
  expiring('expiring'),

  /// Sold, but the start date has not arrived.
  @JsonValue('upcoming')
  upcoming('upcoming'),

  /// Deliberately paused. Not the same as expired: a frozen member has not
  /// lapsed, and telling them they have is a bad conversation.
  @JsonValue('frozen')
  frozen('frozen'),

  /// Expired, cancelled, or a spent session pack.
  @JsonValue('expired')
  expired('expired'),

  /// No membership at all.
  @JsonValue('none')
  none('none'),

  /// The member has left the gym.
  @JsonValue('left')
  left('left');

  const CheckInBanner(this.wire);

  final String wire;

  static CheckInBanner fromDb(String value) => CheckInBanner.values.firstWhere(
        (e) => e.wire == value,
        orElse: () => throw UnknownEnumValue('CheckInBanner', value),
      );

  /// Whether this is something the desk has to act on rather than wave past.
  bool get needsAttention => this != CheckInBanner.active;

  String toDb() => wire;
}

/// Why a check-in was not recorded. Null when it was.
enum CheckInRefusal {
  /// Already checked in today. An override with a reason forces it through --
  /// the member genuinely left and came back, or the first row was a mistake.
  @JsonValue('already_checked_in')
  alreadyCheckedIn('already_checked_in');

  const CheckInRefusal(this.wire);

  final String wire;

  static CheckInRefusal fromDb(String value) =>
      CheckInRefusal.values.firstWhere(
        (e) => e.wire == value,
        orElse: () => throw UnknownEnumValue('CheckInRefusal', value),
      );

  String toDb() => wire;
}

@freezed
abstract class CheckInMemberSummary with _$CheckInMemberSummary {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory CheckInMemberSummary({
    required String id,
    required String fullName,
    String? memberCode,
    String? phone,
    String? photoPath,
    MemberStatus? status,
  }) = _CheckInMemberSummary;

  factory CheckInMemberSummary.fromJson(Map<String, dynamic> json) =>
      _$CheckInMemberSummaryFromJson(json);
}

@freezed
abstract class CheckInBranchSummary with _$CheckInBranchSummary {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory CheckInBranchSummary({
    required String id,
    required String name,
  }) = _CheckInBranchSummary;

  factory CheckInBranchSummary.fromJson(Map<String, dynamic> json) =>
      _$CheckInBranchSummaryFromJson(json);
}

@freezed
abstract class CheckInResult with _$CheckInResult {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory CheckInResult({
    required bool ok,
    CheckInRefusal? reason,
    CheckInBanner? banner,
    CheckInMemberSummary? member,
    CheckInBranchSummary? branch,
    // Money is integer paisa end to end.
    @Default(0) int duePaisa,
  }) = _CheckInResult;

  const CheckInResult._();

  factory CheckInResult.fromJson(Map<String, dynamic> json) =>
      _$CheckInResultFromJson(json);

  /// Already checked in today, and no override was given.
  bool get isDuplicate =>
      !ok && reason == CheckInRefusal.alreadyCheckedIn;

  /// Whether the desk owes this member a conversation before waving them in.
  bool get needsAttention =>
      duePaisa > 0 || (banner?.needsAttention ?? false);
}
