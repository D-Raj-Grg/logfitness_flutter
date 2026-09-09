// Mirrors `public.branches`.
//
// Verified field-for-field against the live schema on 2026-09-09.
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';

part 'branch.freezed.dart';
part 'branch.g.dart';

@freezed
abstract class Branch with _$Branch {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Branch({
    required String id,
    required String orgId,
    required String name,
    required BranchStatus status,
    String? address,
    String? phone,
    // `time` columns, carried as the wire string. Nothing reads them yet and
    // parsing a bare `HH:MM:SS` into a `DateTime` would invent a date.
    String? opensAt,
    String? closesAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Branch;

  const Branch._();

  factory Branch.fromJson(Map<String, dynamic> json) => _$BranchFromJson(json);

  bool get isActive => status == BranchStatus.active;
}
