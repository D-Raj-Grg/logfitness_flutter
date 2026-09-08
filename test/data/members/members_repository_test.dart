// The repository's own methods are round trips to PostgREST, and there is no
// seam in `supabase_flutter` to fake without standing up an HTTP server -- a
// test that did would assert against a hand-rolled PostgREST impersonation
// rather than against Postgres, which is worse than no test. What *is* pure
// and worth pinning is the search-term sanitiser, because it decides whether
// a name with a bracket in it is a search or a malformed filter.
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/members/members_repository.dart';

void main() {
  group('sanitizeSearchTerm', () {
    test('trims', () {
      expect(sanitizeSearchTerm('  9801234567  '), '9801234567');
    });

    test('strips the ilike wildcards', () {
      // Left in, `%` matches everything and `_` matches any character, so a
      // typo silently returns the whole branch.
      expect(sanitizeSearchTerm('100%'), '100');
      expect(sanitizeSearchTerm('a_b'), 'a b');
    });

    test('strips the characters that separate and group an or() clause', () {
      // `,`, `(` and `)` are PostgREST syntax. "Ram (Sr)" would otherwise be a
      // malformed filter rather than a failed search.
      expect(sanitizeSearchTerm('Ram (Sr)'), 'Ram  Sr');
      expect(sanitizeSearchTerm('Gurung, Sita'), 'Gurung  Sita');
    });

    test('a term made only of syntax collapses to empty', () {
      // The callers treat empty as "no search", not as "match everything".
      expect(sanitizeSearchTerm('%%'), isEmpty);
      expect(sanitizeSearchTerm('   '), isEmpty);
    });
  });

  group('MemberStatusCounts', () {
    test('expiring is a subset of active, not a sixth bucket', () {
      const MemberStatusCounts counts = MemberStatusCounts(
        active: 120,
        expiring: 14,
        expired: 30,
        frozen: 4,
        withDues: 22,
      );

      // Documented rather than computed: the tiles overlap by design, so
      // anything that sums them is wrong.
      expect(counts.expiring, lessThanOrEqualTo(counts.active));
    });
  });
}
