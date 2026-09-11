import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/theme_mode_controller.dart';
import 'supabase/supabase_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSupabase();

  // Read before the first frame. Loading the theme lazily would show someone
  // who chose dark a light frame first, every launch.
  final themeMode = await loadThemeMode();

  runApp(
    ProviderScope(
      overrides: [themeModeStartupProvider.overrideWithValue(themeMode)],
      child: const LordOfGymsApp(),
    ),
  );
}
