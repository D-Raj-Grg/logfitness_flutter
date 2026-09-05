import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/data/auth/auth_repository.dart';
import 'package:logfitness_flutter/data/auth/current_staff.dart';
import 'package:logfitness_flutter/features/auth/auth_controller.dart';
import 'package:logfitness_flutter/features/members/member_lookup_panel.dart';

/// Fetches the current staff principal's display row directly, for the one
/// case [Principal.staff] does not already carry it: claims identify a
/// staff principal by id only (`org_id`, `staff_id`, `staff_role`), not by
/// name. [Principal.staffPendingRefresh] already carries a [CurrentStaff]
/// row and does not need this.
final _staffDisplayProvider = FutureProvider.autoDispose<CurrentStaff?>((
  ref,
) {
  return ref.watch(authRepositoryProvider).currentStaff();
});

/// Root shell for staff roles (`front_desk`, `trainer`, `manager`,
/// `owner`): counter operations — scan check-in, collect payment, walk-in
/// signup, renewals, today's collection.
///
/// TODO(phase-4): build the staff front-desk app inside this shell.
class StaffShell extends ConsumerWidget {
  const StaffShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final principalAsync = ref.watch(principalProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Staff'),
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
          _StaffChrome(principalAsync: principalAsync),
          const SizedBox(height: Brand.spaceXl),
          // Phase 1 proof of the widget -> controller -> repository ->
          // supabase chain. Phase 5 replaces it with the real member
          // search.
          const MemberLookupPanel(),
          const SizedBox(height: Brand.spaceLg),
          Text(
            'TODO(phase-4): front desk (scan check-in, payment, walk-in '
            'signup, renewals, today\'s collection) goes here.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// The signed-in chrome: org name, the person's name, and the role they are
/// currently logged in as. Showing the role here is a UX convenience for the
/// counter staff, per PLANNING.md §4 — it is not an access-control check;
/// RLS is what actually gates what this session can read or write.
class _StaffChrome extends ConsumerWidget {
  const _StaffChrome({required this.principalAsync});

  final AsyncValue<Principal> principalAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return principalAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Text('Could not load session: $error'),
      data: (principal) {
        return switch (principal) {
          PrincipalStaffPendingRefresh(:final staff) => _StaffCard(
            orgName: staff.orgName,
            fullName: staff.fullName,
            roleLabel: staff.role.wire,
            refreshing: true,
          ),
          PrincipalStaff(:final claims) => Consumer(
            builder: (context, ref, _) {
              final display = ref.watch(_staffDisplayProvider);
              return display.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, _) => _StaffCard(
                  orgName: claims.orgId,
                  fullName: claims.staffId ?? '',
                  roleLabel: claims.staffRole?.wire ?? '',
                  refreshing: false,
                ),
                data: (staff) => _StaffCard(
                  orgName: staff?.orgName ?? claims.orgId,
                  fullName: staff?.fullName ?? claims.staffId ?? '',
                  roleLabel: claims.staffRole?.wire ?? '',
                  refreshing: false,
                ),
              );
            },
          ),
          // Any other principal state means the router misrouted; render
          // nothing rather than guessing at a name.
          _ => Icon(Icons.point_of_sale, size: 64, color: colorScheme.secondary),
        };
      },
    );
  }
}

class _StaffCard extends StatelessWidget {
  const _StaffCard({
    required this.orgName,
    required this.fullName,
    required this.roleLabel,
    required this.refreshing,
  });

  final String orgName;
  final String fullName;
  final String roleLabel;
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
            const SizedBox(height: Brand.spaceXs),
            Text('Logged in as $roleLabel', style: textTheme.bodyMedium),
            if (refreshing) ...[
              const SizedBox(height: Brand.spaceSm),
              Text(
                'Refreshing session…',
                style: textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
