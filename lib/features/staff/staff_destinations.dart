// The staff shell's navigation table — the Dart analogue of the web
// console's `components/app/nav-items.ts`. Adding a destination is one entry
// in [staffDestinations]; nothing else in the shell needs to change.
//
// Filtering here is for clarity, not for security. See
// `staff_capabilities.dart` for the full statement of that rule: RLS is what
// actually refuses, and its refusal must always be rendered.
import 'package:flutter/material.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/features/members/member_lookup_panel.dart';
import 'package:logfitness_flutter/features/attendance/check_in_screen.dart';
import 'package:logfitness_flutter/features/staff/staff_capabilities.dart';
import 'package:logfitness_flutter/features/visitors/visitor_log_screen.dart';

/// One place a staff member can go.
@immutable
class StaffDestination {
  const StaffDestination({
    required this.id,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    this.requires,
    this.builder,
  });

  /// Stable identifier, used as the widget key and in tests. Never shown.
  final String id;

  /// The label under the bottom-bar icon and in the More sheet.
  final String label;

  final IconData icon;
  final IconData selectedIcon;

  /// The capability a role must hold to be offered this destination. `null`
  /// means every staff role sees it.
  final StaffCapability? requires;

  /// The screen behind this destination. `null` until the sub-project that
  /// owns it lands (TASKS.md, "Staff parity programme"), at which point the
  /// shell renders [StaffPlaceholderScreen] instead — so adding a
  /// destination stays a single entry here whether or not its screen exists.
  final Widget Function()? builder;

  /// Whether [capabilities] is offered this destination.
  bool isVisibleTo(Set<StaffCapability> capabilities) =>
      requires == null || capabilities.contains(requires);
}

/// Every staff destination, in the order they are offered.
///
/// Ordering is load-bearing: [primaryDestinations] takes the first few
/// visible entries for the bottom bar and [overflowDestinations] takes the
/// rest, so the most-used counter screens are listed first. The eventual
/// target is parity with the console's ~19 routes (TASKS.md, "Staff parity
/// programme"), which is why the tail of this list is expected to grow and
/// why the split is computed rather than hand-maintained.
const List<StaffDestination> staffDestinations = <StaffDestination>[
  StaffDestination(
    id: 'check-in',
    label: 'Check-in',
    icon: Icons.qr_code_scanner_outlined,
    selectedIcon: Icons.qr_code_scanner,
    requires: StaffCapability.checkIn,
    builder: _checkInScreen,
  ),
  StaffDestination(
    id: 'members',
    label: 'Members',
    icon: Icons.people_outline,
    selectedIcon: Icons.people,
    requires: StaffCapability.lookUpMember,
    builder: _membersScreen,
  ),
  StaffDestination(
    id: 'visitors',
    label: 'Visitors',
    icon: Icons.meeting_room_outlined,
    selectedIcon: Icons.meeting_room,
    requires: StaffCapability.walkInSignup,
    builder: _visitorsScreen,
  ),
  StaffDestination(
    id: 'collection',
    label: 'Collection',
    icon: Icons.payments_outlined,
    selectedIcon: Icons.payments,
    requires: StaffCapability.viewTodaysCollection,
  ),
  // Trainers have no other destination — PLANNING.md §4 gives them classes
  // and nothing else — so this entry is what keeps their shell from being
  // empty. It is not in the brief's initial list; it is in §4.
  StaffDestination(
    id: 'classes',
    label: 'Classes',
    icon: Icons.event_outlined,
    selectedIcon: Icons.event,
    requires: StaffCapability.manageOwnClasses,
  ),
  StaffDestination(
    id: 'reports',
    label: 'Reports',
    icon: Icons.bar_chart_outlined,
    selectedIcon: Icons.bar_chart,
    requires: StaffCapability.viewBranchReports,
  ),
  // Settings is the signed-in person's own account and preferences — sign
  // out, app version, theme — not the org administration the console keeps
  // under `/settings`. Branch and staff administration stays on the web
  // console (CLAUDE.md, "Scope discipline"), so no role is gated out of this
  // one.
  StaffDestination(
    id: 'settings',
    label: 'Settings',
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
  ),
];

/// The only destination with a screen so far: the Phase 1 phone lookup, kept
/// mounted so the widget → controller → repository → supabase chain stays
/// exercised until sub-project C replaces it with the real member list
/// (TASKS.md, "Staff parity programme"). A top-level function rather than a
/// closure so [staffDestinations] can stay `const`.
Widget _membersScreen() => const SingleChildScrollView(
  padding: EdgeInsets.all(Brand.spaceLg),
  child: MemberLookupPanel(),
);

/// The counter's check-in console. A top-level function rather than a closure
/// so [staffDestinations] can stay `const`.
Widget _checkInScreen() => const CheckInScreen();

/// The visitor log, sub-project B's screen. A top-level function rather than
/// a closure so [staffDestinations] can stay `const`.
Widget _visitorsScreen() => const VisitorLogScreen();

/// How many destinations the bottom bar shows before the rest move behind
/// "More". Four is the Material 3 comfortable maximum for a
/// [NavigationBar] on a phone; the fifth slot is spent on More itself.
const int maxPrimaryDestinations = 4;

/// The destinations [capabilities] is offered, in declaration order.
List<StaffDestination> destinationsFor(Set<StaffCapability> capabilities) =>
    staffDestinations
        .where((destination) => destination.isVisibleTo(capabilities))
        .toList(growable: false);

/// The destinations that get a slot in the bottom bar.
///
/// When everything fits, More is not rendered and all of them are primary.
/// When it does not, one slot is surrendered to More so the overflow is
/// reachable.
List<StaffDestination> primaryDestinations(List<StaffDestination> visible) =>
    visible.length <= maxPrimaryDestinations
    ? visible
    : visible.sublist(0, maxPrimaryDestinations - 1);

/// The destinations that live behind More. Empty when everything fits.
List<StaffDestination> overflowDestinations(List<StaffDestination> visible) =>
    visible.length <= maxPrimaryDestinations
    ? const <StaffDestination>[]
    : visible.sublist(maxPrimaryDestinations - 1);
