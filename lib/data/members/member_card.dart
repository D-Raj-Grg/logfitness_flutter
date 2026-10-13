// Mirrors one `member_cards` row: an RFID card handed to a member, which the
// reader at the door (`rfid_check_in`, service-role only) resolves back to
// them. See
// `logfitness_saas/supabase/migrations/20261012100000_rfid_devices_and_member_cards.sql`.
//
// A card is never deleted. Revoking sets `revoked_at`, `revoked_by` and a
// reason, and a guard trigger refuses any other edit, so the history of who
// held which card survives a lost card and its replacement.
import 'package:freezed_annotation/freezed_annotation.dart';

part 'member_card.freezed.dart';
part 'member_card.g.dart';

@freezed
abstract class MemberCard with _$MemberCard {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory MemberCard({
    required String id,
    required String orgId,
    required String memberId,

    /// Upper-case hex, 8 to 20 characters -- the column's own check.
    required String cardUid,
    String? assignedBy,
    required DateTime assignedAt,
    DateTime? revokedAt,
    String? revokedBy,
    String? revokeReason,
  }) = _MemberCard;

  const MemberCard._();

  factory MemberCard.fromJson(Map<String, dynamic> json) =>
      _$MemberCardFromJson(json);

  /// Still opens the door. At most one live card per member, and per UID per
  /// org, by partial unique index.
  bool get isLive => revokedAt == null;
}

/// The UID as `assign_member_card` will store it: upper-cased, everything
/// that is not hex stripped. Readers and phones print `04:a3:1b:2c`; the
/// column holds `04A31B2C`.
///
/// The RPC normalises again on its side. Doing it here as well is so the desk
/// is shown, and checked against, the value that will actually be stored.
String normalizeCardUid(String raw) =>
    raw.toUpperCase().replaceAll(RegExp('[^0-9A-F]'), '');

/// The `member_cards.card_uid` check: `^[0-9A-F]{8,20}$`. Expects an already
/// normalised value.
bool isValidCardUid(String uid) => RegExp(r'^[0-9A-F]{8,20}$').hasMatch(uid);
