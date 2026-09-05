import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:logfitness_flutter/features/auth/link_screen.dart';
import 'package:logfitness_flutter/features/auth/login_screen.dart';
import 'package:logfitness_flutter/features/auth/splash_screen.dart';
import 'package:logfitness_flutter/features/member/member_shell.dart';
import 'package:logfitness_flutter/features/staff/staff_shell.dart';
import 'package:logfitness_flutter/supabase/supabase_providers.dart';

const splashPath = '/splash';
const loginPath = '/login';
const linkPath = '/link';
const memberPath = '/member';
const staffPath = '/staff';

/// Bumps whenever session or claims change so [GoRouter] re-evaluates its
/// redirect. A plain [ValueNotifier]/[ChangeNotifier] driven off provider
/// listeners, per go_router's `refreshListenable` contract.
class RouterRefreshNotifier extends ChangeNotifier {
  RouterRefreshNotifier(Ref ref) {
    ref.listen(sessionProvider, (previous, next) => notifyListeners());
    ref.listen(claimsProvider, (previous, next) => notifyListeners());
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
  final session = ref.read(sessionProvider);

  if (session == null) {
    return currentPath == loginPath ? null : loginPath;
  }

  final claims = ref.read(claimsProvider);
  if (claims == null) {
    // Authenticated but not yet linked to a member/staff principal. This is
    // a normal, stable state (see PLANNING.md §5 "Claims contract") — never
    // bounce a user already sitting on /link back through itself.
    return currentPath == linkPath ? null : linkPath;
  }

  if (claims.isMember) {
    return currentPath == memberPath ? null : memberPath;
  }

  if (claims.staffRole != null) {
    return currentPath == staffPath ? null : staffPath;
  }

  // Linked but neither a member nor a recognised staff role — treat like
  // the not-yet-linked state rather than looping.
  return currentPath == linkPath ? null : linkPath;
}
