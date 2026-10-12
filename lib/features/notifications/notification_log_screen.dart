// The delivery log.
//
// The question this screen answers is the one an owner asks the morning after
// a sweep: did last night's reminders actually go out, and if not, why not. So
// the four counts lead, the live-refresh line sits under them saying whether
// what is on screen is still moving, and the rows are the console's
// `/notifications` table rewritten for a thumb.
//
// A widget that builds a PostgREST query is a review failure (PLANNING.md §6):
// everything here goes through the controllers in this folder.
//
// NO "no gateway is set up yet" BANNER, deliberately. `notification_providers`
// has an owner-only SELECT policy, so a manager's read of it comes back **empty
// rather than refused** -- and a manager is exactly who this screen is for
// besides the owner. A banner derived from that read would tell a manager that
// a gym with three working gateways has none. The place to say it is the
// owner-only settings screen, which is another sub-project's surface.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/data/notifications/notification_message.dart';
import 'package:logfitness_flutter/data/notifications/notification_queries.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/features/common/async_value_view.dart';
import 'package:logfitness_flutter/features/common/failure_snackbar.dart';
import 'package:logfitness_flutter/features/notifications/notification_actions_controller.dart';
import 'package:logfitness_flutter/features/notifications/notification_labels.dart';
import 'package:logfitness_flutter/features/notifications/notification_live_refresh.dart';
import 'package:logfitness_flutter/features/notifications/notification_log_controller.dart';
import 'package:logfitness_flutter/features/notifications/widgets/notification_filter_sheet.dart';
import 'package:logfitness_flutter/features/notifications/widgets/notification_tile.dart';
import 'package:logfitness_flutter/features/staff/staff_capabilities.dart';

class NotificationLogScreen extends ConsumerStatefulWidget {
  const NotificationLogScreen({super.key});

  @override
  ConsumerState<NotificationLogScreen> createState() =>
      _NotificationLogScreenState();
}

class _NotificationLogScreenState extends ConsumerState<NotificationLogScreen> {
  final ScrollController _scroll = ScrollController();
  final TextEditingController _search = TextEditingController();

