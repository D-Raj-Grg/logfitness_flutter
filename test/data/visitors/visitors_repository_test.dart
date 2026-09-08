// No network, no real Supabase. Everything a query builder does is exercised
// against PostgREST or not at all, so what is tested here is the logic that
// decides *what* gets sent: the search expression, the shape of an insert and
// a patch, and the guard that keeps `converted` out of the plain update path.
//
// The parity target is `logfitness_saas/lib/db/visitors.ts` -- these
// assertions are written against its behaviour, so a drift in either client
// shows up as a failing test rather than as two logs that disagree.
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/visitors/visitors_repository.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';

void main() {
  group('VisitorStatusFilter', () {
    test('open expands to exactly the statuses visitors_open_idx carries', () {
      expect(VisitorStatusFilter.open.toDb(), <String>['new', 'contacted']);
    });

    test('every other filter selects one status', () {
      expect(VisitorStatusFilter.isNew.toDb(), <String>['new']);
      expect(VisitorStatusFilter.contacted.toDb(), <String>['contacted']);
      expect(VisitorStatusFilter.converted.toDb(), <String>['converted']);
      expect(VisitorStatusFilter.lost.toDb(), <String>['lost']);
    });
  });

  group('visitorSearchFilter', () {
    test('matches a name anywhere and a phone from the start', () {
      expect(
        visitorSearchFilter('Anjali'),
        'full_name.ilike.%Anjali%,phone.ilike.Anjali%',
      );
    });

    test('trims, so a stray space is not a search', () {
      expect(visitorSearchFilter('  Anjali  '), contains('%Anjali%'));
      expect(visitorSearchFilter('   '), isNull);
      expect(visitorSearchFilter(''), isNull);
      expect(visitorSearchFilter(null), isNull);
    });

    test('strips the characters that are `or` syntax', () {
      // `%`, `_`, `,` and the parentheses would otherwise change the meaning
      // of the expression rather than the term inside it.
      expect(
        visitorSearchFilter('a%b_c,d(e)f'),
        'full_name.ilike.%a b c d e f%,phone.ilike.a b c d e f%',
      );
    });

    test('a term made only of stripped characters searches for nothing', () {
      expect(visitorSearchFilter('%,()'), isNull);
    });
  });

  group('visitorInsertValues', () {
    test('sends the walk-in, and leaves the trigger columns alone', () {
      final values = visitorInsertValues(
        orgId: '22222222-2222-2222-2222-222222222222',
        branchId: '33333333-3333-3333-3333-333333333333',
        fullName: '  Anjali Shrestha ',
        phone: ' 9800000000 ',
        kind: VisitorKind.guest,
        note: 'Trialling for a day.',
        interestedPlanId: '44444444-4444-4444-4444-444444444444',
      );

      expect(values, <String, dynamic>{
        'org_id': '22222222-2222-2222-2222-222222222222',
        'branch_id': '33333333-3333-3333-3333-333333333333',
        'kind': 'guest',
        'full_name': 'Anjali Shrestha',
        'phone': '9800000000',
        'note': 'Trialling for a day.',
        'interested_plan_id': '44444444-4444-4444-4444-444444444444',
      });
      // `visited_on` absent: set_visitor_defaults fills it from
      // org_today(org_id), which is the org's day, not the device's.
      expect(values.containsKey('visited_on'), isFalse);
      // Neither of these is ever the client's to send.
      expect(values.containsKey('created_by'), isFalse);
      expect(values.containsKey('status'), isFalse);
    });

    test('kind defaults to enquiry, as the column does', () {
      final values = visitorInsertValues(
        orgId: 'org',
        branchId: 'branch',
        fullName: 'Bibek Karki',
        phone: '9811111111',
      );

      expect(values['kind'], 'enquiry');
    });

    test('a backdated visit goes over the wire as a bare date', () {
      final values = visitorInsertValues(
        orgId: 'org',
        branchId: 'branch',
        fullName: 'Bibek Karki',
        phone: '9811111111',
        visitedOn: DateTime.utc(2026, 9, 7),
      );

      expect(values['visited_on'], '2026-09-07');
    });
  });

  group('visitorUpdateValues', () {
    test('an untouched patch is empty', () {
      expect(visitorUpdateValues(), isEmpty);
    });

    test('only the columns passed appear', () {
      final values = visitorUpdateValues(status: VisitorStatus.contacted);

      expect(values, <String, dynamic>{'status': 'contacted'});
    });

    test('passing null clears a nullable column', () {
      // A note the desk deleted and a note it did not edit are different
      // writes, and the sentinel is what tells them apart.
      final values = visitorUpdateValues(note: null, interestedPlanId: null);

      expect(values, <String, dynamic>{
        'note': null,
        'interested_plan_id': null,
      });
    });

    test('trims name and phone, and encodes visited_on as a date', () {
      final values = visitorUpdateValues(
        fullName: '  Anjali Shrestha ',
        phone: ' 9800000000 ',
        kind: VisitorKind.guest,
        visitedOn: DateTime.utc(2026, 9, 8),
      );

      expect(values, <String, dynamic>{
        'full_name': 'Anjali Shrestha',
        'phone': '9800000000',
        'kind': 'guest',
        'visited_on': '2026-09-08',
      });
    });

    test('lost and contacted are settable; converted is not', () {
      expect(
        visitorUpdateValues(status: VisitorStatus.lost)['status'],
        'lost',
      );
      expect(
        visitorUpdateValues(status: VisitorStatus.isNew)['status'],
        'new',
      );

      // visitors_converted_shape requires the member id and the timestamp to
      // move with the status. convert_visitor is the only write that does.
      expect(
        () => visitorUpdateValues(status: VisitorStatus.converted),
        throwsA(
          isA<AppFailure>().having(
            (failure) => failure.kind,
            'kind',
            FailureKind.invalid,
          ),
        ),
      );
    });
  });

  group('VisitorPage', () {
    test('hasMore is true while the filtered set outruns the pages read', () {
      const first = VisitorPage(rows: <Never>[], total: 45, page: 1, pageSize: 20);
      const last = VisitorPage(rows: <Never>[], total: 45, page: 3, pageSize: 20);

      expect(first.hasMore, isTrue);
      expect(last.hasMore, isFalse);
    });
  });
}
