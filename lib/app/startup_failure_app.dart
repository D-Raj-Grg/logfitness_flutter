import 'package:flutter/material.dart';

import 'package:logfitness_flutter/app/theme.dart';

/// Shown when start-up throws before [LordOfGymsApp] can mount.
///
/// Without this, a throw in `main` leaves the iOS launch storyboard on
/// screen forever — the app looks frozen on the logo with nothing to
/// report. Build 8 shipped that way: it was built without the Supabase
/// `--dart-define`s, so `SupabaseConfig.assertConfigured` threw and every
/// App Store install hung on the splash. A visible message turns that
/// class of mistake into something a tester can read out loud.
class StartupFailureApp extends StatelessWidget {
  const StartupFailureApp({required this.error, super.key});

  /// The object thrown during start-up.
  final Object error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gym Tross',
      debugShowCheckedModeBanner: false,
      theme: appLightTheme,
      darkTheme: appDarkTheme,
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Gym Tross couldn't start",
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please update to the latest version, or contact support '
                    'with the message below.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SelectableText(
                    '$error',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
