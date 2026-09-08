// Mirrors `public.visitors`. See
// `logfitness_saas/supabase/migrations/20260908110100_visitors.sql`.
//
// A log, not a CRM. One row per person who walked in, four statuses, one
// note, and a conversion that points at the member they became. The scope
// decision is recorded in `logfitness_saas/PLANNING.md` §4: no reminders, no
// assignment, no campaigns, no funnel report.
//
// Verified field-for-field against the live schema on 2026-09-09.
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/format/plain_date.dart';

part 'visitor.freezed.dart';
part 'visitor.g.dart';

@freezed
abstract class Visitor with _$Visitor {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Visitor({
    required String id,
    required String orgId,
    // The branch they walked into. Not nullable upstream: a walk-in happens
    // somewhere, and it is what scopes who may write the row.
    required String branchId,
    required VisitorKind kind,
    required String fullName,
    required String phone,
    // `date`. Filled by the `set_visitor_defaults` trigger from the org's own
    // today, and left editable so the desk can log yesterday's walk-in this
    // morning.
    @PlainDateConverter() required DateTime visitedOn,
    String? note,
    String? interestedPlanId,
    required VisitorStatus status,
    String? convertedMemberId,
    DateTime? convertedAt,
    String? createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Visitor;

  const Visitor._();

  factory Visitor.fromJson(Map<String, dynamic> json) =>
      _$VisitorFromJson(json);

  /// True once this walk-in has been registered as a member. The database's
  /// `visitors_converted_shape` constraint guarantees the member id and the
  /// timestamp move together with the status, so any one of the three is a
  /// sound test.
  bool get isConverted => status == VisitorStatus.converted;

  /// The rows the desk still owes a callback. Mirrors the partial index
  /// `visitors_open_idx` upstream.
  bool get isOpen =>
      status == VisitorStatus.isNew || status == VisitorStatus.contacted;
}
