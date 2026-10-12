import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/data/auth/current_member.dart';
import 'package:logfitness_flutter/features/auth/auth_controller.dart';
import 'package:logfitness_flutter/features/common/async_value_view.dart';
import 'package:logfitness_flutter/features/member/home/member_providers.dart';
import 'package:logfitness_flutter/features/member/messages/member_messages_screen.dart';

/// Read-only profile (v1) plus messages entry and sign out.
class MemberProfileScreen extends ConsumerWidget {
  const MemberProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(memberSelfProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(Brand.spaceMd),
        children: <Widget>[
          AsyncValueView<CurrentMember>(
            value: async,
            onRetry: () => ref.invalidate(memberSelfProvider),
            data: (m) => Card(
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: Text(m.fullName),
                    subtitle: Text('Member ${m.memberCode}'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.phone_outlined),
                    title: Text(m.phone),
                  ),
                  ListTile(
                    leading: const Icon(Icons.store_outlined),
                    title: Text(m.homeBranchName),
                    subtitle: Text(m.orgName),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Brand.spaceMd),
          Card(
            child: ListTile(
              leading: const Icon(Icons.mail_outline),
              title: const Text('Messages'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const MemberMessagesScreen(),
                ),
              ),
            ),
          ),
          const SizedBox(height: Brand.spaceMd),
          OutlinedButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
    );
  }
}
