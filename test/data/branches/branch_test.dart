import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/branches/branch.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';

void main() {
  test('Branch.fromJson maps a realistic PostgREST row', () {
    final branch = Branch.fromJson(<String, dynamic>{
      'id': '11111111-1111-1111-1111-111111111111',
      'org_id': '22222222-2222-2222-2222-222222222222',
      'name': 'Thamel',
      'status': 'active',
      'address': 'Thamel Marg',
      'phone': '9801111111',
      'opens_at': '06:00:00',
      'closes_at': '21:00:00',
      'created_at': '2026-01-02T03:04:05Z',
      'updated_at': '2026-01-02T03:04:05Z',
    });

    expect(branch.name, 'Thamel');
    expect(branch.status, BranchStatus.active);
    expect(branch.isActive, isTrue);
    // `time` columns stay wire strings: parsing a bare HH:MM:SS into a
    // DateTime would invent a date.
    expect(branch.opensAt, '06:00:00');
  });

  test('an inactive branch still reads, because its rows still exist', () {
    final branch = Branch.fromJson(<String, dynamic>{
      'id': '11111111-1111-1111-1111-111111111111',
      'org_id': '22222222-2222-2222-2222-222222222222',
      'name': 'Closed branch',
      'status': 'inactive',
      'created_at': '2026-01-02T03:04:05Z',
      'updated_at': '2026-01-02T03:04:05Z',
    });

    expect(branch.status, BranchStatus.inactive);
    expect(branch.isActive, isFalse);
  });

  test('BranchStatus covers the whole Postgres enum', () {
    expect(
      BranchStatus.values.map((e) => e.wire).toSet(),
      <String>{'active', 'inactive'},
    );
  });

  test('an unknown status fails loudly rather than defaulting', () {
    expect(
      () => BranchStatus.fromDb('archived'),
      throwsA(isA<UnknownEnumValue>()),
    );
  });
}
