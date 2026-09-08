// The branch switcher in the staff shell's app bar. TASKS.md Phase 5:
// "Branch switcher in the staff shell, options limited to branch_ids[] from
// claims."
//
// It offers exactly what the claim carries and nothing else. That is a
// convenience, not a boundary — see `branch_scope.dart`.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/features/staff/branch_scope.dart';

const Key branchSwitcherKey = Key('branch-switcher');

/// Sentinel for the aggregate entry, so `null` can stay the "no branch
/// selected" value in [SelectedBranch] without a nullable menu value.
const String _aggregateValue = '__all__';

/// A [PopupMenuButton] over the branches on the `branch_ids[]` claim.
///
/// Renders nothing when there is only one thing to look at — a front desk
/// assigned to a single branch has no decision to make, and an inert control
/// in the app bar only invites one.
class BranchSwitcher extends ConsumerWidget {
  const BranchSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scope = ref.watch(branchScopeProvider);
    if (!scope.canSwitch) {
      return const SizedBox.shrink();
    }

    final names = ref.watch(branchNamesProvider);
    final theme = Theme.of(context);

    // "All branches" for an owner covers the org, including a branch created
    // since this token was minted; for everyone else it means "all of mine".
    // The wording has to differ, because to a manager the two are not the
    // same claim about what they are seeing.
    final aggregateLabel = scope.isOrgWide ? 'All branches' : 'All my branches';
    final selected = scope.selectedBranchId;

    return PopupMenuButton<String>(
      key: branchSwitcherKey,
      tooltip: 'Branch',
      initialValue: selected ?? _aggregateValue,
      onSelected: (String value) => ref
          .read(selectedBranchProvider.notifier)
          .select(value == _aggregateValue ? null : value),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: _aggregateValue,
          child: Text(aggregateLabel),
        ),
        if (scope.options.isNotEmpty) const PopupMenuDivider(),
        for (final String branchId in scope.options)
          PopupMenuItem<String>(
            value: branchId,
            child: Text(branchLabel(branchId, names)),
          ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.store_mall_directory_outlined,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 140),
              child: Text(
                selected == null
                    ? aggregateLabel
                    : branchLabel(selected, names),
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge,
              ),
            ),
            const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
      ),
    );
  }
}

/// What to call [branchId] on screen.
///
/// Claims carry ids only, and there is no `branches` repository in this app
/// yet, so until [branchNamesProvider] is backed by one this degrades to a
/// short prefix of the uuid — recognisable enough to tell two branches apart
/// without pretending to be a name.
String branchLabel(String branchId, Map<String, String> names) {
  final name = names[branchId];
  if (name != null && name.isNotEmpty) {
    return name;
  }
  return branchId.length > 8 ? 'Branch ${branchId.substring(0, 8)}' : branchId;
}
