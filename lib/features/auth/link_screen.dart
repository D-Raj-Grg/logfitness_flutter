import 'package:flutter/material.dart';

/// Shown when a session is authenticated but carries no claims yet — the
/// principal row (member or staff) has not been linked to this auth user.
/// A normal, stable state, not an error.
///
/// TODO(phase-2): build the invite-accept / link flow and trigger a claims
/// refresh once linking completes.
class LinkScreen extends StatelessWidget {
  const LinkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Link account')),
      body: const Center(child: Text('Link')),
    );
  }
}
