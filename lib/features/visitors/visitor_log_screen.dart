// The visitor log.
//
// The screen answers one question a counter actually asks: who walked in that
// I still owe a call, and what is their number. So it opens on "Needs a call"
// rather than on the whole log, the phone sits on every row, and dialling is
// one tap from the list.
//
// A widget that builds a PostgREST query is a review failure (PLANNING.md §6):
// everything here goes through the controllers in this folder.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/data/visitors/visitor.dart';
import 'package:logfitness_flutter/data/visitors/visitors_repository.dart';
import 'package:logfitness_flutter/features/common/async_value_view.dart';
import 'package:logfitness_flutter/features/common/failure_snackbar.dart';
import 'package:logfitness_flutter/features/staff/branch_scope.dart';
import 'package:logfitness_flutter/features/visitors/visitor_form_screen.dart';
import 'package:logfitness_flutter/features/visitors/visitor_detail_screen.dart';
import 'package:logfitness_flutter/features/visitors/visitor_list_controller.dart';
import 'package:logfitness_flutter/features/visitors/widgets/visitor_labels.dart';
import 'package:logfitness_flutter/features/visitors/widgets/visitor_tile.dart';

/// Maps a chip to the repository filter it stands for. `all` is the absence
/// of a status filter rather than a status of its own.
VisitorStatusFilter? _filterFor(VisitorStatusFilterName name) =>
    switch (name) {
      VisitorStatusFilterName.open => VisitorStatusFilter.open,
      VisitorStatusFilterName.isNew => VisitorStatusFilter.isNew,
      VisitorStatusFilterName.contacted => VisitorStatusFilter.contacted,
      VisitorStatusFilterName.converted => VisitorStatusFilter.converted,
      VisitorStatusFilterName.lost => VisitorStatusFilter.lost,
      VisitorStatusFilterName.all => null,
    };

class VisitorLogScreen extends ConsumerStatefulWidget {
  const VisitorLogScreen({super.key});

  @override
  ConsumerState<VisitorLogScreen> createState() => _VisitorLogScreenState();
}

