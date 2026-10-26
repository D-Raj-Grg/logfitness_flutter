// One fee of the gym's fees catalogue: a charge on top of a plan price, such as
// registration or a member card. Mirrors `public.fees`
// (`logfitness_saas/supabase/migrations/20261027100000_fee_catalogue.sql`).
//
// Plain class rather than freezed: it is read whole through one repository and
// never serialised anywhere else.
import 'package:flutter/foundation.dart';

import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';

@immutable
class Fee {
  const Fee({
    required this.id,
    required this.orgId,
    required this.name,
    required this.chargeRule,
    required this.amountPaisa,
    required this.allPlans,
    required this.planIds,
    required this.isActive,
    required this.sortOrder,
  });

  factory Fee.fromRow(Map<String, dynamic> row) => Fee(
    id: row['id'] as String,
    orgId: row['org_id'] as String,
    name: row['name'] as String,
    chargeRule: FeeChargeRule.fromDb(row['charge_rule'] as String),
    // Money is integer paisa end to end. Never a double, never converted here.
    amountPaisa: (row['amount_paisa'] as num).toInt(),
    allPlans: row['all_plans'] as bool,
    planIds: <String>[
      for (final Object? id in (row['plan_ids'] as List<dynamic>? ?? <dynamic>[]))
        id as String,
    ],
    isActive: row['is_active'] as bool,
    sortOrder: (row['sort_order'] as num).toInt(),
  );

  final String id;
  final String orgId;
  final String name;
  final FeeChargeRule chargeRule;
  final int amountPaisa;

  /// On for every plan, including plans created later. [planIds] is then empty.
  final bool allPlans;
  final List<String> planIds;
  final bool isActive;
  final int sortOrder;

  /// Whether this fee reaches [planId]. Mirrors `sale_fees()`:
  /// `all_plans or plan = any(plan_ids)`. Active-ness is the caller's filter.
  bool appliesTo(String planId) => allPlans || planIds.contains(planId);
}
