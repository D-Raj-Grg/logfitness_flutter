// The status pill on a visitor row.
//
// Colour carries meaning here, so it is taken from the theme's semantic roles
// rather than picked: an open callback should draw the eye at a glance down a
// list, and a closed one should not. Nothing is hardcoded — see Brand and
// theme.dart.
import 'package:flutter/material.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/features/visitors/widgets/visitor_labels.dart';

class VisitorStatusBadge extends StatelessWidget {
  const VisitorStatusBadge(this.status, {super.key});

  final VisitorStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // `new` is the work that has not been touched, so it gets the primary
    // role. `contacted` is in progress: outlined, present but quieter.
    // `converted` and `lost` are both finished, and a finished row should
    // recede whether or not it ended well — the log is read to find what is
    // still open.
    final (Color background, Color foreground, Color? border) =
        switch (status) {
      VisitorStatus.isNew => (
          scheme.primaryContainer,
          scheme.onPrimaryContainer,
          null,
        ),
      VisitorStatus.contacted => (
          Colors.transparent,
          scheme.onSurfaceVariant,
          scheme.outline,
        ),
      VisitorStatus.converted => (
          scheme.secondaryContainer,
          scheme.onSecondaryContainer,
          null,
        ),
      VisitorStatus.lost => (
          scheme.surfaceContainerHighest,
          scheme.onSurfaceVariant,
          null,
        ),
    };

    final label = visitorStatusLabel(status);

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

/// The round status mark used where a full pill would crowd a row: a dot in
/// the status colour, read by screen readers as the same label as the badge.
class VisitorStatusDot extends StatelessWidget {
  const VisitorStatusDot(this.status, {this.size = 10, super.key});

  final VisitorStatus status;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Open work is loud, finished work recedes -- same rule as the badge.
    final (Color fill, Color? ring) = switch (status) {
      VisitorStatus.isNew => (scheme.primary, null),
      VisitorStatus.contacted => (Colors.transparent, scheme.primary),
      VisitorStatus.converted => (scheme.tertiary, null),
      VisitorStatus.lost => (scheme.outlineVariant, null),
    };
    return Semantics(
      label: 'Status: ${visitorStatusLabel(status)}',
      child: ExcludeSemantics(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: fill,
            border: ring == null ? null : Border.all(color: ring, width: 2),
          ),
        ),
      ),
    );
  }
}
