import 'dart:convert';

import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// The claims the Supabase access-token hook injects into a session's JWT.
///
/// The hook does NOT set a `role` claim -- `role` belongs to PostgREST and
/// stays `authenticated` for every request. Instead, the principal type is
/// carried by which id claim is present: `staff_role` for a staff principal,
/// `member_id` for a member principal. Both carry `org_id` and
/// `branch_ids[]`; staff also carry `staff_id`. See
/// `../logfitness_saas/supabase/migrations/20260905150300_hook_leaves_the_postgrest_role_claim_alone.sql`.
///
/// A freshly created session, before the principal row (`members` or
/// `staff`) is linked to the auth user, carries none of these claims. That
/// is a normal, expected state — [fromSession] returns `null` for it, and
/// the router handles the absence rather than treating it as an error.
/// Thrown when the access-token hook produced a claim set this client cannot
/// make sense of. Distinct from "no claims yet", which is a normal state.
class MalformedClaims implements Exception {
  const MalformedClaims(this.field, this.value);

  final String field;
  final Object? value;

  @override
  String toString() => 'MalformedClaims: $field was $value';
}

class AppClaims {
  const AppClaims({
    required this.orgId,
    required this.branchIds,
    this.staffRole,
    this.memberId,
    this.staffId,
  });

  final String orgId;
  final List<String> branchIds;

  /// The staff role, or `null` when this session belongs to a member (or
  /// carries no principal claims at all — which [fromSession] already
  /// filters out).
  final StaffRole? staffRole;

  /// The linked member id, or `null` for a staff principal.
  final String? memberId;

  /// The linked staff id, or `null` for a member principal.
  final String? staffId;

  /// Whether this session belongs to a member principal, as opposed to a
  /// staff principal. A member carries `member_id` and no `staff_role`.
  bool get isMember => memberId != null && staffRole == null;

  /// Whether this session belongs to a staff principal.
  bool get isStaff => staffRole != null;

  /// Decodes the claims carried by [session]'s access token.
  ///
  /// Returns `null` when the token carries no principal claims yet.
  static AppClaims? fromSession(Session session) =>
      fromJwtPayload(_decodeJwtPayload(session.accessToken));

  /// Decodes claims out of an already-parsed JWT payload map.
  ///
  /// Returns `null` only when neither `staff_role` nor `member_id` is
  /// present — the normal shape of a session created before the principal
  /// row is linked.
  ///
  /// Throws [MalformedClaims] when a principal marker IS present but the
  /// rest of the claim set is not the shape the access-token hook produces
  /// (a missing `org_id`, a `branch_ids` that is not a list of strings, or
  /// both principal markers at once). Those are backend regressions, and
  /// reading them as "not linked yet" would hide one behind a screen that
  /// tells the user everything is fine.
  ///
  /// Throws [UnknownEnumValue] if `staff_role` is present but not a
  /// recognised `staff_role` value — an unrecognised role must fail loudly,
  /// per PLANNING.md §5, rather than be silently treated as either shell.
  static AppClaims? fromJwtPayload(Map<String, dynamic> payload) {
    final orgId = payload['org_id'];
    final branchIds = payload['branch_ids'];
    final staffRoleWire = payload['staff_role'];
    final memberId = payload['member_id'];
    final staffId = payload['staff_id'];

    if (staffRoleWire is! String && memberId is! String) {
      // Neither principal claim is present: signed in, not yet linked. This
      // is the only shape that legitimately produces null.
      return null;
    }

    // A principal marker IS present, so the rest of the claim set must be
    // well formed. Returning null here instead would render a token the hook
    // built wrong as an ordinary "not linked yet" account, and hide the
    // regression behind a friendly screen.
    if (orgId is! String || orgId.isEmpty) {
      throw MalformedClaims('org_id', orgId);
    }
    if (branchIds is! List) {
      throw MalformedClaims('branch_ids', branchIds);
    }
    if (staffRoleWire is String && memberId is String) {
      throw MalformedClaims('staff_role + member_id', payload);
    }

    return AppClaims(
      orgId: orgId,
      branchIds: branchIds.map((dynamic id) {
        if (id is! String) {
          throw MalformedClaims('branch_ids entry', id);
        }
        return id;
      }).toList(),
      staffRole: staffRoleWire is String ? StaffRole.fromDb(staffRoleWire) : null,
      memberId: memberId is String ? memberId : null,
      staffId: staffId is String ? staffId : null,
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
