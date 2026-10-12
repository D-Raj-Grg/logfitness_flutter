// Member access cards: the RFID card a member taps at the door.
//
// Writes go through `assign_member_card` and `revoke_member_card` (security
// invoker, so RLS still decides who may run them), never a direct insert or
// update: assigning also revokes a replaced card and clears the matching
// unassigned scans, and that belongs in one transaction. The door itself is
// `rfid_check_in`, which is service-role only and is never called from a
// client -- not from this app, not from the console.
//
// RLS is the tenant boundary; no client-side `org_id` filter appears here.
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:logfitness_flutter/data/members/member_card.dart';
import 'package:logfitness_flutter/data/members/unassigned_card_scan.dart';
import 'package:logfitness_flutter/data/repository_guard.dart';
import 'package:logfitness_flutter/supabase/supabase_providers.dart';

part 'member_cards_repository.g.dart';

class MemberCardsRepository {
  const MemberCardsRepository(this._client);

  final SupabaseClient _client;

  /// The member's live card, or `null` when they have none (or RLS hides it).
  /// At most one row can match: `(member_id) where revoked_at is null` is a
  /// partial unique index.
  Future<MemberCard?> liveCard(String memberId) {
    return guardFailures(() async {
      final Map<String, dynamic>? row = await _client
          .from('member_cards')
          .select('*')
          .eq('member_id', memberId)
          .isFilter('revoked_at', null)
          .maybeSingle();
      return row == null ? null : MemberCard.fromJson(row);
    });
  }

  /// The most recent taps of cards nobody holds yet, newest first, with the
  /// reader's name embedded.
  ///
  /// [branchIds] is the branch picker, not a permission: null means every
  /// branch RLS already allows (`has_branch_access(branch_id)`).
  Future<List<UnassignedCardScan>> listUnassignedScans({
    List<String>? branchIds,
    int limit = 10,
  }) {
    return guardFailures(() async {
      PostgrestFilterBuilder<PostgrestList> request = _client
          .from('unassigned_card_scans')
          .select('*, devices(name)');
      if (branchIds != null) {
        request = request.inFilter('branch_id', branchIds);
      }
      final PostgrestList rows = await request
          .order('last_seen_at', ascending: false)
          .limit(limit);
      return rows
          .map((Map<String, dynamic> row) => UnassignedCardScan.fromJson(row))
          .toList(growable: false);
    });
  }

  /// Hands [cardUid] to the member. Returns the new `member_cards` row.
  ///
  /// The RPC refuses a member who already holds a card unless [replace] is
  /// set, in which case it revokes the old one with the reason `Replaced`. A
  /// UID that is live for someone else is refused with "That card belongs to
  /// <member code>", which reaches the desk as written.
  Future<MemberCard> assign({
    required String memberId,
    required String cardUid,
    bool replace = false,
  }) {
    return guardFailures(() async {
      final dynamic result = await _client.rpc<dynamic>(
        'assign_member_card',
        params: <String, dynamic>{
          'p_member_id': memberId,
          'p_card_uid': cardUid,
          'p_replace': replace,
        },
      );
      return MemberCard.fromJson(
        Map<String, dynamic>.from(result as Map<dynamic, dynamic>),
      );
    });
  }

  /// Revokes the member's live card. [reason] is required by the RPC and by
  /// the table's check constraint.
  ///
  /// The returned row is not read: nothing here acts on it, and the caller
  /// re-reads [liveCard] anyway.
  Future<void> revoke({required String memberId, required String reason}) {
    return guardFailures(() async {
      await _client.rpc<dynamic>(
        'revoke_member_card',
        params: <String, dynamic>{
          'p_member_id': memberId,
          'p_reason': reason,
        },
      );
    });
  }
}

@riverpod
MemberCardsRepository memberCardsRepository(Ref ref) {
  return MemberCardsRepository(ref.watch(supabaseClientProvider));
}

/// The member's live card, for the "Access card" tile.
@riverpod
Future<MemberCard?> memberLiveCard(Ref ref, String memberId) {
  return ref.watch(memberCardsRepositoryProvider).liveCard(memberId);
}
