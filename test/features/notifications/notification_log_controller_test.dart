// Exercises the delivery log's controllers against a fake
// NotificationsRepository -- no network, no real Supabase client. The fake
// `implements` the repository, the house pattern from
// visitor_controllers_test.dart, so the controller is tested through the same
// surface a screen calls.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/notifications/notification_message.dart';
import 'package:logfitness_flutter/data/notifications/notification_queries.dart';
import 'package:logfitness_flutter/data/notifications/notifications_repository.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/features/notifications/notification_log_controller.dart';
import 'package:logfitness_flutter/features/staff/branch_scope.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

NotificationMessage notificationRow(
  String id, {
  NotificationStatus status = NotificationStatus.sent,
}) => NotificationMessage(
  id: id,
  orgId: 'org-1',
  branchId: 'branch-1',
  channel: NotificationChannel.sms,
  event: NotificationEvent.renewalReminder,
  toAddress: '9800000000',
  body: 'Your membership ends on Friday.',
  status: status,
  attempts: 1,
  scheduledFor: DateTime.utc(2026, 9, 12, 2),
  nextAttemptAt: DateTime.utc(2026, 9, 12, 2),
  dedupeKey: 'renewal:$id',
  createdAt: DateTime.utc(2026, 9, 12, 2),
  updatedAt: DateTime.utc(2026, 9, 12, 2),
);

class FakeNotificationsRepository implements NotificationsRepository {
  final List<NotificationListFilter> listCalls = <NotificationListFilter>[];

  /// Total the fake reports, which drives `hasMore`.
  int total = 2;
  int pageSize = 1;

  /// Thrown by the *next* `listNotifications` only, which is how a page-two
  /// failure is staged without breaking page one.
  Object? nextListError;
  Object? listError;

  /// Status of the rows the fake hands back. The live-refresh tests move this.
  NotificationStatus rowStatus = NotificationStatus.sent;

  List<String>? lastCountBranchIds;
  List<NotificationStatus>? lastCountStatuses;

  @override
  Future<NotificationPage> listNotifications(
    NotificationListFilter filter,
  ) async {
    listCalls.add(filter);
    if (listError != null) throw listError!;
    if (nextListError != null) {
      final Object error = nextListError!;
      nextListError = null;
      throw error;
    }
    return NotificationPage(
      rows: <NotificationMessage>[
        notificationRow('n-${filter.page}', status: rowStatus),
      ],
      total: total,
      page: filter.page,
      pageSize: pageSize,
    );
  }

  @override
  Future<NotificationStatusCounts> notificationStatusCounts(
    List<String>? branchIds,
    List<NotificationStatus> statuses,
  ) async {
    lastCountBranchIds = branchIds;
    lastCountStatuses = statuses;
    return NotificationStatusCounts(<NotificationStatus, int>{
      for (final NotificationStatus status in statuses) status: 3,
    });
  }

  int retryCallCount = 0;
  int cancelCallCount = 0;
  Object? writeError;

  @override
  Future<void> retryNotification(String notificationId) async {
    retryCallCount++;
    if (writeError != null) throw writeError!;
  }

  @override
  Future<void> cancelNotification(String notificationId) async {
    cancelCallCount++;
    if (writeError != null) throw writeError!;
  }

  @override
  Never noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not faked');
}

