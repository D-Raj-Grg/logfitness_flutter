// `orgs.settings` -- the jsonb bag of owner-editable preferences.
//
// Reads are plain selects (staff may read their own org, RLS "staff read their
// own org"). Writes go through the `set_org_setting` RPC, never `orgs.update`:
// an update would replace the whole bag and clobber keys this screen does not
// know about. The RPC is owner-only (`42501` otherwise), allow-lists the keys
// and validates the values.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:logfitness_flutter/data/repository_guard.dart';
import 'package:logfitness_flutter/domain/validation/org_preferences.dart';
import 'package:logfitness_flutter/supabase/supabase_providers.dart';

class OrgSettingsRepository {
  const OrgSettingsRepository(this._client);

  final SupabaseClient _client;

  /// The org's preferences with defaults applied, or null when RLS hides the
  /// row.
  Future<OrgPreferences?> preferences(String orgId) {
    return guardFailures(() async {
      final Map<String, dynamic>? row = await _client
          .from('orgs')
          .select('settings')
          .eq('id', orgId)
          .maybeSingle();
      return row == null ? null : OrgPreferences.fromSettings(row['settings']);
    });
  }

  /// Writes both keys. Two RPC calls, each an atomic merge of one key.
  Future<void> savePreferences(OrgPreferences values) {
    return guardFailures(() async {
      await _client.rpc<dynamic>(
        'set_org_setting',
        params: <String, dynamic>{
          '_key': 'class_cancellation_window_minutes',
          '_value': values.cancellationWindowMinutes,
        },
      );
      await _client.rpc<dynamic>(
        'set_org_setting',
        params: <String, dynamic>{
          '_key': 'notification_locale',
          '_value': values.notificationLocale,
        },
      );
    });
  }
}

final Provider<OrgSettingsRepository> orgSettingsRepositoryProvider =
    Provider<OrgSettingsRepository>(
      (Ref ref) => OrgSettingsRepository(ref.watch(supabaseClientProvider)),
    );
