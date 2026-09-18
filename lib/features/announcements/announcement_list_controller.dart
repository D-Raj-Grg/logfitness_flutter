// The announcements list's read side.
//
// Mirrors `listAnnouncements` in `logfitness_saas/lib/db/announcements.ts` and
// the paging on `app/(app)/announcements/page.tsx`. One notifier rather than
// the delivery log's two: there is nothing to filter. The console's list has no
// filters either -- a gym sends a handful of these a month, and reading is
// org-wide on purpose, because a manager who cannot see that the owner
// announced a national closure will announce it again.
//
// The paging shape is the log's, deliberately identical: a generation counter
// that throws away a page fetched against a list that has since started over,
// an append failure that rides inside the data state rather than blanking it,
// and a `refresh` that re-reads the loaded window instead of dropping a
// scrolled reader back to the top.
//
// Widgets call controllers; controllers call repositories (PLANNING.md §6).
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:logfitness_flutter/data/announcements/announcement_overview.dart';
import 'package:logfitness_flutter/data/announcements/announcement_queries.dart';
import 'package:logfitness_flutter/data/announcements/announcements_repository.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';

part 'announcement_list_controller.g.dart';

/// What the announcements tab renders.
class AnnouncementListState {
  const AnnouncementListState({
    required this.rows,
    required this.total,
    required this.page,
    required this.hasMore,
    this.loadingMore = false,
    this.appendFailure,
  });

  final List<AnnouncementOverview> rows;

  /// The count the database reports for the whole set, not the number loaded.
  final int total;

  final int page;
  final bool hasMore;

  /// True while a `loadMore` is in flight — a spinner under the list, not the
  /// empty screen that `AsyncValue.loading` means.
  final bool loadingMore;

  /// Set when fetching the *next* page failed. The rows on screen stay; a list
  /// that silently stops growing is indistinguishable from one that has ended.
  final AppFailure? appendFailure;

  /// How many messages across the loaded announcements are still moving. The
  /// live-refresh poller runs on exactly this number and stops at zero.
  int get pendingCount =>
      rows.fold<int>(0, (int sum, AnnouncementOverview row) => sum + row.queued);

  AnnouncementListState copyWith({
    List<AnnouncementOverview>? rows,
    int? total,
    int? page,
    bool? hasMore,
    bool? loadingMore,
    AppFailure? appendFailure,
    bool clearAppendFailure = false,
  }) {
    return AnnouncementListState(
      rows: rows ?? this.rows,
      total: total ?? this.total,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      loadingMore: loadingMore ?? this.loadingMore,
      appendFailure: clearAppendFailure
          ? null
          : (appendFailure ?? this.appendFailure),
    );
  }
}

@riverpod
class AnnouncementList extends _$AnnouncementList {
  /// Bumped every time the list starts over. An in-flight [loadMore] captures
  /// it and discards its answer if it has moved, because a page appended to a
  /// list that no longer exists is worse than no page at all.
  int _generation = 0;

  static const int _pageSize = 20;

  @override
  Future<AnnouncementListState> build() async {
    _generation++;
    final AnnouncementPage page = await ref
        .read(announcementsRepositoryProvider)
        .listAnnouncements(const AnnouncementListFilter(pageSize: _pageSize));

    return AnnouncementListState(
      rows: page.rows,
      total: page.total,
      page: page.page,
      hasMore: page.hasMore,
    );
  }

  /// Appends the next page. A no-op when there is nothing more or a fetch is
  /// already running, so a fling at the bottom cannot queue five requests.
  Future<void> loadMore() async {
    final AnnouncementListState? current = state.value;
    if (current == null || !current.hasMore || current.loadingMore) return;

    state = AsyncValue<AnnouncementListState>.data(
      current.copyWith(loadingMore: true, clearAppendFailure: true),
    );

    final int startedAt = _generation;

    try {
      final AnnouncementPage page = await ref
          .read(announcementsRepositoryProvider)
          .listAnnouncements(
            AnnouncementListFilter(
              page: current.page + 1,
              pageSize: _pageSize,
            ),
          );
      if (_generation != startedAt) return;
      state = AsyncValue<AnnouncementListState>.data(
        AnnouncementListState(
          rows: <AnnouncementOverview>[...current.rows, ...page.rows],
          total: page.total,
          page: page.page,
          hasMore: page.hasMore,
        ),
      );
    } catch (error, stackTrace) {
      if (_generation != startedAt) return;
      state = AsyncValue<AnnouncementListState>.data(
        current.copyWith(
          loadingMore: false,
          appendFailure: mapError(error, stackTrace),
        ),
      );
    }
  }

  /// Re-reads what is already on screen. Used after a send or a cancel, by
  /// pull-to-refresh, and by the poller.
  ///
  /// Deliberately **not** `ref.invalidateSelf()`, for the reason written out at
  /// length in `notification_log_controller.dart`: that renders a loading state
  /// on every poll, replacing a list somebody is watching with a spinner.
  Future<void> refresh() async {
    final AnnouncementListState? current = state.value;
    final int pagesLoaded = current?.page ?? 1;
    final int windowSize = _pageSize * pagesLoaded;

    _generation++;

    try {
      final AnnouncementPage page = await ref
          .read(announcementsRepositoryProvider)
          .listAnnouncements(AnnouncementListFilter(pageSize: windowSize));

      state = AsyncValue<AnnouncementListState>.data(
        AnnouncementListState(
          rows: page.rows,
          total: page.total,
          // The logical page count, not the one-big-page the request used, so
          // `loadMore` carries on from where the reader actually is.
          page: pagesLoaded,
          hasMore: windowSize < page.total,
        ),
      );
    } catch (error, stackTrace) {
      final AnnouncementListState? keep = state.value;
      if (keep == null) {
        state = AsyncValue<AnnouncementListState>.error(
          mapError(error, stackTrace),
          stackTrace,
        );
        return;
      }
      state = AsyncValue<AnnouncementListState>.data(
        keep.copyWith(
          loadingMore: false,
          appendFailure: mapError(error, stackTrace),
        ),
      );
    }
  }
}

/// How many messages across the loaded announcements are still queued.
///
/// A separate `int`-valued provider rather than a `select` on the list, for the
/// same reason `notificationPendingCount` is one: a generated notifier provider
/// exposes no `select`, and the poller must not be rebuilt by every appended
/// page.
@riverpod
int announcementPendingCount(Ref ref) =>
    ref.watch(announcementListProvider).value?.pendingCount ?? 0;
