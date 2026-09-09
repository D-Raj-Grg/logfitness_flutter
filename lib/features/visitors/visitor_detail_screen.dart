// One walk-in, and the things a desk does about them.
//
// The actions are the point of the screen: call, mark called, mark not
// joining, edit, and register them as a member. Everything reports its
// outcome -- a refusal from the database has to reach the person who tried it,
// because role gating in this app is UX only (CLAUDE.md).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/data/visitors/visitor.dart';
import 'package:logfitness_flutter/data/visitors/visitors_repository.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/format/dates.dart';
import 'package:logfitness_flutter/features/common/async_value_view.dart';
import 'package:logfitness_flutter/features/common/failure_snackbar.dart';
import 'package:logfitness_flutter/features/members/register_member_screen.dart';
import 'package:logfitness_flutter/features/staff/staff_capabilities.dart';
import 'package:logfitness_flutter/features/visitors/visitor_actions_controller.dart';
import 'package:logfitness_flutter/features/visitors/visitor_form_screen.dart';
import 'package:logfitness_flutter/features/visitors/widgets/visitor_labels.dart';
import 'package:logfitness_flutter/features/visitors/widgets/visitor_status_badge.dart';

/// One visitor, read fresh so an edit made elsewhere is not shown stale.
final visitorDetailProvider =
    FutureProvider.family<Visitor?, String>((ref, String visitorId) {
  return ref.watch(visitorsRepositoryProvider).getVisitor(visitorId);
});

class VisitorDetailScreen extends ConsumerWidget {
  const VisitorDetailScreen({required this.visitorId, super.key});

  final String visitorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visitor = ref.watch(visitorDetailProvider(visitorId));

    return Scaffold(
      appBar: AppBar(title: const Text('Walk-in')),
      body: AsyncValueView<Visitor?>(
        value: visitor,
        onRetry: () => ref.invalidate(visitorDetailProvider(visitorId)),
        isEmpty: (Visitor? row) => row == null,
        emptyMessage: 'That walk-in is no longer in the log.',
        data: (Visitor? row) => _Detail(visitor: row!),
      ),
    );
  }
}

class _Detail extends ConsumerWidget {
  const _Detail({required this.visitor});

  final Visitor visitor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final capabilities = ref.watch(staffCapabilitiesProvider);
    final busy = ref.watch(visitorActionsProvider);

    // UX only. The database refuses independently -- `owners delete visitors`
    // is the policy, and a non-owner who reaches this action anyway gets a
    // 42501 that the snackbar renders as a refusal. Hiding the button is a
    // courtesy, never the control (CLAUDE.md).
    final canDelete = capabilities.contains(StaffCapability.accessAllBranches);

    return ListView(
      padding: const EdgeInsets.all(Brand.spaceMd),
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(visitor.fullName, style: theme.textTheme.headlineSmall),
            ),
            VisitorStatusBadge(visitor.status),
          ],
        ),
        const SizedBox(height: Brand.spaceSm),
        Text(visitor.phone, style: theme.textTheme.titleMedium),
        const SizedBox(height: Brand.spaceXs),
        Text(
          '${visitorKindLabel(visitor.kind)} · '
          '${formatPlainDate(visitor.visitedOn)}',
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        if (visitor.note != null && visitor.note!.trim().isNotEmpty) ...<Widget>[
          const SizedBox(height: Brand.spaceMd),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(Brand.spaceMd),
              child: Text(visitor.note!),
            ),
          ),
        ],
        const SizedBox(height: Brand.spaceLg),

        if (visitor.isConverted)
          // Nothing left to chase. Saying so beats offering actions that the
          // `visitors_converted_shape` constraint would refuse anyway.
          Card(
            color: theme.colorScheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(Brand.spaceMd),
              child: Text(
                'Joined as a member'
                '${visitor.convertedAt == null ? '' : ' on ${formatDate(visitor.convertedAt!)}'}.',
                style: TextStyle(color: theme.colorScheme.onSecondaryContainer),
              ),
            ),
          )
        else ...<Widget>[
          FilledButton.icon(
            key: const ValueKey<String>('visitor-register'),
            onPressed: busy ? null : () => _register(context, ref),
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('Register as a member'),
          ),
          const SizedBox(height: Brand.spaceSm),
          if (visitor.status != VisitorStatus.contacted)
            OutlinedButton.icon(
              key: const ValueKey<String>('visitor-mark-contacted'),
              onPressed: busy
                  ? null
                  : () => _run(
                        context,
                        ref,
                        () => ref
                            .read(visitorActionsProvider.notifier)
                            .markContacted(visitor.id),
                      ),
              icon: const Icon(Icons.phone_forwarded_outlined),
              label: const Text('Mark called'),
            ),
          const SizedBox(height: Brand.spaceSm),
          if (visitor.status != VisitorStatus.lost)
            OutlinedButton.icon(
              key: const ValueKey<String>('visitor-mark-lost'),
              onPressed: busy
                  ? null
                  : () => _run(
                        context,
                        ref,
                        () => ref
                            .read(visitorActionsProvider.notifier)
                            .markLost(visitor.id),
                      ),
              icon: const Icon(Icons.do_not_disturb_on_outlined),
              label: const Text('Not joining'),
            ),
        ],

        const SizedBox(height: Brand.spaceSm),
        OutlinedButton.icon(
          key: const ValueKey<String>('visitor-edit'),
          onPressed: busy
              ? null
              : () async {
                  await Navigator.of(context).push<String>(
                    MaterialPageRoute<String>(
                      builder: (_) => VisitorFormScreen(existing: visitor),
                    ),
                  );
                  ref.invalidate(visitorDetailProvider(visitor.id));
                },
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Edit'),
        ),

        if (canDelete) ...<Widget>[
          const SizedBox(height: Brand.spaceLg),
          TextButton.icon(
            key: const ValueKey<String>('visitor-delete'),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            onPressed: busy ? null : () => _confirmDelete(context, ref),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Delete this walk-in'),
          ),
        ],
      ],
    );
  }

  Future<void> _register(BuildContext context, WidgetRef ref) async {
    // Registering from a walk-in *is* a prefilled registration, and passing
    // the visitor id is what makes the new member get linked back — the
    // console's own member form takes a `visitorId` for exactly this.
    final memberId = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => RegisterMemberScreen(
          prefillName: visitor.fullName,
          prefillPhone: visitor.phone,
          visitorId: visitor.id,
        ),
      ),
    );

    if (memberId != null) {
      ref.invalidate(visitorDetailProvider(visitor.id));
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete this walk-in?'),
        content: Text(
          'The record of ${visitor.fullName} walking in will be removed. '
          'Nothing financial hangs off it, but it is still someone else\'s '
          'note of a conversation.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep it'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final result =
        await ref.read(visitorActionsProvider.notifier).delete(visitor.id);
    if (!context.mounted) {
      return;
    }
    switch (result) {
      case VisitorActionSucceeded():
        Navigator.of(context).pop();
      case VisitorActionFailed(:final failure):
        showFailureSnackBar(context, failure);
    }
  }

  Future<void> _run(
    BuildContext context,
    WidgetRef ref,
    Future<VisitorActionResult> Function() action,
  ) async {
    final result = await action();
    if (!context.mounted) {
      return;
    }
    switch (result) {
      case VisitorActionSucceeded():
        ref.invalidate(visitorDetailProvider(visitor.id));
      case VisitorActionFailed(:final failure):
        showFailureSnackBar(context, failure);
    }
  }
}
