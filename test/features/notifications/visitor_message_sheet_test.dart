// The walk-in send sheet. The member sheet's twin, so this checks the two
// things that are deliberately *different* about it -- three reasons, and no
// opt-out branch -- plus the blockers it does share.
//
// `Override` is not exported by flutter_riverpod 3.1.0, so every overrides
// list stays an untyped literal (TASKS.md, Discovered, 2026-09-05).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/notifications/notification_previews.dart';
import 'package:logfitness_flutter/data/notifications/notifications_repository.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/features/common/failure_view.dart';
import 'package:logfitness_flutter/features/notifications/member_message_sheet.dart';
import 'package:logfitness_flutter/features/notifications/visitor_message_sheet.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

VisitorMessagePreview _preview({
  String? body = 'Namaste Bikash, thanks for visiting Lord of Gyms.',
  String? toAddress = '9811111111',
  bool reachable = true,
  bool hasGateway = true,
}) => VisitorMessagePreview(
  toAddress: toAddress,
  subject: null,
  body: body,
  reachable: reachable,
  hasGateway: hasGateway,
);

class _FakeNotificationsRepository implements NotificationsRepository {
  _FakeNotificationsRepository({
    VisitorMessagePreview? preview,
    this.previewsByEvent = const <NotificationEvent, VisitorMessagePreview>{},
    this.previewError,
    this.sendError,
  }) : preview = preview ?? _preview();

  VisitorMessagePreview? preview;
  final Map<NotificationEvent, VisitorMessagePreview> previewsByEvent;
  Object? previewError;
  Object? sendError;

  final List<NotificationEvent> previewedEvents = <NotificationEvent>[];
  Map<String, Object?>? lastSend;

  @override
  Future<VisitorMessagePreview?> previewVisitorNotification(
    String visitorId,
    NotificationEvent event, {
    NotificationChannel channel = NotificationChannel.sms,
  }) async {
    previewedEvents.add(event);
    if (previewError != null) {
      throw previewError!;
    }
    return previewsByEvent[event] ?? preview;
  }

  @override
  Future<String> sendVisitorNotification({
    required String visitorId,
    required NotificationEvent event,
    NotificationChannel channel = NotificationChannel.sms,
    String? body,
    String? subject,
  }) async {
    lastSend = <String, Object?>{
      'visitorId': visitorId,
      'event': event,
      'body': body,
    };
    if (sendError != null) {
      throw sendError!;
    }
    return 'msg-2';
  }

  @override
  Never noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not faked');
}

