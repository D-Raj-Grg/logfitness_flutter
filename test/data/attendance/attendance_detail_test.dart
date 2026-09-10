import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/attendance/attendance_detail.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';

Map<String, dynamic> _row({
  String? checkedOutAt,
  bool isOverride = false,
  String method = 'qr',
}) =>
    <String, dynamic>{
      'id': '11111111-1111-1111-1111-111111111111',
      'member_id': '22222222-2222-2222-2222-222222222222',
      'org_id': '33333333-3333-3333-3333-333333333333',
      'branch_id': '44444444-4444-4444-4444-444444444444',
      'branch_name': 'Thamel',
      'member_code': 'M-0042',
      'full_name': 'Anjali Shrestha',
      'phone': '9800000000',
      'photo_path': null,
      'attended_on': '2026-09-09',
      'checked_in_at': '2026-09-09T00:45:00Z',
      'checked_out_at': checkedOutAt,
      'checked_in_by': '55555555-5555-5555-5555-555555555555',
      'checked_in_by_name': 'Front Desk',
      'membership_id': '66666666-6666-6666-6666-666666666666',
      'membership_status_at_checkin': 'active',
      'due_paisa_at_checkin': 250000,
      'days_to_expiry_at_checkin': 12,
      'method': method,
      'is_override': isOverride,
      'override_reason': null,
      'notes': null,
    };

void main() {
  test('maps a realistic attendance_detail row', () {
    final visit = AttendanceDetail.fromJson(_row());

    expect(visit.fullName, 'Anjali Shrestha');
    expect(visit.branchName, 'Thamel');
    expect(visit.method, AttendanceMethod.qr);
    // The snapshot is what was true at the door, and it is money in paisa.
    expect(visit.duePaisaAtCheckin, 250000);
    expect(visit.membershipStatusAtCheckin, MembershipStatus.active);
    expect(visit.daysToExpiryAtCheckin, 12);
  });

  test('attended_on is a calendar day, not an instant', () {
    final visit = AttendanceDetail.fromJson(_row());

    // A 00:45 UTC check-in is 06:30 in Kathmandu on the same date. If
    // `attended_on` were shifted like an instant it would read 08 Sep.
    expect(visit.attendedOn, DateTime.utc(2026, 9, 9));
    expect(visit.attendedOn!.isUtc, isTrue);
  });

  test('an open visit is one with no checkout', () {
    expect(AttendanceDetail.fromJson(_row()).isOpen, isTrue);
    expect(
      AttendanceDetail.fromJson(
        _row(checkedOutAt: '2026-09-09T02:00:00Z'),
      ).isOpen,
      isFalse,
    );
  });

  test('an override is visible, because it is what a manager looks for', () {
    expect(AttendanceDetail.fromJson(_row()).wasOverridden, isFalse);
    expect(
      AttendanceDetail.fromJson(_row(isOverride: true)).wasOverridden,
      isTrue,
    );
  });

  test('AttendanceMethod covers the whole Postgres enum', () {
    // `biometric` is in the database even though biometric hardware is out of
    // scope for v1. A row written by anything else still has to read.
    expect(
      AttendanceMethod.values.map((e) => e.wire).toSet(),
      <String>{'manual', 'qr', 'card', 'biometric'},
    );
  });

  test('an unknown method fails loudly rather than defaulting', () {
    expect(
      () => AttendanceDetail.fromJson(_row(method: 'facial')),
      throwsA(anything),
    );
  });
}
