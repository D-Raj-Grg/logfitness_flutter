// The fees catalogue's providers, and the one place that knows which other
// providers hold a copy of it.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/data/fees/fee.dart';
import 'package:logfitness_flutter/data/fees/fees_repository.dart';
import 'package:logfitness_flutter/supabase/supabase_providers.dart';

/// The whole catalogue, active or not (`listFees`).
final FutureProvider<List<Fee>> feeCatalogueProvider =
    FutureProvider<List<Fee>>(
      (Ref ref) => ref.watch(feesRepositoryProvider).listFees(),
    );

/// What a sale quotes from: the active fees and how this org charges. Shared by
/// the register and renew screens.
///
/// Resolves to [FeeSetup.legacy] for a session with no org claim -- there is
/// nothing to read and nothing to quote.
///
/// Auto-disposed on purpose: the sale screens keep it alive while they are open
/// and it is read afresh each time one opens. A fee the owner changed on the
/// web console, or on another phone, must be what the next sale is quoted from;
/// a copy cached for the life of the app would quote last week's fees against
/// an RPC that charges today's.
final FutureProvider<FeeSetup> feeSetupProvider =
    FutureProvider.autoDispose<FeeSetup>((Ref ref) async {
  final String? orgId = ref.watch(claimsProvider)?.orgId;
  if (orgId == null) {
    return FeeSetup.legacy;
  }
  return ref.watch(feesRepositoryProvider).feeSetup(orgId);
});

/// Call after any fee write. [feeCatalogueProvider] is cached for the life of
/// the app, and [feeSetupProvider] stays alive for as long as a sale screen is
/// open beneath this one, so without this a fee added or retired here would not
/// change the list (or the quote) until they were next rebuilt.
void refreshFeeProviders(WidgetRef ref) {
  ref
    ..invalidate(feeCatalogueProvider)
    ..invalidate(feeSetupProvider);
}
