// Mirrors `public.memberships`. See
// `logfitness_saas/supabase/migrations/20260905120300_memberships.sql`.
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';

part 'membership.freezed.dart';
part 'membership.g.dart';

@freezed
abstract class Membership with _$Membership {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Membership({
    required String id,
    required String orgId,
    required String branchId,
    required String memberId,
    required String planId,
    // Snapshot of the plan as sold at the time of sale.
    required String planName,
    required PlanType planType,
    required DateTime startDate,
    DateTime? endDate,
    int? sessionsTotal,
    int? sessionsRemaining,
    // Money is integer paisa end to end. Never a double, never converted here.
    required int pricePaisa,
    required int discountPaisa,
    required MembershipStatus status,
    DateTime? frozenOn,
    required int frozenDays,
    DateTime? cancelledAt,
    String? cancelReason,
    String? previousMembershipId,
    String? soldBy,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Membership;

  factory Membership.fromJson(Map<String, dynamic> json) =>
      _$MembershipFromJson(json);
}
