// One row of the delivery log.
//
// A phone row is not the console's table with columns removed. The question
// being answered here is "was this person told, and if not why not", so the
// recipient leads, the status sits where the eye lands after it, and the body
// -- which is the thing that was actually said -- gets two lines rather than
// one. The reason, the channel and the time are secondary; the failure text is
// not, and is rendered in full when there is one.
import 'package:flutter/material.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/data/notifications/notification_message.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/format/dates.dart';
import 'package:logfitness_flutter/features/notifications/notification_labels.dart';
import 'package:logfitness_flutter/features/notifications/widgets/notification_status_badge.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    required this.message,
    this.senderName,
    this.trailing,
    this.onTap,
    super.key,
  });

  final NotificationMessage message;

  /// The staff member who pressed Send, when this was sent by hand. Resolved by
  /// the caller -- the log has the id, not the name.
  final String? senderName;

  /// The row's overflow menu, where the reader may act on it. Absent on the
  /// member profile's Messages tab, which is a history rather than a queue.
  final Widget? trailing;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    final String reason = notificationEventShort(message.event);
    final String channel = notificationChannelLabel(message.channel);
    final String when = formatDateTime(message.createdAt);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Brand.spaceMd,
          vertical: Brand.spaceSm + Brand.spaceXs,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    message.toAddress,
                    style: theme.textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: Brand.spaceXs),
                  Text(
                    message.body,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: Brand.spaceXs),
                  Text(
                    <String>[
                      reason,
                      channel,
                      when,
                      // Null `created_by` means a sweep raised it. Saying who
                      // pressed Send is half the point of the column.
                      if (senderName != null) 'by $senderName',
                    ].join(' · '),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  if (message.lastError != null) ...<Widget>[
                    const SizedBox(height: Brand.spaceXs),
                    Text(
                      message.lastError!,
                      // Not red for a skipped row: "no gateway on this channel"
                      // is an explanation, not an error, and the badge beside
                      // it already says which of the two this is.
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: message.status == NotificationStatus.failed
                            ? scheme.error
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (message.attempts > 1) ...<Widget>[
                    const SizedBox(height: Brand.spaceXs),
                    Text(
                      '${message.attempts} attempts',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: Brand.spaceSm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                NotificationStatusBadge(message.status),
                ?trailing,
              ],
            ),
          ],
        ),
      ),
    );
  }
}
