// The Messages destination's two tabs.
//
// The load-bearing test here is the keep-alive one. `TabBarView` disposes the
// `State` of the tab that is off screen, and the delivery log owns a scroll
// position, a search field and a poller whose fifteen-minute clock starts when
// it mounts -- so without `AutomaticKeepAliveClientMixin` a glance at
// announcements and back would silently re-fetch the log and drop the reader to
// the top. That is exactly the kind of regression nobody reports as a bug; it
// just feels bad.
//
// `Override` is not exported by flutter_riverpod 3.1.0, so every overrides list
// stays an untyped literal (TASKS.md, Discovered, 2026-09-05).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/announcements/announcement_overview.dart';
import 'package:logfitness_flutter/data/announcements/announcement_queries.dart';
import 'package:logfitness_flutter/data/announcements/announcements_repository.dart';
import 'package:logfitness_flutter/data/notifications/notification_message.dart';
import 'package:logfitness_flutter/data/notifications/notification_queries.dart';
import 'package:logfitness_flutter/data/notifications/notifications_repository.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/features/announcements/announcements_tab.dart';
import 'package:logfitness_flutter/features/notifications/messages_screen.dart';
import 'package:logfitness_flutter/features/notifications/notification_log_screen.dart';
import 'package:logfitness_flutter/features/staff/branch_scope.dart';
import 'package:logfitness_flutter/features/staff/staff_capabilities.dart';

class _FakeNotificationsRepository implements NotificationsRepository {
  int listCallCount = 0;

  @override
  Future<NotificationPage> listNotifications(
    NotificationListFilter filter,
  ) async {
    listCallCount++;
    return NotificationPage(
      rows: <NotificationMessage>[
        NotificationMessage(
          id: 'n-1',
          orgId: 'org-1',
          branchId: 'branch-1',
          channel: NotificationChannel.sms,
          event: NotificationEvent.renewalReminder,
          toAddress: '9800000000',
          body: 'Your membership ends on Friday.',
          status: NotificationStatus.sent,
          attempts: 1,
          scheduledFor: DateTime.utc(2026, 9, 18, 2),
          nextAttemptAt: DateTime.utc(2026, 9, 18, 2),
          dedupeKey: 'renewal:n-1',
          createdAt: DateTime.utc(2026, 9, 18, 2),
          updatedAt: DateTime.utc(2026, 9, 18, 2),
        ),
      ],
      total: 1,
      page: 1,
      pageSize: 20,
    );
  }

  @override
  Future<NotificationStatusCounts> notificationStatusCounts(
    List<String>? branchIds,
    List<NotificationStatus> statuses,
  ) async => NotificationStatusCounts(<NotificationStatus, int>{
    for (final NotificationStatus status in statuses) status: 0,
  });

  @override
  Never noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not faked');
}

class _FakeAnnouncementsRepository implements AnnouncementsRepository {
  int listCallCount = 0;

  @override
  Future<AnnouncementPage> listAnnouncements(
    AnnouncementListFilter filter,
  ) async {
    listCallCount++;
    return AnnouncementPage(
      rows: <AnnouncementOverview>[
        AnnouncementOverview(
          id: 'a-1',
          orgId: 'org-1',
          title: 'Closed Sunday',
          body: 'We are shut on Sunday.',
          channel: NotificationChannel.sms,
          audience: AnnouncementAudience.both,
          status: AnnouncementStatus.sending,
          state: AnnouncementState.sent,
          scheduledFor: DateTime.utc(2026, 9, 18, 2),
          createdAt: DateTime.utc(2026, 9, 18, 2),
          total: 1,
          queued: 0,
          sent: 1,
          failed: 0,
          skipped: 0,
          cancelled: 0,
        ),
      ],
      total: 1,
      page: 1,
      pageSize: 20,
    );
  }

  @override
  Never noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not faked');
}

