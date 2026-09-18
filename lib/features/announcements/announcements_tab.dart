// The announcements list.
//
// Mirrors `app/(app)/announcements/page.tsx` and its table. The second tab of
// the Messages destination: the first answers "did last night's reminders go
// out", this one answers "what have we told everybody, and has it arrived yet".
//
// A widget that builds a PostgREST query is a review failure (PLANNING.md §6):
// everything here goes through the controllers in this folder.
//
// NO "no gateway is set up yet" BANNER, for the reason written out at length in
// `notification_log_screen.dart`: `notification_providers` has an owner-only
// SELECT policy, so a manager or a desk reading it gets an empty list rather
// than a refusal, and a banner derived from that would tell a gym with three
// working gateways that it has none.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/data/announcements/announcement_overview.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/features/announcements/announcement_composer_screen.dart';
import 'package:logfitness_flutter/features/announcements/announcement_list_controller.dart';
import 'package:logfitness_flutter/features/announcements/announcement_live_refresh.dart';
import 'package:logfitness_flutter/features/announcements/send_announcement_controller.dart';
import 'package:logfitness_flutter/features/announcements/widgets/announcement_tile.dart';
import 'package:logfitness_flutter/features/announcements/widgets/cancel_announcement_dialog.dart';
import 'package:logfitness_flutter/features/common/async_value_view.dart';
import 'package:logfitness_flutter/features/common/docked_action.dart';
import 'package:logfitness_flutter/features/common/failure_snackbar.dart';
import 'package:logfitness_flutter/features/staff/staff_capabilities.dart';

class AnnouncementsTab extends ConsumerStatefulWidget {
  const AnnouncementsTab({super.key});

  @override
  ConsumerState<AnnouncementsTab> createState() => _AnnouncementsTabState();
}

class _AnnouncementsTabState extends ConsumerState<AnnouncementsTab> {
  final ScrollController _scroll = ScrollController();

  /// The phone's answer to the console's `window.addEventListener('focus')`,
  /// and this tab's own rather than the host's -- see `messages_screen.dart`
  /// for why a shared one would fetch this list for somebody who never opened
  /// the tab.
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _lifecycle = AppLifecycleListener(
      onStateChange: (AppLifecycleState lifecycleState) {
        // `mounted` because a lifecycle callback can land after this route has
        // been popped but before the listener is disposed.
        if (!mounted) return;
        final AnnouncementLiveRefresh poller = ref.read(
          announcementLiveRefreshProvider.notifier,
        );
        switch (lifecycleState) {
          case AppLifecycleState.resumed:
            poller.onResumed();
          case AppLifecycleState.inactive:
          case AppLifecycleState.paused:
          case AppLifecycleState.hidden:
          case AppLifecycleState.detached:
            poller.onBackgrounded();
        }
      },
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final double remaining =
        _scroll.position.maxScrollExtent - _scroll.position.pixels;
    // Fetch before the list ends, so a scroll does not stop dead waiting for a
    // round trip. `loadMore` is a no-op when there is nothing more or a fetch
    // is already running, so firing early is cheap.
    if (remaining < 400) {
      ref.read(announcementListProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<AnnouncementListState> listing = ref.watch(
      announcementListProvider,
    );
    // Read so the poller is alive for as long as this tab is. Nothing else
    // instantiates it, and a notifier nobody watches never builds its timer.
    final AnnouncementLiveRefreshState live = ref.watch(
      announcementLiveRefreshProvider,
    );
    final bool canSend = ref
        .watch(staffCapabilitiesProvider)
        .contains(StaffCapability.sendAnnouncement);

    // An append that failed has to be said out loud: a list that silently stops
    // growing is indistinguishable from one that has ended.
    ref.listen<AsyncValue<AnnouncementListState>>(announcementListProvider, (
      AsyncValue<AnnouncementListState>? previous,
      AsyncValue<AnnouncementListState> next,
    ) {
      final AppFailure? failure = next.value?.appendFailure;
      if (failure != null && failure != previous?.value?.appendFailure) {
        showFailureSnackBar(
          context,
          failure,
          onRetry: failure.isRefusal
              ? null
              : () => ref.read(announcementListProvider.notifier).loadMore(),
        );
      }
    });

    return Scaffold(
      body: Column(
        children: <Widget>[
          _LiveRefreshLine(state: live),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () =>
                  ref.read(announcementListProvider.notifier).refresh(),
              child: AsyncValueView<AnnouncementListState>(
                value: listing,
                isEmpty: (AnnouncementListState value) => value.rows.isEmpty,
                emptyMessage:
                    'Nothing announced yet. A closure, a holiday, a change of '
                    'hours — this is where you tell everybody at once.',
                onRetry: () => ref.invalidate(announcementListProvider),
                data: (AnnouncementListState value) => ListView.separated(
                  controller: _scroll,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: value.rows.length + 1,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (BuildContext context, int index) {
                    if (index == value.rows.length) {
                      return _ListFooter(state: value);
                    }
                    final AnnouncementOverview row = value.rows[index];
                    return AnnouncementTile(
                      key: ValueKey<String>(row.id),
                      row: row,
                      onCancel: canSend && row.isCancellable
                          ? () => _cancel(row)
                          : null,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: !canSend
          ? null
          : DockedAction(
              label: 'New announcement',
              icon: Icons.campaign_outlined,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const AnnouncementComposerScreen(),
                ),
              ),
            ),
    );
  }

  Future<void> _cancel(AnnouncementOverview row) async {
    final bool confirmed = await confirmCancelAnnouncement(
      context,
      title: row.title,
      waiting: row.queued,
    );
    if (!confirmed || !mounted) return;

    final AnnouncementActionResult result = await ref
        .read(sendAnnouncementProvider.notifier)
        .cancel(row.id);
    if (!mounted) return;

    switch (result) {
      case AnnouncementFailed(:final AppFailure failure):
        showFailureSnackBar(context, failure);
      case AnnouncementCancelled(:final String message):
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      // `cancel` returns nothing else; the other two cases belong to send and
      // test. Written out rather than defaulted so a new result type is a
      // compile error here.
      case AnnouncementSent():
      case AnnouncementTested():
        break;
    }
  }
}

/// "3 still moving — this list updates itself", and what it says once it has
/// given up. Both strings are the console's, and the delivery log's.
class _LiveRefreshLine extends ConsumerWidget {
  const _LiveRefreshLine({required this.state});

  final AnnouncementLiveRefreshState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.pending == 0) {
      return const SizedBox(height: Brand.spaceXs);
    }

    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Brand.spaceMd,
        Brand.spaceSm,
        Brand.spaceMd,
        0,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: state.gaveUp
            ? TextButton(
                key: const ValueKey<String>('announcement-live-resume'),
                onPressed: () =>
                    ref.read(announcementLiveRefreshProvider.notifier).resume(),
                child: const Text('Stopped checking. Check again'),
              )
            : Text(
                '${state.pending} still going out — this list updates itself',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
      ),
    );
  }
}

class _ListFooter extends StatelessWidget {
  const _ListFooter({required this.state});

  final AnnouncementListState state;

  @override
  Widget build(BuildContext context) {
    if (state.loadingMore) {
      return const Padding(
        padding: EdgeInsets.all(Brand.spaceMd),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (!state.hasMore) return const SizedBox(height: Brand.spaceMd);
    return const SizedBox(height: Brand.spaceXl);
  }
}
