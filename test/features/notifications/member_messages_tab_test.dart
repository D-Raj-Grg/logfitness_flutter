// The member profile's Messages tab: a history, and it has to read as one.
//
// `Override` is not exported by flutter_riverpod 3.1.0, so every overrides
// list stays an untyped literal (TASKS.md, Discovered, 2026-09-05).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/notifications/notification_message.dart';
import 'package:logfitness_flutter/data/notifications/notifications_repository.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/features/common/failure_view.dart';
import 'package:logfitness_flutter/features/notifications/member_messages_tab.dart';
import 'package:logfitness_flutter/features/notifications/widgets/notification_tile.dart';
import 'package:logfitness_flutter/features/staff/staff_capabilities.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

NotificationMessage _message(
  String id, {
  String body = 'Your membership ends on 2026-09-20.',
  NotificationStatus status = NotificationStatus.sent,
}) => NotificationMessage(
  id: id,
  orgId: 'org-1',
  branchId: 'branch-1',
  memberId: 'm-1',
  channel: NotificationChannel.sms,
  event: NotificationEvent.renewalReminder,
  toAddress: '9800000000',
  body: body,
  status: status,
  attempts: 1,
  scheduledFor: DateTime.utc(2026, 9, 13, 2, 30),
  nextAttemptAt: DateTime.utc(2026, 9, 13, 2, 30),
  dedupeKey: 'renewal:$id',
  createdAt: DateTime.utc(2026, 9, 13, 2, 30),
  updatedAt: DateTime.utc(2026, 9, 13, 2, 30),
);

class _FakeNotificationsRepository implements NotificationsRepository {
  _FakeNotificationsRepository({
    this.rows = const <NotificationMessage>[],
    this.error,
  });

  final List<NotificationMessage> rows;
  final Object? error;

  String? lastMemberId;

  @override
  Future<List<NotificationMessage>> listNotificationsForMember(
    String memberId, {
    int limit = 25,
  }) async {
    lastMemberId = memberId;
    if (error != null) {
      throw error!;
    }
    return rows;
  }

  @override
  Never noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not faked');
}

Future<void> _pump(
  WidgetTester tester,
  _FakeNotificationsRepository repository, {
  Set<StaffCapability> capabilities = const <StaffCapability>{
    StaffCapability.sendMemberMessage,
  },
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        notificationsRepositoryProvider.overrideWithValue(repository),
        staffCapabilitiesProvider.overrideWithValue(capabilities),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: MemberMessagesTab(memberId: 'm-1', memberName: 'Anjali'),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('MemberMessagesTab', () {
    testWidgets('renders one row per message', (WidgetTester tester) async {
      final repository = _FakeNotificationsRepository(
        rows: <NotificationMessage>[
          _message('n-1'),
          _message('n-2', body: 'Rs 3,400 is outstanding.'),
        ],
      );
      await _pump(tester, repository);

      expect(repository.lastMemberId, 'm-1');
      expect(find.byType(NotificationTile), findsNWidgets(2));
      expect(find.text('Rs 3,400 is outstanding.'), findsOneWidget);
    });

    testWidgets('is a history, not a queue: no row actions', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        _FakeNotificationsRepository(
          rows: <NotificationMessage>[
            _message('n-1', status: NotificationStatus.failed),
          ],
        ),
      );

      // Resend and Cancel belong on the delivery log, where someone is
      // auditing the outbox. Here the desk is looking at one person.
      final NotificationTile tile = tester.widget<NotificationTile>(
        find.byType(NotificationTile),
      );
      expect(tile.trailing, isNull);
    });

    testWidgets('an empty tab says nothing has been sent, and means it', (
      WidgetTester tester,
    ) async {
      await _pump(tester, _FakeNotificationsRepository());

      // An empty tab and a tab that failed to load look identical from the
      // outside, and only one of them is a claim about what the gym did.
      expect(
        find.text('Nothing has been sent to this member yet.'),
        findsOneWidget,
      );
    });

    testWidgets('offers the send to a desk that holds the capability', (
      WidgetTester tester,
    ) async {
      await _pump(tester, _FakeNotificationsRepository());

      expect(
        find.byKey(const ValueKey<String>('member-messages-send')),
        findsOneWidget,
      );
    });

    testWidgets('hides the send from a trainer', (WidgetTester tester) async {
      await _pump(
        tester,
        _FakeNotificationsRepository(),
        // A trainer holds none of the notification capabilities;
        // `member_message_target` refuses them independently, which is why
        // hiding this is a courtesy rather than the control.
        capabilities: const <StaffCapability>{StaffCapability.checkIn},
      );

      expect(
        find.byKey(const ValueKey<String>('member-messages-send')),
        findsNothing,
      );
      expect(find.text('Send an SMS'), findsNothing);
    });

    testWidgets('a refusal reads as a refusal, not an empty history', (
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

      expect(find.byType(FailureView), findsOneWidget);
      expect(
        find.text('Nothing has been sent to this member yet.'),
        findsNothing,
      );
    });
  });
}
