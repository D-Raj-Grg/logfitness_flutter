// Mints the member's check-in QR token with the `mint_qr_token` Postgres RPC
// (20260905150000_qr_tokens_in_postgres.sql). Not an Edge Function. With no
// `p_member_id` the function resolves the caller from the JWT.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:logfitness_flutter/data/repository_guard.dart';
import 'package:logfitness_flutter/supabase/supabase_providers.dart';

class QrToken {
  const QrToken({
    required this.token,
    required this.ttl,
    required this.mintedAt,
  });

  final String token;
  final Duration ttl;

  /// Local receipt time. Expiry is measured from this, not from the server's
  /// `expires_at`, so a skewed device clock cannot shorten or lengthen it.
  final DateTime mintedAt;

  DateTime get expiresAt => mintedAt.add(ttl);
}

class QrTokenRepository {
  const QrTokenRepository(this._client);

  final SupabaseClient _client;

  Future<QrToken> mint() {
    return guardFailures(() async {
      final res = await _client.rpc('mint_qr_token');
      final map = res as Map<String, dynamic>;
      return QrToken(
        token: map['token'] as String,
        ttl: Duration(seconds: (map['ttl_seconds'] as num).toInt()),
        mintedAt: DateTime.now(),
      );
    });
  }
}

final qrTokenRepositoryProvider = Provider<QrTokenRepository>((ref) {
  return QrTokenRepository(ref.watch(supabaseClientProvider));
});
