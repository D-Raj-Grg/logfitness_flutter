// The card models and the UID rule the desk's manual entry is checked against
// before it reaches `assign_member_card`.
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/members/member_card.dart';
import 'package:logfitness_flutter/data/members/unassigned_card_scan.dart';

void main() {
  group('normalizeCardUid', () {
    test('upper-cases and strips separators, as the RPC does', () {
      // Readers and phones print UIDs as `04:a3:1b:2c` or `04 A3 1B 2C`; the
      // column stores `04A31B2C`. Matching the server's own normalisation
      // means the desk sees the value that will actually be stored.
      expect(normalizeCardUid('04:a3:1b:2c'), '04A31B2C');
      expect(normalizeCardUid(' 04 A3 1B 2C '), '04A31B2C');
      expect(normalizeCardUid('04-a3-1b-2c-de-f0-11'), '04A31B2CDEF011');
    });

    test('anything that is not hex is dropped, not kept', () {
      expect(normalizeCardUid('zz'), isEmpty);
      expect(normalizeCardUid('04g3'), '043');
    });
  });

  group('isValidCardUid', () {
    test('accepts 8 to 20 upper-case hex characters', () {
      expect(isValidCardUid('04A31B2C'), isTrue);
      expect(isValidCardUid('04A31B2CDEF01122AABB'), isTrue);
    });

    test('mirrors the column check on both ends', () {
      expect(isValidCardUid('04A31B2'), isFalse); // 7
      expect(isValidCardUid('04A31B2CDEF01122AABBC'), isFalse); // 21
      expect(isValidCardUid('04a31b2c'), isFalse); // not normalised
      expect(isValidCardUid(''), isFalse);
    });
  });

  group('MemberCard', () {
    Map<String, dynamic> row({String? revokedAt, String? reason}) =>
        <String, dynamic>{
          'id': '11111111-1111-1111-1111-111111111111',
          'org_id': '33333333-3333-3333-3333-333333333333',
          'member_id': '22222222-2222-2222-2222-222222222222',
          'card_uid': '04A31B2C',
          'assigned_by': '55555555-5555-5555-5555-555555555555',
          'assigned_at': '2026-10-12T04:15:00Z',
          'revoked_at': revokedAt,
          'revoked_by': null,
          'revoke_reason': reason,
        };

    test('maps a member_cards row', () {
      final card = MemberCard.fromJson(row());

      expect(card.memberId, '22222222-2222-2222-2222-222222222222');
      expect(card.cardUid, '04A31B2C');
      expect(card.assignedAt, DateTime.utc(2026, 10, 12, 4, 15));
      expect(card.isLive, isTrue);
    });

    test('a revoked card is not live', () {
      final card = MemberCard.fromJson(
        row(revokedAt: '2026-10-13T01:00:00Z', reason: 'Lost'),
      );

      expect(card.isLive, isFalse);
      expect(card.revokeReason, 'Lost');
    });
  });

  group('UnassignedCardScan', () {
    Map<String, dynamic> row({Object? devices}) => <String, dynamic>{
      'id': '77777777-7777-7777-7777-777777777777',
      'org_id': '33333333-3333-3333-3333-333333333333',
      'branch_id': '44444444-4444-4444-4444-444444444444',
      'device_id': '88888888-8888-8888-8888-888888888888',
      'card_uid': 'DEADBEEF',
      'first_seen_at': '2026-10-12T04:00:00Z',
      'last_seen_at': '2026-10-12T04:10:00Z',
      'scan_count': 3,
      'devices': devices,
    };

    test('reads the device name off the devices(name) embed', () {
      final scan = UnassignedCardScan.fromJson(
        row(devices: <String, dynamic>{'name': 'Front door'}),
      );

      expect(scan.cardUid, 'DEADBEEF');
      expect(scan.scanCount, 3);
      expect(scan.lastSeenAt, DateTime.utc(2026, 10, 12, 4, 10));
      expect(scan.deviceName, 'Front door');
    });

    test('a device the caller cannot read leaves the name empty', () {
      // An embed RLS hides comes back null; the scan is still assignable.
      final scan = UnassignedCardScan.fromJson(row());

      expect(scan.deviceName, isNull);
      expect(scan.cardUid, 'DEADBEEF');
    });
  });
}
