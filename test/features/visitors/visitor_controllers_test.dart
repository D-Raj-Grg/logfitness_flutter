// Exercises the visitor controllers against a fake VisitorsRepository -- no
// network, no real Supabase client. The fake `implements` the repository, the
// house pattern from auth_controller_test.dart, so the controller is tested
// through the same surface a screen calls.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/visitors/visitor.dart';
import 'package:logfitness_flutter/data/visitors/visitors_repository.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/features/visitors/visitor_actions_controller.dart';
import 'package:logfitness_flutter/features/visitors/visitor_list_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Visitor _visitor(String id) => Visitor(
      id: id,
      orgId: 'org-1',
      branchId: 'branch-1',
      kind: VisitorKind.enquiry,
      fullName: 'Anjali Shrestha',
      phone: '9800000000',
      visitedOn: DateTime.utc(2026, 9, 9),
      status: VisitorStatus.isNew,
      createdAt: DateTime.utc(2026, 9, 9, 4, 30),
      updatedAt: DateTime.utc(2026, 9, 9, 4, 30),
    );

class FakeVisitorsRepository implements VisitorsRepository {
  final List<VisitorListFilter> listCalls = <VisitorListFilter>[];

  /// Total the fake reports, which drives `hasMore`.
  int total = 2;
  int pageSize = 1;
  Object? listError;
  Object? writeError;

  int convertCallCount = 0;
  String? lastConvertedVisitorId;
  String? lastConvertedMemberId;
  Object? lastStatusWritten;
  int insertCallCount = 0;
  int deleteCallCount = 0;

  @override
  Future<VisitorPage> listVisitors(VisitorListFilter filter) async {
    listCalls.add(filter);
    if (listError != null) {
      throw listError!;
    }
    return VisitorPage(
      rows: <Visitor>[_visitor('v-${filter.page}')],
      total: total,
      page: filter.page,
      pageSize: pageSize,
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
    insertCallCount++;
    if (writeError != null) {
      throw writeError!;
    }
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
  }) async {
    lastStatusWritten = status;
    if (writeError != null) {
      throw writeError!;
    }
  }

  @override
  Future<void> deleteVisitor(String visitorId) async {
    deleteCallCount++;
    if (writeError != null) {
      throw writeError!;
    }
  }

  @override
  Future<void> convertVisitor(String visitorId, String memberId) async {
    convertCallCount++;
    lastConvertedVisitorId = visitorId;
    lastConvertedMemberId = memberId;
    if (writeError != null) {
      throw writeError!;
    }
  }
}

