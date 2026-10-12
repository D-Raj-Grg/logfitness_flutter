// Reads and the write behind Settings -> Preferences. Hand-written, matching
// the letterhead providers.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/data/orgs/org_settings_repository.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/domain/validation/org_preferences.dart';
import 'package:logfitness_flutter/supabase/supabase_providers.dart';

final FutureProvider<OrgPreferences?> orgPreferencesProvider =
    FutureProvider<OrgPreferences?>((Ref ref) async {
      final String? orgId = ref.watch(claimsProvider)?.orgId;
      if (orgId == null) return null;
      return ref.watch(orgSettingsRepositoryProvider).preferences(orgId);
    });

/// Null on success, the failure otherwise. `true` state while saving.
class PreferencesSaveController extends Notifier<bool> {
  @override
  bool build() => false;

  Future<AppFailure?> save(OrgPreferences values) async {
    state = true;
    try {
      await ref.read(orgSettingsRepositoryProvider).savePreferences(values);
      ref.invalidate(orgPreferencesProvider);
      return null;
    } catch (error, stackTrace) {
      // A half-applied save is possible (two keys); re-read either way.
      ref.invalidate(orgPreferencesProvider);
      return mapError(error, stackTrace);
    } finally {
      state = false;
    }
  }
}

final NotifierProvider<PreferencesSaveController, bool>
preferencesSaveProvider = NotifierProvider<PreferencesSaveController, bool>(
  PreferencesSaveController.new,
);
