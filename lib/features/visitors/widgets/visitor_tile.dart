// One row of the visitor log.
//
// Three lines, one job each, so the eye can skim down the left edge:
//   1. who, and when they came in
//   2. the number to ring (the identity anchor, PLANNING.md section 5)
//   3. where they stand: status mark, kind, and the note if there is one
// Call and text sit in their own right-hand column, each a 48dp target, so a
// desk working down the list never has to open a row to ring someone.
import 'package:flutter/material.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/data/visitors/visitor.dart';
import 'package:logfitness_flutter/domain/format/dates.dart';
import 'package:logfitness_flutter/features/visitors/widgets/visitor_labels.dart';
import 'package:logfitness_flutter/features/visitors/widgets/visitor_status_badge.dart';

/// What a row's overflow menu offers. Mirrors the console's visitor row menu
/// in `components/visitors/visitor-table.tsx`.
enum VisitorRowAction {
  /// One tap, no sheet: the gym's own wording, rendered in Postgres, sent as
  /// it stands.
  sendWelcome,

  /// The sheet, for anything that needs saying differently.
  sendMessage,
}

class VisitorTile extends StatelessWidget {
  const VisitorTile({
    required this.visitor,
    this.onTap,
    this.onCall,
    this.onRowAction,
    super.key,
  });

  final Visitor visitor;
  final VoidCallback? onTap;

  /// Dialling is the whole point of an open row, so it is one tap from the
  /// list rather than one tap from a detail screen.
  final ValueChanged<String>? onCall;

  /// The row's SMS menu. Null hides it -- the capability is checked by the
  /// caller, and the menu is never offered on a converted visitor because
  /// `send_visitor_notification` refuses one.
  final ValueChanged<VisitorRowAction>? onRowAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    final hasNote = visitor.note != null && visitor.note!.trim().isNotEmpty;
    final showCall = onCall != null && visitor.isOpen;
    final showSms = onRowAction != null && !visitor.isConverted;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Brand.spaceMd,
          Brand.spaceSm,
          Brand.spaceSm,
          Brand.spaceSm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
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
                          visitor.fullName,
                          style: theme.textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: Brand.spaceSm),
                      Text(
                        // `visited_on` is a calendar day, so it is formatted
                        // without a timezone shift -- see plain_date.dart.
                        formatPlainDate(visitor.visitedOn),
                        style: muted,
                        maxLines: 1,
                      ),
                    ],
                  ),
                  const SizedBox(height: Brand.spaceXs),
                  Text(
                    visitor.phone,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFeatures: const <FontFeature>[
                        FontFeature.tabularFigures(),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: Brand.spaceXs),
                  Row(
                    children: <Widget>[
                      VisitorStatusDot(visitor.status),
                      const SizedBox(width: Brand.spaceSm),
                      Flexible(
                        child: Text(
                          '${visitorStatusLabel(visitor.status)} · '
                          '${visitorKindLabel(visitor.kind)}',
                          style: muted,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (hasNote)
                    Padding(
                      padding: const EdgeInsets.only(top: Brand.spaceXs),
                      child: Text(
                        visitor.note!,
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            if (showCall)
              IconButton.filledTonal(
                onPressed: () => onCall!(visitor.phone),
                icon: const Icon(Icons.phone_outlined),
                tooltip: 'Call ${visitor.fullName}',
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              ),
            if (showSms)
              PopupMenuButton<VisitorRowAction>(
                key: ValueKey<String>('visitor-sms-${visitor.id}'),
                icon: const Icon(Icons.sms_outlined),
                iconSize: 24,
                tooltip: 'Text ${visitor.fullName}',
                constraints: const BoxConstraints(minWidth: 48),
                onSelected: onRowAction,
                itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<VisitorRowAction>>[
                  const PopupMenuItem<VisitorRowAction>(
                    value: VisitorRowAction.sendWelcome,
                    child: Text('Send welcome SMS'),
                  ),
                  const PopupMenuItem<VisitorRowAction>(
                    value: VisitorRowAction.sendMessage,
                    child: Text('Send message…'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
