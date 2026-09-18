// The delivery log screen, checked where it can fail silently: a refused read
// that looks empty, an empty log that looks refused, and a row menu offered to
// someone the database is going to turn down.
//
// `Override` is not exported by flutter_riverpod 3.1.0, so every overrides
// list stays an untyped literal (TASKS.md, Discovered, 2026-09-05).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/notifications/notification_message.dart';
import 'package:logfitness_flutter/data/notifications/notification_queries.dart';
import 'package:logfitness_flutter/data/notifications/notifications_repository.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/features/common/failure_view.dart';
import 'package:logfitness_flutter/features/notifications/notification_live_refresh.dart';
import 'package:logfitness_flutter/features/notifications/notification_log_screen.dart';
import 'package:logfitness_flutter/features/notifications/widgets/notification_tile.dart';
import 'package:logfitness_flutter/features/staff/branch_scope.dart';
import 'package:logfitness_flutter/features/staff/staff_capabilities.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

NotificationMessage _row(
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

class _FakeNotificationsRepository implements NotificationsRepository {
  _FakeNotificationsRepository({
    this.rows = const <NotificationMessage>[],
    this.error,
  });

  List<NotificationMessage> rows;
  Object? error;
  NotificationListFilter? lastFilter;

  @override
  Future<NotificationPage> listNotifications(
    NotificationListFilter filter,
  ) async {
    lastFilter = filter;
    if (error != null) throw error!;
    return NotificationPage(
      rows: rows,
      total: rows.length,
      page: filter.page,
      pageSize: filter.pageSize,
    );
  }

  @override
  Future<NotificationStatusCounts> notificationStatusCounts(
    List<String>? branchIds,
    List<NotificationStatus> statuses,
  ) async {
    return NotificationStatusCounts(<NotificationStatus, int>{
      for (final NotificationStatus status in statuses) status: 3,
    });
  }

  final List<String> retried = <String>[];
  final List<String> cancelled = <String>[];

  /// A real RPC is not instant, and the bug this fake exists to catch only
  /// appears across an await: the write notifier used to be auto-disposed, so
  /// by the time the call returned its `Ref` was dead and the confirmation
  /// never reached the screen.
  Duration writeDelay = const Duration(milliseconds: 50);

  @override
  Future<void> retryNotification(String notificationId) async {
    await Future<void>.delayed(writeDelay);
    retried.add(notificationId);
  }

  @override
  Future<void> cancelNotification(String notificationId) async {
    await Future<void>.delayed(writeDelay);
    cancelled.add(notificationId);
  }

  @override
  Never noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not faked');
}

Future<void> _pump(
  WidgetTester tester,
  _FakeNotificationsRepository repository, {
  Set<StaffCapability> capabilities = const <StaffCapability>{
    StaffCapability.viewNotificationLog,
  },
}) async {
  await tester.pumpWidget(
    ProviderScope(
      // Spread into an untyped literal so inference supplies `Override`,
      // which flutter_riverpod 3.1.0 does not export.
      overrides: [
        notificationsRepositoryProvider.overrideWithValue(repository),
        staffCapabilitiesProvider.overrideWithValue(capabilities),
        branchScopeProvider.overrideWithValue(
          const BranchScope(
            options: <String>['branch-1'],
            selectedBranchId: 'branch-1',
            isOrgWide: false,
          ),
        ),
        // No row in these tests is pending, so no timer starts -- but an
        // interval this long means a stray one could never fire inside a
        // `pumpAndSettle` either.
        notificationPollIntervalProvider.overrideWithValue(
          const Duration(hours: 1),
        ),
      ],
      child: const MaterialApp(home: NotificationLogScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('NotificationLogScreen', () {
    testWidgets('renders a row per message', (WidgetTester tester) async {
      await _pump(
        tester,
        _FakeNotificationsRepository(
          rows: <NotificationMessage>[_row('n-1'), _row('n-2')],
        ),
      );

      expect(find.byType(NotificationTile), findsNWidgets(2));
    });

    testWidgets('the summary strip carries the database\'s own counts', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        _FakeNotificationsRepository(rows: <NotificationMessage>[_row('n-1')]),
      );

      // The console's wording, verbatim: "Not sent" is not "Skipped" to the
      // person being asked whether a member was told.
      expect(find.text('Delivered 3'), findsOneWidget);
      expect(find.text('Waiting 3'), findsOneWidget);
      expect(find.text('Failed 3'), findsOneWidget);
      expect(find.text('Not sent 3'), findsOneWidget);
    });

    testWidgets('an empty log says so, and does not blame a filter', (
      WidgetTester tester,
    ) async {
      await _pump(tester, _FakeNotificationsRepository());

      // The second sentence is the console's, and it is the half that tells an
      // owner what to do next, so it is asserted rather than tolerated.
      expect(
        find.textContaining('Nothing has been sent yet'),
        findsOneWidget,
      );
      expect(
        find.textContaining('gateway is set up in Settings'),
        findsOneWidget,
      );
      expect(find.text('Clear filters'), findsNothing);
    });

    testWidgets('an empty *filtered* log says it is the filter', (
      WidgetTester tester,
    ) async {
      await _pump(tester, _FakeNotificationsRepository());

      final Finder failedChip = find.byKey(
        const ValueKey<String>('notification-filter-failed'),
      );
      await tester.ensureVisible(failedChip);
      await tester.tap(failedChip);
      await tester.pumpAndSettle();

      expect(find.text('Nothing matches this filter.'), findsOneWidget);
      expect(find.text('Clear filters'), findsOneWidget);
    });

    testWidgets('a refusal renders as a refusal, not an empty log', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        _FakeNotificationsRepository(
          error: const PostgrestException(
            message: 'permission denied for table notification_messages',
            code: '42501',
          ),
        ),
      );

      // The distinction this whole surface exists for: refused is not empty,
      // and it is not a generic error either.
      expect(find.byType(FailureView), findsOneWidget);
      expect(find.textContaining('refused'), findsWidgets);
      expect(find.text('Nothing has been sent yet'), findsNothing);
    });

    testWidgets('a status chip changes what is asked for', (
      WidgetTester tester,
    ) async {
      final _FakeNotificationsRepository repository =
          _FakeNotificationsRepository(
            rows: <NotificationMessage>[_row('n-1')],
          );
      await _pump(tester, repository);

      final Finder skippedChip = find.byKey(
        const ValueKey<String>('notification-filter-skipped'),
      );
      await tester.ensureVisible(skippedChip);
      await tester.tap(skippedChip);
      await tester.pumpAndSettle();

      expect(repository.lastFilter?.status, NotificationStatus.skipped);
      expect(repository.lastFilter?.page, 1);
    });

    testWidgets('the row menu is offered to a log holder', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        _FakeNotificationsRepository(
          rows: <NotificationMessage>[
            _row('n-1', status: NotificationStatus.failed),
          ],
        ),
      );

      await tester.tap(
        find.byKey(const ValueKey<String>('notification-actions-n-1')),
      );
      await tester.pumpAndSettle();

      // `retry_notification` takes failed, cancelled and not-sent; a failed
      // row is not cancellable, so only one entry is offered.
      expect(find.text('Send again'), findsOneWidget);
      expect(find.text('Cancel'), findsNothing);
    });

    testWidgets('a queued row is offered Cancel rather than Send again', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        _FakeNotificationsRepository(
          rows: <NotificationMessage>[
            _row('n-1', status: NotificationStatus.sent),
            _row('n-2', status: NotificationStatus.cancelled),
          ],
        ),
      );

      // A delivered message has nothing to do to it at all.
      expect(
        find.byKey(const ValueKey<String>('notification-actions-n-1')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey<String>('notification-actions-n-2')),
        findsOneWidget,
      );
    });

    testWidgets('Send again actually resends, and says so', (
      WidgetTester tester,
    ) async {
      // The regression this pins: `NotificationActions` was auto-disposed and
      // nothing watched it, so Riverpod disposed it a frame after the tap. The
      // RPC still ran, but the resumed code touched a dead `Ref` -- the
      // confirmation never appeared, and on the error path the desk was told
      // "nothing was saved" about a message that had just been re-queued.
      final _FakeNotificationsRepository repository =
          _FakeNotificationsRepository(
            rows: <NotificationMessage>[
              _row('n-1', status: NotificationStatus.failed),
            ],
          );
      await _pump(tester, repository);

      await tester.tap(
        find.byKey(const ValueKey<String>('notification-actions-n-1')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Send again'));
      await tester.pumpAndSettle();

      expect(repository.retried, <String>['n-1']);
      expect(
        find.text('Queued again. It goes out within a minute.'),
        findsOneWidget,
      );
    });

    testWidgets('Cancel stops the message, and says so', (
      WidgetTester tester,
    ) async {
      final _FakeNotificationsRepository repository =
          _FakeNotificationsRepository(
            rows: <NotificationMessage>[
              _row('n-1', status: NotificationStatus.queued),
            ],
          );
      await _pump(tester, repository);

      await tester.tap(
        find.byKey(const ValueKey<String>('notification-actions-n-1')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(repository.cancelled, <String>['n-1']);
      expect(find.text('Cancelled. It will not be sent.'), findsOneWidget);
    });

    testWidgets('no capability, no row menu — and still the rows', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        _FakeNotificationsRepository(
          rows: <NotificationMessage>[
            _row('n-1', status: NotificationStatus.failed),
          ],
        ),
        capabilities: const <StaffCapability>{},
      );

      expect(find.byType(NotificationTile), findsOneWidget);
      expect(
        find.byKey(const ValueKey<String>('notification-actions-n-1')),
        findsNothing,
      );
    });
  });
}
