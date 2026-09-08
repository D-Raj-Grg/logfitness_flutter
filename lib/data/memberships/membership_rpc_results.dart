// The `jsonb` shapes the membership RPCs return. See
// `logfitness_saas/supabase/migrations/20260905120700_membership_rpcs.sql`
// (renew / freeze / unfreeze / cancel / set_member_left / reactivate) and
// `20260907120400_adjust_membership_dates.sql`.
//
// Every one of these is a *whole transaction's* answer. `renew_membership`
// writes a membership, an invoice and possibly a payment, and returns the ids
// of all three plus the due it left behind -- which is exactly why the app
// calls the function instead of doing the three writes itself.
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/format/plain_date.dart';

part 'membership_rpc_results.freezed.dart';
part 'membership_rpc_results.g.dart';

/// What `renew_membership` returns.
@freezed
abstract class RenewMembershipResult with _$RenewMembershipResult {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory RenewMembershipResult({
    required String membershipId,
    required String invoiceId,
    required String invoiceNo,

    /// Null when the sale took no money. An invoice with a due and no payment
    /// row is a legitimate outcome, not a failure.
    String? paymentId,
    @PlainDateConverter() required DateTime startDate,

    /// Null for a session pack with no validity window.
    @NullablePlainDateConverter() DateTime? endDate,
    // Money is integer paisa end to end.
    required int totalPaisa,

    /// `(subtotal - discount) - amount_paid`, computed inside the function.
    /// Read it rather than recomputing: the subtotal includes the joining fee
    /// the RPC decided to charge, which the caller does not know.
    required int duePaisa,
  }) = _RenewMembershipResult;

  factory RenewMembershipResult.fromJson(Map<String, dynamic> json) =>
      _$RenewMembershipResultFromJson(json);
}

/// What `freeze_membership` returns.
@freezed
abstract class FreezeMembershipResult with _$FreezeMembershipResult {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory FreezeMembershipResult({
    required String membershipId,

    /// `org_today(org_id)`, not the device's today. A `date`.
    @PlainDateConverter() required DateTime frozenOn,
  }) = _FreezeMembershipResult;

  factory FreezeMembershipResult.fromJson(Map<String, dynamic> json) =>
      _$FreezeMembershipResultFromJson(json);
}

/// What `unfreeze_membership` returns.
@freezed
abstract class UnfreezeMembershipResult with _$UnfreezeMembershipResult {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory UnfreezeMembershipResult({
    required String membershipId,

    /// How many days the freeze actually lasted, and therefore how far the
    /// end date just moved. The function computes it from `org_today`, so it
    /// is the only trustworthy source for it.
    required int pausedDays,
    @NullablePlainDateConverter() DateTime? endDate,
  }) = _UnfreezeMembershipResult;

  factory UnfreezeMembershipResult.fromJson(Map<String, dynamic> json) =>
      _$UnfreezeMembershipResultFromJson(json);
}

/// What `cancel_membership` returns: the membership and the status it now
/// holds.
@freezed
abstract class MembershipStatusResult with _$MembershipStatusResult {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory MembershipStatusResult({
    required String membershipId,
    required MembershipStatus status,
  }) = _MembershipStatusResult;

  factory MembershipStatusResult.fromJson(Map<String, dynamic> json) =>
      _$MembershipStatusResultFromJson(json);
}

/// What `adjust_membership_dates` returns.
///
/// The window moves; the sale does not. Plan, price, discount and branch are
/// still refused by `guard_membership_immutability`, and the start date only
/// moves through this RPC, only before anyone has checked in against it. The
/// previous dates come back so the screen can say what changed without having
/// held stale state across the round trip.
@freezed
abstract class AdjustMembershipDatesResult with _$AdjustMembershipDatesResult {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory AdjustMembershipDatesResult({
    required String membershipId,
    required String memberId,
    @PlainDateConverter() required DateTime previousStartDate,
    @NullablePlainDateConverter() DateTime? previousEndDate,
    @PlainDateConverter() required DateTime startDate,
    @NullablePlainDateConverter() DateTime? endDate,

    /// Signed day counts, computed in Postgres as `date - date`. Negative
    /// means the window moved earlier or shortened.
    required int daysMoved,
    required int daysChanged,
    required MembershipStatus status,
  }) = _AdjustMembershipDatesResult;

  factory AdjustMembershipDatesResult.fromJson(Map<String, dynamic> json) =>
      _$AdjustMembershipDatesResultFromJson(json);
}
