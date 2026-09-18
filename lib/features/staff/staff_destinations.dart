// The staff shell's navigation table — the Dart analogue of the web
// console's `components/app/nav-items.ts`. Adding a destination is one entry
// in [staffDestinations]; nothing else in the shell needs to change.
//
// Filtering here is for clarity, not for security. See
// `staff_capabilities.dart` for the full statement of that rule: RLS is what
// actually refuses, and its refusal must always be rendered.
import 'package:flutter/material.dart';

import 'package:logfitness_flutter/features/attendance/check_in_screen.dart';
import 'package:logfitness_flutter/features/members/member_list_screen.dart';
import 'package:logfitness_flutter/features/notifications/messages_screen.dart';
import 'package:logfitness_flutter/features/settings/settings_screen.dart';
import 'package:logfitness_flutter/features/payments/arrears_screen.dart';
import 'package:logfitness_flutter/features/payments/collection_sheet_screen.dart';
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
    this.requiresAny,
    this.builder,
    this.alwaysOverflow = false,
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

  /// Any one of these is enough, for a destination that hosts more than one
  /// thing behind one label.
  ///
  /// Messages is the reason it exists: the delivery log is owner-and-manager
  /// and announcements reach the front desk, so gating the destination on
  /// either one alone hides a tab from somebody who holds it. The screen then
  /// renders only the tabs the caller actually holds -- see
  /// `messages_screen.dart`.
  final Set<StaffCapability>? requiresAny;

  /// The screen behind this destination. `null` until the sub-project that
  /// owns it lands (TASKS.md, "Staff parity programme"), at which point the
  /// shell renders [StaffPlaceholderScreen] instead — so adding a
  /// destination stays a single entry here whether or not its screen exists.
  final Widget Function()? builder;

  /// Keeps this destination out of the bottom bar even when there is room
  /// for it, so it is only ever reached through More.
  ///
  /// Check-in is the one entry that wants this. The counter's phone is not
  /// the door: check-in happens on the scanner/kiosk, and putting it in a
  /// bar slot cost a slot and made it the shell's landing screen — which is
  /// how an owner signing in got a check-in console and a keyboard instead
  /// of their members.
  final bool alwaysOverflow;

  /// Whether [capabilities] is offered this destination.
  bool isVisibleTo(Set<StaffCapability> capabilities) {
    // [requiresAny], when given, is the whole rule. Falling through to the
    // `requires == null` branch after it fails would read as "no requirement"
    // and offer the destination to every role -- which is how a trainer was
    // briefly offered Messages.
    final Set<StaffCapability>? any = requiresAny;
    if (any != null) return any.any(capabilities.contains);
    return requires == null || capabilities.contains(requires);
  }
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
  // Members is first because it is what the shell opens on: the record is
  // the thing every other counter task starts from — renew, collect, freeze,
  // record a departure — and it is the one screen no staff role is without.
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
    builder: _collectionScreen,
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
  // Arrears is the only report built, and it is the one a counter acts on
  // rather than reads, so it is what Reports opens on. Phase 6's ranged
  // collection and expiring-soon dashboards land beside it later; when they
  // do this becomes an index and arrears becomes a row in it.
  StaffDestination(
    id: 'reports',
    label: 'Reports',
    icon: Icons.bar_chart_outlined,
    selectedIcon: Icons.bar_chart,
    requires: StaffCapability.viewBranchReports,
    builder: _reportsScreen,
  ),
  // "Messages", not "Notifications", and the difference is not cosmetic: on a
  // phone "Notifications" is what the operating system's own shade is called,
  // so a destination by that name reads as app settings — permissions, badges,
  // alerts — rather than as the SMS the gym sent a member last night. The
  // console can call it Notifications because a browser has no such shade.
  //
  // Landing behind More is correct rather than a compromise. With five bar
  // slots an owner reaches this through one extra tap, and this is a screen
  // the desk *reads* — did last night's reminders go out — not one it works
  // from. Members, Collection and Check-in are the working surfaces and they
  // keep the slots.
  StaffDestination(
    id: 'notifications',
    label: 'Messages',
    icon: Icons.sms_outlined,
    selectedIcon: Icons.sms,
    requiresAny: <StaffCapability>{
      StaffCapability.viewNotificationLog,
      StaffCapability.sendAnnouncement,
    },
    builder: _messagesScreen,
  ),
  // Behind More by [alwaysOverflow], not by ordering — see that field.
  StaffDestination(
    id: 'check-in',
    label: 'Check-in',
    icon: Icons.qr_code_scanner_outlined,
    selectedIcon: Icons.qr_code_scanner,
    requires: StaffCapability.checkIn,
    builder: _checkInScreen,
    alwaysOverflow: true,
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
    builder: _settingsScreen,
  ),
];

