// The signed-in person's own settings.
//
// Deliberately not org administration — branches, staff, plans and notification
// gateways stay on the web console (CLAUDE.md, "Scope discipline"). What
// belongs here is what this person, on this phone, can change about their own
// use of the app.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/app/theme_mode_controller.dart';

/// What each mode is called on screen. "System" rather than "Automatic",
/// because it follows the phone's setting and saying so is shorter than
/// explaining it.
String themeModeLabel(ThemeMode mode) => switch (mode) {
      ThemeMode.system => 'System',
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
    };

IconData themeModeIcon(ThemeMode mode) => switch (mode) {
      ThemeMode.system => Icons.brightness_auto_outlined,
      ThemeMode.light => Icons.light_mode_outlined,
      ThemeMode.dark => Icons.dark_mode_outlined,
    };

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(Brand.spaceMd),
      children: <Widget>[
        Text('Appearance', style: theme.textTheme.titleSmall),
        const SizedBox(height: Brand.spaceSm),
        SegmentedButton<ThemeMode>(
          key: const ValueKey<String>('theme-mode-selector'),
          segments: <ButtonSegment<ThemeMode>>[
            for (final ThemeMode m in ThemeMode.values)
              ButtonSegment<ThemeMode>(
                value: m,
                icon: Icon(themeModeIcon(m)),
                label: Text(themeModeLabel(m)),
              ),
          ],
          selected: <ThemeMode>{mode},
          // Applies immediately and is written afterwards, so the screen never
          // waits on a disk write to change colour.
          onSelectionChanged: (Set<ThemeMode> next) =>
              ref.read(themeModeProvider.notifier).set(next.first),
        ),
        const SizedBox(height: Brand.spaceSm),
        Text(
          mode == ThemeMode.system
              ? "Follows this phone's setting."
              : 'Stays ${themeModeLabel(mode).toLowerCase()} whatever the phone is set to.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
