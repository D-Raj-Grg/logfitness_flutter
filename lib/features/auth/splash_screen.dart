import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/features/auth/auth_controller.dart';

/// How long [principalProvider] is allowed to resolve before this screen
/// shows a spinner. A cold start that resolves faster than this (session
/// already cached, no claims round trip needed) never shows a spinner at
/// all -- it just blinks past this screen, which is the point: a
/// spinner-flash on every launch reads as janky, not as "working".
const _spinnerDelay = Duration(milliseconds: 400);

/// Shown while [principalProvider] is resolving on a cold start, before the
/// router's redirect has anywhere to send the session. Holds no navigation
/// logic of its own -- see `lib/app/router.dart`.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _showSpinner = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(_spinnerDelay, () {
      if (mounted) setState(() => _showSpinner = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watching principalProvider here (rather than just letting the router
    // resolve it) is what makes this screen rebuild the instant resolution
    // finishes, instead of waiting for the next timer tick.
    final principal = ref.watch(principalProvider);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Lord of Gyms',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (_showSpinner && principal.isLoading) ...[
              const SizedBox(height: Brand.spaceLg),
              const CircularProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }
}
