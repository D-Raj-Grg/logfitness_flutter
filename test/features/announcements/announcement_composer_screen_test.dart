// The composer, checked at the places where the screen is the last thing
// standing between a desk and four hundred messages: what disables Send, what
// the credit line multiplies, and whether a refusal reaches the person.
//
// `Override` is not exported by flutter_riverpod 3.1.0, so every overrides
// list stays an untyped literal (TASKS.md, Discovered, 2026-09-05).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/announcements/announcement_audience_count.dart';
import 'package:logfitness_flutter/data/announcements/announcement_queries.dart';
import 'package:logfitness_flutter/data/announcements/announcements_repository.dart';
import 'package:logfitness_flutter/data/branches/branch.dart';
import 'package:logfitness_flutter/data/branches/branches_repository.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/features/announcements/announcement_audience_controller.dart';
import 'package:logfitness_flutter/features/announcements/announcement_composer_screen.dart';
import 'package:logfitness_flutter/features/staff/branch_scope.dart';

class _FakeRepository implements AnnouncementsRepository {
  _FakeRepository({this.reachable = 128, this.sendError});

  final int reachable;
  final Object? sendError;

  int sendCount = 0;

  @override
  Future<AnnouncementAudienceCount> countAnnouncementAudience(
    AnnouncementAudienceQuery query,
  ) async => AnnouncementAudienceCount(
    total: reachable + 4,
    reachable: reachable,
    unusable: 4,
    members: reachable,
    visitors: 0,
  );

  @override
  Future<String> sendAnnouncement({
    required String title,
    required String body,
    required AnnouncementAudience audience,
    NotificationChannel channel = NotificationChannel.sms,
    String? branchId,
    List<MemberStatus>? memberStatuses,
    int? visitorDays,
    DateTime? scheduledFor,
  }) async {
    sendCount++;
    if (sendError != null) throw sendError!;
    return 'a-1';
  }

  @override
  Never noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not faked');
}

