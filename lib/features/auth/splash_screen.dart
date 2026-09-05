import 'package:flutter/material.dart';

/// Shown briefly while the router's redirect decides the initial
/// destination. Holds no logic of its own — see `lib/app/router.dart`.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Splash'),
            SizedBox(height: 16),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
