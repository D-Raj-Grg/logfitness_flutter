// The one primary action on a list screen, docked rather than floating.
//
// A floating button is Material's default and it was the wrong default here.
// These lists carry a status badge, an amount owed and an expiry date down
// their right-hand edge, and an extended FAB sits on exactly that column for
// whatever row happens to be beneath it. Bottom padding only rescues the last
// row at full scroll; everywhere else the button covers the half of the row a
// desk actually reads.
//
// Docking it costs a strip of list height permanently and occludes nothing,
// which is the better trade when the occluded thing is how much a member owes.
// It also keeps the label — the design context calls this audience "not
// tech-sophisticated", and a naked `+` asks them to guess.
//
// Renders as the screen's `bottomNavigationBar`, so the list lays out above it
// and needs no padding of its own. Inside the staff shell that puts it
// directly above the navigation bar.
import 'package:flutter/material.dart';

import 'package:logfitness_flutter/app/brand.dart';

class DockedAction extends StatelessWidget {
  const DockedAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    super.key,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      // Sits on the surface rather than over it, so the boundary between list
      // and action is a real edge instead of a shadow.
      color: theme.colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Brand.spaceMd,
            Brand.spaceSm,
            Brand.spaceMd,
            Brand.spaceSm,
          ),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onPressed,
              icon: Icon(icon),
              label: Text(label),
              style: FilledButton.styleFrom(
                // Tall enough to hit without looking, which is the point at a
                // counter with someone waiting.
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
