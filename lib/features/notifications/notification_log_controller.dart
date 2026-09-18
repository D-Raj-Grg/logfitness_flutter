// The delivery log's read side.
//
// Two notifiers rather than one, exactly as the visitor log does it: the
// filter is state a person edits (a chip row, a search field, a branch
// switch), and the page of rows is state the database owns. Keeping them
// apart means changing a filter re-runs the query from page one -- the only
// correct behaviour, because page 3 of the old filter has nothing to do with
// page 3 of the new one -- while scrolling appends without disturbing the
// filter.
//
// Nothing here is a security boundary. RLS already bounds `notification_messages`
// to the org and, for anyone who is not an owner or a manager, to their own
// branches, before a single one of these filters is applied.
//
// Widgets call controllers; controllers call repositories (PLANNING.md §6).
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:logfitness_flutter/data/notifications/notification_message.dart';
import 'package:logfitness_flutter/data/notifications/notification_queries.dart';
import 'package:logfitness_flutter/data/notifications/notifications_repository.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/features/staff/branch_scope.dart';

part 'notification_log_controller.g.dart';

/// The slice of the log the screen is currently showing.
///
/// Opens unfiltered, unlike the visitor log: a delivery log is read to find
/// out what happened last night, and "last night" includes the messages that
/// went out fine. Narrowing to failures by default would answer a question
/// nobody asked and hide the denominator.
@riverpod
class NotificationFilter extends _$NotificationFilter {
  @override
  NotificationListFilter build() {
    // The branch scope is seeded here rather than pushed in from the screen
    // after the first frame. It has to be: the list notifier watches this one,
    // so whatever this returns is what the *first* query carries, and a filter
    // that starts null means "every branch RLS allows". A manager with Thamel
    // selected would get one painted frame of the whole chain's delivery log --
    // other branches' phone numbers and message bodies -- before it narrowed.
    // RLS permits those rows, so nothing leaks past the tenant boundary; it is
    // still the wrong answer on screen, and `notificationStatusCounts` reads
    // the scope directly, so the strip and the list would disagree for a frame.
    //
    // Watching also means the switcher re-queries from page one on its own.
    // That resets the reader's other narrowings, which is the right trade: a
    // branch change is a change of subject, and page 3 of Thamel's failures is
    // not page 3 of Hetauda's.
    final BranchScope scope = ref.watch(branchScopeProvider);
    return NotificationListFilter(branchIds: scope.effectiveBranchIds);
  }

  void setStatus(NotificationStatus? status) {
    state = _copy(status: status, clearStatus: status == null);
  }

  void setEvent(NotificationEvent? event) {
    state = _copy(event: event, clearEvent: event == null);
  }

  void setChannel(NotificationChannel? channel) {
    state = _copy(channel: channel, clearChannel: channel == null);
  }

  void setQuery(String? query) {
    final String? trimmed = query?.trim();
    final String? next = (trimmed == null || trimmed.isEmpty) ? null : trimmed;
    state = _copy(query: next, clearQuery: next == null);
  }

  /// Set from the shell's branch scope. A null list means "every branch RLS
  /// allows"; an empty list is a real filter matching nothing, so the caller
  /// must not conflate the two -- the branch switcher may not silently widen.
  void setBranchIds(List<String>? branchIds) {
    state = _copy(branchIds: branchIds, clearBranchIds: branchIds == null);
  }

  /// Drops every narrowing the reader added. The branch scope survives: it is
  /// the shell's selection, not a filter this screen owns.
  void clear() {
    state = NotificationListFilter(
      branchIds: ref.read(branchScopeProvider).effectiveBranchIds,
      pageSize: state.pageSize,
    );
  }

  /// The `clearX` flags are what make `null` expressible. Without them
  /// `_copy(status: null)` is indistinguishable from "leave status alone",
  /// and a chip that is tapped off never turns the filter off.
  NotificationListFilter _copy({
    List<String>? branchIds,
    NotificationStatus? status,
    NotificationEvent? event,
    NotificationChannel? channel,
    String? query,
    bool clearBranchIds = false,
    bool clearStatus = false,
    bool clearEvent = false,
    bool clearChannel = false,
    bool clearQuery = false,
  }) {
    return NotificationListFilter(
      branchIds: clearBranchIds ? null : (branchIds ?? state.branchIds),
      status: clearStatus ? null : (status ?? state.status),
      event: clearEvent ? null : (event ?? state.event),
      channel: clearChannel ? null : (channel ?? state.channel),
      query: clearQuery ? null : (query ?? state.query),
      pageSize: state.pageSize,
    );
  }
}

/// What the log screen renders: the rows loaded so far, and whether asking
/// for more is worth doing.
class NotificationLogState {
  const NotificationLogState({
    required this.rows,
    required this.total,
    required this.page,
    required this.hasMore,
    this.loadingMore = false,
    this.appendFailure,
  });

  final List<NotificationMessage> rows;

  /// The count the database reports for the whole filter, not the number
  /// loaded. "20 of 413 messages" needs both.
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

  /// How many of the loaded rows are still moving. The live-refresh poller
  /// runs on exactly this number, and stops the moment it reaches zero.
  int get pendingCount =>
      rows.where((NotificationMessage row) => row.isPending).length;

