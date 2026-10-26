// Settings -> Fees: the fees catalogue (owner only).
//
// Port of the console's `/settings/fees` page (`fees-table.tsx`): add a fee,
// open one to edit it, and put it on or off. There is no delete, here or on the
// console -- a fee that was ever charged is retired by deactivating it, because
// past sales keep a snapshot of what they charged.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/data/fees/fee.dart';
import 'package:logfitness_flutter/data/fees/fees_repository.dart';
import 'package:logfitness_flutter/data/plans/membership_plan.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/domain/format/money.dart';
import 'package:logfitness_flutter/domain/validation/fee_form.dart';
import 'package:logfitness_flutter/features/common/async_value_view.dart';
import 'package:logfitness_flutter/features/common/docked_action.dart';
import 'package:logfitness_flutter/features/common/failure_snackbar.dart';
import 'package:logfitness_flutter/features/settings/catalogue/fee_form_screen.dart';
import 'package:logfitness_flutter/features/settings/catalogue/fee_providers.dart';
import 'package:logfitness_flutter/features/settings/catalogue/plan_providers.dart';
import 'package:logfitness_flutter/features/staff/staff_capabilities.dart';

enum FeeAction { edit, toggleActive }

class FeesScreen extends ConsumerStatefulWidget {
  const FeesScreen({super.key});

  @override
  ConsumerState<FeesScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends ConsumerState<FeesScreen> {
  final Set<String> _busy = <String>{};

  Future<void> _open(Fee? fee) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => FeeFormScreen(fee: fee)),
    );
  }

  Future<void> _toggle(Fee fee) async {
    final bool turnOff = fee.isActive;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(
          turnOff ? 'Deactivate ${fee.name}?' : 'Charge ${fee.name} again?',
        ),
        content: Text(
          turnOff
              ? 'It will stop being charged on new sales. Sales already made '
                    'are not changed.'
              : 'It will be charged on new sales again.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const ValueKey<String>('fee-toggle-confirm'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(turnOff ? 'Deactivate' : 'Activate'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy.add(fee.id));
    try {
      await ref.read(feesRepositoryProvider).setFeeActive(fee.id, !turnOff);
    } catch (error, stackTrace) {
      if (!mounted) return;
      setState(() => _busy.remove(fee.id));
      showFailureSnackBar(context, mapError(error, stackTrace));
      return;
    }
    refreshFeeProviders(ref);
    if (!mounted) return;
    setState(() => _busy.remove(fee.id));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            turnOff ? '${fee.name} is now inactive.' : '${fee.name} is active.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Fee>> fees = ref.watch(feeCatalogueProvider);
    final Map<String, String> planNames = <String, String>{
      for (final MembershipPlan p
          in ref.watch(planCatalogueProvider).value ?? const <MembershipPlan>[])
        p.id: p.name,
    };
    final bool canManage = ref
        .watch(staffCapabilitiesProvider)
        .contains(StaffCapability.manageFees);
    final bool charging =
        ref.watch(feeSetupProvider).value?.catalogueEnabled ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Fees')),
      bottomNavigationBar: canManage
          ? DockedAction(
              label: 'Add fee',
              icon: Icons.add,
              onPressed: () => unawaited(_open(null)),
            )
          : null,
      body: Column(
        children: <Widget>[
          if (!charging)
            Container(
              key: const ValueKey<String>('fees-not-charging'),
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(
                Brand.spaceMd,
                Brand.spaceMd,
                Brand.spaceMd,
                0,
              ),
              padding: const EdgeInsets.all(Brand.spaceMd),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(Brand.radiusMedium),
              ),
              child: const Text(
                'These fees are not being charged yet. Until your gym is '
                'switched over, the joining fee on each plan is charged '
                'instead. You can set the fees up here ahead of time.',
              ),
            ),
          Expanded(
            child: AsyncValueView<List<Fee>>(
              value: fees,
              onRetry: () => ref.invalidate(feeCatalogueProvider),
              isEmpty: (List<Fee> f) => f.isEmpty,
              emptyMessage:
                  'No fees yet. Add a registration fee, a card fee, or '
                  'anything else you charge on top of a plan.',
              data: (List<Fee> f) => ListView.separated(
                padding: const EdgeInsets.all(Brand.spaceMd),
                itemCount: f.length,
                separatorBuilder: (_, _) => const Divider(),
                itemBuilder: (BuildContext context, int i) {
                  final Fee fee = f[i];
                  return FeeTile(
                    fee: fee,
                    appliesTo: feeAppliesToLabel(fee, planNames),
                    busy: _busy.contains(fee.id),
                    onTap: canManage ? () => unawaited(_open(fee)) : null,
                    onAction: canManage
                        ? (FeeAction a) {
                            switch (a) {
                              case FeeAction.edit:
                                unawaited(_open(fee));
                              case FeeAction.toggleActive:
                                unawaited(_toggle(fee));
                            }
                          }
                        : null,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "All plans", or the plan names, or a count once the list gets long.
String feeAppliesToLabel(Fee fee, Map<String, String> planNames) {
  if (fee.allPlans) return 'All plans';
  final List<String> names = <String>[
    for (final String id in fee.planIds) planNames[id] ?? 'Unknown plan',
  ];
  if (names.length <= 3) return names.join(', ');
  return '${names.take(2).join(', ')} and ${names.length - 2} more';
}

class FeeTile extends StatelessWidget {
  const FeeTile({
    required this.fee,
    required this.appliesTo,
    this.busy = false,
    this.onTap,
    this.onAction,
    super.key,
  });

  final Fee fee;
  final String appliesTo;
  final bool busy;
  final VoidCallback? onTap;
  final void Function(FeeAction action)? onAction;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final Color muted = scheme.onSurfaceVariant;

    return Semantics(
      container: true,
      label: '${fee.name}, ${fee.isActive ? 'active' : 'inactive'}',
      child: InkWell(
        key: ValueKey<String>('fee-row-${fee.id}'),
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
                  Icons.receipt_long_outlined,
                  color: fee.isActive ? scheme.onSurface : muted,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      fee.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: fee.isActive ? null : muted,
                      ),
                    ),
                    const SizedBox(height: Brand.spaceXs),
                    Wrap(
                      spacing: Brand.spaceSm,
                      runSpacing: Brand.spaceXs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        Text(
                          formatMoney(fee.amountPaisa),
                          style: theme.textTheme.titleSmall,
                        ),
                        Text(
                          fee.isActive ? 'Active' : 'Inactive',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: muted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Brand.spaceXs),
                    Text(
                      feeRuleLabel(fee.chargeRule),
                      style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                    ),
                    Text(
                      'Applies to: $appliesTo',
                      style: theme.textTheme.bodyMedium?.copyWith(color: muted),
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
                PopupMenuButton<FeeAction>(
                  key: ValueKey<String>('fee-menu-${fee.id}'),
                  tooltip: 'Fee actions',
                  onSelected: onAction,
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<FeeAction>>[
                        const PopupMenuItem<FeeAction>(
                          value: FeeAction.edit,
                          child: Text('Edit fee'),
                        ),
                        PopupMenuItem<FeeAction>(
                          value: FeeAction.toggleActive,
                          child: Text(fee.isActive ? 'Deactivate' : 'Activate'),
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
