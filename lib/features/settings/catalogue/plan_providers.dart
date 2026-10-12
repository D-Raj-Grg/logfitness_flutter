// The plan catalogue's providers, and the one place that knows which other
// providers hold a copy of it.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/data/plans/membership_plan.dart';
import 'package:logfitness_flutter/data/plans/plans_repository.dart';
import 'package:logfitness_flutter/features/members/register_member_screen.dart'
    show branchPlansProvider;
import 'package:logfitness_flutter/features/payments/payment_queries.dart'
    show sellablePlansProvider;
import 'package:logfitness_flutter/features/visitors/visitor_detail_screen.dart'
    show visitorPlanProvider;
import 'package:logfitness_flutter/features/visitors/visitor_form_screen.dart'
    show visitorBranchPlansProvider;

/// The whole catalogue, active or not (`listPlans`).
final FutureProvider<List<MembershipPlan>> planCatalogueProvider =
    FutureProvider<List<MembershipPlan>>(
      (Ref ref) => ref.watch(plansRepositoryProvider).listPlans(),
    );

/// Call after any plan write. The catalogue is not the only reader: the
/// register, renew and visitor screens each keep a per-branch copy of the
/// sellable list, and none of them is auto-disposed, so without this a plan
/// added or retired here would not show up (or would linger) over there until
/// the app restarted.
void refreshPlanProviders(WidgetRef ref) {
  ref
    ..invalidate(planCatalogueProvider)
    ..invalidate(sellablePlansProvider)
    ..invalidate(branchPlansProvider)
    ..invalidate(visitorBranchPlansProvider)
    ..invalidate(visitorPlanProvider);
}
