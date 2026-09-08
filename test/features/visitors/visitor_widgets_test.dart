// The visitor log's presentation, checked where it can silently drift.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/visitors/visitor.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/features/visitors/widgets/visitor_labels.dart';
import 'package:logfitness_flutter/features/visitors/widgets/visitor_status_badge.dart';
import 'package:logfitness_flutter/features/visitors/widgets/visitor_tile.dart';

Visitor _visitor({
  VisitorStatus status = VisitorStatus.isNew,
  VisitorKind kind = VisitorKind.enquiry,
  String? note,
}) =>
    Visitor(
      id: 'v-1',
      orgId: 'org-1',
      branchId: 'branch-1',
      kind: kind,
      fullName: 'Anjali Shrestha',
      phone: '9800000000',
      visitedOn: DateTime.utc(2026, 9, 9),
      note: note,
      status: status,
      createdAt: DateTime.utc(2026, 9, 9, 4, 30),
      updatedAt: DateTime.utc(2026, 9, 9, 4, 30),
    );

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('labels', () {
    test('match the words the console uses, not the enum names', () {
      // Parity with logfitness_saas/components/visitors/visitors-table.tsx.
      // The desk and the manager are discussing the same person.
      expect(visitorStatusLabel(VisitorStatus.isNew), 'New');
      expect(visitorStatusLabel(VisitorStatus.contacted), 'Contacted');
      expect(visitorStatusLabel(VisitorStatus.converted), 'Joined');
      expect(visitorStatusLabel(VisitorStatus.lost), 'Not joining');
      expect(visitorKindLabel(VisitorKind.enquiry), 'Enquiry');
      expect(visitorKindLabel(VisitorKind.guest), 'Guest');
    });

    test('every status and kind has a label', () {
      for (final status in VisitorStatus.values) {
        expect(visitorStatusLabel(status), isNotEmpty);
      }
      for (final kind in VisitorKind.values) {
        expect(visitorKindLabel(kind), isNotEmpty);
      }
    });
  });

  group('VisitorStatusBadge', () {
    testWidgets('renders the human label, never the wire value',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(const VisitorStatusBadge(VisitorStatus.converted)),
      );

      expect(find.text('Joined'), findsOneWidget);
      expect(find.text('converted'), findsNothing);
    });

    testWidgets('announces the status to a screen reader',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(const VisitorStatusBadge(VisitorStatus.lost)),
      );

      expect(
        tester.getSemantics(find.byType(VisitorStatusBadge)).label,
        contains('Not joining'),
      );
    });
  });

  group('VisitorTile', () {
    testWidgets('leads with the name and the phone number',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(VisitorTile(visitor: _visitor())));

      expect(find.text('Anjali Shrestha'), findsOneWidget);
      // The phone is the identity anchor (PLANNING.md §5) and is read aloud
      // while dialling, so it is not fine print.
      expect(find.text('9800000000'), findsOneWidget);
    });

    testWidgets('renders visited_on as its own calendar day, unshifted',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(VisitorTile(visitor: _visitor())));

      // A date column moved by the org's +05:45 offset would read 08 Sep.
      expect(find.textContaining('09 Sep 2026'), findsOneWidget);
    });

    testWidgets('offers a call action on an open row only',
        (WidgetTester tester) async {
      String? dialled;
      await tester.pumpWidget(
        _wrap(
          VisitorTile(
            visitor: _visitor(),
            onCall: (String phone) => dialled = phone,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.phone_outlined));
      expect(dialled, '9800000000');
    });

    testWidgets('a finished row offers no call action',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(
          VisitorTile(
            visitor: _visitor(status: VisitorStatus.converted),
            onCall: (String _) {},
          ),
        ),
      );

      // Chasing someone who already joined is the log's own noise.
      expect(find.byIcon(Icons.phone_outlined), findsNothing);
    });

    testWidgets('shows a note when there is one, and nothing when blank',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(VisitorTile(visitor: _visitor(note: 'Asked about morning rates'))),
      );
      expect(find.text('Asked about morning rates'), findsOneWidget);

      await tester.pumpWidget(
        _wrap(VisitorTile(visitor: _visitor(note: '   '))),
      );
      expect(find.textContaining('Asked'), findsNothing);
    });
  });
}
