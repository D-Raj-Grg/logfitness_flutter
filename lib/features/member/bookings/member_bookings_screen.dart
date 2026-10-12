// The member's own bookings: booked, waitlisted and cancelled, with cancel.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/data/classes/class_board_notifier.dart';
import 'package:logfitness_flutter/data/classes/class_booking.dart';
import 'package:logfitness_flutter/domain/classes/class_booking_status.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/features/common/failure_snackbar.dart';
import 'package:logfitness_flutter/features/common/failure_view.dart';

class MemberBookingsScreen extends ConsumerWidget {
  const MemberBookingsScreen({super.key});

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
          data: (data) {
            final now = DateTime.now();
            final bookings = [...data.bookings]
              ..sort((a, b) {
                // Live and upcoming first (soonest first), then the rest by
                // most recent class.
                final aUp = a.status.isLive && a.startsAt.isAfter(now);
                final bUp = b.status.isLive && b.startsAt.isAfter(now);
                if (aUp != bUp) return aUp ? -1 : 1;
                return aUp
                    ? a.startsAt.compareTo(b.startsAt)
                    : b.startsAt.compareTo(a.startsAt);
              });
            return RefreshIndicator(
              onRefresh: notifier.refresh,
              child: bookings.isEmpty
                  ? ListView(
                      children: const <Widget>[
                        SizedBox(height: 120),
                        Center(child: Text('You have no class bookings yet.')),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(Brand.spaceMd),
                      itemCount: bookings.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: Brand.spaceSm),
                      itemBuilder: (context, i) => _BookingTile(
                        booking: bookings[i],
                        busy: data.busy.contains(bookings[i].id),
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }
}

class _BookingTile extends ConsumerWidget {
  const _BookingTile({required this.booking, required this.busy});

  final ClassBooking booking;
  final bool busy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final upcoming = booking.startsAt.isAfter(DateTime.now());
    final canCancel =
        booking.status.isLive && upcoming && !booking.sessionCancelled;
    final when =
        '${DateFormat('EEE d MMM').format(booking.startsAt)} · '
        '${DateFormat('h:mm a').format(booking.startsAt)}';
    final dim = booking.status == ClassBookingStatus.cancelled;

    return Card(
      child: Opacity(
        opacity: dim ? 0.6 : 1,
        child: ListTile(
          title: Text(booking.className),
          subtitle: Text(
            [
              when,
              if (booking.room != null && booking.room!.isNotEmpty)
                booking.room!,
              if (booking.sessionCancelled) 'Class cancelled',
            ].join(' · '),
          ),
          leading: Chip(
            visualDensity: VisualDensity.compact,
            label: Text(booking.status.label),
          ),
          trailing: canCancel
              ? TextButton(
                  onPressed: busy ? null : () => _cancel(context, ref),
                  child: Text(
                    booking.status == ClassBookingStatus.waitlisted
                        ? 'Leave'
                        : 'Cancel',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(classBoardProvider.notifier).cancel(booking);
    } catch (error, stack) {
      if (context.mounted) {
        showErrorSnackBar(context, error, stackTrace: stack);
      }
    }
  }
}
