import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:logfitness_flutter/supabase/secure_session_storage.dart';
import 'package:logfitness_flutter/supabase/supabase_config.dart';

/// Initializes the Supabase client for the whole app.
///
/// Call once, before `runApp`. Fails loudly via
/// [SupabaseConfig.assertConfigured] if the required `--dart-define` values
/// were not supplied.
Future<void> initSupabase() async {
  SupabaseConfig.assertConfigured();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.publishableKey,
    authOptions: FlutterAuthClientOptions(
      localStorage: SecureSessionStorage(),
    ),
  );
}
