// Settings -> Branches: a read-only list. Creating, renaming and
// deactivating a branch stays on the web console (PLANNING.md §4).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/data/branches/branch.dart';
import 'package:logfitness_flutter/data/branches/branches_repository.dart';
import 'package:logfitness_flutter/features/common/async_value_view.dart';

class BranchesScreen extends ConsumerWidget {
  const BranchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Branch>> branches = ref.watch(branchesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Branches')),
      body: AsyncValueView<List<Branch>>(
        value: branches,
        onRetry: () => ref.invalidate(branchesProvider),
        isEmpty: (List<Branch> b) => b.isEmpty,
        emptyMessage: 'No branches yet.',
        data: (List<Branch> b) => ListView.separated(
          padding: const EdgeInsets.all(Brand.spaceMd),
          itemCount: b.length + 1,
          separatorBuilder: (_, _) => const Divider(),
          itemBuilder: (BuildContext context, int i) {
            if (i == b.length) {
              return Padding(
                padding: const EdgeInsets.only(top: Brand.spaceSm),
                child: Text(
                  'Branches are managed on the web console.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              );
            }
            return BranchTile(branch: b[i]);
          },
        ),
      ),
    );
  }
}

class BranchTile extends StatelessWidget {
  const BranchTile({required this.branch, super.key});

  final Branch branch;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<String> lines = <String>[
      if (branch.address?.trim().isNotEmpty ?? false) branch.address!.trim(),
      if (branch.phone?.trim().isNotEmpty ?? false) branch.phone!.trim(),
    ];
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.store_outlined),
      title: Text(branch.name),
      subtitle: lines.isEmpty ? null : Text(lines.join('\n')),
      isThreeLine: lines.length > 1,
      trailing: Text(
        branch.isActive ? 'Active' : 'Inactive',
        style: theme.textTheme.labelMedium?.copyWith(
          color: branch.isActive
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