class _VisitorLogScreenState extends ConsumerState<VisitorLogScreen> {
  final ScrollController _scroll = ScrollController();
  final TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    _search.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) {
      return;
    }
    final remaining = _scroll.position.maxScrollExtent - _scroll.position.pixels;
    // Fetch before the list actually ends, so a scroll does not stop dead
    // waiting for a round trip. `loadMore` is itself a no-op when there is
    // nothing more or a fetch is already running, so firing early is cheap.
    if (remaining < 400) {
      ref.read(visitorListProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scope = ref.watch(branchScopeProvider);
    final filter = ref.watch(visitorFilterProvider);
    final listing = ref.watch(visitorListProvider);

    // The shell's branch selection is the log's branch filter. Pushed in a
    // post-frame callback because reading a provider is not a legal place to
    // write one, and the scope changes when someone uses the switcher.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final next = scope.effectiveBranchIds;
      if (!_sameScope(next, ref.read(visitorFilterProvider).branchIds)) {
        ref.read(visitorFilterProvider.notifier).setBranchIds(next);
      }
    });

    // An append that failed has to be said out loud: a list that silently
    // stops growing is indistinguishable from one that has ended.
    ref.listen<AsyncValue<VisitorListState>>(visitorListProvider,
        (AsyncValue<VisitorListState>? previous, AsyncValue<VisitorListState> next) {
      final failure = next.value?.appendFailure;
      if (failure != null && failure != previous?.value?.appendFailure) {
        showFailureSnackBar(
          context,
          failure,
          onRetry: failure.isRefusal
              ? null
              : () => ref.read(visitorListProvider.notifier).loadMore(),
        );
      }
    });

    return Scaffold(
      body: Column(
        children: <Widget>[
          _SearchField(
            controller: _search,
            onSubmitted: (String value) =>
                ref.read(visitorFilterProvider.notifier).setQuery(value),
          ),
          _StatusChips(
            selected: filter.status,
            onSelected: (VisitorStatusFilterName name) => ref
                .read(visitorFilterProvider.notifier)
                .setStatus(_filterFor(name)),
          ),
          _CountLine(listing: listing),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(visitorListProvider.notifier).refresh(),
              child: AsyncValueView<VisitorListState>(
                value: listing,
                onRetry: () => ref.invalidate(visitorListProvider),
                isEmpty: (VisitorListState state) => state.rows.isEmpty,
                emptyMessage: filter.status == VisitorStatusFilter.open
                    ? 'No callbacks outstanding.'
                    : 'No walk-ins logged yet.',
                emptyAction: FilledButton.tonal(
                  onPressed: () => _openForm(context),
                  child: const Text('Log a walk-in'),
                ),
                data: (VisitorListState state) => ListView.separated(
                  controller: _scroll,
                  physics: const AlwaysScrollableScrollPhysics(),
                  // Clears the FAB. Without it the extended button parks on
                  // top of the last row -- and the last row is a person with
                  // a phone number on it.
                  padding: const EdgeInsets.only(bottom: 88),
                  itemCount: state.rows.length + (state.loadingMore ? 1 : 0),
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (BuildContext context, int index) {
                    if (index >= state.rows.length) {
                      return const Padding(
                        padding: EdgeInsets.all(Brand.spaceMd),
                        child: Center(
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    }
                    final Visitor visitor = state.rows[index];
                    return VisitorTile(
                      visitor: visitor,
                      onTap: () => Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              VisitorDetailScreen(visitorId: visitor.id),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        // See the note in check_in_screen.dart: destinations share a route
        // subtree, so every FAB in the shell needs its own hero tag.
        heroTag: 'visitor-log-fab',
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.person_add_alt),
        label: const Text('Log walk-in'),
      ),
    );
  }

  Future<void> _openForm(BuildContext context) async {
    await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(builder: (_) => const VisitorFormScreen()),
    );
  }

  static bool _sameScope(List<String>? a, List<String>? b) {
    if (a == null || b == null) {
      return a == null && b == null;
    }
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onSubmitted});

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Brand.spaceMd,
        Brand.spaceMd,
        Brand.spaceMd,
        Brand.spaceSm,
      ),
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          // Name or phone, because someone who enquired last month and walks
          // back in is looked up by whichever the desk has to hand.
          hintText: 'Search name or phone',
          isDense: true,
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    controller.clear();
                    onSubmitted('');
                  },
                ),
        ),
        onSubmitted: onSubmitted,
      ),
    );
  }
}

class _StatusChips extends StatelessWidget {
  const _StatusChips({required this.selected, required this.onSelected});

  final VisitorStatusFilter? selected;
  final ValueChanged<VisitorStatusFilterName> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: Brand.spaceMd),
      child: Row(
        children: <Widget>[
          for (final VisitorStatusFilterName name
              in VisitorStatusFilterName.values)
            Padding(
              padding: const EdgeInsets.only(right: Brand.spaceSm),
              child: FilterChip(
                key: ValueKey<String>('visitor-filter-${name.name}'),
                label: Text(visitorStatusFilterLabel(name)),
                selected: _filterFor(name) == selected,
                onSelected: (_) => onSelected(name),
              ),
            ),
        ],
      ),
    );
  }
}

class _CountLine extends StatelessWidget {
  const _CountLine({required this.listing});

  final AsyncValue<VisitorListState> listing;

  @override
  Widget build(BuildContext context) {
    final state = listing.value;
    if (state == null || state.rows.isEmpty) {
      return const SizedBox(height: Brand.spaceSm);
    }

    // Both numbers, because "12" alone does not say whether the desk is
    // looking at the whole filter or the first page of it.
    final text = state.rows.length >= state.total
        ? '${state.total} walk-in${state.total == 1 ? '' : 's'}'
        : '${state.rows.length} of ${state.total}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Brand.spaceMd,
        Brand.spaceSm,
        Brand.spaceMd,
        Brand.spaceXs,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ),
    );
  }
}
