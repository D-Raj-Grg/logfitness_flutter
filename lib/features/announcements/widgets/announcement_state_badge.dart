// The stage pill on an announcement row.
//
// The twin of `notification_status_badge.dart`, and it borrows that file's
// colour vocabulary on purpose so that "sent" means the same shade on both tabs
// of the Messages screen. Colour comes from the theme's semantic roles rather
// than being picked -- see `theme.dart`.
//
// It renders `state`, never `status`: what is true now, not what was asked for.
import 'package:flutter/material.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/data/announcements/announcement_overview.dart';
import 'package:logfitness_flutter/features/announcements/announcement_labels.dart';

class AnnouncementStateBadge extends StatelessWidget {
  const AnnouncementStateBadge(this.state, {super.key});

  final AnnouncementState state;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    final (Color background, Color foreground, Color? border) =
        switch (state) {
          // Everything that was going to go out has gone. The good end, and
          // quiet: this list is read to find what is still moving.
          AnnouncementState.sent => (
            scheme.secondaryContainer,
            scheme.onSecondaryContainer,
            null,
          ),
          // Leaving the outbox right now, a minute at a time.
          AnnouncementState.sending => (
            scheme.primaryContainer,
            scheme.onPrimaryContainer,
            null,
          ),
          // Written, dated forward, and not going anywhere yet.
          AnnouncementState.scheduled => (
            Colors.transparent,
            scheme.onSurfaceVariant,
            scheme.outline,
          ),
          // Stopped, and deliberately **not** an error colour. Nothing went
          // wrong: somebody changed their mind in time, which is the feature
          // working.
          AnnouncementState.cancelled => (
            scheme.surfaceContainerHighest,
            scheme.onSurfaceVariant,
            null,
          ),
        };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Brand.spaceSm,
        vertical: Brand.spaceXs / 2,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(Brand.radiusMedium),
        border: border == null ? null : Border.all(color: border),
      ),
      child: Text(
        announcementStateLabel(state),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
