// Reads the branches the caller can see.
//
// Mirrors `logfitness_saas/lib/db/branches.ts`, minus its writes: creating,
// renaming and deactivating a branch stays on the web console (PLANNING.md §4
// — branch administration is one of the two things parity deliberately does
// not bring across). Only the read is here, because every staff screen in
// this app needs to turn a branch id into a name.
//
// RLS limits this to the caller's org, so no org filter is applied -- or
// needed. A query that returned the right rows only because of a client-side
// filter would be a policy bug to fix upstream (CLAUDE.md).
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:logfitness_flutter/data/branches/branch.dart';
import 'package:logfitness_flutter/data/repository_guard.dart';
import 'package:logfitness_flutter/supabase/supabase_providers.dart';

part 'branches_repository.g.dart';

class BranchesRepository {
  const BranchesRepository(this._client);

  final SupabaseClient _client;

  static const _table = 'branches';

  /// Every branch the caller may read, ordered by name like the console's
  /// `listBranches`.
  ///
  /// Includes inactive branches. A member registered at a branch that was
  /// later closed still has to render with that branch's name, and a switcher
  /// that hid it would leave those rows attributed to an id.
  Future<List<Branch>> listBranches() {
    return guardFailures(() async {
      final rows = await _client.from(_table).select().order('name', ascending: true);
      return (rows as List<dynamic>)
          .map((row) => Branch.fromJson(row as Map<String, dynamic>))
          .toList();
    });
  }

  Future<Branch?> fetchById(String branchId) {
    return guardFailures(() async {
      final row =
          await _client.from(_table).select().eq('id', branchId).maybeSingle();
      return row == null ? null : Branch.fromJson(row);
    });
  }
}

@riverpod
BranchesRepository branchesRepository(Ref ref) {
  return BranchesRepository(ref.watch(supabaseClientProvider));
}

/// Every branch the caller can read, loaded once and shared.
///
/// A `Future` provider rather than a plain one because the switcher, the
/// register form's home-branch picker and every screen that prints a branch
/// name all want the same list, and none of them should each issue their own
/// query for it.
@riverpod
Future<List<Branch>> branches(Ref ref) {
  return ref.watch(branchesRepositoryProvider).listBranches();
}
