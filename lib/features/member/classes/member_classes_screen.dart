// Upcoming classes at the member's home branch (RLS scopes the rows), with
// optimistic book / cancel and waitlist state.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/data/classes/class_board_notifier.dart';
import 'package:logfitness_flutter/data/classes/class_session.dart';
import 'package:logfitness_flutter/domain/classes/class_booking_status.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/features/common/failure_snackbar.dart';
import 'package:logfitness_flutter/features/common/failure_view.dart';

class MemberClassesScreen extends ConsumerWidget {
  const MemberClassesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final board = ref.watch(classBoardProvider);
    final notifier = ref.read(classBoardProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: board.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Padding(
            padding: const EdgeInsets.all(Brand.spaceMd),
            child: Center(
              child: FailureView(
                failure: mapError(error, stack),
                onRetry: notifier.refresh,
              ),
            ),
          ),
          data: (data) => RefreshIndicator(
            onRefresh: notifier.refresh,
            child: data.sessions.isEmpty
                ? ListView(
                    children: const <Widget>[
                      SizedBox(height: 120),
                      Center(child: Text('No upcoming classes right now.')),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(Brand.spaceMd),
                    itemCount: data.sessions.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: Brand.spaceSm),
                    itemBuilder: (context, i) =>
                        _SessionCard(session: data.sessions[i], board: data),
                  ),
          ),
        ),
      ),
    );
  }
}

class _SessionCard extends ConsumerWidget {
  const _SessionCard({required this.session, required this.board});

  final ClassSession session;
  final ClassBoard board;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mine = board.liveBookingFor(session.id);
    final busy =
        board.busy.contains(session.id) ||
        (mine != null && board.busy.contains(mine.id));
    final when =
        '${DateFormat('EEE d MMM').format(session.startsAt)} · '
        '${DateFormat('h:mm a').format(session.startsAt)}–'
        '${DateFormat('h:mm a').format(session.endsAt)}';
    final capacityText = session.isFull
        ? 'Full · ${session.capacity} seats'
        : '${session.spotsLeft} of ${session.capacity} spots left';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Brand.spaceMd),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(session.className, style: theme.textTheme.titleMedium),
                  const SizedBox(height: Brand.spaceXs),
                  Text(when, style: theme.textTheme.bodyMedium),
                  if (session.room != null && session.room!.isNotEmpty)
                    Text(session.room!, style: theme.textTheme.bodySmall),
                  const SizedBox(height: Brand.spaceXs),
                  Text(capacityText, style: theme.textTheme.bodySmall),
                  if (mine != null) ...<Widget>[
                    const SizedBox(height: Brand.spaceXs),
                    Chip(
                      visualDensity: VisualDensity.compact,
                      label: Text(
                        mine.status == ClassBookingStatus.waitlisted
                            ? 'On the waitlist'
                            : 'You are booked',
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: Brand.spaceSm),
            if (mine != null)
              OutlinedButton(
                onPressed: busy ? null : () => _cancel(context, ref),
                child: Text(
                  mine.status == ClassBookingStatus.waitlisted
                      ? 'Leave'
                      : 'Cancel',
                ),
              )
            else
              FilledButton(
                onPressed: busy ? null : () => _book(context, ref),
                child: Text(session.isFull ? 'Join waitlist' : 'Book'),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _book(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final status = await ref.read(classBoardProvider.notifier).book(session);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            status == ClassBookingStatus.waitlisted
                ? 'Class is full. You are on the waitlist.'
                : 'Booked ${session.className}.',
          ),
        ),
      );
    } catch (error, stack) {
      if (context.mounted) {
        showErrorSnackBar(context, error, stackTrace: stack);
      }
    }
  }

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    final mine = board.liveBookingFor(session.id);
    if (mine == null) return;
    try {
      await ref.read(classBoardProvider.notifier).cancel(mine);
    } catch (error, stack) {
      if (context.mounted) {
        showErrorSnackBar(context, error, stackTrace: stack);
      }
    }
  }
}
