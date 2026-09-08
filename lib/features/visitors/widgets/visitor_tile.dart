// One row of the visitor log.
//
// A phone row is not a table row with the columns removed. The console shows
// name, phone, kind, date, plan and status side by side because it has the
// width; here the question the desk is answering is "who do I still owe a
// call, and what is their number", so the name and the phone lead, the status
// sits where the eye lands after them, and everything else is secondary.
//
// The phone number is the identity anchor in this product (PLANNING.md §5),
// which is why it is rendered at body size rather than as fine print: it is
// the thing being read aloud while dialling.
import 'package:flutter/material.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/data/visitors/visitor.dart';
import 'package:logfitness_flutter/domain/format/dates.dart';
import 'package:logfitness_flutter/features/visitors/widgets/visitor_labels.dart';
import 'package:logfitness_flutter/features/visitors/widgets/visitor_status_badge.dart';

class VisitorTile extends StatelessWidget {
  const VisitorTile({
    required this.visitor,
    this.onTap,
    this.onCall,
    super.key,
  });

  final Visitor visitor;
  final VoidCallback? onTap;

  /// Dialling is the whole point of an open row, so it is one tap from the
  /// list rather than one tap from a detail screen.
  final ValueChanged<String>? onCall;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                    visitor.fullName,
                    style: theme.textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: Brand.spaceXs),
                  Text(
                    visitor.phone,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: Brand.spaceXs),
                  Text(
                    // `visited_on` is a calendar day, so it is formatted
                    // without a timezone shift -- see plain_date.dart.
                    '${visitorKindLabel(visitor.kind)} · '
                    '${formatPlainDate(visitor.visitedOn)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (visitor.note != null && visitor.note!.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: Brand.spaceXs),
                      child: Text(
                        visitor.note!,
                        style: theme.textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: Brand.spaceSm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                VisitorStatusBadge(visitor.status),
                if (onCall != null && visitor.isOpen)
                  Padding(
                    padding: const EdgeInsets.only(top: Brand.spaceXs),
                    child: IconButton(
                      onPressed: () => onCall!(visitor.phone),
                      icon: const Icon(Icons.phone_outlined),
                      tooltip: 'Call ${visitor.fullName}',
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
