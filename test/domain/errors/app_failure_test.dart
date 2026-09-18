// The one behaviour this file exists to protect: a database refusal reaches
// the screen. The web console shipped a bug on 2026-09-07 where a `42501` was
// swallowed and a refused write looked like a successful one; every case here
// is a way that could happen again.
import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('PostgrestException', () {
    test('42501 is a refusal, said in those words', () {
      final failure = mapError(
        const PostgrestException(
          message: 'new row violates row-level security policy for table '
              '"visitors"',
          code: '42501',
        ),
      );

      expect(failure.kind, FailureKind.refused);
      expect(failure.isRefusal, isTrue);
      expect(failure.code, '42501');
      // Not "something went wrong": the desk is told it was refused, and why
      // it might have been.
      expect(failure.message, contains('refused'));
      expect(failure.message, contains('branches'));
    });

    test('23505 on members_org_phone gets the phone sentence', () {
      final failure = mapError(
        const PostgrestException(
          message: 'duplicate key value violates unique constraint '
              '"members_org_phone"',
          code: '23505',
        ),
      );

      expect(failure.kind, FailureKind.duplicate);
      expect(failure.message, contains('already has that phone number'));
      // The sentence tells the desk what to do instead, which is the whole
      // reason it replaces Postgres's.
      expect(failure.message, contains('Search for them'));
    });

    test('23505 on an unrecognised constraint still says it is a duplicate',
        () {
      final failure = mapError(
        const PostgrestException(
          message: 'duplicate key value violates unique constraint '
              '"visitors_pkey"',
          code: '23505',
        ),
      );

      expect(failure.kind, FailureKind.duplicate);
      expect(failure.message, 'That record already exists.');
    });

    test('23505 raised by hand keeps the sentence the RPC wrote', () {
      // `enqueue_notification` and `send_member_notification` both raise
      // `unique_violation` themselves, with a sentence already written for a
      // person. Replacing it with "That record already exists." would tell the
      // desk nothing about the two-minute guard they just hit.
      for (final String message in <String>[
        'That message has already been queued',
        'That message is already queued for this member',
      ]) {
        final failure = mapError(
          PostgrestException(message: message, code: '23505'),
        );

        expect(failure.kind, FailureKind.duplicate);
        expect(failure.message, message);
      }
    });

    test('23514 passes the database\'s own sentence through', () {
      // convert_visitor raises this one, already written for a person.
      const message = 'That visitor has already been registered as a member';
      final failure = mapError(
        const PostgrestException(message: message, code: '23514'),
      );

      expect(failure.kind, FailureKind.invalid);
      expect(failure.message, message);
    });

    test('P0002 is not-found, with the RPC\'s own words', () {
      final failure = mapError(
        const PostgrestException(message: 'Visitor not found', code: 'P0002'),
      );

      expect(failure.kind, FailureKind.notFound);
      expect(failure.message, 'Visitor not found');
    });

    test('an unmapped code still surfaces the database message', () {
      // Never a generic string. Silence is the failure mode being prevented.
      final failure = mapError(
        const PostgrestException(
          message: 'canceling statement due to statement timeout',
          code: '57014',
        ),
      );

      expect(failure.kind, FailureKind.unknown);
      expect(failure.code, '57014');
      expect(failure.message, 'canceling statement due to statement timeout');
    });
  });

  group('non-Postgrest errors', () {
    test('a SocketException is offline, and says nothing was saved', () {
      final failure = mapError(const SocketException('Failed host lookup'));

      expect(failure.kind, FailureKind.offline);
      // Writes are never queued locally, so this must not imply otherwise.
      expect(failure.message, contains('nothing was saved'));
    });

    test('a TimeoutException is offline too', () {
      final failure = mapError(TimeoutException('no response'));

      expect(failure.kind, FailureKind.offline);
    });

    test('an UnknownEnumValue says the app is out of date', () {
      // Schema drift, not a user error. Friendly copy is how it survives to
      // production -- see PLANNING.md §5.
      final failure = mapError(
        const UnknownEnumValue('VisitorStatus', 'archived'),
      );

      expect(failure.kind, FailureKind.unknown);
      expect(failure.message, contains('out of date'));
      expect(failure.message, contains('archived'));
    });

    test('an AuthException is unauthenticated', () {
      final failure = mapError(const AuthException('JWT expired'));

      expect(failure.kind, FailureKind.unauthenticated);
      expect(failure.message, contains('Sign in again'));
    });

    test('an AppFailure passes through untouched', () {
      // Repositories throw these directly for guards they enforce
      // themselves -- the converted-status guard, for one -- and mapError
      // must not re-wrap them.
      const original = AppFailure(FailureKind.invalid, 'Already said it.');

      expect(identical(mapError(original), original), isTrue);
    });

    test('anything else is unknown, and never claims a write happened', () {
      final failure = mapError(Exception('boom'));

      expect(failure.kind, FailureKind.unknown);
      expect(failure.message, contains('nothing was saved'));
    });
  });

  test('toString carries the kind and the code, for the log', () {
    const failure = AppFailure(
      FailureKind.refused,
      'The database refused that.',
      code: '42501',
    );

    expect(failure.toString(), contains('refused'));
    expect(failure.toString(), contains('42501'));
  });
}
