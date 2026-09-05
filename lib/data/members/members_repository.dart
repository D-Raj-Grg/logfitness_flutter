// Placeholder repository proving the widget -> controller -> repository ->
// Supabase chain (PLANNING.md §6). Only `members` is wired up in Phase 1;
// the other modules (plans, memberships, invoices, payments) get their own
// repositories once their controllers land.
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:logfitness_flutter/data/members/member.dart';
import 'package:logfitness_flutter/supabase/supabase_providers.dart';

part 'members_repository.g.dart';

/// A repository is the only thing that touches `supabase` (PLANNING.md §6).
/// Controllers call repositories; widgets call controllers.
///
/// RLS is the tenant boundary, not this class. Every query here relies on
/// the session's Postgres policies to scope rows to the caller's org; this
/// repository never adds a client-side `org_id` filter. A query that would
/// return rows across tenants if a client-side filter were removed is a
/// policy bug to fix upstream, not something to patch here.
class MembersRepository {
  const MembersRepository(this._client);

  final SupabaseClient _client;

  static const _table = 'members';

  /// Fetches one member by primary key, or `null` if RLS hides it or it
  /// does not exist. The two cases are indistinguishable by design — that
  /// is what row-level security means.
  Future<Member?> fetchById(String id) async {
    final row = await _client
        .from(_table)
        .select()
        .eq('id', id)
        .maybeSingle();
    if (row == null) {
      return null;
    }
    return Member.fromJson(row);
  }

  /// Searches members by phone (the identity anchor — see PLANNING.md §5).
  ///
  /// The `ilike` filter below is presentation-side narrowing only: it never
  /// substitutes for tenant isolation. The set of rows Postgres is willing
  /// to return is already bounded by RLS before this filter is applied.
  Future<List<Member>> searchByPhone(String phone) async {
    final rows = await _client
        .from(_table)
        .select()
        .ilike('phone', '%$phone%');
    return (rows as List<dynamic>)
        .map((row) => Member.fromJson(row as Map<String, dynamic>))
        .toList();
  }
}

@riverpod
MembersRepository membersRepository(Ref ref) {
  return MembersRepository(ref.watch(supabaseClientProvider));
}
