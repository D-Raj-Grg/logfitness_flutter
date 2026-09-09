// The visitor log's screens, checked where they can fail silently.
//
// `Override` is not exported by flutter_riverpod 3.1.0, so every overrides
// list stays an untyped literal (TASKS.md, Discovered, 2026-09-05).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/visitors/visitor.dart';
import 'package:logfitness_flutter/data/visitors/visitors_repository.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/features/auth/auth_controller.dart';
import 'package:logfitness_flutter/features/common/failure_view.dart';
import 'package:logfitness_flutter/features/visitors/visitor_form_screen.dart';
import 'package:logfitness_flutter/features/visitors/visitor_log_screen.dart';
import 'package:logfitness_flutter/features/visitors/widgets/visitor_tile.dart';
import 'package:logfitness_flutter/supabase/app_claims.dart';
import 'package:logfitness_flutter/supabase/supabase_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Visitor _visitor(String id, {String name = 'Anjali Shrestha'}) => Visitor(
      id: id,
      orgId: 'org-1',
      branchId: 'branch-1',
      kind: VisitorKind.enquiry,
      fullName: name,
      phone: '9800000000',
      visitedOn: DateTime.utc(2026, 9, 9),
      status: VisitorStatus.isNew,
      createdAt: DateTime.utc(2026, 9, 9, 4, 30),
      updatedAt: DateTime.utc(2026, 9, 9, 4, 30),
    );

class _FakeVisitorsRepository implements VisitorsRepository {
  _FakeVisitorsRepository({this.rows = const <Visitor>[], this.error});

  List<Visitor> rows;
  Object? error;

  VisitorListFilter? lastFilter;
  Map<String, Object?>? lastInsert;

  @override
  Future<VisitorPage> listVisitors(VisitorListFilter filter) async {
    lastFilter = filter;
    if (error != null) {
      throw error!;
    }
    return VisitorPage(
      rows: rows,
      total: rows.length,
      page: filter.page,
      pageSize: filter.pageSize,
    );
  }

  @override
  Future<Visitor?> getVisitor(String visitorId) async => _visitor(visitorId);

  @override
  Future<String> insertVisitor({
    required String orgId,
    required String branchId,
    required String fullName,
    required String phone,
    VisitorKind kind = VisitorKind.enquiry,
    DateTime? visitedOn,
    String? note,
    String? interestedPlanId,
  }) async {
    lastInsert = <String, Object?>{
      'fullName': fullName,
      'phone': phone,
      'kind': kind,
      'visitedOn': visitedOn,
      'note': note,
    };
    return 'v-new';
  }

  @override
  Future<void> updateVisitor(
    String visitorId, {
    Object? fullName = visitorFieldUnchanged,
    Object? phone = visitorFieldUnchanged,
    Object? kind = visitorFieldUnchanged,
    Object? visitedOn = visitorFieldUnchanged,
    Object? note = visitorFieldUnchanged,
    Object? interestedPlanId = visitorFieldUnchanged,
    Object? status = visitorFieldUnchanged,
  }) async {}

  @override
  Future<void> deleteVisitor(String visitorId) async {}

  @override
  Future<void> convertVisitor(String visitorId, String memberId) async {}
}

AppClaims _claims() => const AppClaims(
      orgId: 'org-1',
      staffId: 'staff-1',
      staffRole: StaffRole.frontDesk,
      branchIds: <String>['branch-1'],
    );

List<dynamic> _overrides(_FakeVisitorsRepository repository) {
  final claims = _claims();
  return <dynamic>[
    visitorsRepositoryProvider.overrideWithValue(repository),
    claimsProvider.overrideWithValue(claims),
    principalProvider.overrideWithValue(
      AsyncValue<Principal>.data(Principal.staff(claims)),
    ),
  ];
}