  NotificationLogState copyWith({
    List<NotificationMessage>? rows,
    int? total,
    int? page,
    bool? hasMore,
    bool? loadingMore,
    AppFailure? appendFailure,
    bool clearAppendFailure = false,
  }) {
    return NotificationLogState(
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
class NotificationLog extends _$NotificationLog {
  /// Bumped every time the list starts over -- a filter change (which re-runs
  /// [build]) or a [refresh]. An in-flight [loadMore] captures it and throws
  /// its answer away if it has moved, because a page fetched against the old
  /// filter appended to the new list is worse than no page at all: the chips
  /// would say "Failed" over a list that is mostly not.
  int _generation = 0;

  @override
  Future<NotificationLogState> build() async {
    _generation++;
    // Watching the filter is what makes an edit re-query from page one.
    final NotificationListFilter filter = ref.watch(notificationFilterProvider);
    final NotificationPage page = await ref
        .read(notificationsRepositoryProvider)
        .listNotifications(filter);

    return NotificationLogState(
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
    final NotificationLogState? current = state.value;
    if (current == null || !current.hasMore || current.loadingMore) {
      return;
    }

    state = AsyncValue<NotificationLogState>.data(
      current.copyWith(loadingMore: true, clearAppendFailure: true),
    );

    final NotificationListFilter filter = ref.read(notificationFilterProvider);
    final NotificationListFilter next = NotificationListFilter(
      branchIds: filter.branchIds,
      status: filter.status,
      event: filter.event,
      channel: filter.channel,
      query: filter.query,
      page: current.page + 1,
      pageSize: filter.pageSize,
    );

    final int startedAt = _generation;

    try {
      final NotificationPage page = await ref
          .read(notificationsRepositoryProvider)
          .listNotifications(next);
      // The list started over while this page was in flight -- someone changed
      // a filter, or the poller re-read page one underneath it. Whatever came
      // back describes a list that no longer exists.
      if (_generation != startedAt) return;
      state = AsyncValue<NotificationLogState>.data(
        NotificationLogState(
          rows: <NotificationMessage>[...current.rows, ...page.rows],
          total: page.total,
          page: page.page,
          hasMore: page.hasMore,
        ),
      );
    } catch (error, stackTrace) {
      if (_generation != startedAt) return;
      // A failed *append* must not blank the rows already on screen, so this
      // stays a data state and carries the failure in it. The failure still
      // has to reach the person: the screen reads `appendFailure` and shows
      // it, because a silently truncated list is indistinguishable from a
      // list that has ended.
      state = AsyncValue<NotificationLogState>.data(
        current.copyWith(
          loadingMore: false,
          appendFailure: mapError(error, stackTrace),
        ),
      );
    }
  }

  /// Re-reads what is already on screen, keeping the filter. Used after a
  /// resend or a cancel, by pull-to-refresh, and by the live-refresh poller.
  ///
  /// Deliberately **not** `ref.invalidateSelf()`. That puts the provider into
  /// `AsyncLoading`, and `AsyncValueView` renders a loading state on a refresh
  /// (`skipLoadingOnRefresh: false`), so every eight-second poll would replace
  /// the whole list with a full-screen spinner and drop the reader back to the
  /// top -- on the one screen whose entire point is watching rows change while
  /// you look at them.
  ///
  /// It also re-reads every page the reader has loaded rather than dropping
  /// back to page one, in a single request: shortening the list under a
  /// scrolled reader moves the ground under them just as badly as blanking it.
  /// One request, because the rows are contiguous from the top -- `range(0, n)`
  /// is the same query with a wider window.
  Future<void> refresh() async {
    final NotificationLogState? current = state.value;
    final NotificationListFilter filter = ref.read(notificationFilterProvider);
    final int pagesLoaded = current?.page ?? 1;
    final int windowSize = filter.pageSize * pagesLoaded;

    _generation++;

    final NotificationListFilter window = NotificationListFilter(
      branchIds: filter.branchIds,
      status: filter.status,
      event: filter.event,
      channel: filter.channel,
      query: filter.query,
      pageSize: windowSize,
    );

    try {
      final NotificationPage page = await ref
          .read(notificationsRepositoryProvider)
          .listNotifications(window);

      state = AsyncValue<NotificationLogState>.data(
        NotificationLogState(
          rows: page.rows,
          total: page.total,
          // The logical page count, not the synthetic one-big-page the request
          // used, so `loadMore` carries on from where the reader actually is.
          page: pagesLoaded,
          hasMore: windowSize < page.total,
        ),
      );
    } catch (error, stackTrace) {
      final NotificationLogState? keep = state.value;
      if (keep == null) {
        // Nothing on screen to protect: the first load is still the first load,
        // and an error state is the honest answer.
        state = AsyncValue<NotificationLogState>.error(
          mapError(error, stackTrace),
          stackTrace,
        );
        return;
      }
      // A failed re-read must not blank a list someone is reading, for the same
      // reason a failed append must not. It rides the same channel.
      state = AsyncValue<NotificationLogState>.data(
        keep.copyWith(
          loadingMore: false,
          appendFailure: mapError(error, stackTrace),
        ),
      );
    }
  }
}

/// How many messages are sitting in each of the four states the summary strip
/// shows.
///
/// Watches the branch scope rather than the filter: the strip is the
/// denominator the filter is read against, so narrowing to "Failed" must not
/// also change the number beside "Failed".
@riverpod
Future<NotificationStatusCounts> notificationStatusCounts(Ref ref) async {
  final BranchScope scope = ref.watch(branchScopeProvider);
  return ref
      .read(notificationsRepositoryProvider)
      .notificationStatusCounts(scope.effectiveBranchIds, kSummaryStatuses);
}
