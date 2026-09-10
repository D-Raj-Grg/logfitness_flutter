// The member list, checked where it can fail silently.
//
// `Override` is not exported by flutter_riverpod 3.1.0, so every overrides
// list stays an untyped literal spread into `overrides:` (TASKS.md,
// Discovered, 2026-09-05).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/members/member_list_query.dart';
import 'package:logfitness_flutter/data/members/member_overview.dart';
import 'package:logfitness_flutter/data/members/members_repository.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/features/auth/auth_controller.dart';
import 'package:logfitness_flutter/features/common/failure_view.dart';
import 'package:logfitness_flutter/features/members/member_list_controller.dart';
import 'package:logfitness_flutter/features/members/member_list_screen.dart';
import 'package:logfitness_flutter/supabase/app_claims.dart';
import 'package:logfitness_flutter/supabase/supabase_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

MemberOverview _member(
  String id, {
  String name = 'Anjali Shrestha',
  String code = 'M-0001',
  int duePaisa = 0,
  DateTime? archivedAt,
}) => MemberOverview(
  id: id,
  orgId: 'org-1',
  homeBranchId: 'branch-1',
  homeBranchName: 'Thamel',
  memberCode: code,
  fullName: name,
  phone: '9800000000',
  status: MemberStatus.active,
  joinedOn: DateTime.utc(2026, 1, 4),
  duePaisa: duePaisa,
  hasMembershipHistory: true,
  archivedAt: archivedAt,
);

class _FakeMembersRepository implements MembersRepository {
  _FakeMembersRepository({
    this.rows = const <MemberOverview>[],
    this.total,
    this.error,
    this.counts = const MemberStatusCounts(
      active: 12,
      expiring: 3,
      expired: 4,
      frozen: 1,
      withDues: 2,
    ),
  });

  List<MemberOverview> rows;

  /// Defaults to `rows.length`; set it higher to make the list believe there
  /// is another page.
  int? total;
  Object? error;
  MemberStatusCounts counts;

  MemberListQuery? lastQuery;
  List<String>? lastBranchIds;
  int listCallCount = 0;

  @override
  Future<MemberListResult> listMembers(
    MemberListQuery query, {
    List<String>? branchIds,
  }) async {
    listCallCount++;
    lastQuery = query;
    lastBranchIds = branchIds;
    if (error != null) {
      throw error!;
    }
    return MemberListResult(
      rows: rows,
      total: total ?? rows.length,
      page: query.page,
      pageSize: query.pageSize,
    );
  }

  @override
  Future<MemberStatusCounts> memberStatusCounts({
    List<String>? branchIds,
  }) async => counts;

  @override
  Never noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not faked');
}

AppClaims _claims() => const AppClaims(
  orgId: 'org-1',
  staffId: 'staff-1',
  staffRole: StaffRole.frontDesk,
  branchIds: <String>['branch-1'],
);

List<dynamic> _overrides(_FakeMembersRepository repository) {
  final AppClaims claims = _claims();
  return <dynamic>[
    membersRepositoryProvider.overrideWithValue(repository),
    claimsProvider.overrideWithValue(claims),
    principalProvider.overrideWithValue(
      AsyncValue<Principal>.data(Principal.staff(claims)),
    ),
  ];
}

/// The chip row scrolls horizontally, so a chip past the fold has to be
/// brought into view before it can be tapped.
Future<void> _tapChip(WidgetTester tester, MemberListFilter? filter) async {
  final Finder chip = find.byKey(memberFilterChipKey(filter));
  await tester.ensureVisible(chip);
  await tester.pumpAndSettle();
  await tester.tap(chip);
  await tester.pumpAndSettle();
}