void main() {
  late FakeVisitorsRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = FakeVisitorsRepository();
    container = ProviderContainer(
      // Untyped literal on purpose: `Override` is not exported by
      // flutter_riverpod 3.1.0 (TASKS.md, Discovered, 2026-09-05).
      overrides: [
        visitorsRepositoryProvider.overrideWithValue(repository),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('VisitorFilter', () {
    test('opens on the callbacks the desk still owes, not the whole log', () {
      final filter = container.read(visitorFilterProvider);
      expect(filter.status, VisitorStatusFilter.open);
      expect(
        VisitorStatusFilter.open.statuses,
        <VisitorStatus>[VisitorStatus.isNew, VisitorStatus.contacted],
      );
    });

    test('a null status clears the filter rather than being ignored', () {
      final notifier = container.read(visitorFilterProvider.notifier);
      notifier.setStatus(null);
      expect(container.read(visitorFilterProvider).status, isNull);
    });

    test('a blank query is stored as null, not as an empty search', () {
      final notifier = container.read(visitorFilterProvider.notifier);
      notifier.setQuery('   ');
      expect(container.read(visitorFilterProvider).query, isNull);
      notifier.setQuery('  Anjali  ');
      expect(container.read(visitorFilterProvider).query, 'Anjali');
    });

    test('an empty branch list is a real filter, never widened to null', () {
      final notifier = container.read(visitorFilterProvider.notifier);
      notifier.setBranchIds(<String>[]);
      // The branch switcher must not silently show every branch when the
      // caller meant "none of them".
      expect(container.read(visitorFilterProvider).branchIds, isEmpty);
      expect(container.read(visitorFilterProvider).branchIds, isNotNull);
    });
  });

  group('VisitorList', () {
    test('loads the first page against the current filter', () async {
      final state = await container.read(visitorListProvider.future);
      expect(state.rows, hasLength(1));
      expect(state.page, 1);
      expect(state.hasMore, isTrue);
      expect(repository.listCalls.single.status, VisitorStatusFilter.open);
    });

    test('changing a filter re-queries from page one', () async {
      await container.read(visitorListProvider.future);
      container.read(visitorFilterProvider.notifier).setQuery('9800');
      final state = await container.read(visitorListProvider.future);

      expect(state.page, 1);
      expect(repository.listCalls.last.query, '9800');
      expect(repository.listCalls.last.page, 1);
    });

    test('loadMore appends rather than replacing', () async {
      await container.read(visitorListProvider.future);
      await container.read(visitorListProvider.notifier).loadMore();

      final state = container.read(visitorListProvider).value!;
      expect(state.rows.map((Visitor v) => v.id), <String>['v-1', 'v-2']);
      expect(state.page, 2);
      expect(state.hasMore, isFalse);
    });

    test('loadMore is a no-op once the last page is in', () async {
      await container.read(visitorListProvider.future);
      await container.read(visitorListProvider.notifier).loadMore();
      final callsBefore = repository.listCalls.length;

      await container.read(visitorListProvider.notifier).loadMore();
      expect(repository.listCalls, hasLength(callsBefore));
    });

    test('a failed append keeps the rows and reports why', () async {
      await container.read(visitorListProvider.future);
      repository.listError = const SocketExceptionStub();

      await container.read(visitorListProvider.notifier).loadMore();
      final state = container.read(visitorListProvider).value!;

      // Blanking a list someone is reading because page two timed out is a
      // worse answer than leaving it and saying so.
      expect(state.rows, hasLength(1));
      expect(state.loadingMore, isFalse);
      expect(state.appendFailure, isNotNull);
    });
  });

  group('VisitorActions', () {
    test('logging a walk-in reports the new id and refreshes the log',
        () async {
      await container.read(visitorListProvider.future);
      final callsBefore = repository.listCalls.length;

      final result =
          await container.read(visitorActionsProvider.notifier).log(
                orgId: 'org-1',
                branchId: 'branch-1',
                fullName: 'Anjali Shrestha',
                phone: '9800000000',
              );

      expect(result, isA<VisitorActionSucceeded>());
      expect((result as VisitorActionSucceeded).visitorId, 'v-new');
      expect(repository.insertCallCount, 1);
      // The log is the screen behind the action, so it is stale afterwards.
      expect(repository.listCalls.length, greaterThan(callsBefore));
    });

    test('a database refusal comes back as a refusal, not a generic error',
        () async {
      await container.read(visitorListProvider.future);
      repository.writeError = const PostgrestException(
        message: 'new row violates row-level security policy',
        code: '42501',
      );

      final result = await container
          .read(visitorActionsProvider.notifier)
          .markLost('v-1');

      expect(result, isA<VisitorActionFailed>());
      final failed = result as VisitorActionFailed;
      // Role gating in this app is UX only; the refusal is the database's and
      // it has to reach the person who tried.
      expect(failed.isRefusal, isTrue);
      expect(failed.failure.kind, FailureKind.refused);
    });

    test('markContacted writes the contacted status', () async {
      await container.read(visitorListProvider.future);
      await container
          .read(visitorActionsProvider.notifier)
          .markContacted('v-1');
      expect(repository.lastStatusWritten, VisitorStatus.contacted);
    });

    test('convert points the visitor at the member it became', () async {
      await container.read(visitorListProvider.future);
      final result =
          await container.read(visitorActionsProvider.notifier).convert(
                visitorId: 'v-1',
                memberId: 'm-9',
              );

      expect(result, isA<VisitorActionSucceeded>());
      expect(repository.convertCallCount, 1);
      expect(repository.lastConvertedVisitorId, 'v-1');
      expect(repository.lastConvertedMemberId, 'm-9');
    });
  });
}

/// Stands in for a dropped connection without depending on `dart:io` in a
/// test that otherwise needs none.
class SocketExceptionStub implements Exception {
  const SocketExceptionStub();
}
