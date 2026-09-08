// The `jsonb` shapes the member RPCs return. See
// `logfitness_saas/supabase/migrations/20260907120100_register_member_start_date.sql`
// (`register_member`) and `20260907120000_member_archive.sql`
// (`archive_member`, `restore_member`).
//
// These are modelled rather than read as raw maps because the caller acts on
// them: registration hands the new member id to the router, and a sale that
// went through hands an invoice with a due to the payment screen.
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/format/plain_date.dart';

part 'member_rpc_results.freezed.dart';
part 'member_rpc_results.g.dart';

/// What `register_member` returns.
///
/// The function builds `{member_id, member_code, sold}` and then **merges
/// `renew_membership`'s own object over it** when a plan was sold, so every
/// field below `sold` is present exactly when `sold` is true. It is one
/// transaction on purpose: a sale that is refused registers nobody, which is
/// the difference between a member who owes money and a member who does not
/// exist.
@freezed
abstract class RegisterMemberResult with _$RegisterMemberResult {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory RegisterMemberResult({
    required String memberId,

    /// Minted by `prepare_member_row`, never supplied by the client.
    required String memberCode,
    required bool sold,
    String? membershipId,
    String? invoiceId,
    String? invoiceNo,

    /// Null when the sale took no money -- an invoice raised to be settled
    /// later.
    String? paymentId,
    @NullablePlainDateConverter() DateTime? startDate,
    @NullablePlainDateConverter() DateTime? endDate,
    // Money is integer paisa end to end.
    int? totalPaisa,
    int? duePaisa,
  }) = _RegisterMemberResult;

  factory RegisterMemberResult.fromJson(Map<String, dynamic> json) =>
      _$RegisterMemberResultFromJson(json);
}

/// What `archive_member` returns.
@freezed
abstract class ArchiveMemberResult with _$ArchiveMemberResult {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory ArchiveMemberResult({
    required String memberId,

    /// `timestamptz`, not a date: archiving is an instant, and the audit
    /// trail wants the time of day.
    required DateTime archivedAt,
  }) = _ArchiveMemberResult;

  factory ArchiveMemberResult.fromJson(Map<String, dynamic> json) =>
      _$ArchiveMemberResultFromJson(json);
}

/// What `restore_member`, `set_member_left` and `reactivate_member` all
/// return: the member, and the status the trigger derived once the write
/// landed.
///
/// One model for three RPCs because they genuinely return one shape. The
/// status is echoed back precisely so the caller does not have to guess it --
/// `members.status` is trigger-derived and the app may never write it
/// (CLAUDE.md), so reading it out of the RPC's own answer is the only honest
/// way to know what it became.
@freezed
abstract class MemberStatusResult with _$MemberStatusResult {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory MemberStatusResult({
    required String memberId,
    required MemberStatus status,
  }) = _MemberStatusResult;

  factory MemberStatusResult.fromJson(Map<String, dynamic> json) =>
      _$MemberStatusResultFromJson(json);
}
