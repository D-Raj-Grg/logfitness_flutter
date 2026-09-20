import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/startup_failure_app.dart';
import 'app/theme_mode_controller.dart';
import 'supabase/supabase_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Anything thrown before runApp leaves the native launch screen up for
  // good, so a misconfigured build reads as a frozen logo rather than as a
  // fault. Catch it and put the reason on screen instead.
  try {
    await initSupabase();

    // Read before the first frame. Loading the theme lazily would show
    // someone who chose dark a light frame first, every launch.
    final themeMode = await loadThemeMode();

    runApp(
      ProviderScope(
        overrides: [themeModeStartupProvider.overrideWithValue(themeMode)],
        child: const LordOfGymsApp(),
      ),
    );
  } catch (error, stackTrace) {
    debugPrint('Start-up failed: $error\n$stackTrace');
    runApp(StartupFailureApp(error: error));
  }
}
