// The member list's read side.
//
// Two notifiers rather than one, for the reason the visitor log gives: the
// query is state a person edits (a chip, a search box, the branch switcher)
// and the page of rows is state the database owns. Changing the query re-runs
// from page one -- the only correct behaviour, because page 3 of the old
// filter has nothing to do with page 3 of the new one -- while scrolling
// appends without disturbing the query.
//
// Widgets call controllers; controllers call repositories (PLANNING.md §6). A
// widget that builds a PostgREST query is a review failure.
//
// Declared by hand rather than with `@riverpod`: nothing here needs codegen,
// and the manual form is what `lib/features/staff/branch_scope.dart` already
// uses.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/data/members/member_list_query.dart';
import 'package:logfitness_flutter/data/members/member_overview.dart';
import 'package:logfitness_flutter/data/members/members_repository.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/features/staff/branch_scope.dart';

/// The query the list is currently showing.
///
/// Opens on no status filter, which is the console's default and -- because
/// the repository excludes `archived_at` for every filter except
/// [MemberListFilter.archived] -- still hides the people the desk deliberately
/// put away. Archived is opt-in and nothing else widens into it.
class MemberQuery extends Notifier<MemberListQuery> {
  @override
  MemberListQuery build() => const MemberListQuery();

  /// Every edit resets to page one. The old offset is meaningless against a
  /// new result set, and the console resets for the same reason.
  void setStatus(MemberListFilter? status) {
    state = MemberListQuery(
      q: state.q,
      status: status,
      pageSize: state.pageSize,
    );
  }

  void setQuery(String q) {
    state = MemberListQuery(
      q: q.trim(),
      status: state.status,
      pageSize: state.pageSize,
    );
  }
}

final memberQueryProvider = NotifierProvider<MemberQuery, MemberListQuery>(
  MemberQuery.new,
);

/// What the list screen renders: the rows loaded so far, and whether asking
/// for more is worth doing.
///
/// A plain Dart class, not freezed -- it never crosses the wire, so there is
/// nothing to generate.
class MemberListState {
  const MemberListState({
    required this.rows,
    required this.total,
    required this.page,
    required this.pageSize,
    this.loadingMore = false,
    this.appendFailure,
  });

  final List<MemberOverview> rows;

  /// The count the database reports for the whole filter, not the number
  /// loaded. "25 of 412 members" needs both.
  final int total;

  final int page;
  final int pageSize;

  /// True while a [MemberList.loadMore] is in flight. Distinct from the
  /// notifier's own `AsyncValue.loading`, which means the *first* page is
  /// loading: a spinner under a list is a different thing from an empty
  /// screen.
  final bool loadingMore;

  /// Set when fetching the *next* page failed. The rows already on screen
  /// stay -- blanking a list someone is reading because page four was refused
  /// is a worse answer than leaving it and saying so. The screen shows this as
  /// a snackbar, because a list that silently stops growing is
  /// indistinguishable from one that has ended.
  final AppFailure? appendFailure;

  /// Whether the database has rows this page window did not reach. Derived
  /// from the count rather than from a short page, so it is right even when
  /// the last page is exactly full.
  bool get hasMore => rows.length < total;

  MemberListState copyWith({
    List<MemberOverview>? rows,
    int? total,
    int? page,
    int? pageSize,
    bool? loadingMore,
    AppFailure? appendFailure,
    bool clearAppendFailure = false,
  }) {
    return MemberListState(
      rows: rows ?? this.rows,
      total: total ?? this.total,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      loadingMore: loadingMore ?? this.loadingMore,
      appendFailure: clearAppendFailure
          ? null
          : (appendFailure ?? this.appendFailure),
    );
  }
}

class MemberList extends AsyncNotifier<MemberListState> {
  @override
  Future<MemberListState> build() async {
    // Watching both is what makes an edit -- to the chips, the search box, or
    // the shell's branch switcher -- re-query from page one.
    final MemberListQuery query = ref.watch(memberQueryProvider);
    final BranchScope scope = ref.watch(branchScopeProvider);

    final MemberListResult result = await ref
        .read(membersRepositoryProvider)
        .listMembers(query, branchIds: scope.effectiveBranchIds);

    return MemberListState(
      rows: result.rows,
      total: result.total,
      page: result.page,
      pageSize: result.pageSize,
    );
  }

  /// Appends the next page. Does nothing when there is no more to fetch or a
  /// fetch is already in flight, so a fling at the bottom of the list cannot
  /// queue five identical requests.
  Future<void> loadMore() async {
    final MemberListState? current = state.value;
    if (current == null || !current.hasMore || current.loadingMore) {
      return;
    }

    state = AsyncValue<MemberListState>.data(
      current.copyWith(loadingMore: true, clearAppendFailure: true),
    );

    final MemberListQuery query = ref.read(memberQueryProvider);
    final BranchScope scope = ref.read(branchScopeProvider);
    final MemberListQuery next = MemberListQuery(
      q: query.q,
      status: query.status,
      page: current.page + 1,
      pageSize: query.pageSize,
    );

    try {
      final MemberListResult result = await ref
          .read(membersRepositoryProvider)
          .listMembers(next, branchIds: scope.effectiveBranchIds);
      state = AsyncValue<MemberListState>.data(
        MemberListState(
          rows: <MemberOverview>[...current.rows, ...result.rows],
          total: result.total,
          page: result.page,
          pageSize: result.pageSize,
        ),
      );
    } catch (error, stackTrace) {
      // A failed *append* must not blank the rows already on screen, so this
      // stays a data state and carries the failure in it. It still has to
      // reach the person -- a `42501` on page four means this desk may not
      // read that branch, not that the list ended (see
      // `lib/features/common/failure_view.dart`).
      state = AsyncValue<MemberListState>.data(
        current.copyWith(
          loadingMore: false,
          appendFailure: mapError(error, stackTrace),
        ),
      );
    }
  }

  /// Re-reads from page one, keeping the query. Used by pull-to-refresh and
  /// after a write elsewhere in the app.
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final memberListProvider =
    AsyncNotifierProvider<MemberList, MemberListState>(MemberList.new);

/// The summary strip above the list.
///
/// Its own provider rather than part of [MemberListState] because the counts
/// do not change when the desk pages or types: they answer "what does this
/// branch look like today", and re-running five count queries on every
/// keystroke would be five round trips for an answer that did not move.
/// Scoped to the same branches as the list so the strip and the rows cannot
/// describe different sets of people.
final memberStatusCountsProvider = FutureProvider<MemberStatusCounts>((
  ref,
) async {
  final BranchScope scope = ref.watch(branchScopeProvider);
  return ref
      .read(membersRepositoryProvider)
      .memberStatusCounts(branchIds: scope.effectiveBranchIds);
});
