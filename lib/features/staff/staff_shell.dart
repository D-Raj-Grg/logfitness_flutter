// The staff shell: chrome, navigation, and branch scope for every staff
// role.
//
// STRUCTURE, AND WHY
//
// A [NavigationBar] with up to four destinations plus a "More" sheet for the
// overflow, driven off the single declarative list in
// `staff_destinations.dart` (the Dart analogue of the console's
// `nav-items.ts`). Adding a destination is one entry in that list.
//
// A bar-plus-overflow was chosen over a drawer because the target is ~19
// destinations at parity (TASKS.md, "Staff parity programme") but the *daily*
// surface is three or four screens at a counter, often one-handed with a
// phone in the other hand — a drawer puts every one of those behind a gesture
// and a second tap, and hides which screen you are on. The overflow sheet
// costs the long tail one extra tap, which is the right trade when the long
// tail is Reports and Settings. It also degrades correctly by role without
// any per-role layout: a trainer sees two destinations and no More, a manager
// sees six and one.
//
// Destinations are shell-internal state rather than nested go_router routes.
// `lib/app/router.dart` says its redirect is "the ONLY place auth/role
// navigation is decided", and it lands every staff principal on exactly
// `/staff`. Giving each tab a URL would need `/staff` to redirect onward to
// whichever tab the role can see, putting a second, role-dependent
// navigation decision beside the guard — and no single child path is granted
// to all four roles, so that redirect could not be written without a loop.
// Deep links into a specific staff screen (from a push notification, Phase 3)
// are the reason to revisit this; they are not needed yet.
//
// Role filtering here is UX only. See `staff_capabilities.dart`.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/data/auth/auth_repository.dart';
import 'package:logfitness_flutter/data/auth/current_staff.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/features/auth/auth_controller.dart';
import 'package:logfitness_flutter/features/staff/branch_switcher.dart';
import 'package:logfitness_flutter/features/staff/staff_capabilities.dart';
import 'package:logfitness_flutter/features/staff/staff_destinations.dart';
import 'package:logfitness_flutter/features/staff/staff_placeholder_screen.dart';

const Key staffNavigationBarKey = Key('staff-navigation-bar');
const Key staffMoreSheetKey = Key('staff-more-sheet');

/// The bottom-bar entry that opens the overflow sheet. Not a destination —
/// it never becomes the selected index.
const Key staffMoreButtonKey = Key('staff-nav-more');

/// Key for the bar entry or sheet row belonging to [id].
Key staffDestinationKey(String id) => Key('staff-nav-$id');

/// Fetches the current staff principal's display row, for the one case
/// [Principal.staff] does not already carry it: claims identify a staff
/// principal by id only (`org_id`, `staff_id`, `staff_role`), not by name.
/// [Principal.staffPendingRefresh] already carries a [CurrentStaff] row and
/// does not need this.
final _staffDisplayProvider = FutureProvider.autoDispose<CurrentStaff?>((ref) {
  return ref.watch(authRepositoryProvider).currentStaff();
});

/// Root shell for staff roles (`front_desk`, `trainer`, `manager`, `owner`).
class StaffShell extends ConsumerStatefulWidget {
  const StaffShell({super.key});

  @override
  ConsumerState<StaffShell> createState() => _StaffShellState();
}

class _StaffShellState extends ConsumerState<StaffShell> {
  /// Index into the *visible* destination list, not into
  /// [staffDestinations]. Clamped on every build, because the visible list
  /// shrinks when a session's role resolves or changes underneath it.
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(staffRoleProvider);

