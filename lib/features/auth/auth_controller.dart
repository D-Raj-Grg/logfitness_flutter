// The auth controller and the `principalProvider` it keeps in sync. Both
// live here (rather than split across files) because they are the one
// public surface screens and the router are meant to read -- see
// PLANNING.md §6 ("A repository is the only thing that touches `supabase`.
// Controllers call repositories; widgets call controllers.").
import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:logfitness_flutter/data/auth/auth_repository.dart';
import 'package:logfitness_flutter/data/auth/current_member.dart';
import 'package:logfitness_flutter/data/auth/current_staff.dart';
import 'package:logfitness_flutter/supabase/app_claims.dart';
import 'package:logfitness_flutter/supabase/supabase_providers.dart';

part 'auth_controller.freezed.dart';
part 'auth_controller.g.dart';

/// What the signed-in account actually is, resolved in the order PLANNING.md
/// §5 specifies: claims on the token first (no network round trip), then
/// `current_staff()`, then `current_member()`, then "not linked".
///
/// The `*PendingRefresh` cases exist because `current_staff()`/
/// `current_member()` are readable before the JWT carries claims: they let
/// the app tell "linked, but this token predates it -- refresh" apart from
/// "genuinely never linked", instead of bouncing both into the same "not
/// linked" screen.
@freezed
sealed class Principal with _$Principal {
  /// No session at all.
  const factory Principal.signedOut() = PrincipalSignedOut;

  /// The token's own claims identify a staff principal.
  const factory Principal.staff(AppClaims claims) = PrincipalStaff;

  /// The token's own claims identify a member principal.
  const factory Principal.member(AppClaims claims) = PrincipalMember;

  /// Signed in, no claims yet, but `current_staff()` found a linked staff
  /// row -- the session just needs [AuthController.linkPrincipal] (or any
  /// refresh) to pick up the claims the hook would stamp.
  const factory Principal.staffPendingRefresh(CurrentStaff staff) =
      PrincipalStaffPendingRefresh;

  /// Same, for a linked member row.
  const factory Principal.memberPendingRefresh(CurrentMember member) =
      PrincipalMemberPendingRefresh;

  /// Signed in, no claims, and neither RPC found a linked row: a genuinely
  /// unlinked account. Normal for an invited member who has not yet called
  /// [AuthController.linkPrincipal], or for an account with no invitation at
  /// all.
  const factory Principal.notLinked() = PrincipalNotLinked;
}

/// Resolves [Principal] for the current session. The router and every
/// screen that needs to know "who is this" read this provider rather than
/// re-deriving it.
@riverpod
Future<Principal> principal(Ref ref) async {
  final session = ref.watch(sessionProvider);
  if (session == null) {
    return const Principal.signedOut();
  }

  final claims = ref.watch(claimsProvider);
  if (claims != null) {
    return claims.isStaff ? Principal.staff(claims) : Principal.member(claims);
  }

  final repository = ref.watch(authRepositoryProvider);

  final staff = await repository.currentStaff();
  final member = staff == null ? await repository.currentMember() : null;

  if (staff == null && member == null) {
    return const Principal.notLinked();
  }

  // A principal row exists but the token predates it, so it carries no claims
  // and every RLS-scoped read would come back empty. Refresh once, here, rather
  // than routing into a shell that looks fine and silently sees nothing. One
  // attempt only: if the refreshed token still has no claims (the access-token
  // hook disabled, say), the pending state renders and says so instead of
  // spinning.
  Session? refreshedSession;
  try {
    refreshedSession = await repository.refreshSession();
  } on Exception {
    // A refresh that fails leaves the stale token in place; the pending state
    // below is still the honest answer.
    refreshedSession = null;
  }

  final refreshedClaims = refreshedSession == null
      ? null
      : AppClaims.fromSession(refreshedSession);

  if (refreshedClaims != null) {
    return refreshedClaims.isStaff
        ? Principal.staff(refreshedClaims)
        : Principal.member(refreshedClaims);
  }

  return staff != null
      ? Principal.staffPendingRefresh(staff)
      : Principal.memberPendingRefresh(member!);
}

/// The outcome of the most recent [AuthController.linkPrincipal] attempt.
///
/// `notLinked` is a normal, renderable state -- a member not yet invited, or
/// an ambiguous invitation staff need to resolve -- not an error. Only an
/// unexpected failure (network, an unrecognised Postgres error) surfaces
/// through [AsyncValue.error].
@freezed
sealed class LinkOutcome with _$LinkOutcome {
  const factory LinkOutcome.linked(String principalId) = LinkOutcomeLinked;
  const factory LinkOutcome.notLinked(LinkFailure reason) = LinkOutcomeNotLinked;
}

/// Sign-in, sign-out, and account-linking, as one `AsyncValue<LinkOutcome?>`
/// state: `null` before anything has been attempted, `loading` mid-call,
/// `data(LinkOutcome...)` after a [linkPrincipal] attempt settles, and
/// `error` only for a failure none of the above accounts for.
@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<LinkOutcome?> build() => null;

  /// Signs in with email + password. Loading and failure both surface
  /// through [AsyncValue] -- widgets read `.isLoading` / `.hasError`
  /// directly rather than this controller exposing bespoke flags.
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(authRepositoryProvider)
          .signIn(email: email, password: password);
      return null;
    });
  }

  /// Signs out and clears every provider that cached data scoped to the
  /// signed-out session, so nothing from the previous account survives into
  /// the next sign-in.
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signOut();
      ref.invalidate(sessionProvider);
      ref.invalidate(claimsProvider);
      ref.invalidate(principalProvider);
      return null;
    });
  }

  /// Adopts a pending invitation for the signed-in account, refreshes the
  /// session so the new claims are picked up, then invalidates the
  /// session/claims/principal providers so the router re-evaluates.
  ///
  /// A [LinkFailure] is not surfaced as an error state: it becomes
  /// `LinkOutcome.notLinked`, a value the UI renders directly, per
  /// PLANNING.md's "signed in but not linked is a normal state" rule.
  Future<void> linkPrincipal() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      try {
        final principalId = await repository.linkMemberAccount();
        await repository.refreshSession();
        ref.invalidate(sessionProvider);
        ref.invalidate(claimsProvider);
        ref.invalidate(principalProvider);
        return LinkOutcome.linked(principalId);
      } on LinkException catch (exception) {
        return LinkOutcome.notLinked(exception.failure);
      }
    });
  }
}
