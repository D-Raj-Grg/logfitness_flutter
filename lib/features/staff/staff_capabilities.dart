// ============================================================================
// THIS FILE IS UX ONLY. IT IS NOT ACCESS CONTROL.
//
// CLAUDE.md: "Role gates the shell, RLS gates the data. Client-side role
// checks are UX only. Never treat a hidden button as an access control."
//
// Everything below decides what a staff member is *offered*. What they can
// actually read or write is decided in Postgres, by RLS policies and by the
// guard triggers behind the RPCs, against the claims on their JWT. The two
// are deliberately independent: this table can be wrong, or stale, or
// bypassed by a modified client, and the database still refuses.
//
// The corollary matters as much as the rule: because the database refuses
// independently, **its refusal must always reach the screen**. Hiding a
// button and then swallowing the `42501` that comes back anyway is how the
// web console shipped its 2026-09-07 bug, where a manager acting outside
// their branches saw a refusal rendered as success. `FailureView` in
// `lib/features/common/failure_view.dart` exists so that cannot recur here;
// never pair a gate in this file with a silent catch.
// ============================================================================
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/features/auth/auth_controller.dart';

/// A single thing a staff member may be offered in the app.
///
/// One entry per clause of PLANNING.md §4. Screens and nav destinations ask
/// for a capability rather than testing a role, so §4 is stated exactly once
/// and a role change is a change to [_capabilitiesByRole] alone.
enum StaffCapability {
  // --- front desk (PLANNING.md §4, `front_desk` row) -----------------------
  /// Scan and manual check-in.
  checkIn,

  /// `record_payment`.
  collectPayment,

  /// Walk-in signup: the visitor log and the `register_member` behind it.
  walkInSignup,

  /// `renew_membership`.
  renewMembership,

  /// Today's collection sheet via `daily_collection`.
  viewTodaysCollection,

  /// Find a member and read their record.
  ///
  /// §4 lists "member management" against `manager`, not `front_desk`, but
  /// the same row grants front desk renewals and payment collection — both of
  /// which begin by finding the member. So *lookup* is separated from
  /// *management*: the destructive half stays manager-and-up, which is what
  /// §4's "freezes, cancellations, refunds" actually enumerates. The web
  /// console draws the line in the same place — `nav-items.ts` gives Members
  /// to `owner`, `manager` and `front_desk`.
  lookUpMember,

  /// `set_member_left` / `reactivate_member`.
  ///
  /// Front desk and up, decided 2026-09-11, aligning this app with both the
  /// database and the console after the three disagreed.
  ///
  /// The database settles it: `jwt_can_serve_members()` is
  /// `{owner, manager, front_desk}` and `set_member_left` is `security
  /// invoker`, so a front desk is already permitted to run it. A gate here
  /// that refused them protected nothing — RLS is the boundary — and only hid
  /// the action from the one person who ever learns the fact. The console
  /// agrees: `requireRole('owner', 'manager', 'front_desk')`.
  ///
  /// And an unrecorded departure is not neutral. It leaves someone counted as
  /// an active member, which inflates exactly the numbers the chain reports
  /// exist to get right — churn especially. Making the desk fetch a manager to
  /// write down "they moved to Pokhara" is how it stops being written down.
  ///
  /// Reversible (`reactivate_member`) and non-financial, which is what
  /// separates it from [cancelMembership].
  recordDeparture,

  // --- trainer (PLANNING.md §4, `trainer` row) ----------------------------
  /// Own classes and sessions, and attendance for them. Trainer-only by §4;
  /// managers and owners administer the timetable on the web console.
  manageOwnClasses,

  // --- manager (PLANNING.md §4, `manager` row) ----------------------------
  /// Editing a member record, archiving, restoring.
  manageMembers,

  /// `freeze_membership` / `unfreeze_membership`.
  freezeMembership,

  /// `cancel_membership` only. Cancelling voids an entitlement someone paid
  /// for, which is why it sits with refunds rather than with [recordDeparture].
  cancelMembership,

  /// `refund_payment` / `reverse_payment`.
  refundPayment,

  /// Branch reports: `daily_collection` over a range, `arrears_report`.
  viewBranchReports,

  // --- owner (PLANNING.md §4, `owner` row) --------------------------------
  /// Manager capability across *every* branch in the org, rather than only
  /// the branches on the staff row. Read by the branch switcher, never by a
  /// nav destination — an owner's surface is a manager's surface widened, not
  /// a different set of screens.
  accessAllBranches,
}

/// "Check-in (scan and manual), collect payment, walk-in signup, renewals,
/// today's collection."
const Set<StaffCapability> _frontDesk = <StaffCapability>{
  StaffCapability.checkIn,
  StaffCapability.collectPayment,
  StaffCapability.walkInSignup,
  StaffCapability.renewMembership,
  StaffCapability.viewTodaysCollection,
  StaffCapability.lookUpMember,
  StaffCapability.recordDeparture,
};

/// "Everything front desk can do, plus member management, freezes,
/// cancellations, refunds, and branch reports."
const Set<StaffCapability> _manager = <StaffCapability>{
  ..._frontDesk,
  StaffCapability.manageMembers,
  StaffCapability.freezeMembership,
  StaffCapability.cancelMembership,
  StaffCapability.refundPayment,
  StaffCapability.viewBranchReports,
};

/// PLANNING.md §4, transcribed. This is the whole role model; nothing else in
/// the app may switch on a [StaffRole].
const Map<StaffRole, Set<StaffCapability>>
_capabilitiesByRole = <StaffRole, Set<StaffCapability>>{
  StaffRole.frontDesk: _frontDesk,

  // "Own classes and sessions, attendance for them." Deliberately disjoint
  // from the front desk set: a trainer is not a cashier.
  StaffRole.trainer: <StaffCapability>{StaffCapability.manageOwnClasses},

  StaffRole.manager: _manager,

  // "Manager capability across every branch in the org." The only difference
  // from a manager is reach, so the set is the manager set plus that reach.
  StaffRole.owner: <StaffCapability>{
    ..._manager,
    StaffCapability.accessAllBranches,
  },
};

/// What [role] is offered, per PLANNING.md §4.
Set<StaffCapability> capabilitiesFor(StaffRole role) =>
    _capabilitiesByRole[role] ?? const <StaffCapability>{};

/// The signed-in staff member's role, or `null` when the session is not a
/// staff principal (or has not resolved yet).
///
/// Reads [principalProvider] rather than the claims directly so the
/// `*PendingRefresh` state — linked, but carrying a token minted before the
/// claims existed — resolves to a role too, instead of rendering an empty
/// shell while the refresh lands.
final staffRoleProvider = Provider<StaffRole?>((ref) {
  final principal = ref.watch(principalProvider).value;
  return switch (principal) {
    PrincipalStaff(:final claims) => claims.staffRole,
    PrincipalStaffPendingRefresh(:final staff) => staff.role,
    _ => null,
  };
});

/// What the signed-in staff member is offered. Empty for a non-staff or
/// unresolved session, so a widget that gates on a capability fails closed.
final staffCapabilitiesProvider = Provider<Set<StaffCapability>>((ref) {
  final role = ref.watch(staffRoleProvider);
  return role == null ? const <StaffCapability>{} : capabilitiesFor(role);
});
