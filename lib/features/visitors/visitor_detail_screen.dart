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
import 'package:logfitness_flutter/data/plans/membership_plan.dart';
import 'package:logfitness_flutter/data/plans/plans_repository.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/format/dates.dart';
import 'package:logfitness_flutter/features/common/async_value_view.dart';
import 'package:logfitness_flutter/features/common/failure_snackbar.dart';
import 'package:logfitness_flutter/features/members/register_member_screen.dart';
import 'package:logfitness_flutter/features/notifications/member_message_sheet.dart';
import 'package:logfitness_flutter/features/notifications/send_message_controller.dart';
import 'package:logfitness_flutter/features/notifications/visitor_message_sheet.dart';
import 'package:logfitness_flutter/features/staff/staff_capabilities.dart';
import 'package:logfitness_flutter/features/visitors/visitor_actions_controller.dart';
import 'package:logfitness_flutter/features/visitors/visitor_form_screen.dart';
import 'package:logfitness_flutter/features/visitors/widgets/visitor_dial.dart';
import 'package:logfitness_flutter/features/visitors/widgets/visitor_labels.dart';
import 'package:logfitness_flutter/features/visitors/widgets/visitor_status_badge.dart';

/// What they asked about, resolved to the plan's name.
///
/// Renders nothing at all if the plan cannot be resolved. A plan deleted since
/// the visit nulls the column upstream (`on delete set null`), and a plan that
/// simply fails to load is not worth an error here — the visit still happened,
/// and the rest of the screen is what the desk came for.
class _InterestedPlanLine extends ConsumerWidget {
  const _InterestedPlanLine({required this.planId});

  final String planId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final plan = ref.watch(visitorPlanProvider(planId)).value;
    if (plan == null) {
      return const SizedBox.shrink();
    }
    return Text(
      'Interested in ${plan.name}',
      style: theme.textTheme.bodyMedium
          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
    );
  }
}

