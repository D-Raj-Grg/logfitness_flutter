// No network, no real Supabase: exercises the pure error-mapping logic that
// [AuthRepository.linkMemberAccount] relies on, against the fixed SQLSTATE
// codes `link_member_account()` raises. See
// `../logfitness_saas/supabase/migrations/20260905150100_member_app_auth.sql`.
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/auth/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('mapLinkFailure', () {
    test('no_data_found (P0002) maps to noInvitation', () {
      final failure = mapLinkFailure(
        const PostgrestException(
          message: 'No pending invitation for this email address',
          code: 'P0002',
        ),
      );

      expect(failure, LinkFailure.noInvitation);
    });

    test('cardinality_violation (21000) maps to ambiguousInvitation', () {
      final failure = mapLinkFailure(
        const PostgrestException(
          message: 'That email address is invited at more than one gym',
          code: '21000',
        ),
      );

      expect(failure, LinkFailure.ambiguousInvitation);
    });

    test('insufficient_privilege (42501) maps to notAuthenticated', () {
      final failure = mapLinkFailure(
        const PostgrestException(message: 'Not authenticated', code: '42501'),
      );

      expect(failure, LinkFailure.notAuthenticated);
    });

    test('any other code maps to unknown', () {
      final failure = mapLinkFailure(
        const PostgrestException(message: 'boom', code: '57014'),
      );

      expect(failure, LinkFailure.unknown);
    });

    test('a missing code maps to unknown', () {
      final failure = mapLinkFailure(
        const PostgrestException(message: 'boom'),
      );

      expect(failure, LinkFailure.unknown);
    });
  });

  group('LinkException', () {
    test('carries the mapped failure and includes it in toString', () {
      const exception = LinkException(
        LinkFailure.noInvitation,
        'No pending invitation for this email address',
      );

      expect(exception.failure, LinkFailure.noInvitation);
      expect(exception.toString(), contains('noInvitation'));
    });
  });
}
