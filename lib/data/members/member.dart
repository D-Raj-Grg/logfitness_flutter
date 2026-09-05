// Mirrors `public.members`. See
// `logfitness_saas/supabase/migrations/20260905120100_members.sql`.
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';

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
    DateTime? dateOfBirth,
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
    required DateTime joinedOn,
    DateTime? leftOn,
    String? leftReason,
    String? createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Member;

  factory Member.fromJson(Map<String, dynamic> json) =>
      _$MemberFromJson(json);
}
