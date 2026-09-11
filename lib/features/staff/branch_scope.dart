// Which branch the staff shell is currently looking at.
//
// The options come off the `branch_ids[]` claim the access-token hook stamps
// on the session (see `lib/supabase/app_claims.dart`), which is the same
// array RLS reads. Nothing here narrows what the database will return: a
// selection is a *filter* a repository may pass to a query, never a
// permission. A forged or stale branch id gets the caller nothing extra,
// because the policy checks the claim, not this provider. Read
// `staff_capabilities.dart` for the full statement of that rule.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/data/branches/branch.dart';
import 'package:logfitness_flutter/data/branches/branches_repository.dart';
import 'package:logfitness_flutter/features/staff/staff_capabilities.dart';
import 'package:logfitness_flutter/supabase/app_claims.dart';
import 'package:logfitness_flutter/supabase/supabase_providers.dart';

/// What the shell is scoped to right now.
class BranchScope {
  const BranchScope({
    required this.options,
    required this.selectedBranchId,
    required this.isOrgWide,
  });

  /// The branch ids this session may choose between, straight from the
  /// `branch_ids[]` claim.
  ///
  /// For an owner this is often empty: the access-token hook copies
  /// `staff.branch_ids` verbatim, and upstream an owner's is empty *because*
  /// an empty array means "the whole org" to the RLS policies
  /// (`coalesce(array_length(branch_ids, 1), 0) = 0`). [isOrgWide] is what
  /// distinguishes that from a staff row that was never assigned a branch.
  final List<String> options;

  /// The single branch in focus, or `null` for the aggregate view.
  final String? selectedBranchId;

  /// Whether this session reaches every branch in the org — PLANNING.md §4's
  /// owner row.
  final bool isOrgWide;

  /// Whether there is more than one thing to pick between. A front desk
  /// assigned to one branch gets no switcher at all.
  bool get canSwitch => isOrgWide || options.length > 1;

  /// The branch ids a repository should filter on, or `null` for "do not
  /// filter — let RLS bound it".
  ///
  /// `null` for an owner on the aggregate view is deliberate and mirrors the
  /// console's `lib/scope.ts`: it also covers a branch created after the
  /// session's token was minted, which an explicit list would silently miss.
  /// Everyone else's aggregate is their own [options], because "all" means
  /// "all of mine".
  List<String>? get effectiveBranchIds {
    final selected = selectedBranchId;
    if (selected != null) {
      return <String>[selected];
    }
    return isOrgWide ? null : options;
  }

  @override
  bool operator ==(Object other) =>
      other is BranchScope &&
      other.selectedBranchId == selectedBranchId &&
      other.isOrgWide == isOrgWide &&
      _sameIds(other.options, options);

  @override
  int get hashCode =>
      Object.hash(selectedBranchId, isOrgWide, Object.hashAll(options));

  static bool _sameIds(List<String> a, List<String> b) {
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
}

/// The branch ids this session may choose between.
///
/// Separated from [branchScopeProvider] so a test — or a later screen that
/// only needs the list — can read the options without also depending on the
/// mutable selection.
///
/// The claim alone cannot answer this. An owner's `branch_ids[]` is *empty*,
/// because empty is what the RLS policies read as "the whole org"
/// (`coalesce(array_length(branch_ids, 1), 0) = 0`). Taking the claim
/// verbatim therefore offered an owner nothing to pick from, which is how the
/// register form ended up with no home branch, no branch picker, and — since
/// the plan catalogue is queried per branch — an empty Plan dropdown when
/// "Sell a plan now" was switched on.
///
/// So it mirrors the console's `resolveBranchScope` in `lib/scope.ts`: an
/// org-wide session is offered every branch it can read, and everyone else is
/// offered the branches on their staff row. Still UX only — the list comes
/// from a query RLS has already bounded, and a selection is a filter, never a
/// permission.
final branchOptionsProvider = Provider<List<String>>((ref) {
  final AppClaims? claims = ref.watch(claimsProvider);
  final List<String> claimed = claims?.branchIds ?? const <String>[];
  final bool isOrgWide = ref
      .watch(staffCapabilitiesProvider)
      .contains(StaffCapability.accessAllBranches);

  // For everyone else the claim is the answer, and the branch read is not
  // consulted at all -- deliberately, so a screen that only needs the ids
  // never depends on a network round trip it has no use for.
  if (!isOrgWide) {
    return claimed;
  }

  // While that read is in flight or failed, fall back to the claim: empty for
  // an owner, which is the honest answer -- nothing loaded yet, nothing to
  // offer -- rather than a list invented here.
  final List<Branch>? readable = ref.watch(branchesProvider).value;
  return readable == null
      ? claimed
      : readable.map((Branch branch) => branch.id).toList(growable: false);
});

/// The branch the user has picked, or `null` for the aggregate view.
///
/// Kept as its own writable notifier rather than folded into
/// [branchScopeProvider] so that the derived scope stays a pure function of
/// (claims, selection) and cannot drift.
class SelectedBranch extends Notifier<String?> {
  /// Starts on the aggregate view. A session that covers exactly one branch
  /// is already scoped to it by [BranchScope.effectiveBranchIds], so there is
  /// nothing to pre-select.
  @override
  String? build() => null;

  /// Picks a branch, or `null` for the aggregate view.
  void select(String? branchId) => state = branchId;
}

/// The selected branch id. Data-layer callers should prefer
/// [branchScopeProvider], which also knows what "no selection" means for the
/// current role.
final selectedBranchProvider = NotifierProvider<SelectedBranch, String?>(
  SelectedBranch.new,
);

/// The branch scope every staff query should be built against.
///
/// This is the provider other agents read: `ref.watch(branchScopeProvider)`
/// in a controller, then pass `.effectiveBranchIds` to the repository.
final branchScopeProvider = Provider<BranchScope>((ref) {
  final options = ref.watch(branchOptionsProvider);
  final capabilities = ref.watch(staffCapabilitiesProvider);
  final selected = ref.watch(selectedBranchProvider);

  // A selection the claims no longer cover — the staff row was reassigned
  // and the token refreshed — falls back to the aggregate rather than
  // pinning the shell to a branch this session cannot see. The console does
  // the same with a stale `?branch=` parameter, and for the same reason: a
  // stale bookmark is not an attack and should not produce a dead screen.
  final covered = selected != null && options.contains(selected);

  return BranchScope(
    options: options,
    selectedBranchId: covered ? selected : null,
    isOrgWide: capabilities.contains(StaffCapability.accessAllBranches),
  );
});

/// Display names for branch ids, keyed by id.
///
/// Claims carry ids and nothing else, so a readable switcher needs a read of
/// the `branches` table — hence `lib/data/branches/`, which exists for this.
///
/// Resolves to an empty map while the read is in flight or if it fails, and
/// the switcher falls back to a shortened id. That fallback is deliberate: a
/// branch switcher is navigation, and failing to load one branch's *name* is
/// not a reason to take the switcher away from someone standing at a counter.
/// The rows themselves are still bounded by RLS either way.
final branchNamesProvider = Provider<Map<String, String>>((ref) {
  final branches = ref.watch(branchesProvider);
  return branches.maybeWhen(
    data: (List<Branch> rows) => <String, String>{
      for (final Branch branch in rows) branch.id: branch.name,
    },
    orElse: () => const <String, String>{},
  );
});
