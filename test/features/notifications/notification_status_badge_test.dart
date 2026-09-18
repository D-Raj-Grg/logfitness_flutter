// The status pill, and the one decision inside it that is worth a test.
//
// `skipped` and `cancelled` are not failures. `skipped` is what the outbox
// writes when the gym deliberately did not send -- no gateway on the channel,
// no token stored, an opted-out member, a number that cannot be delivered to.
// Painting it in the error role sends an owner hunting a gateway fault that
// does not exist, and tells a desk a member was not reached when the record
// says the opposite. The badge is the only place that call is made, so it is
// asserted here against the theme's roles rather than against pixel values.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/features/notifications/notification_labels.dart';
import 'package:logfitness_flutter/features/notifications/widgets/notification_status_badge.dart';

/// The badge's container colour, alongside the scheme it was resolved from, so
/// an assertion can name a role instead of a hex value.
Future<({Color? background, ColorScheme scheme})> _pumpBadge(
  WidgetTester tester,
  NotificationStatus status,
) async {
  late ColorScheme scheme;

  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0B6E4F)),
      ),
      home: Scaffold(
        body: Builder(
          builder: (BuildContext context) {
            scheme = Theme.of(context).colorScheme;
            return NotificationStatusBadge(status);
          },
        ),
      ),
    ),
  );

  final Container container = tester.widget<Container>(
    find.descendant(
      of: find.byType(NotificationStatusBadge),
      matching: find.byType(Container),
    ),
  );

  return (
    background: (container.decoration! as BoxDecoration).color,
    scheme: scheme,
  );
}

void main() {
  group('NotificationStatusBadge', () {
    testWidgets('renders the human label, never the wire value', (
      WidgetTester tester,
    ) async {
      await _pumpBadge(tester, NotificationStatus.skipped);

      expect(find.text('Not sent'), findsOneWidget);
      expect(find.text('skipped'), findsNothing);
    });

    testWidgets('every status has a label and a pill', (
      WidgetTester tester,
    ) async {
      for (final NotificationStatus status in NotificationStatus.values) {
        final result = await _pumpBadge(tester, status);

        expect(find.text(notificationStatusShort(status)), findsOneWidget);
        expect(
          result.background,
          isNotNull,
          reason: '${status.wire} must render a pill',
        );
      }
    });

    testWidgets('announces the status to a screen reader', (
      WidgetTester tester,
    ) async {
      await _pumpBadge(tester, NotificationStatus.failed);

      expect(
        tester.getSemantics(find.byType(NotificationStatusBadge)).label,
        contains('Failed'),
      );
    });
  });

  group('skipped and cancelled do not read as failures', () {
    testWidgets('skipped is neutral, not the error role', (
      WidgetTester tester,
    ) async {
      final result = await _pumpBadge(tester, NotificationStatus.skipped);

      expect(
        result.background,
        result.scheme.surfaceContainerHighest,
        reason: 'skipped is a decision, not a fault',
      );
      expect(result.background, isNot(result.scheme.errorContainer));
      expect(result.background, isNot(result.scheme.error));
    });

    testWidgets('cancelled is neutral too', (WidgetTester tester) async {
      final result = await _pumpBadge(tester, NotificationStatus.cancelled);

      expect(result.background, result.scheme.surfaceContainerHighest);
      expect(result.background, isNot(result.scheme.errorContainer));
    });

    testWidgets('failed is the only status painted in the error role', (
      WidgetTester tester,
    ) async {
      final failed = await _pumpBadge(tester, NotificationStatus.failed);
      expect(failed.background, failed.scheme.errorContainer);

      for (final NotificationStatus status in NotificationStatus.values) {
        if (status == NotificationStatus.failed) continue;
        final result = await _pumpBadge(tester, status);
        expect(
          result.background,
          isNot(result.scheme.errorContainer),
          reason: '${status.wire} must not read as a failure',
        );
      }
    });

    testWidgets('skipped and cancelled are visually distinct from failed', (
      WidgetTester tester,
    ) async {
      final skipped = await _pumpBadge(tester, NotificationStatus.skipped);
      final cancelled = await _pumpBadge(tester, NotificationStatus.cancelled);
      final failed = await _pumpBadge(tester, NotificationStatus.failed);

      expect(skipped.background, isNot(failed.background));
      expect(cancelled.background, isNot(failed.background));
      // And their words differ too -- colour is never the only carrier.
      expect(
        notificationStatusShort(NotificationStatus.skipped),
        isNot(notificationStatusShort(NotificationStatus.failed)),
      );
    });
  });

  group('the states that did work read as such', () {
    testWidgets('sent uses the secondary container, quietly', (
      WidgetTester tester,
    ) async {
      final result = await _pumpBadge(tester, NotificationStatus.sent);
      expect(result.background, result.scheme.secondaryContainer);
    });

    testWidgets('sending uses the primary container', (
      WidgetTester tester,
    ) async {
      final result = await _pumpBadge(tester, NotificationStatus.sending);
      expect(result.background, result.scheme.primaryContainer);
    });

    testWidgets('queued is an outline, so the log reads as still moving', (
      WidgetTester tester,
    ) async {
      final result = await _pumpBadge(tester, NotificationStatus.queued);
      expect(result.background, Colors.transparent);
    });
  });
}
