// The plan catalogue, mirroring the web console's
// `logfitness_saas/lib/db/plans.ts`.
//
// Reads the catalogue and, since the 2026-09-09 parity decision (TASKS.md),
// writes it: `createPlan` and `updatePlan` mirror the console's `insertPlan`
// and `updatePlan`, and `setPlanActive` mirrors its `setPlanActive` action.
// There is no delete: the console offers none either -- a plan is retired by
// deactivating it, because memberships keep pointing at it.
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:logfitness_flutter/data/plans/membership_plan.dart';
import 'package:logfitness_flutter/data/repository_guard.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/domain/validation/plan_form.dart';
import 'package:logfitness_flutter/supabase/supabase_providers.dart';

part 'plans_repository.g.dart';

/// A repository is the only thing that touches `supabase` (PLANNING.md §6).
///
/// RLS scopes every query below to the caller's org. Nothing here filters by
/// `org_id`.
class PlansRepository {
  const PlansRepository(this._client);

  final SupabaseClient _client;

  static const String _table = 'membership_plans';

  /// The whole catalogue, active or not. Mirrors the console's `listPlans`.
  ///
  /// Inactive plans sort last but are still returned: a membership sold last
  /// year points at a plan that may since have been retired, and a catalogue
  /// view that hid it would make that membership unreadable.
  Future<List<MembershipPlan>> listPlans() {
    return guardFailures(() async {
      final PostgrestList rows = await _client
          .from(_table)
          .select('*')
          .order('is_active', ascending: false)
          .order('sort_order', ascending: true)
          .order('name', ascending: true);
      return rows
          .map((Map<String, dynamic> row) => MembershipPlan.fromJson(row))
          .toList();
    });
  }

  /// Plans on sale at one branch: active, and either org-wide or listing this
  /// branch. This is the list a renewal or a walk-in sale offers. Mirrors the
  /// console's `listPlansForBranch`.
  ///
  /// `branch_ids` is a `uuid[]` where **empty means every branch**, so the
  /// filter is two clauses, not one: `eq.{}` for the org-wide plans and
  /// `cs.{id}` (contains) for the ones scoped to this branch. Testing only for
  /// containment would silently drop the org-wide catalogue, which is most of
  /// it.
  Future<List<MembershipPlan>> listPlansForBranch(String branchId) {
    return guardFailures(() async {
      final PostgrestList rows = await _client
          .from(_table)
          .select('*')
          .eq('is_active', true)
          .or('branch_ids.eq.{},branch_ids.cs.{$branchId}')
          .order('sort_order', ascending: true)
          .order('name', ascending: true);
      return rows
          .map((Map<String, dynamic> row) => MembershipPlan.fromJson(row))
          .toList();
    });
  }

  /// One plan by primary key, or `null` if it does not exist or RLS hides it
  /// -- indistinguishable by design. Mirrors the console's `getPlan`.
  Future<MembershipPlan?> fetchById(String planId) {
    return guardFailures(() async {
      final Map<String, dynamic>? row = await _client
          .from(_table)
          .select('*')
          .eq('id', planId)
          .maybeSingle();
      if (row == null) {
        return null;
      }
      return MembershipPlan.fromJson(row);
    });
  }

  /// Adds a plan and returns its id. Mirrors the console's `insertPlan`.
  ///
  /// `org_id` comes from the caller's claims, never from a form; the RLS
  /// insert policy independently rejects any other org. A new plan is always
  /// active. The (org, name) unique rule surfaces as
  /// [kPlanDuplicateName], as on the console.
  Future<String> createPlan({
    required String orgId,
    required PlanValues values,
  }) {
    return guardFailures(() async {
      try {
        final Map<String, dynamic> row = await _client
            .from(_table)
            .insert(<String, dynamic>{
              'org_id': orgId,
              ...values.toRow(),
              'is_active': true,
            })
            .select('id')
            .single();
        return row['id'] as String;
      } on PostgrestException catch (error) {
        throw _duplicateOr(error);
      }
    });
  }

  /// Rewrites a plan's editable columns. Mirrors the console's `updatePlan`.
  ///
  /// RLS turns a plan the caller may not touch into zero updated rows rather
  /// than an error, so the row count is checked: a silent no-op must never
  /// look like a save.
  Future<void> updatePlan(String planId, PlanValues values) {
    return guardFailures(() => _update(planId, values.toRow()));
  }

  /// Puts a plan on or off sale. Mirrors the console's `setPlanActive`.
  Future<void> setPlanActive(String planId, bool isActive) {
    return guardFailures(
      () => _update(planId, <String, dynamic>{'is_active': isActive}),
    );
  }

  Future<void> _update(String planId, Map<String, dynamic> row) async {
    try {
      final PostgrestList updated = await _client
          .from(_table)
          .update(row)
          .eq('id', planId)
          .select('id');
      if (updated.isEmpty) {
        throw const AppFailure(
          FailureKind.notFound,
          'That plan could not be found.',
        );
      }
    } on PostgrestException catch (error) {
      throw _duplicateOr(error);
    }
  }

  /// `23505` on this table can only be the (org, name) rule.
  Object _duplicateOr(PostgrestException error) {
    if (error.code == '23505') {
      return AppFailure(
        FailureKind.duplicate,
        kPlanDuplicateName,
        cause: error,
        code: error.code,
      );
    }
    return error;
  }
}

@riverpod
PlansRepository plansRepository(Ref ref) {
  return PlansRepository(ref.watch(supabaseClientProvider));
}
