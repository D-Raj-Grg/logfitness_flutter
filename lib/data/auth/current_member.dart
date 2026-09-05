// Mirrors one row returned by the `current_member()` RPC. See
// `logfitness_saas/supabase/migrations/20260905150100_member_app_auth.sql`.
//
// Readable before the session carries claims -- that is its whole purpose:
// it lets the app tell "signed in but not linked" from "signed in as a
// member" without depending on the JWT having been refreshed yet.
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';

part 'current_member.freezed.dart';
part 'current_member.g.dart';

@freezed
abstract class CurrentMember with _$CurrentMember {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory CurrentMember({
    required String memberId,
    required String orgId,
    required String orgName,
    required String currency,
    required String timezone,
    required String homeBranchId,
    required String homeBranchName,
    required String memberCode,
    required String fullName,
    // members.email is nullable upstream; the RPC projects the column as-is.
    String? email,
    required String phone,
    required MemberStatus status,
  }) = _CurrentMember;

  factory CurrentMember.fromJson(Map<String, dynamic> json) =>
      _$CurrentMemberFromJson(json);
}