/// One plan by id, for rendering a visitor's interest.
final visitorPlanProvider =
    FutureProvider.family<MembershipPlan?, String>((ref, String planId) {
  return ref.watch(plansRepositoryProvider).fetchById(planId);
});

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

    // Same gate as the member profile's Send SMS, and the same rule behind it:
    // `visitor_message_target` refuses a trainer itself, so hiding the buttons
    // is a courtesy and the refusal still has to reach the screen.
    final canSendMessage =
        capabilities.contains(StaffCapability.sendMemberMessage);

    final muted = theme.textTheme.bodyMedium
        ?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    final hasNote = visitor.note != null && visitor.note!.trim().isNotEmpty;

    return ListView(
      padding: const EdgeInsets.all(Brand.spaceMd),
      children: <Widget>[
        // Header: who, where they stand, and the number.
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Text(visitor.fullName, style: theme.textTheme.headlineSmall),
            ),
            const SizedBox(width: Brand.spaceSm),
            VisitorStatusBadge(visitor.status),
          ],
        ),
        const SizedBox(height: Brand.spaceXs),
        Text(
          '${visitorKindLabel(visitor.kind)} · '
          '${formatPlainDate(visitor.visitedOn)}',
          style: muted,
        ),
        if (visitor.interestedPlanId != null)
          Padding(
            padding: const EdgeInsets.only(top: Brand.spaceXs),
            child: _InterestedPlanLine(planId: visitor.interestedPlanId!),
          ),
        const SizedBox(height: Brand.spaceSm),
        Row(
          children: <Widget>[
            Expanded(
              child: Text(visitor.phone, style: theme.textTheme.titleLarge),
            ),
            if (visitor.isOpen)
              FilledButton.tonalIcon(
                key: const ValueKey<String>('visitor-call'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(48, 48),
                ),
                onPressed: () => dialPhone(context, visitor.phone),
                icon: const Icon(Icons.phone_outlined),
                label: const Text('Call'),
              ),
          ],
        ),
        if (hasNote) ...<Widget>[
          const SizedBox(height: Brand.spaceMd),
          Container(
            padding: const EdgeInsets.all(Brand.spaceMd),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(Brand.radiusMedium),
            ),
            child: Text(visitor.note!),
          ),
        ],
        const SizedBox(height: Brand.spaceLg),

        if (visitor.isConverted)
          // Nothing left to chase. Saying so beats offering actions that the
          // `visitors_converted_shape` constraint would refuse anyway.
          Container(
            padding: const EdgeInsets.all(Brand.spaceMd),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(Brand.radiusMedium),
            ),
            child: Text(
              'Joined as a member'
              '${visitor.convertedAt == null ? '' : ' on ${formatDate(visitor.convertedAt!)}'}.',
              style: TextStyle(color: theme.colorScheme.onSecondaryContainer),
            ),
          )
        else ...<Widget>[
          // Next step: the two things a desk does with an open walk-in.
          FilledButton.icon(
            key: const ValueKey<String>('visitor-register'),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            onPressed: busy ? null : () => _register(context, ref),
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('Convert to member'),
          ),
          if (visitor.status != VisitorStatus.contacted) ...<Widget>[
            const SizedBox(height: Brand.spaceSm),
            FilledButton.tonalIcon(
              key: const ValueKey<String>('visitor-mark-contacted'),
              style:
                  FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
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
              label: const Text('Mark as followed up'),
            ),
          ],
          if (canSendMessage) ...<Widget>[
            const SizedBox(height: Brand.spaceMd),
            // Welcome is one tap, no sheet: the gym's own wording, rendered
            // in Postgres, so it reads like the one the insert trigger sends.
            Wrap(
              spacing: Brand.spaceSm,
              runSpacing: Brand.spaceSm,
              children: <Widget>[
                OutlinedButton.icon(
                  key: const ValueKey<String>('visitor-send-welcome'),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48)),
                  onPressed: busy ? null : () => _sendWelcome(context, ref),
                  icon: const Icon(Icons.waving_hand_outlined),
                  label: const Text('Send welcome SMS'),
                ),
                OutlinedButton.icon(
                  key: const ValueKey<String>('visitor-send-message'),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48)),
                  onPressed: busy
                      ? null
                      : () => showVisitorMessageSheet(
                            context,
                            visitorId: visitor.id,
                            fullName: visitor.fullName,
                          ),
                  icon: const Icon(Icons.sms_outlined),
                  label: const Text('Send message…'),
                ),
              ],
            ),
          ],
        ],

        const SizedBox(height: Brand.spaceLg),
        Text('History', style: theme.textTheme.titleMedium),
        const SizedBox(height: Brand.spaceSm),
        _Timeline(visitor: visitor),

        const SizedBox(height: Brand.spaceMd),
        Wrap(
          spacing: Brand.spaceSm,
          children: <Widget>[
            TextButton.icon(
              key: const ValueKey<String>('visitor-edit'),
              style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
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
            if (!visitor.isConverted && visitor.status != VisitorStatus.lost)
              TextButton.icon(
                key: const ValueKey<String>('visitor-mark-lost'),
                style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
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
            if (canDelete)
              TextButton.icon(
                key: const ValueKey<String>('visitor-delete'),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                  minimumSize: const Size(48, 48),
                ),
                onPressed: busy ? null : () => _confirmDelete(context, ref),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete'),
              ),
          ],
        ),
      ],
    );
  }

  /// The one-tap welcome. A null body means the template is rendered
  /// server-side; see `send_message_controller.dart`.
  Future<void> _sendWelcome(BuildContext context, WidgetRef ref) async {
    final result =
        await ref.read(sendMessageProvider.notifier).toVisitor(
              visitorId: visitor.id,
              event: NotificationEvent.visitorWelcome,
            );
    if (!context.mounted) {
      return;
    }
    switch (result) {
      case SendMessageSucceeded():
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text(kQueuedMessage)));
      case SendMessageFailed(:final failure):
        // Verbatim, as everywhere: "That visitor is a member now" and "That
        // message is already queued" are answers, not crashes.
        showFailureSnackBar(context, failure);
    }
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

/// What has happened to this walk-in, newest last. Built from the row's own
/// timestamps: the log keeps no event table, so a status change shows as the
/// row's last update.
class _Timeline extends StatelessWidget {
  const _Timeline({required this.visitor});

  final Visitor visitor;

  @override
  Widget build(BuildContext context) {
    final events = <(String, String)>[
      ('Walked in', formatPlainDate(visitor.visitedOn)),
      if (visitor.status == VisitorStatus.contacted)
        ('Followed up', formatDate(visitor.updatedAt)),
      if (visitor.status == VisitorStatus.lost)
        ('Marked not joining', formatDate(visitor.updatedAt)),
      if (visitor.isConverted)
        (
          'Joined as a member',
          formatDate(visitor.convertedAt ?? visitor.updatedAt),
        ),
    ];
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      children: <Widget>[
        for (var i = 0; i < events.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(
                  width: 20,
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: 6),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == events.length - 1
                              ? scheme.primary
                              : scheme.outline,
                        ),
                      ),
                      if (i < events.length - 1)
                        Expanded(
                          child: Container(width: 2, color: scheme.outlineVariant),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: Brand.spaceSm),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: Brand.spaceMd),
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: Brand.spaceSm,
                      children: <Widget>[
                        Text(events[i].$1, style: theme.textTheme.bodyMedium),
                        Text(
                          events[i].$2,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
