// One row of the delivery log.
//
// A phone row is not the console's table with columns removed. The question
// being answered here is "was this person told, and if not why not", so the
// recipient leads, the status sits where the eye lands after it, and the body
// -- which is the thing that was actually said -- gets two lines rather than
// one.
//
// Three lines, each with one job, so the eye can skim down the left edge:
//   1. who it was for, and when
//   2. what was said
//   3. why it was sent, over which channel, and how it ended up
// The failure text is not secondary and is not buried in the grey: it gets its
// own tinted block, but only for a row that actually failed. A skipped row's
// explanation stays quiet, because "no gateway on this channel" is not an error.
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
    final bool failed = message.status == NotificationStatus.failed;

    final String reason = notificationEventShort(message.event);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Brand.spaceMd,
          Brand.spaceSm + Brand.spaceXs,
          Brand.spaceSm,
          Brand.spaceSm + Brand.spaceXs,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _StatusMark(status: message.status),
            const SizedBox(width: Brand.spaceMd - Brand.spaceXs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          message.toAddress,
                          style: theme.textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: Brand.spaceSm),
                      Text(
                        _sentAt(message.createdAt),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
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
                  if (message.lastError != null) ...<Widget>[
                    const SizedBox(height: Brand.spaceSm),
                    _Reason(text: message.lastError!, isError: failed),
                  ],
                  const SizedBox(height: Brand.spaceSm),
                  Row(
                    children: <Widget>[
                      Icon(
                        _channelIcon(message.channel),
                        size: 14,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: Brand.spaceXs),
                      Flexible(
                        child: Text(
                          <String>[
                            // The word as well as the icon: Viber's and
                            // SMS's glyphs are not distinguishable at 14px.
                            notificationChannelLabel(message.channel),
                            reason,
                            // Null `created_by` means a sweep raised it. Saying
                            // who pressed Send is half the point of the column.
                            if (senderName != null) 'by $senderName',
                            if (message.attempts > 1)
                              '${message.attempts} attempts',
                          ].join(' · '),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: Brand.spaceSm),
                      NotificationStatusBadge(message.status),
                    ],
                  ),
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }

  static IconData _channelIcon(NotificationChannel channel) =>
      switch (channel) {
        NotificationChannel.sms => Icons.sms_outlined,
        NotificationChannel.viber => Icons.chat_bubble_outline,
        NotificationChannel.email => Icons.mail_outline,
      };

  /// "Today, 14:05", "Yesterday, 09:30", or "05 Oct, 14:05". The year only
  /// appears once the message is old enough for it to matter.
  static String _sentAt(Object createdAt) {
    final DateTime now = DateTime.now().toUtc();
    final String day = formatDate(createdAt);
    final String time = formatTime(createdAt);
    if (day == formatDate(now)) return 'Today, $time';
    if (day == formatDate(now.subtract(const Duration(days: 1)))) {
      return 'Yesterday, $time';
    }
    // "05 Oct 2026" -> "05 Oct" when it is this year.
    final List<String> parts = day.split(' ');
    final bool thisYear =
        parts.length == 3 && parts[2] == formatDate(now).split(' ').last;
    return '${thisYear ? '${parts[0]} ${parts[1]}' : day}, $time';
  }
}

/// The round marker at the start of a row: the outcome as a shape, so a long
/// log can be skimmed for the one that is red before any word is read.
class _StatusMark extends StatelessWidget {
  const _StatusMark({required this.status});

  final NotificationStatus status;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    final (
      IconData icon,
      Color background,
      Color foreground,
    ) = switch (status) {
      NotificationStatus.sent => (
        Icons.check_rounded,
        scheme.secondaryContainer,
        scheme.onSecondaryContainer,
      ),
      NotificationStatus.sending => (
        Icons.north_east_rounded,
        scheme.primaryContainer,
        scheme.onPrimaryContainer,
      ),
      NotificationStatus.queued => (
        Icons.schedule_rounded,
        scheme.surfaceContainerHighest,
        scheme.onSurfaceVariant,
      ),
      NotificationStatus.failed => (
        Icons.priority_high_rounded,
        scheme.errorContainer,
        scheme.onErrorContainer,
      ),
      NotificationStatus.skipped => (
        Icons.remove_rounded,
        scheme.surfaceContainerHighest,
        scheme.onSurfaceVariant,
      ),
      NotificationStatus.cancelled => (
        Icons.close_rounded,
        scheme.surfaceContainerHighest,
        scheme.onSurfaceVariant,
      ),
    };

    // Decorative: the badge on the same row carries the word, and a screen
    // reader should not hear the outcome twice.
    return ExcludeSemantics(
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: Icon(icon, size: 20, color: foreground),
      ),
    );
  }
}

/// The explanation under a row that did not go out, in a block of its own so it
/// is not read as part of the message. Red only for `failed`.
class _Reason extends StatelessWidget {
  const _Reason({required this.text, required this.isError});

  final String text;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: Brand.spaceSm + Brand.spaceXs,
        vertical: Brand.spaceSm,
      ),
      decoration: BoxDecoration(
        color: isError
            ? scheme.errorContainer.withValues(alpha: 0.5)
            : scheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(Brand.radiusSmall),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: isError ? scheme.onErrorContainer : scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