Future<void> _pump(WidgetTester tester, _FakeRepository repository) async {
  // A tall viewport on purpose. The composer is a `ListView`, which builds only
  // what is on screen, and the audience panel and the test-send block live
  // below the fold of the default 800x600 surface -- so on a short surface the
  // assertions below would be testing that a widget was not built rather than
  // what it says.
  tester.view.physicalSize = const Size(1000, 3000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      // Spread into an untyped literal so inference supplies `Override`,
      // which flutter_riverpod 3.1.0 does not export.
      overrides: [
        announcementsRepositoryProvider.overrideWithValue(repository),
        announcementCountDebounceProvider.overrideWithValue(Duration.zero),
        branchScopeProvider.overrideWithValue(
          const BranchScope(
            options: <String>['branch-1'],
            selectedBranchId: 'branch-1',
            isOrgWide: false,
          ),
        ),
        branchesProvider.overrideWith((ref) async => const <Branch>[]),
      ],
      child: const MaterialApp(home: AnnouncementComposerScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

/// The Send button lives in the docked action at the bottom.
///
/// `byWidgetPredicate` rather than `byType`: `FilledButton.icon` builds a
/// private subclass, and `find.byType` matches the exact runtime type only.
final Finder _sendFinder = find.byWidgetPredicate(
  (Widget widget) => widget is FilledButton && widget.child is! Text,
);

FilledButton _send(WidgetTester tester) =>
    tester.widget<FilledButton>(_sendFinder.last);

Future<void> _fillIn(WidgetTester tester, {String? title, String? body}) async {
  if (title != null) {
    await tester.enterText(
      find.byKey(const ValueKey<String>('announcement-title')),
      title,
    );
  }
  if (body != null) {
    await tester.enterText(
      find.byKey(const ValueKey<String>('announcement-body')),
      body,
    );
  }
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Send is off until there is a title and a message', (
    tester,
  ) async {
    await _pump(tester, _FakeRepository());

    expect(_send(tester).onPressed, isNull);

    await _fillIn(tester, title: 'Closed Sunday');
    expect(_send(tester).onPressed, isNull, reason: 'a title alone is not a message');

    await _fillIn(tester, body: 'We are shut on Sunday.');
    expect(_send(tester).onPressed, isNotNull);
  });

  testWidgets('Send is off when the audience is nobody', (tester) async {
    // The filters found people and not one of them can be reached. Pressing
    // Send would write skipped rows and light up no handsets at all.
    await _pump(tester, _FakeRepository(reachable: 0));
    await _fillIn(tester, title: 'Closed Sunday', body: 'We are shut.');

    expect(_send(tester).onPressed, isNull);
    expect(find.text('Nobody matches that audience yet.'), findsOneWidget);
  });

  testWidgets('the button says how many it is about to text', (tester) async {
    await _pump(tester, _FakeRepository());
    await _fillIn(tester, title: 'Closed Sunday', body: 'We are shut.');

    expect(find.text('Send to 128'), findsOneWidget);
  });

  testWidgets('the credit line is recipients times segments', (tester) async {
    await _pump(tester, _FakeRepository());
    await _fillIn(tester, title: 'Closed Sunday', body: 'We are shut.');

    // One English segment each.
    expect(
      find.text('128 will be texted · about 128 SMS credits'),
      findsOneWidget,
    );

    // The one arithmetic an owner will check: Devanagari is UCS-2, 70
    // characters to a segment, so the same sentence costs three times as much.
    await _fillIn(
      tester,
      body: 'हामी आइतबार बन्द छौं। कृपया ध्यान दिनुहोस्। '
          'सोमबारदेखि नियमित समयमा खुल्नेछ। धन्यवाद।',
    );
    expect(
      find.text('128 will be texted · about 256 SMS credits'),
      findsOneWidget,
    );
  });

  testWidgets('the unusable numbers are named, not hidden', (tester) async {
    await _pump(tester, _FakeRepository());
    await _fillIn(tester, title: 'Closed Sunday', body: 'We are shut.');

    expect(
      find.text(
        '128 members · 0 visitors · 4 with no usable number, logged as not sent',
      ),
      findsOneWidget,
    );
  });

  testWidgets('the default branch and window read as chosen, not as blank', (
    tester,
  ) async {
    // A null value renders as the hint, so a nullable picker without one looks
    // like a question nobody answered -- when in fact "every open visitor" is
    // exactly what is selected and what the send will use.
    await _pump(tester, _FakeRepository());

    expect(find.text('Every open visitor'), findsOneWidget);
  });

  testWidgets('a visitors-only audience takes the status chips away', (
    tester,
  ) async {
    await _pump(tester, _FakeRepository());

    expect(
      find.byKey(const ValueKey<String>('announcement-status-active')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey<String>('announcement-audience')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Visitors only').last);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('announcement-status-active')),
      findsNothing,
    );
  });

  testWidgets('a members-only audience takes the visitor window away', (
    tester,
  ) async {
    await _pump(tester, _FakeRepository());

    expect(
      find.byKey(const ValueKey<String>('announcement-visitor-window')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey<String>('announcement-audience')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Members only').last);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('announcement-visitor-window')),
      findsNothing,
    );
  });

  testWidgets('a refusal is shown in the database\'s own words', (tester) async {
    // Hiding the button is UX; the refusal is the boundary, and it has to
    // reach the person rather than be swallowed.
    await _pump(
      tester,
      _FakeRepository(
        sendError: const AppFailure(
          FailureKind.refused,
          'Only an owner, manager or front desk can send an announcement',
          code: '42501',
        ),
      ),
    );
    await _fillIn(tester, title: 'Closed Sunday', body: 'We are shut.');

    await tester.tap(_sendFinder.last);
    await tester.pumpAndSettle();

    expect(
      find.text('Only an owner, manager or front desk can send an announcement'),
      findsOneWidget,
    );
  });

  testWidgets('the test send waits for a number and a message', (tester) async {
    await _pump(tester, _FakeRepository());

    final Finder testButton = find.byKey(
      const ValueKey<String>('announcement-test-send'),
    );
    expect(tester.widget<FilledButton>(testButton).onPressed, isNull);

    await _fillIn(tester, title: 'Closed Sunday', body: 'We are shut.');
    expect(tester.widget<FilledButton>(testButton).onPressed, isNull);

    await tester.enterText(
      find.byKey(const ValueKey<String>('announcement-test-to')),
      '9800000201',
    );
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(testButton).onPressed, isNotNull);
  });
}
