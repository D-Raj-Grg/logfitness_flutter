import 'package:flutter/material.dart';

/// Root shell for the `member` role: plan status, dues, payment history,
/// QR check-in, class browsing and booking.
///
/// TODO(phase-3): build the member app inside this shell.
class MemberShell extends StatelessWidget {
  const MemberShell({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.primaryContainer,
      appBar: AppBar(
        backgroundColor: colorScheme.primaryContainer,
        title: const Text('Member'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fitness_center, size: 64, color: colorScheme.primary),
            const SizedBox(height: 16),
            const Text(
              'Member Shell',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
