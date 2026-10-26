// The fees catalogue, mirroring the web console's
// `logfitness_saas/lib/db/fees.ts`.
//
// Reads it for every seller (the counter quotes from it) and writes it for the
// owner. There is no delete: a fee is retired by deactivating it, because past
// sales keep a snapshot of the fee they charged and the console offers no
// delete either.
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:logfitness_flutter/data/fees/fee.dart';
import 'package:logfitness_flutter/data/repository_guard.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/domain/validation/fee_form.dart';
import 'package:logfitness_flutter/supabase/supabase_providers.dart';

part 'fees_repository.g.dart';

/// How this org charges, as a sale needs it: the active fees, the switch that
/// says whether the catalogue or the plan's legacy joining fee is what the
/// database charges, and the legacy list fee a waiver is struck out against.
///
/// `catalogueEnabled` is `orgs.fee_catalogue_enabled`. While it is false the one
/// fee is the plan's `signup_fee_paisa`, and a screen that quoted catalogue
/// fees would promise a total the RPC then writes differently.
@immutable
class FeeSetup {
  const FeeSetup({
    required this.fees,
    required this.catalogueEnabled,
    required this.standardSignupFeePaisa,
  });

  /// Nothing known yet: a sale quotes the legacy path, which is what an org
  /// that has not switched over gets anyway. Used while the read is in flight
  /// or if it failed -- a sale must not wait on it or break without it.
  static const FeeSetup legacy = FeeSetup(
    fees: <Fee>[],
    catalogueEnabled: false,
    standardSignupFeePaisa: 0,
  );

  final List<Fee> fees;
  final bool catalogueEnabled;
  final int standardSignupFeePaisa;
}

/// A repository is the only thing that touches `supabase` (PLANNING.md §6).
///
/// RLS scopes every query below to the caller's org. Nothing here filters by
/// `org_id`.
class FeesRepository {
  const FeesRepository(this._client);

  final SupabaseClient _client;

  static const String _table = 'fees';

  /// The whole catalogue, active or not. Mirrors the console's `listFees`.
  Future<List<Fee>> listFees() {
    return guardFailures(() async {
      final PostgrestList rows = await _client
          .from(_table)
          .select('*')
          .order('is_active', ascending: false)
          .order('sort_order', ascending: true)
          .order('name', ascending: true);
      return rows.map(Fee.fromRow).toList();
    });
  }

  /// What a sale quotes from: the active fees and how the org charges.
  /// Mirrors the console's `listActiveFees` + `getFeeContext`.
  Future<FeeSetup> feeSetup(String orgId) {
    return guardFailures(() async {
      final PostgrestList rows = await _client
          .from(_table)
          .select('*')
          .eq('is_active', true)
          .order('sort_order', ascending: true)
          .order('name', ascending: true);
      final Map<String, dynamic>? org = await _client
          .from('orgs')
          .select('fee_catalogue_enabled, standard_signup_fee_paisa')
          .eq('id', orgId)
          .maybeSingle();
      final Object? enabled = org?['fee_catalogue_enabled'];
      final Object? standard = org?['standard_signup_fee_paisa'];
      return FeeSetup(
        fees: rows.map(Fee.fromRow).toList(),
        catalogueEnabled: enabled == true,
        standardSignupFeePaisa: standard is num ? standard.toInt() : 0,
      );
    });
  }

  /// Adds a fee at the end of the list and returns its id. Mirrors the
  /// console's `createFee`.
  ///
  /// `org_id` comes from the caller's claims, never from a form; the RLS insert
  /// policy independently rejects any other org and any non-owner. A new fee is
  /// always active. The unique-name rule surfaces as [kFeeDuplicateName].
  Future<String> createFee({
    required String orgId,
    required FeeValues values,
  }) {
    return guardFailures(() async {
      try {
        // A stable append order is what the printed invoice reads.
        final PostgrestList last = await _client
            .from(_table)
            .select('sort_order')
            .order('sort_order', ascending: false)
            .limit(1);
        final int nextSort = last.isEmpty
            ? 0
            : ((last.first['sort_order'] as num).toInt() + 1);
        final Map<String, dynamic> row = await _client
            .from(_table)
            .insert(<String, dynamic>{
              'org_id': orgId,
              ...values.toRow(),
              'is_active': true,
              'sort_order': nextSort,
            })
            .select('id')
            .single();
        return row['id'] as String;
      } on PostgrestException catch (error) {
        throw _duplicateOr(error);
      }
    });
  }

  /// Rewrites a fee's editable columns. Mirrors the console's `updateFee`.
  ///
  /// RLS turns a fee the caller may not touch into zero updated rows rather
  /// than an error, so the row count is checked: a silent no-op must never look
  /// like a save.
  Future<void> updateFee(String feeId, FeeValues values) {
    return guardFailures(() => _update(feeId, values.toRow()));
  }

  /// Puts a fee on or off. Mirrors the console's `setFeeActive`.
  Future<void> setFeeActive(String feeId, bool isActive) {
    return guardFailures(
      () => _update(feeId, <String, dynamic>{'is_active': isActive}),
    );
  }

  Future<void> _update(String feeId, Map<String, dynamic> row) async {
    try {
      final PostgrestList updated = await _client
          .from(_table)
          .update(row)
          .eq('id', feeId)
          .select('id');
      if (updated.isEmpty) {
        throw const AppFailure(
          FailureKind.refused,
          'Only an owner can change the fees.',
        );
      }
    } on PostgrestException catch (error) {
      throw _duplicateOr(error);
    }
  }

  /// `23505` on this table can only be the (org, lower(name)) rule.
  Object _duplicateOr(PostgrestException error) {
    if (error.code == '23505') {
      return AppFailure(
        FailureKind.duplicate,
        kFeeDuplicateName,
        cause: error,
        code: error.code,
      );
    }
    return error;
  }
}

@riverpod
FeesRepository feesRepository(Ref ref) {
  return FeesRepository(ref.watch(supabaseClientProvider));
}
