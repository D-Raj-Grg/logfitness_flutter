// One place that turns a thrown error into something a person at a desk can
// act on.
//
// Why this exists: the web console shipped a bug on 2026-09-07 where two
// Server Actions swallowed a `42501` RLS refusal, so a manager acting outside
// the branches they cover saw nothing happen -- indistinguishable from
// success. This app is *more* exposed to that, not less: `CLAUDE.md` says
// role gating in the UI is UX only and RLS is the real boundary, so a refusal
// the database issues must always reach the screen. A caught-and-discarded
// PostgrestException is a review failure.
//
// The database already writes good sentences for the cases it knows about --
// `convert_visitor` raises "That visitor has already been registered as a
// member" -- so those are passed through rather than replaced. Only the codes
// whose native text is Postgres-internal get substituted.
import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';

/// What went wrong, at the granularity a screen cares about.
enum FailureKind {
  /// The database refused the caller: RLS, a role ceiling, or a guard
  /// trigger. Never presented as a generic error -- the desk needs to know
  /// it was refused, not that "something went wrong".
  refused,

  /// A uniqueness rule was hit. Usually a phone that already belongs to
  /// someone in this org.
  duplicate,

  /// A domain rule the database enforces (a check constraint, or an explicit
  /// `raise` from an RPC).
  invalid,

  /// The row is not there -- or RLS hides it, which is indistinguishable by
  /// design.
  notFound,

  /// No connection. Writes are never queued locally (PLANNING.md scope:
  /// "offline-first is deferred, not solved"), so this must be loud.
  offline,

  /// The session is gone or was never established.
  unauthenticated,

  /// Anything not otherwise classified.
  unknown,
}

/// A failure with a sentence attached.
class AppFailure implements Exception {
  const AppFailure(this.kind, this.message, {this.cause, this.code});

  final FailureKind kind;

  /// Shown to the user as-is.
  final String message;

  /// The original error, kept for logging. Never shown.
  final Object? cause;

  /// The Postgres SQLSTATE or PostgREST code, when there was one.
  final String? code;

  bool get isRefusal => kind == FailureKind.refused;

  @override
  String toString() => 'AppFailure(${kind.name}, code: $code): $message';
}

const _refusedMessage =
    'The database refused that. It is outside the branches or the role you '
    'are assigned to.';

const _offlineMessage =
    'No connection, so nothing was saved. Check the network and try again.';

const _unauthenticatedMessage =
    'Your session has expired. Sign in again to continue.';

/// Unique constraints whose violation has a better sentence than Postgres's.
/// Keyed by the fragment of the constraint name that appears in the message.
const Map<String, String> _duplicateMessages = <String, String>{
  'members_org_phone': 'A member in this organisation already has that phone '
      'number. Search for them instead of registering a second record.',
  'members_org_member_code': 'That member code is already in use.',
  'staff_org_email': 'Someone with that email address is already on the staff '
      'list.',
};

/// Maps anything thrown by a repository into an [AppFailure].
///
/// Pass it the raw error. It never rethrows and never returns null: a screen
/// that reaches this function always gets something to render.
AppFailure mapError(Object error, [StackTrace? stackTrace]) {
  if (error is AppFailure) {
    return error;
  }

  if (error is PostgrestException) {
    return _fromPostgrest(error);
  }

  if (error is AuthException) {
    return AppFailure(
      FailureKind.unauthenticated,
      _unauthenticatedMessage,
      cause: error,
    );
  }

  if (error is UnknownEnumValue) {
    // The database sent a value this build does not know. That is a schema
    // drift bug, not a user error, and hiding it behind friendly copy is how
    // it survives to production.
    return AppFailure(
      FailureKind.unknown,
      'This app is out of date with the server (${error.value}). Update the '
      'app.',
      cause: error,
    );
  }

  if (_isOffline(error)) {
    return AppFailure(FailureKind.offline, _offlineMessage, cause: error);
  }

  return AppFailure(
    FailureKind.unknown,
    'Something went wrong and nothing was saved.',
    cause: error,
  );
}

bool _isOffline(Object error) =>
    error is SocketException ||
    error is HttpException ||
    error is TimeoutException ||
    // `package:http`'s ClientException, matched by name rather than by type:
    // http is a transitive dependency of supabase_flutter, and PLANNING.md §2
    // says the stack table is the whole dependency list, so importing it
    // directly would add a package the plan does not carry.
    error.runtimeType.toString() == 'ClientException';

AppFailure _fromPostgrest(PostgrestException error) {
  final code = error.code;
  final message = error.message;

  switch (code) {
    // insufficient_privilege -- RLS, a role ceiling, or a guard trigger.
    case '42501':
      return AppFailure(FailureKind.refused, _refusedMessage,
          cause: error, code: code);

    // unique_violation.
    case '23505':
      for (final entry in _duplicateMessages.entries) {
        if (message.contains(entry.key)) {
          return AppFailure(FailureKind.duplicate, entry.value,
              cause: error, code: code);
        }
      }
      return AppFailure(
        FailureKind.duplicate,
        'That record already exists.',
        cause: error,
        code: code,
      );

    // check_violation and not_null_violation: the RPCs raise these with
    // sentences already written for a person, so pass them through.
    case '23514':
    case '23502':
      return AppFailure(FailureKind.invalid, message,
          cause: error, code: code);

    // foreign_key_violation -- almost always a stale id in a picker.
    case '23503':
      return AppFailure(
        FailureKind.invalid,
        'Something that was selected no longer exists. Reload and try again.',
        cause: error,
        code: code,
      );

    // no_data_found, raised explicitly by convert_visitor and friends.
    case 'P0002':
      return AppFailure(FailureKind.notFound, message,
          cause: error, code: code);

    // PostgREST: `.single()` matched no rows.
    case 'PGRST116':
      return AppFailure(
        FailureKind.notFound,
        'That record was not found.',
        cause: error,
        code: code,
      );

    // PostgREST: the JWT is missing or expired.
    case 'PGRST301':
    case '42P01':
      return AppFailure(
        FailureKind.unauthenticated,
        _unauthenticatedMessage,
        cause: error,
        code: code,
      );

    default:
      // An unmapped code still surfaces the database's own words. Silence is
      // the failure mode this whole file exists to prevent.
      return AppFailure(FailureKind.unknown, message,
          cause: error, code: code);
  }
}
