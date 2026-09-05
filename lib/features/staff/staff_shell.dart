import 'package:flutter/material.dart';

import 'package:logfitness_flutter/features/members/member_lookup_panel.dart';

/// Root shell for staff roles (`front_desk`, `trainer`, `manager`,
/// `owner`): counter operations — scan check-in, collect payment, walk-in
/// signup, renewals, today's collection.
///
/// TODO(phase-4): build the staff front-desk app inside this shell.
class StaffShell extends StatelessWidget {
  const StaffShell({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(title: const Text('Staff')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: <Widget>[
          Icon(Icons.point_of_sale, size: 64, color: colorScheme.secondary),
          const SizedBox(height: 16),
          const Text(
            'Staff Shell',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          // Phase 1 proof of the widget -> controller -> repository -> supabase
          // chain. Phase 5 replaces it with the real member search.
          const MemberLookupPanel(),
        ],
      ),
    );
  }
}
