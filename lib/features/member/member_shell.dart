import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/data/auth/auth_repository.dart';
import 'package:logfitness_flutter/data/auth/current_member.dart';
import 'package:logfitness_flutter/features/auth/auth_controller.dart';

/// Fetches the current member principal's display row directly, for the
/// one case [Principal.member] does not already carry it: claims identify
/// a member principal by id only, not by name. [Principal.memberPendingRefresh]
/// already carries a [CurrentMember] row and does not need this.
final _memberDisplayProvider = FutureProvider.autoDispose<CurrentMember?>((
  ref,
) {
  return ref.watch(authRepositoryProvider).currentMember();
});

/// Root shell for the `member` role: plan status, dues, payment history,
/// QR check-in, class browsing and booking.
///
/// TODO(phase-3): build the member app inside this shell.
class MemberShell extends ConsumerWidget {
  const MemberShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final principalAsync = ref.watch(principalProvider);

    return Scaffold(
      backgroundColor: colorScheme.primaryContainer,
      appBar: AppBar(
        backgroundColor: colorScheme.primaryContainer,
        title: const Text('Member'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(Brand.spaceLg),
        children: <Widget>[
          _MemberChrome(principalAsync: principalAsync),
          const SizedBox(height: Brand.spaceXl),
          Text(
            'TODO(phase-3): plan status, dues, payment history, QR '
            'check-in, class browsing and booking go here.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// The signed-in chrome: org name and the member's name.
class _MemberChrome extends ConsumerWidget {
  const _MemberChrome({required this.principalAsync});

  final AsyncValue<Principal> principalAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return principalAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Text('Could not load session: $error'),
      data: (principal) {
        return switch (principal) {
          PrincipalMemberPendingRefresh(:final member) => _MemberCard(
            orgName: member.orgName,
            fullName: member.fullName,
            refreshing: true,
          ),
          PrincipalMember(:final claims) => Consumer(
            builder: (context, ref, _) {
              final display = ref.watch(_memberDisplayProvider);
              return display.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, _) => _MemberCard(
                  orgName: claims.orgId,
                  fullName: claims.memberId ?? '',
                  refreshing: false,
                ),
                data: (member) => _MemberCard(
                  orgName: member?.orgName ?? claims.orgId,
                  fullName: member?.fullName ?? claims.memberId ?? '',
                  refreshing: false,
                ),
              );
            },
          ),
          // Any other principal state means the router misrouted; render
          // nothing rather than guessing at a name.
          _ => Icon(Icons.fitness_center, size: 64, color: colorScheme.primary),
        };
      },
    );
  }
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({
    required this.orgName,
    required this.fullName,
    required this.refreshing,
  });

  final String orgName;
  final String fullName;
  final bool refreshing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Brand.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(orgName, style: textTheme.titleMedium),
            const SizedBox(height: Brand.spaceXs),
            Text(fullName, style: textTheme.titleLarge),
            if (refreshing) ...[
              const SizedBox(height: Brand.spaceSm),
              Text('Refreshing session…', style: textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}
