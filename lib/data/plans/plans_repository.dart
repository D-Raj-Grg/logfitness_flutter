// The plan catalogue, mirroring the web console's
// `logfitness_saas/lib/db/plans.ts`.
//
// Read-only on purpose. Plan catalogue CRUD stays on the web console
// (PLANNING.md §1 and §8), so the console's `insertPlan` and `updatePlan` have
// no counterpart here -- their absence is a scope decision, not an oversight.
// What mobile needs is the list a sale picks from and the plan behind a
// membership.
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:logfitness_flutter/data/plans/membership_plan.dart';
import 'package:logfitness_flutter/data/repository_guard.dart';
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
          .order('sort_order')
          .order('name');
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
          .order('sort_order')
          .order('name');
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
}

@riverpod
PlansRepository plansRepository(Ref ref) {
  return PlansRepository(ref.watch(supabaseClientProvider));
}
