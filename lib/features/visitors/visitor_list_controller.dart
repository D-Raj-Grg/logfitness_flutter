// The visitor log's read side.
//
// Two notifiers rather than one: the filter is state a person edits (a chip
// row, a search field, a branch switch), and the page of rows is state the
// database owns. Keeping them apart means changing a filter re-runs the query
// from page one -- which is the only correct behaviour, because page 3 of the
// old filter has nothing to do with page 3 of the new one -- while scrolling
// appends without disturbing the filter.
//
// Widgets call controllers; controllers call repositories (PLANNING.md §6).
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:logfitness_flutter/data/visitors/visitor.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/data/visitors/visitors_repository.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';

part 'visitor_list_controller.g.dart';

/// The filter the log is currently showing.
///
/// Defaults to the callbacks the desk still owes -- `open` is
/// `new` + `contacted`, matching the `visitors_open_idx` partial index
/// upstream. A log opens on the work, not on the archive.
@riverpod
class VisitorFilter extends _$VisitorFilter {
  @override
  VisitorListFilter build() =>
      const VisitorListFilter(status: VisitorStatusFilter.open);

  void setStatus(VisitorStatusFilter? status) {
    state = _copy(status: status, clearStatus: status == null);
  }

  void setKind(VisitorKind? kind) {
    state = _copy(kind: kind, clearKind: kind == null);
  }

  void setQuery(String? query) {
    final trimmed = query?.trim();
    final next = (trimmed == null || trimmed.isEmpty) ? null : trimmed;
    state = _copy(query: next, clearQuery: next == null);
  }

  /// Set from the shell's branch scope. A null list means "every branch RLS
  /// allows"; an empty list is a real filter matching nothing, so the caller
  /// must not conflate the two.
  void setBranchIds(List<String>? branchIds) {
    state = _copy(branchIds: branchIds, clearBranchIds: branchIds == null);
  }

  void setVisitedRange({DateTime? from, DateTime? to}) {
    state = _copy(
      visitedFrom: from,
      visitedTo: to,
      clearVisitedFrom: from == null,
      clearVisitedTo: to == null,
    );
  }

  void clear() {
    state = const VisitorListFilter(status: VisitorStatusFilter.open);
  }

  VisitorListFilter _copy({
    List<String>? branchIds,
    VisitorStatusFilter? status,
    VisitorKind? kind,
    String? query,
    DateTime? visitedFrom,
    DateTime? visitedTo,
    bool clearBranchIds = false,
    bool clearStatus = false,
    bool clearKind = false,
    bool clearQuery = false,
    bool clearVisitedFrom = false,
    bool clearVisitedTo = false,
  }) {
    return VisitorListFilter(
      branchIds: clearBranchIds ? null : (branchIds ?? state.branchIds),
      status: clearStatus ? null : (status ?? state.status),
      kind: clearKind ? null : (kind ?? state.kind),
      query: clearQuery ? null : (query ?? state.query),
      visitedFrom:
          clearVisitedFrom ? null : (visitedFrom ?? state.visitedFrom),
      visitedTo: clearVisitedTo ? null : (visitedTo ?? state.visitedTo),
      pageSize: state.pageSize,
    );
  }
}

/// What the log screen renders: the rows loaded so far, and whether asking
/// for more is worth doing.
class VisitorListState {
  const VisitorListState({
    required this.rows,
    required this.total,
    required this.page,
    required this.hasMore,
    this.loadingMore = false,
    this.appendFailure,
  });

  final List<Visitor> rows;

  /// The count the database reports for the whole filter, not the number
  /// loaded. "12 of 87 walk-ins" needs both.
  final int total;

  final int page;
  final bool hasMore;

  /// True while a `loadMore` is in flight. Distinct from the notifier's own
  /// `AsyncValue.loading`, which means the *first* page is loading: a spinner
  /// at the bottom of a list is a different thing from an empty screen.
  final bool loadingMore;

  /// Set when fetching the *next* page failed. The rows already on screen
  /// stay -- blanking a list someone is reading because page four timed out
  /// is a worse answer than leaving it and saying so. The screen shows this
  /// as a snackbar and a retry on the footer, then clears it.
  final AppFailure? appendFailure;

  VisitorListState copyWith({
    List<Visitor>? rows,
    int? total,
    int? page,
    bool? hasMore,
    bool? loadingMore,
    AppFailure? appendFailure,
    bool clearAppendFailure = false,
  }) {
    return VisitorListState(
      rows: rows ?? this.rows,
      total: total ?? this.total,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      loadingMore: loadingMore ?? this.loadingMore,
      appendFailure:
          clearAppendFailure ? null : (appendFailure ?? this.appendFailure),
    );
  }
}

@riverpod
class VisitorList extends _$VisitorList {
  @override
  Future<VisitorListState> build() async {
    // Watching the filter is what makes an edit re-query from page one.
    final filter = ref.watch(visitorFilterProvider);
    final page = await ref
        .read(visitorsRepositoryProvider)
        .listVisitors(filter);

    return VisitorListState(
      rows: page.rows,
      total: page.total,
      page: page.page,
      hasMore: page.hasMore,
    );
  }

  /// Appends the next page. Does nothing when there is no more to fetch or a
  /// fetch is already in flight, so a fling at the bottom of the list cannot
  /// queue five identical requests.
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.loadingMore) {
      return;
    }

    state = AsyncValue<VisitorListState>.data(
      current.copyWith(loadingMore: true, clearAppendFailure: true),
    );

    final filter = ref.read(visitorFilterProvider);
    final next = VisitorListFilter(
      branchIds: filter.branchIds,
      status: filter.status,
      kind: filter.kind,
      query: filter.query,
      visitedFrom: filter.visitedFrom,
      visitedTo: filter.visitedTo,
      page: current.page + 1,
      pageSize: filter.pageSize,
    );

    try {
      final page =
          await ref.read(visitorsRepositoryProvider).listVisitors(next);
      state = AsyncValue<VisitorListState>.data(
        VisitorListState(
          rows: <Visitor>[...current.rows, ...page.rows],
          total: page.total,
          page: page.page,
          hasMore: page.hasMore,
        ),
      );
    } catch (error, stackTrace) {
      // A failed *append* must not blank the rows already on screen, so this
      // stays a data state and carries the failure in it. The failure still
      // has to reach the person: the screen reads `appendFailure` and shows
      // it, because a silently truncated list is indistinguishable from a
      // list that has ended.
      state = AsyncValue<VisitorListState>.data(
        current.copyWith(
          loadingMore: false,
          appendFailure: mapError(error, stackTrace),
        ),
      );
    }
  }

  /// Re-reads from page one, keeping the filter. Used after a write and by
  /// pull-to-refresh.
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
