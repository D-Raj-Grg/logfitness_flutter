/// Compile-time Supabase configuration.
///
/// Values are supplied via `--dart-define` at build/run time so the
/// Supabase URL and publishable key never live in the tree. See
/// PLANNING.md §6 ("Git") and CLAUDE.md ("No secrets in the tree").
abstract final class SupabaseConfig {
  /// The Supabase project URL, e.g. `https://xxxx.supabase.co`.
  ///
  /// Supplied via `--dart-define=SUPABASE_URL=...`.
  static const String url = String.fromEnvironment('SUPABASE_URL');

  /// The Supabase publishable (anon) key. Never the secret/service key.
  ///
  /// Supplied via `--dart-define=SUPABASE_PUBLISHABLE_KEY=...`.
  static const String publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  /// Whether both required values were supplied at build time.
  static bool get isConfigured => url.isNotEmpty && publishableKey.isNotEmpty;

  /// Throws a [StateError] naming the missing `--dart-define` flags.
  ///
  /// Call this early in app start-up so a misconfigured build fails loudly
  /// instead of surfacing as a confusing network error later.
  static void assertConfigured() {
    if (isConfigured) {
      return;
    }

    final missing = <String>[
      if (url.isEmpty) '--dart-define=SUPABASE_URL=<url>',
      if (publishableKey.isEmpty)
        '--dart-define=SUPABASE_PUBLISHABLE_KEY=<key>',
    ];

    throw StateError(
      'Supabase is not configured. Pass the following flags when running '
      'or building the app: ${missing.join(', ')}.',
    );
  }
}
