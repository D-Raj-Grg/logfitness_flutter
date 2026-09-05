// Mirrors one row returned by the `current_staff()` RPC. Read instead of the
// `staff` table because a fresh session may carry no claims yet -- see
// PLANNING.md §5.
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';

part 'current_staff.freezed.dart';
part 'current_staff.g.dart';

@freezed
abstract class CurrentStaff with _$CurrentStaff {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory CurrentStaff({
    required String staffId,
    required String orgId,
    required String orgName,
    required String fullName,
    required String email,
    required StaffRole role,
    required List<String> branchIds,
  }) = _CurrentStaff;

  factory CurrentStaff.fromJson(Map<String, dynamic> json) =>
      _$CurrentStaffFromJson(json);
}
