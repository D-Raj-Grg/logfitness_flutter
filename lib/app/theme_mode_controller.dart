// Which theme the app is in, and remembering it.
//
// Default is **light**. The app was built dark-first and looked it, but a gym's
// front desk is usually a bright room with a window, and the counter phone is
// held at arm's length under overhead light — the condition dark mode is worst
// in. Someone who prefers dark can still say so, and the choice sticks.
//
// Stored in `shared_preferences` rather than `flutter_secure_storage`: a
// display preference is not a credential, and putting it in the keychain would
// blur where secrets live.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _prefsKey = 'theme_mode';

/// The value read from disk before the first frame, so a person who chose dark
/// never sees a light frame first. `main()` overrides this with what was
/// actually stored; see `main.dart`.
///
/// Defaults rather than throwing. Throwing here would be a louder signal that
/// the override was forgotten, but the cost lands in the wrong place: every
/// widget test that mounts the staff shell reaches Settings, and would have to
/// override a provider it does not care about. The default is the app's own
/// default, so an un-overridden read is correct rather than merely tolerated.
final themeModeStartupProvider = Provider<ThemeMode>((ref) => ThemeMode.light);

/// Reads the stored choice. Returns the default when nothing is stored yet, or
/// when the store is unreadable — a preference that cannot be loaded is not a
/// reason to fail to start.
Future<ThemeMode> loadThemeMode() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    return themeModeFromName(prefs.getString(_prefsKey));
  } catch (_) {
    return ThemeMode.light;
  }
}

/// The wire form, kept stable: these strings are on disk on real devices, so
/// renaming one silently resets everybody's choice.
String themeModeName(ThemeMode mode) => switch (mode) {
      ThemeMode.system => 'system',
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
    };

ThemeMode themeModeFromName(String? name) => switch (name) {
      'system' => ThemeMode.system,
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      // Unknown or absent: the default, not a crash. An old build writing a
      // value this one does not know is a downgrade, not corruption.
      _ => ThemeMode.light,
    };

class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ref.watch(themeModeStartupProvider);

  Future<void> set(ThemeMode mode) async {
    // Switch first, persist second. The screen should not wait on a disk write
    // to change colour, and a failed write costs the preference next launch
    // rather than the interaction now.
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, themeModeName(mode));
    } catch (_) {
      // Nothing useful to say to a person about a preferences write.
    }
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);
