// Settings -> Plans: the plan catalogue (owner and manager).
//
// Port of the console's `/plans` page (`plans-table.tsx`): add a plan, open
// one to edit it, and put it on or off sale. There is no delete, here or on
// the console -- a plan that was ever sold is retired by deactivating it,
// because memberships keep pointing at it.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/data/plans/membership_plan.dart';
import 'package:logfitness_flutter/data/plans/plans_repository.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/domain/format/money.dart';
import 'package:logfitness_flutter/domain/format/plan_pricing.dart';
import 'package:logfitness_flutter/domain/validation/plan_form.dart';
import 'package:logfitness_flutter/features/common/async_value_view.dart';
import 'package:logfitness_flutter/features/common/docked_action.dart';
import 'package:logfitness_flutter/features/common/failure_snackbar.dart';
import 'package:logfitness_flutter/features/settings/catalogue/plan_form_screen.dart';
import 'package:logfitness_flutter/features/settings/catalogue/plan_providers.dart';
import 'package:logfitness_flutter/features/staff/branch_scope.dart';
import 'package:logfitness_flutter/features/staff/staff_capabilities.dart';
import 'package:logfitness_flutter/supabase/supabase_providers.dart';

export 'package:logfitness_flutter/features/settings/catalogue/plan_providers.dart'
    show planCatalogueProvider;

enum PlanAction { edit, toggleActive }

class PlansScreen extends ConsumerStatefulWidget {
  const PlansScreen({super.key});

  @override
  ConsumerState<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends ConsumerState<PlansScreen> {
  final Set<String> _busy = <String>{};

  Future<void> _open(MembershipPlan? plan) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => PlanFormScreen(plan: plan)),
    );
  }

  Future<void> _toggle(MembershipPlan plan) async {
    final StaffRole? role = ref.read(staffRoleProvider);
    final List<String> mine =
        ref.read(claimsProvider)?.branchIds ?? const <String>[];
    // The console refuses this before it reaches the database, because RLS
    // would update zero rows and say nothing.
    if (role == null || !canScopePlan(role, mine, plan.branchIds)) {
      showFailureSnackBar(
        context,
        const AppFailure(FailureKind.refused, kPlanEditOutOfScope),
      );
      return;
    }

    final bool turnOff = plan.isActive;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(
          turnOff ? 'Deactivate ${plan.name}?' : 'Put ${plan.name} on sale?',
        ),
        content: Text(
          turnOff
              ? 'It will stop being offered when you sell a membership. '
                    'Memberships already sold are not changed.'
              : 'It will be offered again when you sell a membership.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const ValueKey<String>('plan-toggle-confirm'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(turnOff ? 'Deactivate' : 'Activate'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy.add(plan.id));
    try {
      await ref.read(plansRepositoryProvider).setPlanActive(plan.id, !turnOff);
    } catch (error, stackTrace) {
      if (!mounted) return;
      setState(() => _busy.remove(plan.id));
      showFailureSnackBar(context, mapError(error, stackTrace));
      return;
    }
    refreshPlanProviders(ref);
    if (!mounted) return;
    setState(() => _busy.remove(plan.id));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            turnOff
                ? '${plan.name} is now inactive.'
                : '${plan.name} is back on sale.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<MembershipPlan>> plans = ref.watch(
      planCatalogueProvider,
    );
    final Map<String, String> branchNames = ref.watch(branchNamesProvider);
    final bool canManage = ref
        .watch(staffCapabilitiesProvider)
        .contains(StaffCapability.managePlans);

    return Scaffold(
      appBar: AppBar(title: const Text('Plans')),
      bottomNavigationBar: canManage
          ? DockedAction(
              label: 'Add plan',
              icon: Icons.add,
              onPressed: () => unawaited(_open(null)),
            )
          : null,
      body: AsyncValueView<List<MembershipPlan>>(
        value: plans,
        onRetry: () => ref.invalidate(planCatalogueProvider),
        isEmpty: (List<MembershipPlan> p) => p.isEmpty,
        emptyMessage:
            'No plans yet. Add the first one to start selling memberships.',
        data: (List<MembershipPlan> p) => ListView.separated(
          padding: const EdgeInsets.all(Brand.spaceMd),
          itemCount: p.length,
          separatorBuilder: (_, _) => const Divider(),
          itemBuilder: (BuildContext context, int i) {
            final MembershipPlan plan = p[i];
            return PlanTile(
              plan: plan,
              soldAt: planBranchLabel(plan, branchNames),
              busy: _busy.contains(plan.id),
              onTap: canManage ? () => unawaited(_open(plan)) : null,
              onAction: canManage
                  ? (PlanAction a) {
                      switch (a) {
                        case PlanAction.edit:
                          unawaited(_open(plan));
                        case PlanAction.toggleActive:
                          unawaited(_toggle(plan));
                      }
                    }
                  : null,
            );
          },
        ),
      ),
    );
  }
}

