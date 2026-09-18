// One announcement, as a row.
//
// Mirrors a row of `components/announcements/announcements-table.tsx`, folded
// from a six-column table into something a thumb can read: the title leads, the
// message follows it in one dimmed line, and the counts sit under the badge
// because "did it arrive" is the question this list exists to answer.
import 'package:flutter/material.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/data/announcements/announcement_overview.dart';
import 'package:logfitness_flutter/domain/format/dates.dart';
import 'package:logfitness_flutter/features/announcements/announcement_labels.dart';
import 'package:logfitness_flutter/features/announcements/widgets/announcement_state_badge.dart';

class AnnouncementTile extends StatelessWidget {
  const AnnouncementTile({
    required this.row,
    this.onCancel,
    super.key,
  });

  final AnnouncementOverview row;

  /// Null hides the Stop entry: either there is nothing left to stop, or this
  /// staff member may not stop it. The database refuses either way -- the menu
  /// is a courtesy, not the boundary.
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Brand.spaceMd,
        Brand.spaceSm,
        Brand.spaceSm,
        Brand.spaceSm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        row.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                    const SizedBox(width: Brand.spaceSm),
                    AnnouncementStateBadge(row.state),
                  ],
                ),
                const SizedBox(height: Brand.spaceXs),
                Text(
                  row.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: Brand.spaceXs),
                Text(
                  announcementDeliveryLine(row),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: Brand.spaceXs / 2),
                Text(
                  _subtitle(row),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (onCancel != null)
            IconButton(
              key: ValueKey<String>('announcement-stop-${row.id}'),
              icon: const Icon(Icons.stop_circle_outlined),
              tooltip: 'Stop the rest',
              onPressed: onCancel,
            ),
        ],
      ),
    );
  }

  /// Who it went to, from where, and when — or when it is *going* to, which is
  /// the more useful fact about one that has not left yet.
  static String _subtitle(AnnouncementOverview row) {
    final String audience = announcementAudienceShort(row.audience);
    final String branch = row.branchName ?? 'Every branch';
    final String when = row.state == AnnouncementState.scheduled
        ? 'Goes out ${formatDateTime(row.scheduledFor)}'
        : formatDateTime(row.createdAt);
    final String who = row.createdByName == null
        ? ''
        : ' · ${row.createdByName}';
    return '$audience · $branch · $when$who';
  }
}
