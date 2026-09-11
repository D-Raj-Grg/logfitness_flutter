import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/app/theme_mode_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  group('stored value', () {
    test('the wire names are stable, because they are on real devices', () {
      // Renaming one of these silently resets everybody's choice on upgrade.
      expect(themeModeName(ThemeMode.system), 'system');
      expect(themeModeName(ThemeMode.light), 'light');
      expect(themeModeName(ThemeMode.dark), 'dark');
    });

    test('round-trips every mode', () {
      for (final ThemeMode m in ThemeMode.values) {
        expect(themeModeFromName(themeModeName(m)), m);
      }
    });

    test('nothing stored means light, and so does nonsense', () {
      expect(themeModeFromName(null), ThemeMode.light);
      // A newer build writing a value this one does not know is a downgrade,
      // not corruption: fall back, do not throw.
      expect(themeModeFromName('midnight'), ThemeMode.light);
    });
  });

  group('loadThemeMode', () {
    test('defaults to light on a fresh install', () async {
      expect(await loadThemeMode(), ThemeMode.light);
    });

    test('returns what was stored', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'theme_mode': 'dark',
      });
      expect(await loadThemeMode(), ThemeMode.dark);
    });
  });

  group('ThemeModeController', () {
    test('starts from the value read before the first frame', () {
      final container = ProviderContainer(
        overrides: [themeModeStartupProvider.overrideWithValue(ThemeMode.dark)],
      );
      addTearDown(container.dispose);
      expect(container.read(themeModeProvider), ThemeMode.dark);
    });

    test('switching applies immediately and persists', () async {
      final container = ProviderContainer(
        overrides: [
          themeModeStartupProvider.overrideWithValue(ThemeMode.light),
        ],
      );
      addTearDown(container.dispose);

      await container.read(themeModeProvider.notifier).set(ThemeMode.dark);

      expect(container.read(themeModeProvider), ThemeMode.dark);
      // And survives the next launch.
      expect(await loadThemeMode(), ThemeMode.dark);
    });
  });
}
