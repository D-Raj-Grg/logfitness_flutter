// Mirrors the `attendance_detail` view, which is what every attendance screen
// actually reads: `attendance` joined to the member, the branch and the staff
// member who checked them in, so a log does not issue a query per row.
//
// Every column is nullable because a view's columns are, even where the
// underlying table's are not. Rather than pretend otherwise, the required
// fields are the ones a row is useless without, and the rest stay optional.
//
// Note what the snapshot columns are for: `membership_status_at_checkin`,
// `due_paisa_at_checkin` and `days_to_expiry_at_checkin` record what was true
// when the person walked in, not what is true now. A log that recomputed them
// would quietly rewrite history -- someone who was expired at the door would
// show as active once they renewed.
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/format/plain_date.dart';

part 'attendance_detail.freezed.dart';
part 'attendance_detail.g.dart';

@freezed
abstract class AttendanceDetail with _$AttendanceDetail {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory AttendanceDetail({
    required String id,
    required String memberId,
    required String orgId,
    String? branchId,
    String? branchName,
    String? memberCode,
    String? fullName,
    String? phone,
    String? photoPath,
    // The gym's own calendar day, not the device's.
    @NullablePlainDateConverter() DateTime? attendedOn,
    DateTime? checkedInAt,
    DateTime? checkedOutAt,
    String? checkedInBy,
    String? checkedInByName,
    String? membershipId,
    MembershipStatus? membershipStatusAtCheckin,
    int? duePaisaAtCheckin,
    int? daysToExpiryAtCheckin,
    AttendanceMethod? method,
    @Default(false) bool isOverride,
    String? overrideReason,
    String? notes,
  }) = _AttendanceDetail;

  const AttendanceDetail._();

  factory AttendanceDetail.fromJson(Map<String, dynamic> json) =>
      _$AttendanceDetailFromJson(json);

  /// Still inside. `check_out_member` is what closes a visit, and an open
  /// visit is never auto-closed upstream -- a known gap recorded in the
  /// console's TASKS.md, which is why a very old open visit is possible.
  bool get isOpen => checkedOutAt == null;

  /// Let in despite the membership saying otherwise. Worth surfacing: it is
  /// the row a manager looks for when a month's numbers do not add up.
  bool get wasOverridden => isOverride;
}
