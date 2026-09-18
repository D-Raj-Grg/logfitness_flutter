// The two pure filter builders behind the delivery log, and the page maths.
//
// No network and no Supabase client: what is tested here is the logic that
// decides *what* gets sent, which is the same thing
// `test/data/visitors/visitors_repository_test.dart` does for the visitor log.
//
// The parity target is `NotificationListFilter` in
// `logfitness_saas/lib/db/notifications.ts`, so a drift in either client shows
// up as a failing test rather than as two logs that disagree about what a gym
// sent.
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/notifications/notification_message.dart';
import 'package:logfitness_flutter/data/notifications/notification_queries.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';

NotificationMessage _message(String id) =>
    NotificationMessage.fromJson(<String, dynamic>{
      'id': id,
      'org_id': 'org-1',
      'branch_id': null,
      'channel': 'sms',
      'event': 'renewal_reminder',
      'to_address': '9779800000000',
      'body': 'Your membership ends on Sunday.',
      'status': 'sent',
      'attempts': 1,
      'scheduled_for': '2026-09-11T02:30:00+00:00',
      'next_attempt_at': '2026-09-11T02:30:00+00:00',
      'dedupe_key': 'k-$id',
      'created_at': '2026-09-11T02:30:00+00:00',
      'updated_at': '2026-09-11T02:30:00+00:00',
    });

