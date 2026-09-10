// The reads behind the sales screens.
//
// A widget that builds a PostgREST query is a review failure (PLANNING.md
// §6), so every screen in this folder watches one of these instead. They are
// declared by hand rather than with `@riverpod` -- no annotation in this
// folder needs `build_runner`.
//
// The family arguments are plain Dart value classes with `==` and `hashCode`,
// because a Riverpod family keyed on a `List<String>` would rebuild forever:
// two equal lists are different objects.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/data/memberships/membership.dart';
import 'package:logfitness_flutter/data/memberships/memberships_repository.dart';
import 'package:logfitness_flutter/data/payments/invoice.dart';
import 'package:logfitness_flutter/data/payments/payment_rpc_results.dart';
import 'package:logfitness_flutter/data/payments/payments_repository.dart';
import 'package:logfitness_flutter/data/plans/membership_plan.dart';
import 'package:logfitness_flutter/data/plans/plans_repository.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';

/// Compares two nullable branch-id lists by value.
///
/// `null` is not the empty list: it means "do not filter -- let RLS bound
/// it", which is what an owner's aggregate view sends
/// (`BranchScope.effectiveBranchIds`).
bool sameBranchIds(List<String>? a, List<String>? b) {
  if (a == null || b == null) {
    return a == null && b == null;
  }
  if (a.length != b.length) {
    return false;
  }
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) {
      return false;
    }
  }
  return true;
}

int _branchIdsHash(List<String>? ids) =>
    ids == null ? 0 : Object.hashAll(ids);

/// Which day's drawer, over which branches.
class CollectionQuery {
  const CollectionQuery({this.on, this.branchIds});

  /// The day to close. `null` means the org's own today, resolved inside
  /// `daily_collection`.
  ///
  /// Deliberately not defaulted to the device's date: a phone in the wrong
  /// timezone would otherwise close the wrong day
  /// (`PaymentsRepository.dailyCollection`).
  final DateTime? on;

  /// `BranchScope.effectiveBranchIds` -- a filter, never a permission.
  final List<String>? branchIds;

  @override
  bool operator ==(Object other) =>
      other is CollectionQuery &&
      other.on == on &&
      sameBranchIds(other.branchIds, branchIds);

  @override
  int get hashCode => Object.hash(on, _branchIdsHash(branchIds));
}

/// Which branches to age the debt over.
class ArrearsQuery {
  const ArrearsQuery({this.branchIds});

  final List<String>? branchIds;

  @override
  bool operator ==(Object other) =>
      other is ArrearsQuery && sameBranchIds(other.branchIds, branchIds);

  @override
  int get hashCode => _branchIdsHash(branchIds);
}

/// Plans sellable at one branch -- the list a renewal picks from.
///
/// Sub-project C's registration screen keeps its own copy of this provider.
/// Duplicated on purpose: importing a screen from another feature folder to
/// borrow a provider couples two independently-owned trees, and the two are
/// never mounted at the same time, so the second fetch costs nothing real.
final sellablePlansProvider =
    FutureProvider.family<List<MembershipPlan>, String>((ref, String branchId) {
      return ref.watch(plansRepositoryProvider).listPlansForBranch(branchId);
    });

/// One member's memberships, newest first.
///
/// The renewal screen reads this for two things it cannot otherwise know:
/// what the current period runs to, and whether this is the member's first
/// membership -- which is what decides the joining fee
/// (`20260906120100_membership_signup_fee.sql`).
final memberMembershipsProvider =
    FutureProvider.family<List<Membership>, String>((ref, String memberId) {
      return ref
          .watch(membershipsRepositoryProvider)
          .listMembershipsForMember(memberId);
    });

/// One member's invoices, newest first.
final memberInvoicesProvider =
    FutureProvider.family<List<Invoice>, String>((ref, String memberId) {
      return ref.watch(paymentsRepositoryProvider).listInvoicesForMember(
        memberId,
      );
    });

/// The invoices a payment can actually be collected against: something still
/// outstanding, and not void.
///
/// Derived rather than filtered in the widget, so the screen's empty state
/// ("nothing outstanding") is a property of the data and not of a `where`
/// clause buried in a `build`.
final openInvoicesProvider =
    FutureProvider.family<List<Invoice>, String>((ref, String memberId) async {
      final List<Invoice> all = await ref.watch(
        memberInvoicesProvider(memberId).future,
      );
      return all
          .where(
            (Invoice invoice) =>
                invoice.duePaisa > 0 && invoice.status != InvoiceStatus.voided,
          )
          .toList(growable: false);
    });

/// Today's drawer, grouped by branch, collector, method and kind.
final dailyCollectionProvider =
    FutureProvider.family<List<DailyCollectionRow>, CollectionQuery>((
      ref,
      CollectionQuery query,
    ) {
      return ref.watch(paymentsRepositoryProvider).dailyCollection(
        on: query.on,
        branchIds: query.branchIds,
      );
    });

/// Who owes money, aged by the database against the org's own today.
final arrearsProvider =
    FutureProvider.family<List<ArrearsRow>, ArrearsQuery>((
      ref,
      ArrearsQuery query,
    ) {
      return ref.watch(paymentsRepositoryProvider).arrearsReport(
        branchIds: query.branchIds,
      );
    });