Future<void> _pump(
  WidgetTester tester,
  _FakeNotificationsRepository repository,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        notificationsRepositoryProvider.overrideWithValue(repository),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: VisitorMessageSheet(visitorId: 'v-1', fullName: 'Bikash'),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

bool _sendEnabled(WidgetTester tester) => tester
    .widget<FilledButton>(
      find.byKey(const ValueKey<String>('visitor-message-send')),
    )
    .onPressed != null;

String _bodyText(WidgetTester tester) => tester
    .widget<TextField>(
      find.byKey(const ValueKey<String>('visitor-message-body')),
    )
    .controller!
    .text;

void main() {
  group('VisitorMessageSheet', () {
    testWidgets('opens on the welcome and prefills the gym’s wording', (
      WidgetTester tester,
    ) async {
      final repository = _FakeNotificationsRepository();
      await _pump(tester, repository);

      expect(repository.previewedEvents, <NotificationEvent>[
        NotificationEvent.visitorWelcome,
      ]);
      expect(
        _bodyText(tester),
        'Namaste Bikash, thanks for visiting Lord of Gyms.',
      );
      expect(_sendEnabled(tester), isTrue);
    });

    testWidgets('offers exactly the three reasons a walk-in can be sent', (
      WidgetTester tester,
    ) async {
      await _pump(tester, _FakeNotificationsRepository());

      await tester.tap(
        find.byKey(const ValueKey<String>('visitor-message-event')),
      );
      await tester.pumpAndSettle();

      // A renewal or a dues reminder has no membership and no balance to put
      // in the sentence for someone who has not joined, and
      // `send_visitor_notification` refuses both.
      expect(find.text('Welcome / thanks for visiting'), findsWidgets);
      expect(find.text('Follow-up'), findsOneWidget);
      expect(find.text('Something else'), findsOneWidget);
      expect(find.text('Dues reminder'), findsNothing);
      expect(find.text('Renewal reminder'), findsNothing);
      expect(find.byType(ListTile), findsNWidgets(3));
    });

    testWidgets('has no opt-out branch, because a walk-in has no standing '
        'instruction', (WidgetTester tester) async {
      await _pump(tester, _FakeNotificationsRepository());

      // `visitor_notification_preview` has no `opt_out` column to report; the
      // desk takes someone out of the sweep by marking them "not joining".
      expect(find.text(kMemberOptOutBlocker), findsNothing);
      expect(_sendEnabled(tester), isTrue);
    });

    testWidgets('an unreachable number blocks the send and says why', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        _FakeNotificationsRepository(preview: _preview(reachable: false)),
      );

      expect(find.text(kUnreachableBlocker), findsOneWidget);
      expect(_sendEnabled(tester), isFalse);
    });

    testWidgets('no gateway blocks the send and points at Settings', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        _FakeNotificationsRepository(preview: _preview(hasGateway: false)),
      );

      expect(find.text(kNoGatewayBlocker), findsOneWidget);
      expect(_sendEnabled(tester), isFalse);
    });

    testWidgets('changing the reason re-fetches and re-fills the editor', (
      WidgetTester tester,
    ) async {
      final repository = _FakeNotificationsRepository(
        previewsByEvent: <NotificationEvent, VisitorMessagePreview>{
          NotificationEvent.visitorWelcome: _preview(body: 'Thanks for coming.'),
          NotificationEvent.visitorFollowUp: _preview(
            body: 'Still thinking it over?',
          ),
        },
      );
      await _pump(tester, repository);
      expect(_bodyText(tester), 'Thanks for coming.');

      await tester.tap(
        find.byKey(const ValueKey<String>('visitor-message-event')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Follow-up').last);
      await tester.pumpAndSettle();

      expect(
        repository.previewedEvents,
        contains(NotificationEvent.visitorFollowUp),
      );
      expect(_bodyText(tester), 'Still thinking it over?');
    });

    testWidgets('what is edited is what is sent', (WidgetTester tester) async {
      final repository = _FakeNotificationsRepository();
      await _pump(tester, repository);

      await tester.enterText(
        find.byKey(const ValueKey<String>('visitor-message-body')),
        'Come back Saturday and try a class.',
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey<String>('visitor-message-send')),
      );
      await tester.pumpAndSettle();

      expect(repository.lastSend?['body'], 'Come back Saturday and try a class.');
      expect(repository.lastSend?['event'], NotificationEvent.visitorWelcome);
    });

    testWidgets('a refused preview reads as a refusal, not an empty form', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        _FakeNotificationsRepository(
          previewError: const PostgrestException(
            message:
                'permission denied for function visitor_notification_preview',
            code: '42501',
          ),
        ),
      );

      expect(find.byType(FailureView), findsOneWidget);
      expect(find.textContaining('refused'), findsWidgets);
    });

    testWidgets('a converted visitor’s refusal reaches the screen verbatim', (
      WidgetTester tester,
    ) async {
      final repository = _FakeNotificationsRepository(
        sendError: const PostgrestException(
          message: 'That visitor is a member now.',
          code: '23514',
        ),
      );
      await _pump(tester, repository);

      await tester.tap(
        find.byKey(const ValueKey<String>('visitor-message-send')),
      );
      await tester.pumpAndSettle();

      // Hiding the action for a converted visitor is a courtesy; this is the
      // gate, and it has to be legible.
      expect(find.text('That visitor is a member now.'), findsOneWidget);
    });
  });
}