void main() {
  group('notificationBranchFilter', () {
    test('null is "every branch RLS allows", so there is no filter', () {
      // An owner with no branch selected. RLS has already bounded the rows;
      // narrowing further here would be the app second-guessing it.
      expect(notificationBranchFilter(null), isNull);
    });

    test('an empty list is a real filter, not "all"', () {
      // The distinction the branch switcher depends on: null widens, empty
      // narrows. Conflating them is how a scoped user silently sees the org.
      expect(notificationBranchFilter(<String>[]), 'branch_id.is.null');
      expect(notificationBranchFilter(<String>[]), isNotNull);
    });

    test('an empty list never emits in.(), which PostgREST rejects', () {
      expect(notificationBranchFilter(<String>[]), isNot(contains('in.(')));
    });

    test('a non-empty list keeps the org-wide clause beside the in-list', () {
      expect(
        notificationBranchFilter(<String>['a', 'b']),
        'branch_id.is.null,branch_id.in.(a,b)',
      );
    });

    test('the is.null clause is present for every non-null input', () {
      // LOAD-BEARING. A message raised for the whole org carries no branch --
      // staff invitations, gateway tests, anything a sweep raised above a
      // branch. Dropping `branch_id.is.null` hides every one of them from a
      // screen that has a branch selected, and the log then quietly disagrees
      // with the console about what the gym sent.
      for (final branchIds in <List<String>>[
        <String>[],
        <String>['a'],
        <String>['a', 'b', 'c'],
      ]) {
        expect(
          notificationBranchFilter(branchIds),
          contains('branch_id.is.null'),
          reason: 'org-wide messages must survive a branch filter',
        );
      }
    });

    test('one branch reads exactly as the console writes it', () {
      expect(
        notificationBranchFilter(<String>['33333333-3333-3333-3333-333333333333']),
        'branch_id.is.null,branch_id.in.(33333333-3333-3333-3333-333333333333)',
      );
    });
  });

  group('notificationSearchFilter', () {
    test('searches the recipient and the body together', () {
      expect(
        notificationSearchFilter('9800'),
        'to_address.ilike.%9800%,body.ilike.%9800%',
      );
    });

    test('blank and whitespace are not searches', () {
      expect(notificationSearchFilter(null), isNull);
      expect(notificationSearchFilter(''), isNull);
      expect(notificationSearchFilter('   '), isNull);
    });

    test('trims, so a stray space is not part of the term', () {
      expect(
        notificationSearchFilter('  9800  '),
        'to_address.ilike.%9800%,body.ilike.%9800%',
      );
    });

    test('strips the characters that are `or` syntax', () {
      // `%`, `_`, `,` and the parentheses are the syntax of the expression
      // itself. None of them is meaningful inside a phone number or the body
      // of a reminder, so they are replaced rather than escaped.
      expect(
        notificationSearchFilter('a%b_c,d(e)f'),
        'to_address.ilike.%a b c d e f%,body.ilike.%a b c d e f%',
      );
    });

    test('a term made only of stripped characters searches for nothing', () {
      expect(notificationSearchFilter('%,()'), isNull);
      expect(notificationSearchFilter('_'), isNull);
    });
  });

  group('NotificationListFilter', () {
    test('defaults to a first page of twenty, unnarrowed', () {
      const filter = NotificationListFilter();

      expect(filter.branchIds, isNull);
      expect(filter.status, isNull);
      expect(filter.event, isNull);
      expect(filter.channel, isNull);
      expect(filter.query, isNull);
      expect(filter.page, 1);
      expect(filter.pageSize, 20);
      expect(filter.isFiltered, isFalse);
    });

    test('isFiltered ignores the branch scope', () {
      // A branch scope is where the reader already is, not something they
      // chose on this screen -- so "clear filters" must not appear because of
      // it.
      expect(
        const NotificationListFilter(branchIds: <String>['a']).isFiltered,
        isFalse,
      );

      expect(
        const NotificationListFilter(
          status: NotificationStatus.failed,
        ).isFiltered,
        isTrue,
      );
      expect(
        const NotificationListFilter(
          event: NotificationEvent.duesReminder,
        ).isFiltered,
        isTrue,
      );
      expect(
        const NotificationListFilter(
          channel: NotificationChannel.viber,
        ).isFiltered,
        isTrue,
      );
      expect(
        const NotificationListFilter(query: '9800').isFiltered,
        isTrue,
      );
    });
  });

  group('NotificationPage.hasMore', () {
    NotificationPage page({
      required int rows,
      required int total,
      int number = 1,
      int size = 20,
    }) => NotificationPage(
      rows: List<NotificationMessage>.generate(
        rows,
        (int i) => _message('m-$i'),
      ),
      total: total,
      page: number,
      pageSize: size,
    );

    test('a full page with more behind it has more', () {
      expect(page(rows: 20, total: 45).hasMore, isTrue);
    });

    test('exactly one page is the boundary, and it has no more', () {
      // 20 of 20: the next `.range()` would come back empty, and an infinite
      // scroll that asked for it would spin forever at the bottom.
      expect(page(rows: 20, total: 20).hasMore, isFalse);
    });

    test('one past the boundary has more', () {
      expect(page(rows: 20, total: 21).hasMore, isTrue);
    });

    test('the last page of several has no more', () {
      expect(page(rows: 5, total: 45, number: 3).hasMore, isFalse);
      expect(page(rows: 20, total: 45, number: 2).hasMore, isTrue);
    });

    test('an empty log has no more', () {
      expect(page(rows: 0, total: 0).hasMore, isFalse);
    });

    test('counts the filtered total, not the rows in hand', () {
      // `total` is PostgREST's exact count over the whole filtered set. A
      // client-side count of what arrived would say "no more" on every page.
      final onePage = page(rows: 20, total: 200);
      expect(onePage.rows, hasLength(20));
      expect(onePage.total, 200);
      expect(onePage.hasMore, isTrue);
    });
  });

  group('kSummaryStatuses', () {
    test('is the four states the summary strip counts, in order', () {
      expect(kSummaryStatuses, <NotificationStatus>[
        NotificationStatus.sent,
        NotificationStatus.queued,
        NotificationStatus.failed,
        NotificationStatus.skipped,
      ]);
    });

    test('carries skipped, which is the whole reason the strip is read', () {
      // "Not sent" is the number an owner is actually looking for: it is what
      // a missing gateway or an opted-out member produces, and it is invisible
      // in a strip that only counts sent and failed.
      expect(kSummaryStatuses, contains(NotificationStatus.skipped));
      expect(kSummaryStatuses, isNot(contains(NotificationStatus.sending)));
      expect(kSummaryStatuses, isNot(contains(NotificationStatus.cancelled)));
    });
  });

  group('NotificationStatusCounts', () {
    test('a state nobody is in reads zero, not null', () {
      const counts = NotificationStatusCounts(<NotificationStatus, int>{
        NotificationStatus.sent: 41,
        NotificationStatus.skipped: 2,
      });

      expect(counts[NotificationStatus.sent], 41);
      expect(counts[NotificationStatus.skipped], 2);
      expect(counts[NotificationStatus.failed], 0);
      expect(counts[NotificationStatus.queued], 0);
    });

    test('total sums every state it holds', () {
      const counts = NotificationStatusCounts(<NotificationStatus, int>{
        NotificationStatus.sent: 41,
        NotificationStatus.queued: 3,
        NotificationStatus.failed: 1,
        NotificationStatus.skipped: 2,
      });

      expect(counts.total, 47);
    });

    test('an empty count totals zero', () {
      expect(const NotificationStatusCounts(<NotificationStatus, int>{}).total, 0);
    });
  });
}
