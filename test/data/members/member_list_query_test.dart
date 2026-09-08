// The filter tokens are a wire contract shared with the web console: a deep
// link one surface writes must be readable by the other, so these strings are
// pinned rather than left to `enum.name`.
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/members/member_list_query.dart';

void main() {
  test('the filter tokens match the console query string exactly', () {
    expect(
      MemberListFilter.values.map((MemberListFilter f) => f.wire).toList(),
      <String>[
        'active',
        'expired',
        'frozen',
        'left',
        'expiring',
        'dues',
        'archived',
      ],
    );
  });

  test('a default query asks for page one, no filter, no term', () {
    const MemberListQuery query = MemberListQuery();

    expect(query.q, '');
    // Null, not `active`: no chip selected shows everyone who is not archived.
    expect(query.status, isNull);
    expect(query.page, 1);
    expect(query.pageSize, defaultMemberPageSize);
  });

  test('the page sizes match the console control', () {
    expect(memberPageSizes, <int>[10, 25, 50, 100]);
    expect(memberPageSizes, contains(defaultMemberPageSize));
  });
}
