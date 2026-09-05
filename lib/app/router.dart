import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:logfitness_flutter/features/auth/auth_controller.dart';
import 'package:logfitness_flutter/features/auth/link_screen.dart';
import 'package:logfitness_flutter/features/auth/login_screen.dart';
import 'package:logfitness_flutter/features/auth/set_password_screen.dart';
import 'package:logfitness_flutter/features/auth/splash_screen.dart';
import 'package:logfitness_flutter/features/member/member_shell.dart';
import 'package:logfitness_flutter/features/staff/staff_shell.dart';
import 'package:logfitness_flutter/supabase/supabase_providers.dart';

const splashPath = '/splash';
const loginPath = '/login';
const linkPath = '/link';
const memberPath = '/member';
const staffPath = '/staff';
const setPasswordPath = '/set-password';

/// Bumps whenever [principalProvider] changes so [GoRouter] re-evaluates
/// its redirect. A plain [ChangeNotifier] driven off a provider listener,
/// per go_router's `refreshListenable` contract.
class RouterRefreshNotifier extends ChangeNotifier {
  RouterRefreshNotifier(Ref ref) {
    ref.listen(principalProvider, (previous, next) => notifyListeners());
  }
}

/// The app's single [GoRouter] instance.
///
/// `redirect` below is the ONLY place auth/role navigation is decided — no
/// screen should independently push a user to another shell. This is
/// navigation only: it decides which shell a session lands on, never what
/// that session can read. Postgres RLS is the actual access-control
/// boundary; a user could be routed to `/staff` and still see nothing if
/// their claims don't check out at the database.
final goRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = RouterRefreshNotifier(ref);
  ref.onDispose(refreshNotifier.dispose);

  final router = GoRouter(
    initialLocation: splashPath,
    refreshListenable: refreshNotifier,
    redirect: (context, state) => _redirect(ref, state),
    routes: [
      GoRoute(
        path: splashPath,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: loginPath,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: linkPath,
        builder: (context, state) => const LinkScreen(),
      ),
      GoRoute(
        path: setPasswordPath,
        builder: (context, state) => const SetPasswordScreen(),
      ),
      GoRoute(
        path: memberPath,
        builder: (context, state) => const MemberShell(),
      ),
      GoRoute(
        path: staffPath,
        builder: (context, state) => const StaffShell(),
      ),
    ],
  );

  // supabase_flutter exchanges an emailed invite or recovery link for a
  // session on its own, and then says so through this event. Without acting on
  // it the invited member would be linked and dropped into a shell having
  // never set a password -- and so could never sign in by email again. This is
  // the one navigation decided outside `_redirect`, because it is a response
  // to an event rather than to a state.
  ref.listen(authStateChangesProvider, (previous, next) {
    if (next case AsyncData(:final value)
        when value.event == AuthChangeEvent.passwordRecovery) {
      router.go(setPasswordPath);
    }
  });

  return router;
});

String? _redirect(Ref ref, GoRouterState state) {
  final currentPath = state.matchedLocation;

  final principalAsync = ref.read(principalProvider);

  // A session that arrives from an invite email lands on /set-password before
  // any principal can be resolved from it, so the guard steps aside -- but only
  // while the account is not yet a resolved principal. Once linking has taken,
  // leaving the exemption unconditional would strand the user on that screen
  // forever with nothing left to do there.
  if (currentPath == setPasswordPath) {
    final finished = principalAsync.hasValue
        ? switch (principalAsync.requireValue) {
            PrincipalStaff() ||
            PrincipalMember() ||
            PrincipalStaffPendingRefresh() ||
            PrincipalMemberPendingRefresh() ||
            // No session at all: the link expired or was already used, and
            // there is nothing to set a password on.
            PrincipalSignedOut() => true,
            PrincipalNotLinked() => false,
          }
        : false;
    if (!finished) {
      return null;
    }
  }

  // An error out of `principalProvider` is not the same as still loading: an
  // unrecognised staff_role, say, throws by design. Splash renders it with a
  // way out, so the app cannot end up inert on a blank screen.
  if (principalAsync.hasError) {
    return currentPath == splashPath ? null : splashPath;
  }

  // Still resolving (cold start, or a refresh in flight). Park on /splash
  // rather than flashing /login at a returning user.
  if (!principalAsync.hasValue) {
    return currentPath == splashPath ? null : splashPath;
  }

  final principal = principalAsync.requireValue;

  return switch (principal) {
    PrincipalSignedOut() => currentPath == loginPath ? null : loginPath,

    // Role gating here is UX only — it picks which shell renders. The
    // database, via RLS, is what actually decides what the session can
    // read or write (PLANNING.md §3/§6).
    PrincipalStaff() => currentPath == staffPath ? null : staffPath,
    PrincipalMember() => currentPath == memberPath ? null : memberPath,

    // The principal row exists but the token predates it — the matching
    // shell renders while a refresh happens, exactly as the web console
    // does. This must NOT land on /link: the account is linked.
    PrincipalStaffPendingRefresh() =>
      currentPath == staffPath ? null : staffPath,
    PrincipalMemberPendingRefresh() =>
      currentPath == memberPath ? null : memberPath,

    PrincipalNotLinked() => currentPath == linkPath ? null : linkPath,
  };
}