    // No staff role means the principal has not resolved yet, or the router
    // misrouted a non-staff session here. Fail closed on the role rather than
    // on the destination list: Settings requires no capability, so an
    // unresolved session would otherwise be shown a one-item shell as though
    // it belonged.
    if (role == null) {
      return Scaffold(
        appBar: _StaffAppBar(onSignOut: _signOut),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final visible = destinationsFor(ref.watch(staffCapabilitiesProvider));
    final index = _index.clamp(0, visible.length - 1);
    final primary = primaryDestinations(visible);
    final overflow = overflowDestinations(visible);
    final selected = visible[index];

    return Scaffold(
      appBar: _StaffAppBar(onSignOut: _signOut, title: selected.label),
      // IndexedStack rather than a single child so a half-typed member search
      // survives a trip to Collection and back. At ~19 destinations this
      // keeps every visited screen alive; that is the point, and it is also
      // the thing to watch if a screen turns out to hold something heavy.
      body: SafeArea(
        child: IndexedStack(
          index: index,
          children: <Widget>[
            for (final StaffDestination destination in visible)
              destination.builder?.call() ??
                  StaffPlaceholderScreen(destination: destination),
          ],
        ),
      ),
      // A role with one destination has nothing to navigate between, and
      // NavigationBar asserts on fewer than two. No role in PLANNING.md §4
      // is that narrow today, but the assert is not worth risking on the
      // next one.
      bottomNavigationBar: visible.length < 2
          ? null
          : NavigationBar(
              key: staffNavigationBarKey,
              // When the selection lives in the overflow, no bar entry is
              // highlighted — but NavigationBar has no "nothing selected", so it
              // sits on More instead, which is where the user went to get here.
              selectedIndex: index < primary.length ? index : primary.length,
              onDestinationSelected: (int tapped) {
                if (tapped < primary.length) {
                  setState(() => _index = tapped);
                } else {
                  _showMoreSheet(overflow, visible);
                }
              },
              destinations: <Widget>[
                for (final StaffDestination destination in primary)
                  NavigationDestination(
                    key: staffDestinationKey(destination.id),
                    icon: Icon(destination.icon),
                    selectedIcon: Icon(destination.selectedIcon),
                    label: destination.label,
                  ),
                if (overflow.isNotEmpty)
                  const NavigationDestination(
                    key: staffMoreButtonKey,
                    icon: Icon(Icons.more_horiz),
                    selectedIcon: Icon(Icons.more_horiz),
                    label: 'More',
                  ),
              ],
            ),
    );
  }

  Future<void> _signOut() =>
      ref.read(authControllerProvider.notifier).signOut();

  void _showMoreSheet(
    List<StaffDestination> overflow,
    List<StaffDestination> visible,
  ) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (BuildContext sheetContext) => SafeArea(
          key: staffMoreSheetKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (final StaffDestination destination in overflow)
                ListTile(
                  key: staffDestinationKey(destination.id),
                  leading: Icon(destination.icon),
                  title: Text(destination.label),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    setState(() => _index = visible.indexOf(destination));
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Chrome shared by every destination: who is signed in, which branch is in
/// scope, and the way out.
class _StaffAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const _StaffAppBar({required this.onSignOut, this.title});

  final Future<void> Function() onSignOut;
  final String? title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final role = ref.watch(staffRoleProvider);

    // Best-effort: claims identify the staff row by id, so the name needs a
    // round trip. It is chrome, not content — if the read fails or is still
    // in flight the role alone is shown rather than a spinner in the app bar.
    final name = ref.watch(_staffDisplayProvider).value?.fullName;
    final subtitle = <String>[
      if (role != null) _roleLabel(role),
      if (name != null && name.isNotEmpty) name,
    ].join(' · ');

    return AppBar(
      titleSpacing: Brand.spaceMd,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(title ?? 'Staff', style: theme.textTheme.titleMedium),
          // Showing the role is a UX convenience for the counter — it tells
          // someone why a button they expected is missing. It is not an
          // access-control statement; RLS decides what this session can
          // actually read or write (PLANNING.md §3).
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
      actions: <Widget>[
        const BranchSwitcher(),
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Sign out',
          onPressed: () => unawaited(onSignOut()),
        ),
      ],
    );
  }
}

/// Matches the console's `ROLE_LABELS` in `lib/roles.ts`, so the same person
/// reads the same word on both surfaces.
String _roleLabel(StaffRole role) => switch (role) {
  StaffRole.owner => 'Owner',
  StaffRole.manager => 'Branch manager',
  StaffRole.frontDesk => 'Front desk',
  StaffRole.trainer => 'Trainer',
};
