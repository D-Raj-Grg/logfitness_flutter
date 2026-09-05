import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'theme.dart';

/// Root widget: wires the two Material 3 themes and the [goRouterProvider]
/// into a single [MaterialApp.router].
class LordOfGymsApp extends ConsumerWidget {
  const LordOfGymsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'Lord of Gyms',
      debugShowCheckedModeBanner: false,
      theme: appLightTheme,
      darkTheme: appDarkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
