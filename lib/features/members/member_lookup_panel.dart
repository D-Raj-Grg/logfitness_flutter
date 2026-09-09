// The widget end of the Phase 1 chain: it talks to the controller and never
// to `supabase`. A widget that builds a PostgREST query is a review failure
// (PLANNING.md §6).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/data/members/member.dart';
import 'package:logfitness_flutter/features/common/async_value_view.dart';
import 'package:logfitness_flutter/features/members/member_lookup_controller.dart';

class MemberLookupPanel extends ConsumerWidget {
  const MemberLookupPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(memberLookupProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TextField(
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Find member by phone',
            hintText: '98########',
          ),
          onSubmitted: (value) =>
              ref.read(memberLookupProvider.notifier).search(value),
        ),
        const SizedBox(height: 16),
        // Routed through AsyncValueView so a `42501` arrives as a refusal
        // with its own treatment rather than as a Dart `toString()` in a
        // Text widget. A refusal that reads like a network hiccup is the
        // failure this whole surface exists to prevent.
        AsyncValueView<List<Member>>(
          value: results,
          isEmpty: (List<Member> members) => members.isEmpty,
          emptyMessage: 'No members searched yet.',
          onRetry: () => ref.invalidate(memberLookupProvider),
          data: (List<Member> members) => Column(
            children: <Widget>[
              for (final Member member in members)
                ListTile(
                  title: Text(member.fullName),
                  subtitle: Text(member.phone),
                  trailing: Text(member.status.wire),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