String planTypeLabel(PlanType type) => planTypeName(type);

/// "Every branch", or the branch names (falling back to a count while the
/// names are still loading).
String planBranchLabel(MembershipPlan plan, Map<String, String> names) {
  if (plan.branchIds.isEmpty) return 'Every branch';
  final List<String> known = <String>[
    for (final String id in plan.branchIds)
      if (names[id] != null) names[id]!,
  ];
  if (known.length == plan.branchIds.length) return known.join(', ');
  final int n = plan.branchIds.length;
  return n == 1 ? '1 branch' : '$n branches';
}

class PlanTile extends StatelessWidget {
  const PlanTile({
    required this.plan,
    this.soldAt,
    this.busy = false,
    this.onTap,
    this.onAction,
    super.key,
  });

  final MembershipPlan plan;
  final String? soldAt;
  final bool busy;
  final VoidCallback? onTap;
  final void Function(PlanAction action)? onAction;

  String _term() {
    final String base = planTermLabel(plan);
    if (plan.planType == PlanType.sessionPack && plan.durationDays != null) {
      return '$base, valid ${plan.durationDays} days';
    }
    return base;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final Color muted = scheme.onSurfaceVariant;
    final String fee = plan.signupFeePaisa > 0
        ? 'Joining fee ${formatMoney(plan.signupFeePaisa)}'
        : 'No joining fee';

    return Semantics(
      container: true,
      label: '${plan.name}, ${plan.isActive ? 'active' : 'inactive'}',
      child: InkWell(
        key: ValueKey<String>('plan-row-${plan.id}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(Brand.radiusSmall),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Brand.spaceSm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 2, right: Brand.spaceMd),
                child: Icon(
                  Icons.card_membership_outlined,
                  color: plan.isActive ? scheme.onSurface : muted,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      plan.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: plan.isActive ? null : muted,
                      ),
                    ),
                    const SizedBox(height: Brand.spaceXs),
                    Wrap(
                      spacing: Brand.spaceSm,
                      runSpacing: Brand.spaceXs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        Text(
                          formatMoney(plan.pricePaisa),
                          style: theme.textTheme.titleSmall,
                        ),
                        _StatusMark(active: plan.isActive),
                      ],
                    ),
                    const SizedBox(height: Brand.spaceXs),
                    Text(
                      '${planTypeLabel(plan.planType)} · ${_term()}',
                      style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                    ),
                    Text(
                      fee,
                      style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                    ),
                    if (soldAt != null)
                      Text(
                        'Sold at: $soldAt',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: muted,
                        ),
                      ),
                  ],
                ),
              ),
              if (busy)
                const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else if (onAction != null)
                PopupMenuButton<PlanAction>(
                  key: ValueKey<String>('plan-menu-${plan.id}'),
                  tooltip: 'Plan actions',
                  onSelected: onAction,
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<PlanAction>>[
                        const PopupMenuItem<PlanAction>(
                          value: PlanAction.edit,
                          child: Text('Edit plan'),
                        ),
                        PopupMenuItem<PlanAction>(
                          value: PlanAction.toggleActive,
                          child: Text(
                            plan.isActive ? 'Deactivate' : 'Activate',
                          ),
                        ),
                      ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Active or Inactive, in words and an icon, never by colour alone.
class _StatusMark extends StatelessWidget {
  const _StatusMark({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color fg = active
        ? scheme.onPrimaryContainer
        : scheme.onSurfaceVariant;
    final Color bg = active
        ? scheme.primaryContainer
        : scheme.surfaceContainerHighest;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(Brand.radiusLarge),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            active ? Icons.check_circle_outline : Icons.pause_circle_outline,
            size: 14,
            color: fg,
          ),
          const SizedBox(width: Brand.spaceXs),
          Text(
            active ? 'Active' : 'Inactive',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: fg),
          ),
        ],
      ),
    );
  }
}