Future<void> _pump(WidgetTester tester, Widget child,
    _FakeVisitorsRepository repository) async {
  await tester.pumpWidget(
    ProviderScope(
      // Spread into an untyped literal so inference supplies `Override`,
      // which flutter_riverpod 3.1.0 does not export (TASKS.md, Discovered).
      overrides: [..._overrides(repository)],
      child: MaterialApp(home: child),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('VisitorLogScreen', () {
    testWidgets('renders a row per walk-in', (WidgetTester tester) async {
      final repository = _FakeVisitorsRepository(
        rows: <Visitor>[_visitor('v-1'), _visitor('v-2', name: 'Bikash Rai')],
      );
      await _pump(tester, const VisitorLogScreen(), repository);

      expect(find.byType(VisitorTile), findsNWidgets(2));
      expect(find.text('Anjali Shrestha'), findsOneWidget);
      expect(find.text('Bikash Rai'), findsOneWidget);
    });

    testWidgets('opens on the callbacks still owed, not the whole log',
        (WidgetTester tester) async {
      final repository = _FakeVisitorsRepository(rows: <Visitor>[_visitor('v-1')]);
      await _pump(tester, const VisitorLogScreen(), repository);

      // `open` is new + contacted, matching `visitors_open_idx` upstream.
      expect(repository.lastFilter?.status, VisitorStatusFilter.open);
    });

    testWidgets('an empty log says so and offers the way out of it',
        (WidgetTester tester) async {
      final repository = _FakeVisitorsRepository();
      await _pump(tester, const VisitorLogScreen(), repository);

      expect(find.text('No callbacks outstanding.'), findsOneWidget);
      expect(find.text('Log a walk-in'), findsOneWidget);
    });

    testWidgets('a refusal renders as a refusal, not an empty log',
        (WidgetTester tester) async {
      final repository = _FakeVisitorsRepository(
        error: const PostgrestException(
          message: 'permission denied for table visitors',
          code: '42501',
        ),
      );
      await _pump(tester, const VisitorLogScreen(), repository);

      // The distinction this whole surface exists for: refused is not empty,
      // and it is not a generic error either.
      expect(find.byType(FailureView), findsOneWidget);
      expect(find.textContaining('refused'), findsWidgets);
    });

    testWidgets('a filter chip changes what is asked for',
        (WidgetTester tester) async {
      final repository = _FakeVisitorsRepository(rows: <Visitor>[_visitor('v-1')]);
      await _pump(tester, const VisitorLogScreen(), repository);

      await tester.tap(find.byKey(const ValueKey<String>('visitor-filter-lost')));
      await tester.pumpAndSettle();

      expect(repository.lastFilter?.status, VisitorStatusFilter.lost);
    });
  });

  group('VisitorFormScreen', () {
    testWidgets('refuses a blank name and a blank phone',
        (WidgetTester tester) async {
      final repository = _FakeVisitorsRepository();
      await _pump(tester, const VisitorFormScreen(), repository);

      await tester.tap(find.text('Log walk-in'));
      await tester.pumpAndSettle();

      expect(find.text('A name is required.'), findsOneWidget);
      expect(find.text('A phone number is required.'), findsOneWidget);
      expect(repository.lastInsert, isNull);
    });

    testWidgets('sends no visited-on date unless one was picked',
        (WidgetTester tester) async {
      final repository = _FakeVisitorsRepository();
      await _pump(tester, const VisitorFormScreen(), repository);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Full name'),
        'Anjali Shrestha',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Phone'),
        '9800000000',
      );
      await tester.tap(find.text('Log walk-in'));
      await tester.pumpAndSettle();

      // The `set_visitor_defaults` trigger fills the org's own today, and the
      // database is the only thing that knows the org's timezone. Sending the
      // device's date instead is how a 06:00 walk-in lands on yesterday.
      expect(repository.lastInsert, isNotNull);
      expect(repository.lastInsert!['visitedOn'], isNull);
      expect(repository.lastInsert!['fullName'], 'Anjali Shrestha');
    });

    testWidgets('says out loud that blank means today',
        (WidgetTester tester) async {
      final repository = _FakeVisitorsRepository();
      await _pump(tester, const VisitorFormScreen(), repository);

      expect(find.textContaining("this gym's own reckoning"), findsOneWidget);
    });
  });
}
