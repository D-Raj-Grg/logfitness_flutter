import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/app/router.dart';
import 'package:logfitness_flutter/app/theme.dart';
import 'package:logfitness_flutter/app/theme_mode_controller.dart';

/// Root widget: wires the two Material 3 themes and the [goRouterProvider]
/// into a single [MaterialApp.router].
class LordOfGymsApp extends ConsumerWidget {
  const LordOfGymsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Gym Tross',
      debugShowCheckedModeBanner: false,
      theme: appLightTheme,
      darkTheme: appDarkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
