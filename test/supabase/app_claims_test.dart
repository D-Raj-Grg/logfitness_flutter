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
    test('decodes a full claims payload', () {
      final claims = AppClaims.fromJwtPayload({
        'org_id': 'org-1',
        'role': 'manager',
        'branch_ids': ['branch-1', 'branch-2'],
      });

      expect(claims, isNotNull);
      expect(claims!.orgId, 'org-1');
      expect(claims.role, 'manager');
      expect(claims.branchIds, ['branch-1', 'branch-2']);
    });

    test('returns null for a payload with no claims', () {
      final claims = AppClaims.fromJwtPayload({
        'sub': 'user-1',
        'aud': 'authenticated',
      });

      expect(claims, isNull);
    });

    test('member payload: isMember is true and staffRole is null', () {
      final claims = AppClaims.fromJwtPayload({
        'org_id': 'org-1',
        'role': 'member',
        'branch_ids': <String>[],
      });

      expect(claims, isNotNull);
      expect(claims!.isMember, isTrue);
      expect(claims.staffRole, isNull);
    });

    test('staff payload: staffRole resolves to StaffRole.frontDesk', () {
      final claims = AppClaims.fromJwtPayload({
        'org_id': 'org-1',
        'role': 'front_desk',
        'branch_ids': ['branch-1'],
      });

      expect(claims, isNotNull);
      expect(claims!.isMember, isFalse);
      expect(claims.staffRole, StaffRole.frontDesk);
    });
  });

  group('AppClaims.fromSession', () {
    test('decodes unpadded base64url JWT payloads', () {
      final payload = {
        'org_id': 'org-1',
        'role': 'owner',
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
