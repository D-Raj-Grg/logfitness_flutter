// The member send sheet, checked where it can be wrong in a way that costs
// money or breaks consent.
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
import 'package:supabase_flutter/supabase_flutter.dart';

MemberMessagePreview _preview({
  String? body = 'Namaste Anjali, Rs 3,400 is outstanding.',
  String? toAddress = '9800000000',
  bool optOut = false,
  bool reachable = true,
  bool hasGateway = true,
}) => MemberMessagePreview(
  toAddress: toAddress,
  subject: null,
  body: body,
  optOut: optOut,
  reachable: reachable,
  hasGateway: hasGateway,
);

class _FakeNotificationsRepository implements NotificationsRepository {
  _FakeNotificationsRepository({
    MemberMessagePreview? preview,
    this.previewsByEvent = const <NotificationEvent, MemberMessagePreview>{},
    this.previewError,
    this.sendError,
  }) : preview = preview ?? _preview();

  MemberMessagePreview? preview;
  final Map<NotificationEvent, MemberMessagePreview> previewsByEvent;
  Object? previewError;
  Object? sendError;

  final List<NotificationEvent> previewedEvents = <NotificationEvent>[];
  Map<String, Object?>? lastSend;

  @override
  Future<MemberMessagePreview?> previewMemberNotification(
    String memberId,
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
  Future<String> sendMemberNotification({
    required String memberId,
    required NotificationEvent event,
    NotificationChannel channel = NotificationChannel.sms,
    String? body,
    String? subject,
  }) async {
    lastSend = <String, Object?>{
      'memberId': memberId,
      'event': event,
      'body': body,
    };
    if (sendError != null) {
      throw sendError!;
    }
    return 'msg-1';
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
      // Spread into an untyped literal so inference supplies `Override`,
      // which flutter_riverpod 3.1.0 does not export.
      overrides: [
        notificationsRepositoryProvider.overrideWithValue(repository),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: MemberMessageSheet(memberId: 'm-1', fullName: 'Anjali'),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

bool _sendEnabled(WidgetTester tester) {
  final FilledButton button = tester.widget<FilledButton>(
    find.byKey(const ValueKey<String>('member-message-send')),
  );
  return button.onPressed != null;
}

String _bodyText(WidgetTester tester) => tester
    .widget<TextField>(
      find.byKey(const ValueKey<String>('member-message-body')),
    )
    .controller!
    .text;

void main() {
  group('MemberMessageSheet', () {
    testWidgets('prefills the gym’s own wording from the preview', (
      WidgetTester tester,
    ) async {
      await _pump(tester, _FakeNotificationsRepository());

      expect(_bodyText(tester), 'Namaste Anjali, Rs 3,400 is outstanding.');
      // Recipient, length and cost, on one line.
      expect(find.textContaining('To 9800000000'), findsOneWidget);
      expect(find.textContaining('1 SMS'), findsOneWidget);
      expect(_sendEnabled(tester), isTrue);
    });

    testWidgets('opens on the dues reminder, which is why the desk is here', (
      WidgetTester tester,
    ) async {
      final repository = _FakeNotificationsRepository();
      await _pump(tester, repository);

      expect(repository.previewedEvents, <NotificationEvent>[
        NotificationEvent.duesReminder,
      ]);
    });

    testWidgets('changing the reason re-fetches and re-fills the editor', (
      WidgetTester tester,
    ) async {
      final repository = _FakeNotificationsRepository(
        previewsByEvent: <NotificationEvent, MemberMessagePreview>{
          NotificationEvent.duesReminder: _preview(body: 'You owe Rs 3,400.'),
          NotificationEvent.birthdayGreeting: _preview(
            body: 'Happy birthday, Anjali!',
          ),
        },
      );
      await _pump(tester, repository);
      expect(_bodyText(tester), 'You owe Rs 3,400.');

      await tester.tap(
        find.byKey(const ValueKey<String>('member-message-event')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Birthday greeting').last);
      await tester.pumpAndSettle();

      // A different reason is a different question to the database, not an
      // edit of an answer already given.
      expect(repository.previewedEvents, contains(
        NotificationEvent.birthdayGreeting,
      ));
      expect(_bodyText(tester), 'Happy birthday, Anjali!');
    });

    testWidgets('an opted-out member cannot be messaged at all', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        _FakeNotificationsRepository(preview: _preview(optOut: true)),
      );

      // Consent is not something a button overrides.
      expect(find.text(kMemberOptOutBlocker), findsOneWidget);
      expect(_sendEnabled(tester), isFalse);
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

    testWidgets('a blank body has nothing to send', (
      WidgetTester tester,
    ) async {
      // `custom_message` has no template to render, so the preview comes back
      // with no body and the desk writes it.
      await _pump(
        tester,
        _FakeNotificationsRepository(preview: _preview(body: null)),
      );

      expect(_bodyText(tester), '');
      expect(_sendEnabled(tester), isFalse);
    });

    testWidgets('what is edited is what is sent', (WidgetTester tester) async {
      final repository = _FakeNotificationsRepository();
      await _pump(tester, repository);

      await tester.enterText(
        find.byKey(const ValueKey<String>('member-message-body')),
        'Please settle Rs 3,400 today.',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey<String>('member-message-send')));
      await tester.pumpAndSettle();

      // The body travels with the send rather than being re-rendered, so the
      // message and the log cannot disagree.
      expect(repository.lastSend?['body'], 'Please settle Rs 3,400 today.');
      expect(repository.lastSend?['event'], NotificationEvent.duesReminder);
    });

    testWidgets('a refused preview reads as a refusal, not an empty form', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        _FakeNotificationsRepository(
          previewError: const PostgrestException(
            message: 'permission denied for function member_notification_preview',
            code: '42501',
          ),
        ),
      );

      expect(find.byType(FailureView), findsOneWidget);
      expect(find.textContaining('refused'), findsWidgets);
    });

    testWidgets('the database’s refusal on send reaches the screen verbatim', (
      WidgetTester tester,
    ) async {
      final repository = _FakeNotificationsRepository(
        // `send_member_notification` raises `check_violation` for an
        // opted-out member, for a channel with no gateway, and for
        // `staff_invite` / `test_message`. Every one of them is a whole
        // sentence written for a person, and `mapError` passes 23514 through
        // untouched.
        sendError: const PostgrestException(
          message: 'This member has asked not to receive messages.',
          code: '23514',
        ),
      );
      await _pump(tester, repository);

      await tester.tap(
        find.byKey(const ValueKey<String>('member-message-send')),
      );
      await tester.pumpAndSettle();

      // Never swallowed. Pairing a hidden button with a silent catch is the
      // 2026-09-07 console bug this whole surface exists to avoid.
      expect(
        find.text('This member has asked not to receive messages.'),
        findsOneWidget,
      );
    });

    testWidgets('a second tap inside two minutes is refused, not silent', (
      WidgetTester tester,
    ) async {
      final repository = _FakeNotificationsRepository(
        // A manual send has no deterministic dedupe key, so the guard upstream
        // is a two-minute window per member and reason, raised as
        // `unique_violation`.
        sendError: const PostgrestException(
          message: 'That message is already queued for this member',
          code: '23505',
        ),
      );
      await _pump(tester, repository);

      await tester.tap(
        find.byKey(const ValueKey<String>('member-message-send')),
      );
      await tester.pumpAndSettle();

      // Verbatim, not the generic duplicate sentence. `mapError`'s 23505 arm
      // used to substitute "That record already exists." for anything it did
      // not recognise by constraint name, which told the desk nothing about the
      // guard they had just hit; it now passes through any message Postgres did
      // not write itself (a real constraint violation always says "violates
      // unique constraint", and a sentence an RPC raised by hand does not).
      expect(
        find.text('That message is already queued for this member'),
        findsOneWidget,
      );
    });
  });
}
