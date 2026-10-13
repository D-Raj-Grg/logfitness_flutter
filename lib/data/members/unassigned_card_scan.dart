// Mirrors one `unassigned_card_scans` row: a card tapped on a reader that
// belongs to nobody yet. This is how a card is enrolled -- the member taps it
// at the door, the tap lands here, and the desk assigns it from the member's
// profile. `rfid_check_in` writes these (security definer); staff only read
// and, through `assign_member_card`, clear them.
//
// Read with a `devices(name)` embed so the desk can tell which reader a tap
// came from without a second query.
import 'package:freezed_annotation/freezed_annotation.dart';

part 'unassigned_card_scan.freezed.dart';
part 'unassigned_card_scan.g.dart';

/// Lifts `name` out of the `devices` embed. Null when the embed is absent or
/// RLS hid the device -- the scan itself is still assignable.
Object? _readDeviceName(Map<dynamic, dynamic> json, String key) {
  final Object? device = json['devices'];
  return device is Map ? device['name'] : null;
}

@freezed
abstract class UnassignedCardScan with _$UnassignedCardScan {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory UnassignedCardScan({
    required String id,
    required String orgId,
    String? branchId,
    String? deviceId,
    required String cardUid,
    DateTime? firstSeenAt,
    required DateTime lastSeenAt,
    @Default(1) int scanCount,
    @JsonKey(readValue: _readDeviceName) String? deviceName,
  }) = _UnassignedCardScan;

  factory UnassignedCardScan.fromJson(Map<String, dynamic> json) =>
      _$UnassignedCardScanFromJson(json);
}
