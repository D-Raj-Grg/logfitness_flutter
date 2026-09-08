import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/visitors/visitor.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';

void main() {
  test('Visitor.fromJson maps a realistic PostgREST row', () {
    final json = <String, dynamic>{
      'id': '11111111-1111-1111-1111-111111111111',
      'org_id': '22222222-2222-2222-2222-222222222222',
      'branch_id': '33333333-3333-3333-3333-333333333333',
      'kind': 'enquiry',
      'full_name': 'Anjali Shrestha',
      'phone': '9800000000',
      'visited_on': '2026-09-08',
      'note': 'Asked about the three-month plan.',
      'interested_plan_id': '44444444-4444-4444-4444-444444444444',
      'status': 'new',
      'converted_member_id': null,
      'converted_at': null,
      'created_by': '55555555-5555-5555-5555-555555555555',
      'created_at': '2026-09-08T09:30:00+00:00',
      'updated_at': '2026-09-08T09:30:00+00:00',
    };

    final visitor = Visitor.fromJson(json);

    expect(visitor.id, '11111111-1111-1111-1111-111111111111');
    expect(visitor.orgId, '22222222-2222-2222-2222-222222222222');
    expect(visitor.branchId, '33333333-3333-3333-3333-333333333333');
    expect(visitor.kind, VisitorKind.enquiry);
    expect(visitor.fullName, 'Anjali Shrestha');
    expect(visitor.phone, '9800000000');
    expect(visitor.note, 'Asked about the three-month plan.');
    expect(visitor.interestedPlanId, '44444444-4444-4444-4444-444444444444');
    expect(visitor.status, VisitorStatus.isNew);
    expect(visitor.convertedMemberId, isNull);
    expect(visitor.convertedAt, isNull);
    expect(visitor.createdBy, '55555555-5555-5555-5555-555555555555');
    expect(visitor.createdAt, DateTime.parse('2026-09-08T09:30:00+00:00'));
    expect(visitor.updatedAt, DateTime.parse('2026-09-08T09:30:00+00:00'));
  });

  test('visited_on decodes to UTC midnight, not a local instant', () {
    // `visited_on` is a `date`. Anything that shifted it onto a wall clock
    // would move the day for an org at +05:45 -- see
    // lib/domain/format/plain_date.dart.
    final visitor = Visitor.fromJson(_row(visitedOn: '2026-09-08'));

    expect(visitor.visitedOn, DateTime.utc(2026, 9, 8));
    expect(visitor.visitedOn.isUtc, isTrue);
    expect(visitor.visitedOn.hour, 0);
    expect(visitor.visitedOn.minute, 0);
  });

  test('Visitor.fromJson maps a converted row', () {
    final visitor = Visitor.fromJson(
      _row(
        kind: 'guest',
        status: 'converted',
        convertedMemberId: '66666666-6666-6666-6666-666666666666',
        convertedAt: '2026-09-09T04:15:00+00:00',
      ),
    );

    expect(visitor.kind, VisitorKind.guest);
    expect(visitor.status, VisitorStatus.converted);
    expect(
      visitor.convertedMemberId,
      '66666666-6666-6666-6666-666666666666',
    );
    expect(visitor.convertedAt, DateTime.parse('2026-09-09T04:15:00+00:00'));
  });

  group('isOpen / isConverted', () {
    test('new and contacted are open, and neither is converted', () {
      for (final status in <String>['new', 'contacted']) {
        final visitor = Visitor.fromJson(_row(status: status));
        expect(visitor.isOpen, isTrue, reason: status);
        expect(visitor.isConverted, isFalse, reason: status);
      }
    });

    test('lost is neither open nor converted', () {
      final visitor = Visitor.fromJson(_row(status: 'lost'));

      expect(visitor.isOpen, isFalse);
      expect(visitor.isConverted, isFalse);
    });

    test('converted is converted and no longer open', () {
      final visitor = Visitor.fromJson(
        _row(
          status: 'converted',
          convertedMemberId: '66666666-6666-6666-6666-666666666666',
          convertedAt: '2026-09-09T04:15:00+00:00',
        ),
      );

      expect(visitor.isConverted, isTrue);
      expect(visitor.isOpen, isFalse);
    });
  });

  test('an unknown status fails loudly rather than defaulting', () {
    // A value this build does not know is schema drift, and PLANNING.md §5
    // says it must never fall through to a silent default.
    expect(
      () => Visitor.fromJson(_row(status: 'archived')),
      throwsA(anything),
    );
  });
}

/// A minimal open enquiry, with only the fields a test varies exposed.
Map<String, dynamic> _row({
  String kind = 'enquiry',
  String status = 'new',
  String visitedOn = '2026-09-08',
  String? convertedMemberId,
  String? convertedAt,
}) {
  return <String, dynamic>{
    'id': '11111111-1111-1111-1111-111111111111',
    'org_id': '22222222-2222-2222-2222-222222222222',
    'branch_id': '33333333-3333-3333-3333-333333333333',
    'kind': kind,
    'full_name': 'Anjali Shrestha',
    'phone': '9800000000',
    'visited_on': visitedOn,
    'note': null,
    'interested_plan_id': null,
    'status': status,
    'converted_member_id': convertedMemberId,
    'converted_at': convertedAt,
    'created_by': null,
    'created_at': '2026-09-08T09:30:00+00:00',
    'updated_at': '2026-09-08T09:30:00+00:00',
  };
}
