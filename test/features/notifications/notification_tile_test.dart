// One row of the delivery log, checked where it can silently drift.
//
// The question a row answers is "was this person told, and if not why not", so
// the recipient, the body and the failure text are the three things that must
// never go missing. The two conditional lines -- the attempt count and the
// sender's name -- are asserted in both directions, because a line that
// appears when it should not is as wrong as one that does not appear at all:
// "1 attempts" is noise, and "by" nobody is a lie about who pressed Send.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/notifications/notification_message.dart';
import 'package:logfitness_flutter/features/notifications/widgets/notification_status_badge.dart';
import 'package:logfitness_flutter/features/notifications/widgets/notification_tile.dart';

NotificationMessage _message({
  String status = 'sent',
  int attempts = 1,
  String? lastError,
  String? createdBy,
  String body = 'Your membership at Log Fitness ends on 14 Sep.',
}) => NotificationMessage.fromJson(<String, dynamic>{
  'id': 'm-1',
  'org_id': 'org-1',
  'branch_id': 'branch-1',
  'member_id': 'member-1',
  'channel': 'sms',
  'event': 'renewal_reminder',
  'provider': 'sparrow_sms',
  'to_address': '9779800000000',
  'body': body,
  'status': status,
  'attempts': attempts,
  'scheduled_for': '2026-09-11T02:30:00+00:00',
  'next_attempt_at': '2026-09-11T02:30:00+00:00',
  'last_error': lastError,
  'dedupe_key': 'renewal_reminder:member-1:2026-09-14',
  'created_by': createdBy,
  'created_at': '2026-09-11T02:30:00+00:00',
  'updated_at': '2026-09-11T02:30:04+00:00',
});

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('NotificationTile', () {
    testWidgets('leads with the recipient and shows what was said', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(NotificationTile(message: _message())));

      expect(find.text('9779800000000'), findsOneWidget);
      // The body is the record of what the member was actually told -- it is
      // stored at enqueue time for exactly that reason, so the row shows it
      // rather than re-rendering the template.
      expect(
        find.text('Your membership at Log Fitness ends on 14 Sep.'),
        findsOneWidget,
      );
    });

    testWidgets('carries the reason, the channel and the time', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(NotificationTile(message: _message())));

      expect(find.textContaining('Renewal'), findsOneWidget);
      expect(find.textContaining('SMS'), findsOneWidget);
      // 02:30 UTC is 08:15 on the org's wall clock (+05:45), not the device's.
      expect(find.textContaining('11 Sep 2026, 08:15'), findsOneWidget);
    });

    testWidgets('shows the status badge', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(NotificationTile(message: _message(status: 'skipped'))),
      );

      expect(find.byType(NotificationStatusBadge), findsOneWidget);
      expect(find.text('Not sent'), findsOneWidget);
    });
  });

  group('the failure text', () {
    testWidgets('is rendered in full when there is one', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          NotificationTile(
            message: _message(
              status: 'failed',
              lastError: 'Gateway returned 401: invalid token',
            ),
          ),
        ),
      );

      // Not truncated and not hidden behind a tap: it is the reason the log
      // is being read.
      expect(
        find.text('Gateway returned 401: invalid token'),
        findsOneWidget,
      );
    });

    testWidgets('a skipped row explains itself too', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          NotificationTile(
            message: _message(
              status: 'skipped',
              lastError: 'No active sms gateway',
            ),
          ),
        ),
      );

      expect(find.text('No active sms gateway'), findsOneWidget);
    });

    testWidgets('nothing is rendered when the row has no error', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(NotificationTile(message: _message())));

      expect(find.textContaining('Gateway returned'), findsNothing);
    });
  });

  group('the attempt count', () {
    testWidgets('appears once a row has been retried', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          NotificationTile(
            message: _message(status: 'failed', attempts: 3),
          ),
        ),
      );

      expect(find.text('3 attempts'), findsOneWidget);
    });

    testWidgets('stays hidden at one attempt -- "1 attempts" is noise', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(NotificationTile(message: _message(attempts: 1))),
      );

      expect(find.textContaining('attempt'), findsNothing);
    });

    testWidgets('stays hidden on a row nothing has tried yet', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          NotificationTile(
            message: _message(status: 'queued', attempts: 0),
          ),
        ),
      );

      expect(find.textContaining('attempt'), findsNothing);
    });
  });

  group('who pressed Send', () {
    testWidgets('is named when the caller resolved one', (
      WidgetTester tester,
    ) async {
      // The log holds `created_by`, an id; the name is resolved by the caller
      // and passed in, which is why it is a parameter rather than a lookup.
      await tester.pumpWidget(
        _wrap(
          NotificationTile(
            message: _message(createdBy: 'staff-1'),
            senderName: 'Ramesh',
          ),
        ),
      );

      expect(find.textContaining('by Ramesh'), findsOneWidget);
    });

    testWidgets('is absent on a row a sweep raised', (
      WidgetTester tester,
    ) async {
      // Null `created_by`, so no name to pass. Inventing a "by" line here
      // would attribute a 02:30 sweep to whoever happens to be reading.
      await tester.pumpWidget(_wrap(NotificationTile(message: _message())));

      expect(find.textContaining(' by '), findsNothing);
    });

    testWidgets('is absent when the caller could not resolve the name', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(NotificationTile(message: _message(createdBy: 'staff-1'))),
      );

      expect(find.textContaining(' by '), findsNothing);
    });
  });

  group('the row as a surface', () {
    testWidgets('renders a trailing widget when one is given', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          NotificationTile(
            message: _message(),
            trailing: const Icon(Icons.more_vert),
          ),
        ),
      );

      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('offers no overflow menu when none is passed', (
      WidgetTester tester,
    ) async {
      // The member profile's Messages tab is a history, not a queue.
      await tester.pumpWidget(_wrap(NotificationTile(message: _message())));

      expect(find.byIcon(Icons.more_vert), findsNothing);
    });

    testWidgets('is tappable when a handler is given', (
      WidgetTester tester,
    ) async {
      int taps = 0;
      await tester.pumpWidget(
        _wrap(
          NotificationTile(message: _message(), onTap: () => taps++),
        ),
      );

      await tester.tap(find.byType(NotificationTile));
      expect(taps, 1);
    });
  });
}
