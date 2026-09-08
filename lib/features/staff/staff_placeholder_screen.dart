// What a declared-but-unbuilt destination renders.
//
// The shell is landing ahead of the screens it navigates to (TASKS.md, "Staff
// parity programme" sub-projects B–F), so every destination needs *something*
// behind it. This says plainly that the screen is not built yet rather than
// showing an empty list, which would be indistinguishable from a branch with
// no data — the same conflation `AppFailure` and `EmptyView` exist to avoid.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/features/staff/branch_scope.dart';
import 'package:logfitness_flutter/features/staff/branch_switcher.dart';
import 'package:logfitness_flutter/features/staff/staff_destinations.dart';

class StaffPlaceholderScreen extends ConsumerWidget {
  const StaffPlaceholderScreen({required this.destination, super.key});

  final StaffDestination destination;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scope = ref.watch(branchScopeProvider);
    final names = ref.watch(branchNamesProvider);

    final scopeLine = switch (scope.selectedBranchId) {
      final String id => 'Scoped to ${branchLabel(id, names)}.',
      null when scope.isOrgWide => 'Scoped to every branch in the org.',
      null when scope.options.isEmpty => 'No branch is assigned to you.',
      null => 'Scoped to your ${scope.options.length} branches.',
    };

    return Padding(
      padding: const EdgeInsets.all(Brand.spaceXl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            destination.icon,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: Brand.spaceMd),
          Text(destination.label, style: theme.textTheme.titleLarge),
          const SizedBox(height: Brand.spaceSm),
          Text(
            'Not built yet.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Brand.spaceMd),
          // Proves the branch selection actually reaches a screen, which is
          // the whole point of the switcher landing before the screens do.
          Text(
            scopeLine,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
