import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_claims.dart';

/// The shared Supabase client, initialized in `initSupabase()` before
/// `runApp`.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Emits every auth state change, replaying the current state to new
/// subscribers (the underlying `onAuthStateChange` stream is a replay
/// subject), so this is never left in a perpetual loading state.
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange;
});

/// The current session, rebuilt whenever [authStateChangesProvider] emits.
///
/// `null` when signed out, or before the first auth state has arrived.
final sessionProvider = Provider<Session?>((ref) {
  final authState = ref.watch(authStateChangesProvider).value;
  return authState?.session ?? Supabase.instance.client.auth.currentSession;
});

/// The claims carried by the current session's access token.
///
/// `null` when signed out, or when the session carries no claims yet —
/// see [AppClaims] for why that is a normal, expected state.
final claimsProvider = Provider<AppClaims?>((ref) {
  final session = ref.watch(sessionProvider);
  if (session == null) {
    return null;
  }
  return AppClaims.fromSession(session);
});
