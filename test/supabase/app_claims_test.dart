import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/supabase/app_claims.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Builds an unsigned JWT string (`header.payload.signature`) carrying
/// [payload], using unpadded base64url for the payload segment — matching
/// how real Supabase-issued tokens are encoded.
String _fakeJwt(Map<String, dynamic> payload) {
  String encode(Map<String, dynamic> map) =>
      base64Url.encode(utf8.encode(jsonEncode(map))).replaceAll('=', '');

  final header = encode({'alg': 'HS256', 'typ': 'JWT'});
  final body = encode(payload);
  return '$header.$body.signature';
}

Session _sessionWithPayload(Map<String, dynamic> payload) {
  return Session(
    accessToken: _fakeJwt(payload),
    tokenType: 'bearer',
    user: const User(
      id: 'user-1',
      appMetadata: {},
      userMetadata: {},
      aud: 'authenticated',
      createdAt: '2026-01-01T00:00:00Z',
    ),
  );
}

void main() {
  group('AppClaims.fromJwtPayload', () {
    test('decodes a staff claims payload', () {
      final claims = AppClaims.fromJwtPayload({
        'role': 'authenticated', // PostgREST's claim -- never read by AppClaims.
        'org_id': 'org-1',
        'staff_id': 'staff-1',
        'staff_role': 'manager',
        'branch_ids': ['branch-1', 'branch-2'],
      });

      expect(claims, isNotNull);
      expect(claims!.orgId, 'org-1');
      expect(claims.staffId, 'staff-1');
      expect(claims.staffRole, StaffRole.manager);
      expect(claims.memberId, isNull);
      expect(claims.branchIds, ['branch-1', 'branch-2']);
      expect(claims.isStaff, isTrue);
      expect(claims.isMember, isFalse);
    });

    test('decodes a member claims payload', () {
      final claims = AppClaims.fromJwtPayload({
        'role': 'authenticated',
        'org_id': 'org-1',
        'member_id': 'member-1',
        'branch_ids': ['branch-1'],
      });

      expect(claims, isNotNull);
      expect(claims!.orgId, 'org-1');
      expect(claims.memberId, 'member-1');
      expect(claims.staffId, isNull);
      expect(claims.staffRole, isNull);
      expect(claims.isMember, isTrue);
      expect(claims.isStaff, isFalse);
    });

    test('returns null for a payload with no principal claims', () {
      final claims = AppClaims.fromJwtPayload({
        'sub': 'user-1',
        'role': 'authenticated',
        'aud': 'authenticated',
      });

      expect(claims, isNull);
    });

    test(
      'returns null when org_id/branch_ids are present but no principal id is',
      () {
        final claims = AppClaims.fromJwtPayload({
          'role': 'authenticated',
          'org_id': 'org-1',
          'branch_ids': <String>[],
        });

        expect(claims, isNull);
      },
    );

    test('throws UnknownEnumValue for an unrecognised staff_role', () {
      expect(
        () => AppClaims.fromJwtPayload({
          'org_id': 'org-1',
          'staff_id': 'staff-1',
          'staff_role': 'ceo',
          'branch_ids': <String>[],
        }),
        throwsA(isA<UnknownEnumValue>()),
      );
    });

    for (final role in StaffRole.values) {
      test('staff payload: staffRole resolves to StaffRole.${role.name}', () {
        final claims = AppClaims.fromJwtPayload({
          'org_id': 'org-1',
          'staff_id': 'staff-1',
          'staff_role': role.wire,
          'branch_ids': ['branch-1'],
        });

        expect(claims, isNotNull);
        expect(claims!.isMember, isFalse);
        expect(claims.isStaff, isTrue);
        expect(claims.staffRole, role);
      });
    }
  });

  group('AppClaims.fromSession', () {
    test('decodes unpadded base64url JWT payloads', () {
      final payload = {
        'org_id': 'org-1',
        'staff_id': 'staff-1',
        'staff_role': 'owner',
        'branch_ids': ['branch-1', 'branch-2', 'branch-3'],
      };
      final session = _sessionWithPayload(payload);

      // Sanity check that the fixture actually produced an unpadded
      // segment, so this test would fail if it stopped exercising the
      // padding-restoration path.
      final rawPayloadSegment = session.accessToken.split('.')[1];
      expect(rawPayloadSegment.contains('='), isFalse);

      final claims = AppClaims.fromSession(session);

      expect(claims, isNotNull);
      expect(claims!.orgId, 'org-1');
      expect(claims.staffRole, StaffRole.owner);
    });

    test('returns null when the session carries no claims yet', () {
      final session = _sessionWithPayload({'sub': 'user-1'});

      expect(AppClaims.fromSession(session), isNull);
    });
  });
}
