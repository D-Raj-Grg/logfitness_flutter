// Mirrors `public.membership_plans`. See
// `logfitness_saas/supabase/migrations/20260905120200_membership_plans.sql`.
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';

part 'membership_plan.freezed.dart';
part 'membership_plan.g.dart';

@freezed
abstract class MembershipPlan with _$MembershipPlan {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory MembershipPlan({
    required String id,
    required String orgId,
    required String name,
    String? description,
    required PlanType planType,
    int? durationDays,
    int? sessionCount,
    // Money is integer paisa end to end. Never a double, never converted here.
    required int pricePaisa,
    required int signupFeePaisa,
    required List<String> branchIds,
    required bool isActive,
    required int sortOrder,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _MembershipPlan;

  factory MembershipPlan.fromJson(Map<String, dynamic> json) =>
      _$MembershipPlanFromJson(json);
}