/// The member list, sub-project C's screen. It replaces the Phase 1 phone
/// lookup panel, which searched one column and could not say which people it
/// was leaving out. A top-level function rather than a closure so
/// [staffDestinations] can stay `const`.
Widget _membersScreen() => const MemberListScreen();

/// This person's own settings. A top-level function rather than a closure so
/// [staffDestinations] can stay `const`.
Widget _settingsScreen() => const SettingsScreen();

/// The counter's check-in console. A top-level function rather than a closure
/// so [staffDestinations] can stay `const`.
Widget _checkInScreen() => const CheckInScreen();

/// The visitor log, sub-project B's screen. A top-level function rather than
/// a closure so [staffDestinations] can stay `const`.
Widget _visitorsScreen() => const VisitorLogScreen();

/// Today's drawer, sub-project D's screen. A top-level function rather than a
/// closure so [staffDestinations] can stay `const`.
Widget _collectionScreen() => const CollectionSheetScreen();

/// Who owes money, sub-project D's other screen. A top-level function rather
/// than a closure so [staffDestinations] can stay `const`.
Widget _reportsScreen() => const ArrearsScreen();

/// The delivery log, sub-project H's screen. A top-level function rather than
/// a closure so [staffDestinations] can stay `const`.
Widget _messagesScreen() => const MessagesScreen();

/// How many destinations the bottom bar shows before the rest move behind
/// "More".
///
/// Five, which is Material 3's maximum for a [NavigationBar]. It was four,
/// and four was costing more than it saved: with the fifth slot spent on More
/// itself, an owner reached only three real destinations from the bar and
/// Collection — the day's money, which a desk opens constantly — sat behind an
/// extra tap. At five, a front desk gets its whole surface with no overflow at
/// all, and an owner gets Collection on the bar.
const int maxPrimaryDestinations = 5;

/// The destinations [capabilities] is offered, in declaration order.
List<StaffDestination> destinationsFor(Set<StaffCapability> capabilities) =>
    staffDestinations
        .where((destination) => destination.isVisibleTo(capabilities))
        .toList(growable: false);

/// The destinations that get a slot in the bottom bar.
///
/// [StaffDestination.alwaysOverflow] entries never take a slot. When what is
/// left fits and nothing was forced out, More is not rendered and all of them
/// are primary; otherwise one slot is surrendered to More so the overflow is
/// reachable.
List<StaffDestination> primaryDestinations(List<StaffDestination> visible) {
  final List<StaffDestination> barred = visible
      .where((destination) => !destination.alwaysOverflow)
      .toList(growable: false);
  final bool needsMore =
      barred.length != visible.length || barred.length > maxPrimaryDestinations;
  if (!needsMore) return barred;
  final int slots = maxPrimaryDestinations - 1;
  return barred.length <= slots ? barred : barred.sublist(0, slots);
}

/// The destinations that live behind More, in declaration order. Empty when
/// everything fits in the bar.
List<StaffDestination> overflowDestinations(List<StaffDestination> visible) {
  final Set<String> primary = primaryDestinations(
    visible,
  ).map((destination) => destination.id).toSet();
  return visible
      .where((destination) => !primary.contains(destination.id))
      .toList(growable: false);
}