  /// The phone's answer to the console's `window.addEventListener('focus')`.
  ///
  /// `AppLifecycleListener` (Flutter 3.13+), not `WidgetsBindingObserver`:
  /// CLAUDE.md's "Flutter 3.38 / Dart 3.10 differ from training data" rule
  /// names that older idiom specifically.
  ///
  /// It stayed here when this screen became one of two tabs (2026-09-18), and
  /// `messages_screen.dart` records the attempt to hoist it: a host that poked
  /// both pollers would *build* the announcements one, and building it fetches
  /// a list the reader may have no tab for. A listener that lives with the
  /// thing it drives cannot make that mistake.
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
        final NotificationLiveRefresh poller = ref.read(
          notificationLiveRefreshProvider.notifier,
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
    _search.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final double remaining =
        _scroll.position.maxScrollExtent - _scroll.position.pixels;
    // Fetch before the list actually ends, so a scroll does not stop dead
    // waiting for a round trip. `loadMore` is itself a no-op when there is
    // nothing more or a fetch is already running, so firing early is cheap.
    if (remaining < 400) {
      ref.read(notificationLogProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final NotificationListFilter filter = ref.watch(notificationFilterProvider);
    final AsyncValue<NotificationLogState> listing = ref.watch(
      notificationLogProvider,
    );
    // Read so the poller is alive for as long as this screen is. Nothing else
    // instantiates it, and a notifier nobody watches never builds its timer.
    final NotificationLiveRefreshState live = ref.watch(
      notificationLiveRefreshProvider,
    );
    final bool canAct = ref
        .watch(staffCapabilitiesProvider)
        .contains(StaffCapability.viewNotificationLog);

    // The shell's branch selection is the log's branch filter, and
    // `NotificationFilter.build` watches the scope itself rather than having it
    // pushed in here after the first frame -- see the comment there. So this
    // screen does not read the scope at all.

    // "Clear filters" in the sheet drops the search term too, so the field has
    // to stop showing one. Without this the box reads as a live filter that is
    // no longer being applied.
    ref.listen<NotificationListFilter>(notificationFilterProvider, (
      NotificationListFilter? previous,
      NotificationListFilter next,
    ) {
      if (next.query == null && _search.text.isNotEmpty) {
        _search.clear();
      }
    });

    // An append that failed has to be said out loud: a list that silently
    // stops growing is indistinguishable from one that has ended.
    ref.listen<AsyncValue<NotificationLogState>>(notificationLogProvider, (
      AsyncValue<NotificationLogState>? previous,
      AsyncValue<NotificationLogState> next,
    ) {
      final AppFailure? failure = next.value?.appendFailure;
      if (failure != null && failure != previous?.value?.appendFailure) {
        showFailureSnackBar(
          context,
          failure,
          onRetry: failure.isRefusal
              ? null
              : () => ref.read(notificationLogProvider.notifier).loadMore(),
        );
      }
    });

    return Scaffold(
      body: Column(
        children: <Widget>[
          _SearchRow(
            controller: _search,
            filterCount: _extraFilterCount(filter),
            onSubmitted: (String value) =>
                ref.read(notificationFilterProvider.notifier).setQuery(value),
            onOpenFilters: () => showNotificationFilterSheet(context),
          ),
          const _StatusFilterRow(),
          _ResultsLine(listing: listing, live: live),
          const Divider(height: 1),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () =>
                  ref.read(notificationLogProvider.notifier).refresh(),
              child: AsyncValueView<NotificationLogState>(
                value: listing,
                onRetry: () => ref.invalidate(notificationLogProvider),
                isEmpty: (NotificationLogState state) => state.rows.isEmpty,
                // Two different sentences, because they are two different
                // facts. "Nothing has been sent yet" about a gym that sends
                // three hundred messages a week, seen because a chip was left
                // on, is a lie the reader will believe.
                emptyMessage: filter.isFiltered
                    ? 'Nothing matches this filter.'
                    : 'Nothing has been sent yet. Reminders start going out once a '
                          'gateway is set up in Settings. Until then nothing is queued '
                          'and nothing is charged.',
                emptyAction: filter.isFiltered
                    ? TextButton(
                        onPressed: () => ref
                            .read(notificationFilterProvider.notifier)
                            .clear(),
                        child: const Text('Clear filters'),
                      )
                    : null,
                data: (NotificationLogState state) => ListView.separated(
                  controller: _scroll,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: state.rows.length + (_hasFooter(state) ? 1 : 0),
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (BuildContext context, int index) {
                    if (index >= state.rows.length) {
                      return _ListFooter(
                        state: state,
                        onRetry: () => ref
                            .read(notificationLogProvider.notifier)
                            .loadMore(),
                      );
                    }
                    final NotificationMessage message = state.rows[index];
                    return NotificationTile(
                      key: ValueKey<String>(message.id),
                      message: message,
                      // TODO(notifications): the log carries `created_by`, a
                      // staff id, and there is no staff-name repository in
                      // `lib/data/` to resolve it against -- `current_staff()`
                      // answers for the signed-in person only. Until one
                      // exists the row says "by" nobody rather than "by
                      // 3f2a-...". Reported to the orchestrator as a gap.
                      senderName: null,
                      trailing: canAct ? _RowActions(message: message) : null,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The list gets a trailing cell while a page is loading, and after one
  /// failed -- in the second case it is the retry, not a spinner.
  static bool _hasFooter(NotificationLogState state) =>
      state.loadingMore || state.appendFailure != null;

  /// How many of the sheet's filters are on, for the badge on its button.
  /// Status is excluded: it has its own visible chip row.
  static int _extraFilterCount(NotificationListFilter filter) =>
      (filter.event != null ? 1 : 0) + (filter.channel != null ? 1 : 0);
}

/// One row of status filters, with the counts folded in.
///
/// This used to be two rows -- a strip of counts and, under it, a second strip
/// of the same statuses as chips -- so every status appeared twice and the
/// screen spent its first third on controls. The counts are of the whole branch
/// scope, not of the current filter: they are the denominator the filter is
/// read against, and a "Failed 0" that only means "0 among the twelve rows
/// matching your search" is worse than no number at all.
///
/// `sending` and `cancelled` have no count (the summary only counts four), but
/// are still rows somebody may want to isolate, so they follow without one.
class _StatusFilterRow extends ConsumerWidget {
  const _StatusFilterRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final NotificationStatus? selected = ref.watch(
      notificationFilterProvider.select(
        (NotificationListFilter filter) => filter.status,
      ),
    );
    // A failed count is not worth a FailureView over a log that loaded: the
    // list underneath is the screen. The chips just lose their numbers.
    final NotificationStatusCounts? counts = ref
        .watch(notificationStatusCountsProvider)
        .value;
    final ColorScheme scheme = Theme.of(context).colorScheme;

    void select(NotificationStatus? status) =>
        ref.read(notificationFilterProvider.notifier).setStatus(status);

    // Failed is the only chip that asks for attention, and only while there is
    // something to attend to.
    final bool anyFailed =
        counts != null && counts[NotificationStatus.failed] > 0;

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Brand.spaceMd),
        children: <Widget>[
          _chip(
            key: 'notification-filter-all',
            label: 'All',
            selected: selected == null,
            onSelected: (_) => select(null),
          ),
          for (final NotificationStatus status in <NotificationStatus>[
            ...kSummaryStatuses,
            NotificationStatus.sending,
            NotificationStatus.cancelled,
          ])
            _chip(
              key: 'notification-filter-${status.name}',
              label: counts != null && kSummaryStatuses.contains(status)
                  ? '${notificationStatusShort(status)} ${counts[status]}'
                  : notificationStatusShort(status),
              selected: selected == status,
              onSelected: (bool now) => select(now ? status : null),
              alert: status == NotificationStatus.failed && anyFailed,
              scheme: scheme,
            ),
        ],
      ),
    );
  }

  static Widget _chip({
    required String key,
    required String label,
    required bool selected,
    required ValueChanged<bool> onSelected,
    bool alert = false,
    ColorScheme? scheme,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: Brand.spaceSm),
      child: Center(
        child: FilterChip(
          key: ValueKey<String>(key),
          label: Text(label),
          selected: selected,
          showCheckmark: false,
          visualDensity: VisualDensity.compact,
          side: alert && !selected && scheme != null
              ? BorderSide(color: scheme.error)
              : null,
          labelStyle: alert && !selected && scheme != null
              ? TextStyle(color: scheme.error)
              : null,
          onSelected: onSelected,
        ),
      ),
    );
  }
}

/// "134 messages", or "20 of 134", and beside it whether the list is still
/// moving. One line where there were two, and nothing at all while there is
/// nothing to say. Both live strings are the console's, verbatim.
class _ResultsLine extends ConsumerWidget {
  const _ResultsLine({required this.listing, required this.live});

  final AsyncValue<NotificationLogState> listing;
  final NotificationLiveRefreshState live;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final TextStyle? quiet = theme.textTheme.labelMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    final NotificationLogState? state = listing.value;
    // Both numbers, because "20" alone does not say whether the reader is
    // looking at the whole filter or the first page of it.
    final String? count = state == null || state.rows.isEmpty
        ? null
        : state.rows.length >= state.total
        ? '${state.total} message${state.total == 1 ? '' : 's'}'
        : '${state.rows.length} of ${state.total}';

    if (count == null && live.pending == 0) {
      return const SizedBox(height: Brand.spaceXs);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Brand.spaceMd,
        0,
        Brand.spaceMd,
        Brand.spaceXs,
      ),
      child: Row(
        children: <Widget>[
          if (count != null) Text(count, style: quiet),
          // Flexible, with the status pushed to the far edge: on a narrow
          // phone or at a larger text size the two no longer share a line, and
          // an unwrapped Row would clip the live status rather than wrap it.
          if (live.pending > 0)
            Flexible(
              child: Align(
                alignment: Alignment.centerRight,
                child: live.gaveUp
                    ? TextButton(
                        key: const ValueKey<String>('notification-live-resume'),
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () => ref
                            .read(notificationLiveRefreshProvider.notifier)
                            .resume(),
                        child: const Text(
                          'Stopped checking. Check again',
                          textAlign: TextAlign.end,
                        ),
                      )
                    : Text(
                        '${live.pending} still moving — this list updates '
                        'itself',
                        style: quiet,
                        textAlign: TextAlign.end,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SearchRow extends StatelessWidget {
  const _SearchRow({
    required this.controller,
    required this.filterCount,
    required this.onSubmitted,
    required this.onOpenFilters,
  });

  final TextEditingController controller;
  final int filterCount;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onOpenFilters;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Brand.spaceMd,
        Brand.spaceSm,
        Brand.spaceSm,
        Brand.spaceSm,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              key: const ValueKey<String>('notification-search'),
              controller: controller,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                // Number or wording: the log is searched either by who was
                // meant to get it or by what it said, and `to_address` and
                // `body` are the two columns the query covers.
                hintText: 'Number, address or wording',
                isDense: true,
                // Rebuilt off the controller itself. Reading `controller.text`
                // straight into a StatelessWidget's build only re-evaluates
                // when something *else* rebuilds the parent, so the clear
                // button appeared and disappeared on the poll tick rather than
                // on the keystroke that changed the field.
                suffix: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,
                  builder: (BuildContext context, TextEditingValue value, _) =>
                      value.text.isEmpty
                      ? const SizedBox.shrink()
                      : IconButton(
                          key: const ValueKey<String>(
                            'notification-search-clear',
                          ),
                          tooltip: 'Clear the search',
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            controller.clear();
                            onSubmitted('');
                          },
                        ),
                ),
              ),
              onSubmitted: onSubmitted,
            ),
          ),
          IconButton(
            key: const ValueKey<String>('notification-filter-button'),
            tooltip: 'Reason and channel',
            onPressed: onOpenFilters,
            icon: Badge(
              // Badge only when something is on, so the button does not look
              // like it is always doing something.
              isLabelVisible: filterCount > 0,
              label: Text('$filterCount'),
              child: const Icon(Icons.tune),
            ),
          ),
        ],
      ),
    );
  }
}

/// The cell under the last row: a spinner while the next page is coming, or
/// the way to ask for it again after one did not.
class _ListFooter extends StatelessWidget {
  const _ListFooter({required this.state, required this.onRetry});

  final NotificationLogState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (state.appendFailure != null) {
      return Padding(
        padding: const EdgeInsets.all(Brand.spaceMd),
        child: Center(
          child: TextButton.icon(
            key: const ValueKey<String>('notification-append-retry'),
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            // The snackbar carried the reason; this is only the way back.
            label: const Text('Load more'),
          ),
        ),
      );
    }

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
}

/// The row's overflow menu.
///
/// Offered only to a `viewNotificationLog` holder, and only the entries the
/// row's own status actually allows -- `retry_notification` takes a failed,
/// cancelled or not-sent message and `cancel_notification` takes one that has
/// not been claimed yet. Hiding the rest is UX; the RPC is what refuses.
class _RowActions extends ConsumerWidget {
  const _RowActions({required this.message});

  final NotificationMessage message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Not `SizedBox.shrink()`: the menu's width is reserved so the times on
    // rows with and without actions line up down the right edge.
    if (!message.isResendable && !message.isCancellable) {
      return const SizedBox(width: 40);
    }

    return PopupMenuButton<String>(
      key: ValueKey<String>('notification-actions-${message.id}'),
      icon: const Icon(Icons.more_vert),
      onSelected: (String action) => _run(context, ref, action),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        if (message.isResendable)
          const PopupMenuItem<String>(
            value: 'retry',
            child: Text('Send again'),
          ),
        if (message.isCancellable)
          const PopupMenuItem<String>(value: 'cancel', child: Text('Cancel')),
      ],
    );
  }

  Future<void> _run(BuildContext context, WidgetRef ref, String action) async {
    final NotificationActions actions = ref.read(
      notificationActionsProvider.notifier,
    );
    final NotificationActionResult result = action == 'retry'
        ? await actions.retry(message.id)
        : await actions.cancel(message.id);

    if (!context.mounted) return;

    switch (result) {
      case NotificationActionSucceeded(message: final String said):
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(said)));
      case NotificationActionFailed(:final AppFailure failure):
        // Never a retry on a refusal: repeating it produces the same refusal
        // and implies the reader did something wrong rather than that the role
        // is the problem (`failure_snackbar.dart`).
        showFailureSnackBar(context, failure);
    }
  }
}