Future<void> _pump(
  WidgetTester tester, {
  required Set<StaffCapability> capabilities,
  _FakeNotificationsRepository? notifications,
  _FakeAnnouncementsRepository? announcements,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      // Spread into an untyped literal so inference supplies `Override`,
      // which flutter_riverpod 3.1.0 does not export.
      overrides: [
        notificationsRepositoryProvider.overrideWithValue(
          notifications ?? _FakeNotificationsRepository(),
        ),
        announcementsRepositoryProvider.overrideWithValue(
          announcements ?? _FakeAnnouncementsRepository(),
        ),
        staffCapabilitiesProvider.overrideWithValue(capabilities),
        branchScopeProvider.overrideWithValue(
          const BranchScope(
            options: <String>['branch-1'],
            selectedBranchId: 'branch-1',
            isOrgWide: false,
          ),
        ),
      ],
      child: const MaterialApp(home: MessagesScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a manager gets both tabs', (tester) async {
    await _pump(
      tester,
      capabilities: const <StaffCapability>{
        StaffCapability.viewNotificationLog,
        StaffCapability.sendAnnouncement,
      },
    );

    expect(find.byType(TabBar), findsOneWidget);
    expect(find.text('Log'), findsOneWidget);
    expect(find.text('Announcements'), findsOneWidget);
  });

  testWidgets('the front desk gets announcements, and no tab bar to tap', (
    tester,
  ) async {
    // The desk holds `sendAnnouncement` and not `viewNotificationLog`, so the
    // destination is reached on the first alone and there is nothing to choose
    // between -- a single tab is a label, not a choice.
    await _pump(
      tester,
      capabilities: const <StaffCapability>{StaffCapability.sendAnnouncement},
    );

    expect(find.byType(TabBar), findsNothing);
    expect(find.byType(AnnouncementsTab), findsOneWidget);
    expect(find.byType(NotificationLogScreen), findsNothing);
  });

  testWidgets('an owner-only log role gets the log, and no tab bar', (
    tester,
  ) async {
    await _pump(
      tester,
      capabilities: const <StaffCapability>{
        StaffCapability.viewNotificationLog,
      },
    );

    expect(find.byType(TabBar), findsNothing);
    expect(find.byType(NotificationLogScreen), findsOneWidget);
  });

  testWidgets('a role with only the log never queries announcements', (
    tester,
  ) async {
    // The lifecycle listener lives with the tab it drives. A single listener in
    // the host that poked both pollers would instantiate the announcements one
    // here -- and its `build` watches the list, so backgrounding the phone
    // would fetch a list this role has no tab for.
    final announcements = _FakeAnnouncementsRepository();
    await _pump(
      tester,
      capabilities: const <StaffCapability>{
        StaffCapability.viewNotificationLog,
      },
      announcements: announcements,
    );

    // The whole way down and back up. `AppLifecycleListener` asserts on a
    // shortcut: the phone goes resumed -> inactive -> hidden -> paused, and
    // returns the same way.
    for (final AppLifecycleState next in <AppLifecycleState>[
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(next);
      await tester.pump();
    }
    await tester.pumpAndSettle();

    expect(announcements.listCallCount, 0);
  });

  testWidgets('switching tabs and back does not re-fetch the log', (
    tester,
  ) async {
    final notifications = _FakeNotificationsRepository();
    await _pump(
      tester,
      capabilities: const <StaffCapability>{
        StaffCapability.viewNotificationLog,
        StaffCapability.sendAnnouncement,
      },
      notifications: notifications,
    );

    final int afterFirstPaint = notifications.listCallCount;
    expect(afterFirstPaint, greaterThan(0));

    await tester.tap(find.text('Announcements'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Log'));
    await tester.pumpAndSettle();

    // The log's state survived the round trip: no second read, which means the
    // scroll position, the loaded pages and the poller's clock survived too.
    expect(notifications.listCallCount, afterFirstPaint);
  });
}
