// A repository is the only thing that touches `supabase` (PLANNING.md §6).
// Controllers call repositories; widgets call controllers.
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:logfitness_flutter/data/auth/current_member.dart';
import 'package:logfitness_flutter/data/auth/current_staff.dart';
import 'package:logfitness_flutter/supabase/auth_deep_links.dart';
import 'package:logfitness_flutter/supabase/supabase_providers.dart';

part 'auth_repository.g.dart';

/// Why [AuthRepository.linkMemberAccount] did not adopt an invitation.
///
/// `noInvitation` and `ambiguousInvitation` are normal outcomes a real member
/// can hit (not yet invited, or invited by two gyms with the same email) --
/// callers should render them, not treat them as unexpected errors.
enum LinkFailure {
  /// `link_member_account()` raised `no_data_found`: no pending invitation
  /// matches the signed-in account's email.
  noInvitation,

  /// `link_member_account()` raised `cardinality_violation`: the same email
  /// is invited by more than one gym and staff must resolve it.
  ambiguousInvitation,

  /// `link_member_account()` raised `insufficient_privilege`: there is no
  /// signed-in user (`auth.uid()` was null).
  notAuthenticated,

  /// Any other failure -- a genuine, unexpected error.
  unknown,
}

/// Thrown by [AuthRepository.linkMemberAccount] when the RPC does not adopt
/// an invitation. Carries a [LinkFailure] so callers can branch on why.
class LinkException implements Exception {
  const LinkException(this.failure, [this.message]);

  final LinkFailure failure;
  final String? message;

  @override
  String toString() =>
      'LinkException(${failure.name}'
      '${message != null ? ': $message' : ''})';
}

/// Postgres condition names `link_member_account()` raises, and their fixed
/// SQLSTATE codes (Postgres Appendix A) -- not something a database upgrade
/// changes.
const _noDataFoundSqlstate = 'P0002';
const _cardinalityViolationSqlstate = '21000';
const _insufficientPrivilegeSqlstate = '42501';

/// Maps a [PostgrestException] raised by `link_member_account()` to the
/// [LinkFailure] it represents. Exposed as a pure function so it can be unit
/// tested without a real Supabase client.
LinkFailure mapLinkFailure(PostgrestException exception) {
  switch (exception.code) {
    case _noDataFoundSqlstate:
      return LinkFailure.noInvitation;
    case _cardinalityViolationSqlstate:
      return LinkFailure.ambiguousInvitation;
    case _insufficientPrivilegeSqlstate:
      return LinkFailure.notAuthenticated;
    default:
      return LinkFailure.unknown;
  }
}

/// The auth data layer: sign-in/out, linking a member's pending invitation,
/// and reading the two principal-row RPCs. See PLANNING.md §5 ("Claims
/// contract") and
/// `../logfitness_saas/supabase/migrations/20260905150100_member_app_auth.sql`.
class AuthRepository {
  const AuthRepository(this._client);

  final SupabaseClient _client;

  /// Signs in with email + password. Staff and invited members share this
  /// one call -- the same accounts, the same `auth.users` table.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() => _client.auth.signOut();

  /// Forces a token refresh so a session picks up claims stamped by the
  /// access-token hook after linking. Returns the refreshed session, or
  /// `null` if there was none to refresh.
  Future<Session?> refreshSession() async {
    final response = await _client.auth.refreshSession();
    return response.session;
  }

  /// Adopts a pending invitation for the signed-in account. Idempotent: a
  /// second call for an already-linked account returns the same member id.
  ///
  /// Throws [LinkException] when the RPC raises `no_data_found` (nothing
  /// pending for this email), `cardinality_violation` (invited at two
  /// gyms), or `insufficient_privilege` (no signed-in user) -- and wraps
  /// anything else as [LinkFailure.unknown].
  Future<String> linkMemberAccount() async {
    try {
      final result = await _client.rpc('link_member_account');
      return result as String;
    } on PostgrestException catch (exception) {
      throw LinkException(mapLinkFailure(exception), exception.message);
    }
  }

  /// Sends the password-reset email. The link comes back to the app through
  /// the custom scheme in `lib/supabase/auth_deep_links.dart`, so the redirect
  /// is not the caller's to choose.
  Future<void> sendPasswordReset(String email) {
    return _client.auth.resetPasswordForEmail(email, redirectTo: kAuthRedirectUrl);
  }

  /// Sets a new password on the signed-in account. This is how an invited
  /// member finishes accepting: the emailed link hands supabase_flutter a
  /// session, and the password is what makes the account usable afterwards.
  Future<UserResponse> updatePassword(String password) {
    return _client.auth.updateUser(UserAttributes(password: password));
  }

  /// The member-principal row for the signed-in account, or `null` when
  /// there is none -- readable before the session carries claims, which is
  /// the whole point of `current_member()`.
  Future<CurrentMember?> currentMember() async {
    final rows = await _client.rpc('current_member') as List<dynamic>;
    if (rows.isEmpty) {
      return null;
    }
    return CurrentMember.fromJson(rows.first as Map<String, dynamic>);
  }

  /// The staff-principal row for the signed-in account, or `null` when
  /// there is none. See [currentMember] for why this is read via RPC rather
  /// than the `staff` table.
  Future<CurrentStaff?> currentStaff() async {
    final rows = await _client.rpc('current_staff') as List<dynamic>;
    if (rows.isEmpty) {
      return null;
    }
    return CurrentStaff.fromJson(rows.first as Map<String, dynamic>);
  }
}

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository(ref.watch(supabaseClientProvider));
}