void main() {
  late FakeNotificationsRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = FakeNotificationsRepository();
    container = ProviderContainer(
      // Untyped literal on purpose: `Override` is not exported by
      // flutter_riverpod 3.1.0 (TASKS.md, Discovered, 2026-09-05).
      overrides: [
        notificationsRepositoryProvider.overrideWithValue(repository),
        branchScopeProvider.overrideWithValue(
          const BranchScope(
            options: <String>['branch-1'],
            selectedBranchId: 'branch-1',
            isOrgWide: false,
          ),
        ),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('NotificationFilter', () {
    test('opens on the whole log, not on the failures', () {
      final NotificationListFilter filter = container.read(
        notificationFilterProvider,
      );
      expect(filter.status, isNull);
      expect(filter.isFiltered, isFalse);
    });

    test('a null status is a real clear, not "leave it alone"', () {
      final NotificationFilter notifier = container.read(
        notificationFilterProvider.notifier,
      )..setStatus(NotificationStatus.failed);
      expect(
        container.read(notificationFilterProvider).status,
        NotificationStatus.failed,
      );

      notifier.setStatus(null);
      expect(container.read(notificationFilterProvider).status, isNull);
    });

    test('an empty branch list is a filter, never widened to "all"', () {
      container
          .read(notificationFilterProvider.notifier)
          .setBranchIds(const <String>[]);
      expect(
        container.read(notificationFilterProvider).branchIds,
        isEmpty,
        reason: 'null means every branch RLS allows; empty means none',
      );
    });

    test('clear keeps the branch scope, which the shell owns', () {
      container.read(notificationFilterProvider.notifier)
        ..setBranchIds(const <String>['branch-1'])
        ..setQuery('9800')
        ..setEvent(NotificationEvent.duesReminder)
        ..clear();

      final NotificationListFilter filter = container.read(
        notificationFilterProvider,
      );
      expect(filter.query, isNull);
      expect(filter.event, isNull);
      expect(filter.branchIds, <String>['branch-1']);
    });
  });

  group('NotificationLog', () {
    test('reads page one and reports what the database counted', () async {
      final NotificationLogState state = await container.read(
        notificationLogProvider.future,
      );

      expect(state.rows.single.id, 'n-1');
      expect(state.page, 1);
      expect(state.total, 2);
      expect(state.hasMore, isTrue);
      expect(repository.listCalls.single.page, 1);
    });

    test('a filter change re-queries from page one', () async {
      await container.read(notificationLogProvider.future);
      await container.read(notificationLogProvider.notifier).loadMore();
      expect(container.read(notificationLogProvider).value?.page, 2);

      container
          .read(notificationFilterProvider.notifier)
          .setStatus(NotificationStatus.failed);
      final NotificationLogState state = await container.read(
        notificationLogProvider.future,
      );

      // Page 3 of the old filter has nothing to do with page 3 of the new one.
      expect(state.page, 1);
      expect(repository.listCalls.last.page, 1);
      expect(repository.listCalls.last.status, NotificationStatus.failed);
    });

    test('loadMore appends rather than replacing', () async {
      await container.read(notificationLogProvider.future);
      await container.read(notificationLogProvider.notifier).loadMore();

      final NotificationLogState state = container
          .read(notificationLogProvider)
          .value!;
      expect(
        state.rows.map((NotificationMessage row) => row.id),
        <String>['n-1', 'n-2'],
      );
      expect(state.page, 2);
      expect(state.hasMore, isFalse);
    });

    test('loadMore is a no-op once there is nothing more to fetch', () async {
      repository.total = 1;
      await container.read(notificationLogProvider.future);
      await container.read(notificationLogProvider.notifier).loadMore();

      expect(repository.listCalls.length, 1);
    });

    test(
      'a failed page two keeps page one on screen and says what happened',
      () async {
        await container.read(notificationLogProvider.future);
        repository.nextListError = const PostgrestException(
          message: 'canceling statement due to statement timeout',
          code: '57014',
        );

        await container.read(notificationLogProvider.notifier).loadMore();

        final NotificationLogState state = container
            .read(notificationLogProvider)
            .value!;
        // The rows a person is reading survive a failure further down.
        expect(state.rows.single.id, 'n-1');
        expect(state.loadingMore, isFalse);
        // And the failure is held rather than swallowed -- a list that
        // silently stops growing reads as a list that has ended.
        expect(state.appendFailure, isNotNull);
      },
    );

    test('pendingCount counts only what is still moving', () async {
      repository.rowStatus = NotificationStatus.queued;
      final NotificationLogState state = await container.read(
        notificationLogProvider.future,
      );
      expect(state.pendingCount, 1);

      expect(
        notificationRow('x', status: NotificationStatus.skipped).isPending,
        isFalse,
      );
    });
  });

  group('notificationStatusCounts', () {
    test('counts the branch scope, not the filter', () async {
      container
          .read(notificationFilterProvider.notifier)
          .setStatus(NotificationStatus.failed);

      final NotificationStatusCounts counts = await container.read(
        notificationStatusCountsProvider.future,
      );

      expect(repository.lastCountBranchIds, <String>['branch-1']);
      expect(repository.lastCountStatuses, kSummaryStatuses);
      expect(counts[NotificationStatus.sent], 3);
    });
  });

  group('regressions found in the 2026-09-12 review', () {
    test('refresh never blanks the list to a loading state', () async {
      // `AsyncValueView` renders a spinner for `AsyncLoading` even when it
      // carries a previous value (`skipLoadingOnRefresh: false`), so a refresh
      // that goes through `invalidateSelf` replaces the whole log with a
      // full-screen spinner -- every eight seconds, on the one screen whose
      // point is watching rows change while you look at them.
      await container.read(notificationLogProvider.future);

      final List<bool> sawLoading = <bool>[];
      container.listen(notificationLogProvider, (
        AsyncValue<NotificationLogState>? previous,
        AsyncValue<NotificationLogState> next,
      ) {
        sawLoading.add(next.isLoading);
      }, fireImmediately: true);

      await container.read(notificationLogProvider.notifier).refresh();

      expect(sawLoading, everyElement(isFalse));
      expect(container.read(notificationLogProvider).value?.rows, isNotEmpty);
    });

    test('refresh re-reads every loaded page, not just the first', () async {
      repository.total = 3;
      await container.read(notificationLogProvider.future);
      await container.read(notificationLogProvider.notifier).loadMore();
      expect(container.read(notificationLogProvider).value?.page, 2);

      repository.listCalls.clear();
      await container.read(notificationLogProvider.notifier).refresh();

      // One request, widened, rather than dropping the reader back to page one
      // and shortening the list under their scroll.
      expect(repository.listCalls, hasLength(1));
      expect(repository.listCalls.single.page, 1);
      // The window is the filter's own page size times the pages loaded, in
      // one request: `range(0, n)` is the same query through a wider window.
      expect(
        repository.listCalls.single.pageSize,
        const NotificationListFilter().pageSize * 2,
      );
      expect(container.read(notificationLogProvider).value?.page, 2);
    });

    test('a page that lands after the filter changed is thrown away', () async {
      repository.total = 9;
      await container.read(notificationLogProvider.future);

      // Page two is in flight when the reader taps a status chip.
      final Future<void> pending = container
          .read(notificationLogProvider.notifier)
          .loadMore();
      container
          .read(notificationFilterProvider.notifier)
          .setStatus(NotificationStatus.failed);
      await container.read(notificationLogProvider.future);
      await pending;

      // Without the generation guard this is 2: a row fetched under the old
      // filter appended to a list the chips claim is only failures.
      expect(container.read(notificationLogProvider).value?.rows, hasLength(1));
    });

    test('the first query is already branch-scoped', () async {
      // The scope used to be pushed in from the screen after the first frame,
      // so page one was fetched unscoped and a manager got one painted frame of
      // the whole chain's messages before it narrowed.
      await container.read(notificationLogProvider.future);

      expect(repository.listCalls.first.branchIds, <String>['branch-1']);
    });
  });

}
