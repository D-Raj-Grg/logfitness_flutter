// The two behaviours every repository leans on. `guardFailures` is the reason
// a `42501` reaches the screen instead of vanishing; `rpcParams` is the reason
// a defaulted RPC argument stays defaulted instead of being overridden with a
// NULL.
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/repository_guard.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('guardFailures', () {
    test('returns the value when nothing throws', () async {
      expect(await guardFailures(() async => 42), 42);
    });

    test('an RLS refusal reaches the caller as a refusal, not as nothing',
        () async {
      await expectLater(
        guardFailures<void>(() async {
          throw const PostgrestException(
            message: 'permission denied for table members',
            code: '42501',
          );
        }),
        throwsA(
          isA<AppFailure>()
              .having((AppFailure f) => f.kind, 'kind', FailureKind.refused)
              .having((AppFailure f) => f.isRefusal, 'isRefusal', isTrue)
              .having((AppFailure f) => f.code, 'code', '42501'),
        ),
      );
    });

    test('a duplicate phone keeps the sentence written for the desk', () async {
      await expectLater(
        guardFailures<void>(() async {
          throw const PostgrestException(
            message:
                'duplicate key value violates unique constraint '
                '"members_org_phone_key"',
            code: '23505',
          );
        }),
        throwsA(
          isA<AppFailure>()
              .having((AppFailure f) => f.kind, 'kind', FailureKind.duplicate)
              .having(
                (AppFailure f) => f.message,
                'message',
                contains('already has that phone number'),
              ),
        ),
      );
    });

    test("an RPC's own sentence is passed through, not replaced", () async {
      await expectLater(
        guardFailures<void>(() async {
          throw const PostgrestException(
            message: 'Only an active membership can be frozen',
            code: '23514',
          );
        }),
        throwsA(
          isA<AppFailure>()
              .having((AppFailure f) => f.kind, 'kind', FailureKind.invalid)
              .having(
                (AppFailure f) => f.message,
                'message',
                'Only an active membership can be frozen',
              ),
        ),
      );
    });

    test('an already-mapped failure passes through unchanged', () async {
      const AppFailure original = AppFailure(
        FailureKind.notFound,
        'That record was not found.',
      );

      await expectLater(
        guardFailures<void>(() async => throw original),
        throwsA(same(original)),
      );
    });

    test('nothing is swallowed -- an unmapped error still throws', () async {
      await expectLater(
        guardFailures<void>(() async => throw StateError('boom')),
        throwsA(isA<AppFailure>()),
      );
    });
  });

  group('rpcParams', () {
    test('omits nulls so a Postgres default stays the default', () {
      // Sending `p_method: null` would override `default 'cash'` with NULL and
      // the payment row's NOT NULL method would then fail.
      expect(
        rpcParams(<String, dynamic>{
          'p_invoice_id': 'abc',
          'p_amount_paisa': 150000,
          'p_reference_no': null,
          'p_notes': null,
        }),
        <String, dynamic>{'p_invoice_id': 'abc', 'p_amount_paisa': 150000},
      );
    });

    test('keeps a zero, which is a value and not an absence', () {
      expect(
        rpcParams(<String, dynamic>{'p_discount_paisa': 0}),
        <String, dynamic>{'p_discount_paisa': 0},
      );
    });

    test('keeps an empty list, which narrows rather than omits', () {
      expect(
        rpcParams(<String, dynamic>{'p_branch_ids': <String>[]}),
        <String, dynamic>{'p_branch_ids': <String>[]},
      );
    });

    test('leaves an all-null map empty rather than sending nulls', () {
      expect(rpcParams(<String, dynamic>{'p_on': null}), isEmpty);
    });
  });
}
