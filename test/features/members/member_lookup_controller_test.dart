// Proves the chain wires up: the controller reaches the repository provider and
// never touches Supabase itself. The repository is overridden with a fake, so
// the test needs no network and no session.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/members/member.dart';
import 'package:logfitness_flutter/data/members/members_repository.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/features/members/member_lookup_controller.dart';

class _FakeMembersRepository implements MembersRepository {
  _FakeMembersRepository(this.rows);

  final List<Member> rows;
  String? lastQuery;

  @override
  Future<Member?> fetchById(String id) async => rows.firstOrNull;

  @override
  Future<List<Member>> searchByPhone(String phone) async {
    lastQuery = phone;
    return rows;
  }
}

Member _member() => Member(
  id: '11111111-1111-4111-8111-111111111111',
  orgId: '22222222-2222-4222-8222-222222222222',
  homeBranchId: '33333333-3333-4333-8333-333333333333',
  memberCode: 'M00001',
  fullName: 'Sita Gurung',
  phone: '9801234567',
  status: MemberStatus.active,
  joinedOn: DateTime.utc(2026, 1, 12),
  createdAt: DateTime.utc(2026, 1, 12),
  updatedAt: DateTime.utc(2026, 1, 12),
);

void main() {
  late _FakeMembersRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = _FakeMembersRepository(<Member>[_member()]);
    container = ProviderContainer(
      overrides: [
        membersRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
  });

  test('starts empty rather than loading', () async {
    expect(await container.read(memberLookupProvider.future), isEmpty);
  });

  test('a search reaches the repository and surfaces its rows', () async {
    await container.read(memberLookupProvider.future);
    await container.read(memberLookupProvider.notifier).search(' 9801234567 ');

    expect(repository.lastQuery, '9801234567');
    expect(container.read(memberLookupProvider).value, hasLength(1));
  });

  test('an empty query short-circuits without hitting the repository', () async {
    await container.read(memberLookupProvider.future);
    await container.read(memberLookupProvider.notifier).search('   ');

    expect(repository.lastQuery, isNull);
    expect(container.read(memberLookupProvider).value, isEmpty);
  });
}
