// Two things every repository in `lib/data/` does the same way, kept in one
// place so they cannot drift apart between modules.
import 'package:logfitness_flutter/domain/errors/app_failure.dart';

/// Runs [body] and turns anything it throws into an [AppFailure], rethrowing
/// with the original stack trace.
///
/// Mapping is not swallowing. `lib/domain/errors/app_failure.dart` records why
/// that distinction is load-bearing: the console shipped a bug where a `42501`
/// RLS refusal was caught and discarded, so a manager acting outside their
/// branches saw a screen indistinguishable from success. Every method here
/// converts and **rethrows**; nothing returns null on error, and nothing
/// catches without raising.
Future<T> guardFailures<T>(Future<T> Function() body) async {
  try {
    return await body();
  } catch (error, stackTrace) {
    Error.throwWithStackTrace(mapError(error, stackTrace), stackTrace);
  }
}

/// Drops null entries from an RPC argument map.
///
/// The console reaches the same behaviour with `?? undefined`, which
/// `JSON.stringify` then omits. Dart has no `undefined`, and the difference
/// matters: several RPC arguments are `bigint default 0` or
/// `payment_method default 'cash'`, so a named call that passes an explicit
/// null overrides the default with a NULL and the function then does
/// arithmetic against nothing. Omitting the key is what "use the default"
/// looks like over PostgREST.
///
/// Arguments that must be able to carry a real null -- `p_end_date` on
/// `adjust_membership_dates`, which is how a session pack with no validity
/// window is expressed -- are passed outside this helper on purpose.
Map<String, dynamic> rpcParams(Map<String, dynamic> params) {
  final Map<String, dynamic> compacted = <String, dynamic>{};
  for (final MapEntry<String, dynamic> entry in params.entries) {
    if (entry.value != null) {
      compacted[entry.key] = entry.value;
    }
  }
  return compacted;
}
