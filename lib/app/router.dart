import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:logfitness_flutter/features/auth/auth_controller.dart';
import 'package:logfitness_flutter/features/auth/link_screen.dart';
import 'package:logfitness_flutter/features/auth/login_screen.dart';
import 'package:logfitness_flutter/features/auth/set_password_screen.dart';
import 'package:logfitness_flutter/features/auth/splash_screen.dart';
import 'package:logfitness_flutter/features/member/member_shell.dart';
import 'package:logfitness_flutter/features/staff/staff_shell.dart';

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

  return GoRouter(
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
});

String? _redirect(Ref ref, GoRouterState state) {
  final currentPath = state.matchedLocation;

  // A session that arrives from an invite email lands here to set a
  // password before any principal can be resolved from it. This is the one
  // route the guard must respect over the principal state, so it is checked
  // before reading `principalProvider` at all.
  if (currentPath == setPasswordPath) {
    return null;
  }

  final principalAsync = ref.read(principalProvider);

  // Still resolving `principalProvider` (cold start, or a refresh in
  // flight). Park on /splash rather than flashing /login at a returning
  // user, and never let an error state loop either.
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
