import 'dart:convert';

import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// The claims the Supabase access-token hook injects into a session's JWT:
/// `{org_id, role, branch_ids[]}`. See PLANNING.md §5 ("Claims contract").
///
/// A freshly created session, before the principal row (`members` or
/// `staff`) is linked to the auth user, carries none of these claims. That
/// is a normal, expected state — [fromSession] returns `null` for it, and
/// the router handles the absence rather than treating it as an error.
class AppClaims {
  const AppClaims({
    required this.orgId,
    required this.role,
    required this.branchIds,
  });

  final String orgId;
  final String role;
  final List<String> branchIds;

  /// Whether this session belongs to a member principal, as opposed to a
  /// staff principal.
  bool get isMember => role == 'member';

  /// The staff role, or `null` when this session belongs to a member.
  ///
  /// Throws [UnknownEnumValue] if `role` is neither `'member'` nor a known
  /// `staff_role` value — an unrecognised role must fail loudly, per
  /// PLANNING.md §5, rather than be silently treated as either shell.
  StaffRole? get staffRole => isMember ? null : StaffRole.fromDb(role);

  /// Decodes the claims carried by [session]'s access token.
  ///
  /// Returns `null` when the token carries no claims yet.
  static AppClaims? fromSession(Session session) =>
      fromJwtPayload(_decodeJwtPayload(session.accessToken));

  /// Decodes claims out of an already-parsed JWT payload map.
  ///
  /// Returns `null` when `org_id`, `role`, or `branch_ids` is missing —
  /// the normal shape of a session created before the principal row is
  /// linked.
  static AppClaims? fromJwtPayload(Map<String, dynamic> payload) {
    final orgId = payload['org_id'];
    final role = payload['role'];
    final branchIds = payload['branch_ids'];

    if (orgId is! String || role is! String || branchIds is! List) {
      return null;
    }

    return AppClaims(
      orgId: orgId,
      role: role,
      branchIds: branchIds.map((dynamic id) => id as String).toList(),
    );
  }

  /// Decodes the payload segment of [jwt] into a JSON map.
  ///
  /// This never verifies the token's signature: the database — via the
  /// access-token hook and RLS policies — is the authority on whether a
  /// claim is valid, not this client. Signature verification here would be
  /// pure theatre; a compromised client can fabricate any payload it likes
  /// regardless, so the security boundary has to (and does) live in
  /// Postgres.
  static Map<String, dynamic> _decodeJwtPayload(String jwt) {
    final parts = jwt.split('.');
    if (parts.length != 3) {
      throw const FormatException('Not a JWT: expected three segments.');
    }

    final normalized = base64Url.normalize(parts[1]);
    final decoded = utf8.decode(base64Url.decode(normalized));
    final payload = jsonDecode(decoded);

    if (payload is! Map<String, dynamic>) {
      throw const FormatException('JWT payload is not a JSON object.');
    }

    return payload;
  }
}
