// Phase 1 placeholder controller. It exists to prove the widget -> controller
// -> repository -> supabase chain end to end (PLANNING.md §6); the real member
// search lands in Phase 5.
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:logfitness_flutter/data/members/member.dart';
import 'package:logfitness_flutter/data/members/members_repository.dart';

part 'member_lookup_controller.g.dart';

@riverpod
class MemberLookup extends _$MemberLookup {
  /// Nothing is searched until the counter types a phone number, so the
  /// initial state is an empty result rather than a loading spinner.
  @override
  Future<List<Member>> build() async => const <Member>[];

  Future<void> search(String phone) async {
    if (phone.trim().isEmpty) {
      state = const AsyncValue<List<Member>>.data(<Member>[]);
      return;
    }

    state = const AsyncValue<List<Member>>.loading();
    state = await AsyncValue.guard(
      () => ref.read(membersRepositoryProvider).searchByPhone(phone.trim()),
    );
  }
}
