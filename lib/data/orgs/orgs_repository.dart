// The org's own settings, as far as a counter needs them.
//
// One value today: the gym's list joining fee. It is here rather than inlined
// in a screen because the counter has to show the same waiver the invoice
// will print -- a plan priced without a fee of its own has no other source for
// the amount (`logfitness_saas/lib/db/orgs.ts`, `getOrgStandardSignupFee`).
//
// Read-only. Org profile editing is owner-only and stays on the web console
// (CLAUDE.md, "Scope discipline").
//
// RLS scopes `orgs` to the caller's own org, so the id filter below is a
// convenience for `maybeSingle`, never the boundary.
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:logfitness_flutter/data/repository_guard.dart';
import 'package:logfitness_flutter/supabase/supabase_providers.dart';

part 'orgs_repository.g.dart';

class OrgsRepository {
  const OrgsRepository(this._client);

  final SupabaseClient _client;

  static const String _table = 'orgs';

  /// The gym's standard joining fee in paisa, or zero when it has none set.
  ///
  /// Zero is also what a failed read would mean, which is why this one does
  /// not swallow: `guardFailures` maps the error and the caller decides. The
  /// screens treat a missing fee as "no waiver to show" rather than blocking
  /// the sale.
  Future<int> standardSignupFeePaisa(String orgId) {
    return guardFailures(() async {
      final Map<String, dynamic>? row = await _client
          .from(_table)
          .select('standard_signup_fee_paisa')
          .eq('id', orgId)
          .maybeSingle();
      final Object? value = row?['standard_signup_fee_paisa'];
      return value is int ? value : 0;
    });
  }
}

@riverpod
OrgsRepository orgsRepository(Ref ref) {
  return OrgsRepository(ref.watch(supabaseClientProvider));
}

/// The gym's list joining fee, loaded once and shared by every sale screen.
///
/// Resolves to zero for a session with no org claim — there is nothing to
/// read and nothing to show.
@riverpod
Future<int> orgStandardSignupFee(Ref ref) async {
  final String? orgId = ref.watch(claimsProvider)?.orgId;
  if (orgId == null) {
    return 0;
  }
  return ref.watch(orgsRepositoryProvider).standardSignupFeePaisa(orgId);
}
