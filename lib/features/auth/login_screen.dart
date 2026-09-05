import 'package:flutter/material.dart';

/// Placeholder for email/password sign-in (staff and invited members).
///
/// TODO(phase-2): build the actual login form and wire it to
/// `supabase_flutter` auth.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: const Center(child: Text('Login')),
    );
  }
}
