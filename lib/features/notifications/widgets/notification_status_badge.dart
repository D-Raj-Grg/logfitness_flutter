// The status pill on a message row.
//
// Colour carries meaning, so it comes from the theme's semantic roles rather
// than being picked -- see `visitor_status_badge.dart`, whose shape this
// follows, and `theme.dart`.
//
// The load-bearing decision is at the bottom of the switch: **`skipped` and
// `cancelled` are not failures.** `skipped` means the gym deliberately did not
// send -- no gateway, no token, an opted-out member, a number that cannot be
// delivered to -- and painting it red sends an owner hunting a gateway problem
// that does not exist. The console makes the same call, in the same words.
import 'package:flutter/material.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/features/notifications/notification_labels.dart';

class NotificationStatusBadge extends StatelessWidget {
  const NotificationStatusBadge(this.status, {super.key});

  final NotificationStatus status;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    final (Color background, Color foreground, Color? border) = switch (status) {
      // Arrived at the gateway. The good end, and quiet: a log is read to find
      // what did *not* work.
      NotificationStatus.sent => (
        scheme.secondaryContainer,
        scheme.onSecondaryContainer,
        null,
      ),
      // In flight right now. The one state that changes while you watch.
      NotificationStatus.sending => (
        scheme.primaryContainer,
        scheme.onPrimaryContainer,
        null,
      ),
      // Waiting for the outbox to claim it.
      NotificationStatus.queued => (
        Colors.transparent,
        scheme.onSurfaceVariant,
        scheme.outline,
      ),
      // The only state that is actually wrong.
      NotificationStatus.failed => (
        scheme.errorContainer,
        scheme.onErrorContainer,
        null,
      ),
      // Neither of these is a failure; both recede.
      NotificationStatus.skipped ||
      NotificationStatus.cancelled => (
        scheme.surfaceContainerHighest,
        scheme.onSurfaceVariant,
        null,
      ),
    };

    final String label = notificationStatusShort(status);

    return Semantics(
      label: 'Status: $label',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Brand.spaceSm,
          vertical: Brand.spaceXs,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(Brand.radiusSmall),
          border: border == null ? null : Border.all(color: border),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: foreground,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
