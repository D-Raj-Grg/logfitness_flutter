// The reminder schedule.
//
// Three things are worth a test here and the rest is layout: money survives the
// trip to the form and back as integer paisa, the welcome rule does not offer
// an hour it cannot honour, and a `time` column stays text.
//
// `Override` is not exported by flutter_riverpod 3.1.0, so every overrides list
// stays an untyped literal (TASKS.md, Discovered, 2026-09-05).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/notifications/notification_rule.dart';
import 'package:logfitness_flutter/data/notifications/notifications_repository.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/features/settings/notifications/rules_form.dart';

NotificationRule _rule({
  String id = 'rule-1',
  NotificationEvent event = NotificationEvent.renewalReminder,
  int offsetDays = 7,
  bool enabled = true,
  int minAmountPaisa = 0,
  int repeatAfterDays = 7,
  String sendAtLocal = '09:00:00',
}) => NotificationRule(
  id: id,
  orgId: 'org-1',
  event: event,
  channel: NotificationChannel.sms,
  enabled: enabled,
  offsetDays: offsetDays,
  minAmountPaisa: minAmountPaisa,
  repeatAfterDays: repeatAfterDays,
  sendAtLocal: sendAtLocal,
  createdAt: DateTime.utc(2026, 9, 1),
  updatedAt: DateTime.utc(2026, 9, 1),
);

class _FakeRepository implements NotificationsRepository {
  _FakeRepository(this.rules);

  List<NotificationRule> rules;
  Map<String, Object?>? lastUpdate;

  @override
  Future<List<NotificationRule>> listNotificationRules() async => rules;

  @override
  Future<void> updateNotificationRule(
    String ruleId, {
    required bool enabled,
    required int minAmountPaisa,
    required int repeatAfterDays,
    required String sendAtLocal,
  }) async {
    lastUpdate = <String, Object?>{
      'ruleId': ruleId,
      'enabled': enabled,
      'minAmountPaisa': minAmountPaisa,
      'repeatAfterDays': repeatAfterDays,
      'sendAtLocal': sendAtLocal,
    };
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError(
    '${invocation.memberName} is not part of the rules form test',
  );
}

Future<void> _pump(WidgetTester tester, _FakeRepository repository) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        notificationsRepositoryProvider.overrideWithValue(repository),
      ],
      child: const MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: RulesForm())),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('rupees and paisa', () {
    test('round-trips as integers', () {
      // Money is integer paisa below the render boundary (CLAUDE.md). A double
      // anywhere in here is a threshold that drifts by a paisa and a member
      // chased over a rounding error.
      for (final int paisa in <int>[0, 100, 250000, 199, 10000000]) {
        expect(rupeesFieldToPaisa(paisaToRupeesField(paisa)), paisa);
      }
    });

    test('reads whole rupees, and paisa when they are typed', () {
      expect(rupeesFieldToPaisa('2500'), 250000);
      expect(rupeesFieldToPaisa('2,500'), 250000);
      expect(rupeesFieldToPaisa('1.5'), 150);
      expect(rupeesFieldToPaisa('1.55'), 155);
      // A third decimal place is not money here, and rounding it would invent
      // a paisa the owner did not type.
      expect(rupeesFieldToPaisa('1.559'), 155);
      expect(rupeesFieldToPaisa(''), 0);
    });

    test('refuses what is not an amount', () {
      expect(rupeesFieldToPaisa('abc'), isNull);
      expect(rupeesFieldToPaisa('1.2.3'), isNull);
      expect(rupeesFieldToPaisa('-5'), isNull);
    });
  });

  group('notificationRuleTitle', () {
    test('T-7 and T-1 read as sentences, not as offsets', () {
      expect(
        notificationRuleTitle(_rule(offsetDays: 7)),
        '7 days before a membership ends',
      );
      expect(
        notificationRuleTitle(_rule(offsetDays: 1)),
        'The day before a membership ends',
      );
    });

    test('dues read from zero days upward', () {
      expect(
        notificationRuleTitle(
          _rule(event: NotificationEvent.duesReminder, offsetDays: 0),
        ),
        'As soon as money is outstanding',
      );
      expect(
        notificationRuleTitle(
          _rule(event: NotificationEvent.duesReminder, offsetDays: 3),
        ),
        'When money has been outstanding for 3 days',
      );
    });
  });

  testWidgets('the visitor welcome offers no hour', (
    WidgetTester tester,
  ) async {
    // It rides an `after insert` trigger on `visitors`, so a time picker here
    // would promise a schedule that does not exist.
    final _FakeRepository repository = _FakeRepository(<NotificationRule>[
      _rule(
        id: 'rule-welcome',
        event: NotificationEvent.visitorWelcome,
        offsetDays: 0,
      ),
    ]);
    await _pump(tester, repository);

    expect(find.text('As soon as a visitor is logged at the desk'), findsOne);
    expect(find.text('Goes out within a minute'), findsOne);
    expect(
      find.byKey(const ValueKey<String>('rule-time-rule-welcome')),
      findsNothing,
    );
  });

  testWidgets('send_at_local round-trips 09:00:00 as 09:00', (
    WidgetTester tester,
  ) async {
    // A `time` column has no date and no zone. It stays text end to end;
    // parsing it into a `DateTime` invents both, and the org's timezone is not
    // the phone's.
    final _FakeRepository repository = _FakeRepository(<NotificationRule>[
      _rule(sendAtLocal: '09:00:00'),
    ]);
    await _pump(tester, repository);

    expect(find.text('Send at 09:00'), findsOne);

    await tester.tap(find.byKey(const ValueKey<String>('rule-save-rule-1')));
    await tester.pumpAndSettle();

    expect(repository.lastUpdate?['sendAtLocal'], '09:00');
  });

  testWidgets('a dues threshold is edited in rupees and saved in paisa', (
    WidgetTester tester,
  ) async {
    final _FakeRepository repository = _FakeRepository(<NotificationRule>[
      _rule(
        id: 'rule-dues',
        event: NotificationEvent.duesReminder,
        offsetDays: 0,
        minAmountPaisa: 250000,
      ),
    ]);
    await _pump(tester, repository);

    expect(find.text('2500'), findsOne);

    await tester.enterText(
      find.byKey(const ValueKey<String>('rule-min-amount-rule-dues')),
      '3000',
    );
    await tester.tap(find.byKey(const ValueKey<String>('rule-save-rule-dues')));
    await tester.pumpAndSettle();

    expect(repository.lastUpdate?['minAmountPaisa'], 300000);
    expect(repository.lastUpdate?['minAmountPaisa'], isA<int>());
  });
}
