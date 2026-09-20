// The gym's own wording.
//
// Two things this screen cannot get wrong: it has to count segments rather
// than characters -- segments are what turn into money, and a Devanagari body
// is 70 to a segment -- and it must offer "reset to the built-in" only where
// there is an org row to delete.
//
// `Override` is not exported by flutter_riverpod 3.1.0, so every overrides list
// stays an untyped literal (TASKS.md, Discovered, 2026-09-05).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/notifications/notification_template.dart';
import 'package:logfitness_flutter/data/notifications/notifications_repository.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/features/notifications/notification_labels.dart';
import 'package:logfitness_flutter/features/settings/notifications/template_editor.dart';
import 'package:logfitness_flutter/supabase/app_claims.dart';
import 'package:logfitness_flutter/supabase/supabase_providers.dart';

class _FakeRepository implements NotificationsRepository {
  _FakeRepository({this.orgOwned = false});

  /// Whether the gym has edited this wording. `template_id` non-null is
  /// exactly what decides whether a reset is offered.
  bool orgOwned;

  /// The wording the fake answers with.
  String body = 'Hi {{member_name}}.';
  String locale = 'en';

  @override
  Future<NotificationTemplatePreview?> previewNotificationTemplate(
    String orgId,
    NotificationEvent event,
    NotificationChannel channel,
    String locale,
  ) async {
    return NotificationTemplatePreview(
      templateId: orgOwned ? 'tpl-${event.wire}' : null,
      subject: null,
      body: body,
    );
  }

  @override
  Future<String> orgNotificationLocale(String orgId) async => locale;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError(
    '${invocation.memberName} is not part of the template editor test',
  );
}

Future<void> _pump(WidgetTester tester, _FakeRepository repository) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        notificationsRepositoryProvider.overrideWithValue(repository),
        claimsProvider.overrideWithValue(
          const AppClaims(
            orgId: 'org-1',
            branchIds: <String>['branch-1'],
            staffRole: StaffRole.owner,
            staffId: 'staff-1',
          ),
        ),
      ],
      child: const MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: TemplateEditor())),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('previewTemplateBody', () {
    test('substitutes the sample values and tidies the gaps', () {
      expect(
        previewTemplateBody('Hi {{member_name}}, {{gym_name}} here.'),
        'Hi Ram Thapa, Lord of Gyms here.',
      );
    });

    test('a placeholder with no sample leaves no double space behind', () {
      expect(previewTemplateBody('Hi {{nobody}} there'), 'Hi there');
    });
  });

  testWidgets('the counter is in segments, and follows what is typed', (
    WidgetTester tester,
  ) async {
    await _pump(tester, _FakeRepository());

    const Key counter = ValueKey<String>('template-segments-renewal_reminder');
    expect(tester.widget<Text>(find.byKey(counter)).data, '1 SMS');

    // 200 ASCII characters is two segments at 160 a segment.
    await tester.enterText(
      find.byKey(const ValueKey<String>('template-body-renewal_reminder')),
      'a' * 200,
    );
    await tester.pump();

    expect(tester.widget<Text>(find.byKey(counter)).data, '2 SMS');
  });

  testWidgets('Devanagari costs more, and the counter says why', (
    WidgetTester tester,
  ) async {
    await _pump(tester, _FakeRepository());

    await tester.enterText(
      find.byKey(const ValueKey<String>('template-body-renewal_reminder')),
      'नमस्ते' * 20, // 120 code units, so two 70-character segments
    );
    await tester.pump();

    final String? text = tester
        .widget<Text>(
          find.byKey(
            const ValueKey<String>('template-segments-renewal_reminder'),
          ),
        )
        .data;
    expect(text, contains('SMS'));
    expect(text, contains('Nepali text sends as Unicode'));
    expect(text, contains('70 characters'));
  });

  testWidgets('reset is offered only for a wording the gym owns', (
    WidgetTester tester,
  ) async {
    // Nothing to reset when the built-in is already what is being used, and a
    // button that deletes nothing is a button that looks broken.
    await _pump(tester, _FakeRepository());

    expect(
      find.byKey(const ValueKey<String>('template-reset-renewal_reminder')),
      findsNothing,
    );
    expect(find.text('Standard wording'), findsWidgets);

    await _pump(tester, _FakeRepository(orgOwned: true));

    expect(
      find.byKey(const ValueKey<String>('template-reset-renewal_reminder')),
      findsOne,
    );
    expect(find.text('Your wording'), findsWidgets);
  });

  testWidgets('every editable event gets an editor', (
    WidgetTester tester,
  ) async {
    await _pump(tester, _FakeRepository());

    for (final NotificationEvent event in <NotificationEvent>[
      NotificationEvent.renewalReminder,
      NotificationEvent.duesReminder,
      NotificationEvent.birthdayGreeting,
      NotificationEvent.visitorWelcome,
      NotificationEvent.visitorFollowUp,
      NotificationEvent.memberWelcome,
      NotificationEvent.paymentReceived,
      NotificationEvent.duesCleared,
    ]) {
      expect(
        find.byKey(ValueKey<String>('template-body-${event.wire}')),
        findsOne,
        reason: '${event.wire} has no editor',
      );
    }
  });

  test('every editable event names the placeholders it can fill', () {
    // An event on the screen with no variable list offers the owner nothing
    // to insert, which reads as "this wording takes no details" rather than
    // as the omission it is.
    for (final NotificationEvent event in kEditableTemplateEvents) {
      expect(
        kTemplateVariables[event],
        isNotNull,
        reason: '${event.wire} is editable but lists no placeholders',
      );
      expect(kTemplateVariables[event], isNotEmpty, reason: event.wire);
    }
  });

  test('every offered placeholder has a sample the preview can substitute', () {
    // The preview drops a placeholder it cannot fill. Offering one that is
    // always dropped is how a body ships with a hole where a figure should be.
    for (final List<String> variables in kTemplateVariables.values) {
      for (final String name in variables) {
        expect(
          kTemplateSampleValues[name],
          isNotNull,
          reason: '$name is offered but has no sample value',
        );
      }
    }
  });
}