Future<void> _pump(
  WidgetTester tester,
  _FakeMembersRepository repository,
) async {
  await tester.pumpWidget(
    ProviderScope(
      // Spread into an untyped literal so inference supplies `Override`,
      // which flutter_riverpod 3.1.0 does not export.
      overrides: [..._overrides(repository)],
      child: const MaterialApp(home: MemberListScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('MemberListScreen', () {
    testWidgets('renders a row per member', (WidgetTester tester) async {
      final repository = _FakeMembersRepository(
        rows: <MemberOverview>[
          _member('m-1'),
          _member('m-2', name: 'Bikash Rai', code: 'M-0002'),
        ],
      );
      await _pump(tester, repository);

      expect(find.byType(MemberTile), findsNWidgets(2));
      expect(find.text('Anjali Shrestha'), findsOneWidget);
      expect(find.text('Bikash Rai'), findsOneWidget);
      // Both numbers, so nobody mistakes a page for the whole filter.
      expect(find.text('2 members'), findsOneWidget);
    });

    testWidgets('opens with no status filter, which excludes the archived', (
      WidgetTester tester,
    ) async {
      final repository = _FakeMembersRepository(
        rows: <MemberOverview>[_member('m-1')],
      );
      await _pump(tester, repository);

      // Archived is opt-in: `listMembers` applies `archived_at is null` for
      // every status except `archived`, so anything but that filter keeps the
      // people the desk deliberately put away out of the list.
      expect(repository.lastQuery?.status, isNull);
      expect(
        repository.lastQuery?.status,
        isNot(MemberListFilter.archived),
      );
    });

    testWidgets('only the Archived chip asks for archived members', (
      WidgetTester tester,
    ) async {
      final repository = _FakeMembersRepository(
        rows: <MemberOverview>[
          _member('m-1', archivedAt: DateTime.utc(2026, 8, 1)),
        ],
      );
      await _pump(tester, repository);

      // Every other chip first: none of them may widen into the archive.
      for (final MemberListFilter filter in MemberListFilter.values) {
        if (filter == MemberListFilter.archived) {
          continue;
        }
        await _tapChip(tester, filter);
        expect(repository.lastQuery?.status, filter);
      }

      await _tapChip(tester, MemberListFilter.archived);

      expect(repository.lastQuery?.status, MemberListFilter.archived);
      // And the row says why it is only ever seen here.
      expect(find.text('Archived'), findsWidgets);
    });

    testWidgets('a chip resets to page one', (WidgetTester tester) async {
      final repository = _FakeMembersRepository(
        rows: <MemberOverview>[_member('m-1')],
        total: 40,
      );
      await _pump(tester, repository);

      await _tapChip(tester, MemberListFilter.dues);

      // Page 3 of the old filter has nothing to do with page 3 of the new one.
      expect(repository.lastQuery?.page, 1);
    });

    testWidgets('the search term reaches the query', (
      WidgetTester tester,
    ) async {
      final repository = _FakeMembersRepository(
        rows: <MemberOverview>[_member('m-1')],
      );
      await _pump(tester, repository);

      await tester.enterText(
        find.byKey(const ValueKey<String>('member-search')),
        '98012',
      );
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      // A phone prefix, a member-code prefix or a name -- the repository's
      // `or()` decides which; the screen only has to send the term.
      expect(repository.lastQuery?.q, '98012');
      expect(repository.lastQuery?.page, 1);
    });

    testWidgets('the branch scope reaches the query', (
      WidgetTester tester,
    ) async {
      final repository = _FakeMembersRepository(
        rows: <MemberOverview>[_member('m-1')],
      );
      await _pump(tester, repository);

      // A front desk assigned to one branch is scoped to it. The filter is
      // the branch picker, never the tenant boundary -- RLS is that.
      expect(repository.lastBranchIds, <String>['branch-1']);
    });

    testWidgets('the summary strip shows the status counts', (
      WidgetTester tester,
    ) async {
      final repository = _FakeMembersRepository(
        rows: <MemberOverview>[_member('m-1')],
        counts: const MemberStatusCounts(
          active: 12,
          // A subset of `active`, not a sixth bucket -- summing the strip
          // double-counts on purpose.
          expiring: 3,
          expired: 4,
          frozen: 1,
          withDues: 2,
        ),
      );
      await _pump(tester, repository);

      expect(find.text('12'), findsOneWidget);
      expect(find.text('Active'), findsWidgets);
      expect(find.text('With dues'), findsOneWidget);
    });

    testWidgets('an empty list says so and offers the way out of it', (
      WidgetTester tester,
    ) async {
      final repository = _FakeMembersRepository();
      await _pump(tester, repository);

      expect(find.textContaining('No members yet'), findsOneWidget);
      expect(find.text('Register a member'), findsOneWidget);
    });

    testWidgets('a refusal renders as a refusal, not an empty list', (
      WidgetTester tester,
    ) async {
      final repository = _FakeMembersRepository(
        error: const PostgrestException(
          message: 'permission denied for table member_overview',
          code: '42501',
        ),
      );
      await _pump(tester, repository);

      // The distinction this surface exists for: refused is not empty, and it
      // is not a generic error either.
      expect(find.byType(FailureView), findsOneWidget);
      expect(find.byKey(refusedFailureKey), findsOneWidget);
      expect(find.textContaining('refused'), findsWidgets);
    });
  });

  group('MemberList paging', () {
    late _FakeMembersRepository repository;
    late ProviderContainer container;

    setUp(() {
      repository = _FakeMembersRepository(
        rows: <MemberOverview>[_member('m-1')],
        total: 40,
      );
      final AppClaims claims = _claims();
      container = ProviderContainer(
        overrides: [
          membersRepositoryProvider.overrideWithValue(repository),
          claimsProvider.overrideWithValue(claims),
          principalProvider.overrideWithValue(
            AsyncValue<Principal>.data(Principal.staff(claims)),
          ),
        ],
      );
      // The screen holds this with `ref.watch`; without an equivalent
      // subscription the notifier auto-disposes across the first await and the
      // test fails on a disposed Ref rather than on anything real.
      container.listen<AsyncValue<MemberListState>>(
        memberListProvider,
        (_, _) {},
      );
    });

    tearDown(() => container.dispose());

    test('loadMore asks for the next page and appends', () async {
      await container.read(memberListProvider.future);
      expect(repository.lastQuery?.page, 1);

      repository.rows = <MemberOverview>[
        _member('m-2', name: 'Bikash Rai', code: 'M-0002'),
      ];
      await container.read(memberListProvider.notifier).loadMore();

      expect(repository.lastQuery?.page, 2);
      final MemberListState state = container.read(memberListProvider).value!;
      // Appended, not replaced: the rows already on screen stay put.
      expect(state.rows.map((MemberOverview row) => row.id), <String>[
        'm-1',
        'm-2',
      ]);
      expect(state.page, 2);
    });

    test('loadMore stops once every row is loaded', () async {
      repository.total = 1;
      container.invalidate(memberListProvider);
      await container.read(memberListProvider.future);
      // Counted from here, so the assertion below is about `loadMore` alone.
      repository.listCallCount = 0;

      await container.read(memberListProvider.notifier).loadMore();

      // No round trip at all: `hasMore` is derived from the count, so it is
      // right even when the last page is exactly full.
      expect(repository.listCallCount, 0);
    });

    test('a refused append keeps the rows and carries the failure', () async {
      await container.read(memberListProvider.future);

      repository.error = const PostgrestException(
        message: 'permission denied for table member_overview',
        code: '42501',
      );
      await container.read(memberListProvider.notifier).loadMore();

      final MemberListState state = container.read(memberListProvider).value!;
      // A list that silently stops growing is indistinguishable from one that
      // has ended, so the failure has to survive to the screen.
      expect(state.rows, hasLength(1));
      expect(state.appendFailure?.isRefusal, isTrue);
    });
  });
}
