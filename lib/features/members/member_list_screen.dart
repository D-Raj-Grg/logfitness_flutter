// The member list -- the console's `/members` on a phone.
//
// The desk asks one question of this screen: find me this person. So the
// search box is the first thing on it, and it takes the three things a front
// desk is ever told -- a phone number, a member code, or a name -- because the
// repository's `or()` expands the term into all three.
//
// Archived members are absent from every chip except Archived. That is not a
// convenience: a desk that sees the people it deliberately archived is the
// defect the filter exists to prevent, and the exclusion is enforced in
// `MembersRepository.listMembers`, not here.
//
// A widget that builds a PostgREST query is a review failure (PLANNING.md §6):
// everything here goes through `member_list_controller.dart`.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/data/members/member_list_query.dart';
import 'package:logfitness_flutter/data/members/member_overview.dart';
import 'package:logfitness_flutter/data/members/members_repository.dart';
import 'package:logfitness_flutter/domain/format/money.dart';
import 'package:logfitness_flutter/domain/format/dates.dart';
import 'package:logfitness_flutter/data/photos/member_photos_repository.dart';
import 'package:logfitness_flutter/features/common/async_value_view.dart';
import 'package:logfitness_flutter/features/common/docked_action.dart';
import 'package:logfitness_flutter/features/members/widgets/member_avatar.dart';
import 'package:logfitness_flutter/features/common/failure_snackbar.dart';
import 'package:logfitness_flutter/features/members/member_detail_screen.dart';
import 'package:logfitness_flutter/features/members/member_labels.dart';
import 'package:logfitness_flutter/features/members/member_list_controller.dart';
import 'package:logfitness_flutter/features/members/register_member_screen.dart';
import 'package:logfitness_flutter/features/notifications/member_message_sheet.dart';
import 'package:logfitness_flutter/features/staff/staff_capabilities.dart';

/// The chips, in the console's order (`STATUS_OPTIONS` in
/// `components/members/member-search.tsx`). `null` leads because it is the
/// unfiltered list; Archived trails because it is the one option that widens
/// rather than narrows.
const List<MemberListFilter?> _filterChips = <MemberListFilter?>[
  null,
  MemberListFilter.active,
  MemberListFilter.expiring,
  MemberListFilter.expired,
  MemberListFilter.frozen,
  MemberListFilter.dues,
  MemberListFilter.left,
  MemberListFilter.archived,
];

/// The widget key for one chip, so a test can tap "Archived" by name.
Key memberFilterChipKey(MemberListFilter? filter) =>
    ValueKey<String>('member-filter-${filter?.wire ?? 'all'}');

class MemberListScreen extends ConsumerStatefulWidget {
  const MemberListScreen({super.key});

  @override
  ConsumerState<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends ConsumerState<MemberListScreen> {
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
    final double remaining =
        _scroll.position.maxScrollExtent - _scroll.position.pixels;
    // Fetch before the list actually ends, so a scroll does not stop dead
    // waiting for a round trip. `loadMore` is a no-op when there is nothing
    // more or a fetch is already running, so firing early is cheap.
    if (remaining < 400) {
      ref.read(memberListProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final MemberListQuery query = ref.watch(memberQueryProvider);
    final AsyncValue<MemberListState> listing = ref.watch(memberListProvider);
    // UX only. Role gating hides a button; RLS is what refuses, and its
    // refusal is always rendered (CLAUDE.md, "Role gates the shell, RLS gates
    // the data").
    final Set<StaffCapability> capabilities = ref.watch(
      staffCapabilitiesProvider,
    );
    final bool canRegister = capabilities.contains(
      StaffCapability.walkInSignup,
    );
    // The desk's real path: chase this month's dues straight off the list,
    // without opening a record it does not need to read. Same gate as the
    // profile's own action, and `member_message_target` refuses a trainer
    // independently.
    final bool canSendMessage = capabilities.contains(
      StaffCapability.sendMemberMessage,
    );

    // An append that failed has to be said out loud: a list that silently
    // stops growing is indistinguishable from one that has ended.
    ref.listen<AsyncValue<MemberListState>>(memberListProvider, (
      AsyncValue<MemberListState>? previous,
      AsyncValue<MemberListState> next,
    ) {
      final failure = next.value?.appendFailure;
      if (failure != null && failure != previous?.value?.appendFailure) {
        showFailureSnackBar(
          context,
          failure,
          // A refusal repeats identically, and offering the retry implies the
          // desk did something wrong rather than that the role or branch
          // assignment is the problem.
          onRetry: failure.isRefusal
              ? null
              : () => ref.read(memberListProvider.notifier).loadMore(),
        );
      }
    });

    return Scaffold(
      body: Column(
        children: <Widget>[
          _SearchField(
            controller: _search,
            onSubmitted: (String value) =>
                ref.read(memberQueryProvider.notifier).setQuery(value),
          ),
          _StatusChips(
            selected: query.status,
            onSelected: (MemberListFilter? filter) =>
                ref.read(memberQueryProvider.notifier).setStatus(filter),
          ),
          _CountLine(listing: listing),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(memberListProvider.notifier).refresh(),
              child: AsyncValueView<MemberListState>(
                value: listing,
                onRetry: () => ref.invalidate(memberListProvider),
                isEmpty: (MemberListState state) => state.rows.isEmpty,
                // The console's two empty copies, kept apart for the same
                // reason it keeps them apart: "nobody matched" and "nobody
                // yet" call for different next actions.
                emptyMessage: query.q.isNotEmpty || query.status != null
                    ? 'No members match. Try a shorter phone prefix or clear '
                          'the filters.'
                    : 'No members yet. Register the first member and they '
                          'will show up here.',
                emptyAction: query.q.isNotEmpty || query.status != null
                    ? FilledButton.tonal(
                        onPressed: _clearFilters,
                        child: const Text('Clear search and filters'),
                      )
                    : canRegister
                    ? FilledButton.tonal(
                        onPressed: () => _openRegister(context),
                        child: const Text('Register a member'),
                      )
                    : null,
                data: (MemberListState state) {
                  // One signing round trip for the page, not one per row.
                  final photoUrls =
                      ref
                          .watch(
                            memberPhotoUrlsProvider(
                              MemberPhotoPaths(
                                state.rows.map(
                                  (MemberOverview m) => m.photoPath,
                                ),
                              ),
                            ),
                          )
                          .value ??
                      const <String, String>{};
                  return ListView.separated(
                    controller: _scroll,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: state.rows.length + (state.loadingMore ? 1 : 0),
                    separatorBuilder: (_, _) => const Divider(
                      height: 1,
                      indent: Brand.spaceMd + 44 + Brand.spaceMd,
                      endIndent: Brand.spaceMd,
                    ),
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
                      final MemberOverview row = state.rows[index];
                      return MemberTile(
                        member: row,
                        photoUrl: photoUrls[row.photoPath],
                        onTap: () => Navigator.of(context).push<void>(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                MemberDetailScreen(memberId: row.id),
                          ),
                        ),
                        onSendMessage: !canSendMessage
                            ? null
                            : () => showMemberMessageSheet(
                                context,
                                memberId: row.id,
                                fullName: row.fullName,
                              ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      // Docked, not floating: a member's status, dues and expiry all live down
      // the right-hand edge, which is precisely where an extended FAB parks.
      bottomNavigationBar: canRegister
          ? DockedAction(
              label: 'Register',
              icon: Icons.person_add_alt,
              onPressed: () => _openRegister(context),
            )
          : null,
    );
  }

  void _clearFilters() {
    _search.clear();
    ref.read(memberQueryProvider.notifier)
      ..setQuery('')
      ..setStatus(null);
  }

  Future<void> _openRegister(BuildContext context) async {
    await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(builder: (_) => const RegisterMemberScreen()),
    );
    if (!mounted) {
      return;
    }
    // A registration that landed is a row this list does not have yet.
    await ref.read(memberListProvider.notifier).refresh();
    ref.invalidate(memberStatusCountsProvider);
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
        Brand.spaceSm,
        Brand.spaceMd,
        Brand.spaceSm,
      ),
      // Rebuilds on typing so the clear button appears as soon as there is
      // something to clear, not only after the next submit.
      child: ListenableBuilder(
        listenable: controller,
        builder: (BuildContext context, _) => TextField(
          key: const ValueKey<String>('member-search'),
          controller: controller,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            // The console's placeholder, and the three things the
            // repository's `or()` actually matches on.
            hintText: 'Phone, name, or member code',
            suffixIcon: controller.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear search',
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      controller.clear();
                      onSubmitted('');
                    },
                  ),
          ),
          onSubmitted: onSubmitted,
        ),
      ),
    );
  }
}

/// The filter row and the only place the status counts are shown: each chip
/// carries its own number, so there is no separate summary strip repeating the
/// same five facts. `expiring` is a subset of `active`, not a sixth bucket.
/// A failed count read just drops the numbers; the chips still filter.
class _StatusChips extends ConsumerWidget {
  const _StatusChips({required this.selected, required this.onSelected});

  final MemberListFilter? selected;
  final ValueChanged<MemberListFilter?> onSelected;

  static int? _countFor(MemberListFilter? filter, MemberStatusCounts? c) {
    if (c == null) {
      return null;
    }
    return switch (filter) {
      MemberListFilter.active => c.active,
      MemberListFilter.expiring => c.expiring,
      MemberListFilter.expired => c.expired,
      MemberListFilter.frozen => c.frozen,
      MemberListFilter.dues => c.withDues,
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MemberStatusCounts? counts = ref
        .watch(memberStatusCountsProvider)
        .value;
    final TextTheme text = Theme.of(context).textTheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: Brand.spaceMd),
      child: Row(
        children: <Widget>[
          for (final MemberListFilter? filter in _filterChips)
            Padding(
              padding: const EdgeInsets.only(right: Brand.spaceSm),
              child: FilterChip(
                key: memberFilterChipKey(filter),
                showCheckmark: false,
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(memberListFilterLabel(filter)),
                    if (_countFor(filter, counts) case final int n) ...<Widget>[
                      const SizedBox(width: Brand.spaceXs + 2),
                      Text(
                        '$n',
                        style: text.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontFeatures: const <FontFeature>[
                            FontFeature.tabularFigures(),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                selected: filter == selected,
                onSelected: (_) => onSelected(filter),
              ),
            ),
        ],
      ),
    );
  }
}

/// One results line under the filters. Fixed height so the list does not jump
/// when it appears.
class _CountLine extends StatelessWidget {
  const _CountLine({required this.listing});

  final AsyncValue<MemberListState> listing;

  @override
  Widget build(BuildContext context) {
    final MemberListState? state = listing.value;
    String? label;
    if (state != null && state.rows.isNotEmpty) {
      // Both numbers, because "25" alone does not say whether the desk is
      // looking at the whole filter or the first page of it.
      label = state.hasMore
          ? '${state.rows.length} of ${state.total}'
          : '${state.total} member${state.total == 1 ? '' : 's'}';
    }
    return Container(
      height: 32,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: Brand.spaceMd),
      child: label == null
          ? null
          : Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
    );
  }
}

/// One member on the list: three lines, one job each.
///
///  1. who: name, with the status mark on the right edge;
///  2. identity: code and phone, secondary;
///  3. plan: name (the only part that may be cut) and when it ends, with the
///     amount owed on the right edge, shown only when something is owed.
class MemberTile extends StatelessWidget {
  const MemberTile({
    required this.member,
    this.photoUrl,
    this.onTap,
    this.onSendMessage,
    super.key,
  });

  final MemberOverview member;

  /// Signed by the list in one round trip for the whole page -- see
  /// `memberPhotoUrlsProvider`. Null is a member with no photo, or a photo
  /// that could not be signed; both render as initials.
  final String? photoUrl;
  final VoidCallback? onTap;

  /// Texting a member is a one-tap action from the list, for the same reason
  /// dialling a walk-in is (`visitor_tile.dart`): the desk works the list, not
  /// the record. Null hides it -- the capability is checked by the caller.
  final VoidCallback? onSendMessage;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final TextTheme text = theme.textTheme;
    final TextStyle? muted = text.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 72),
        child: Padding(
          padding: const EdgeInsets.only(
            left: Brand.spaceMd,
            top: Brand.spaceSm + Brand.spaceXs,
            bottom: Brand.spaceSm + Brand.spaceXs,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // The face is the fastest identification at a counter.
              MemberAvatar(fullName: member.fullName, signedUrl: photoUrl),
              const SizedBox(width: Brand.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          flex: 3,
                          child: Text(
                            member.fullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: Brand.spaceSm),
                        Flexible(
                          flex: 2,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: MemberStatusMark(
                              status: member.status,
                              daysToExpiry: member.daysToExpiry,
                              membershipStatus: member.membershipStatus,
                              hasMembershipHistory: member.hasMembershipHistory,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      // Only ever seen under the Archived chip, where it says
                      // why these rows are missing from every other view.
                      '${member.memberCode} · ${member.phone}'
                      '${member.isArchived ? ' · Archived' : ''}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: muted,
                    ),
                    const SizedBox(height: 2),
                    // Split so the plan name is the only thing that can be
                    // cut: the date is the half that answers "do they need to
                    // renew".
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Row(
                            children: <Widget>[
                              Flexible(
                                child: Text(
                                  _planName(member),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: muted,
                                ),
                              ),
                              Text(
                                _planTail(member),
                                maxLines: 1,
                                style: muted,
                              ),
                            ],
                          ),
                        ),
                        if (member.hasDues) ...<Widget>[
                          const SizedBox(width: Brand.spaceSm),
                          Text(
                            // Money is integer paisa everywhere but here, the
                            // render boundary (CLAUDE.md).
                            'Due ${formatMoney(member.duePaisa)}',
                            maxLines: 1,
                            style: text.labelMedium?.copyWith(
                              color: scheme.error,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (onSendMessage != null)
                IconButton(
                  key: ValueKey<String>('member-send-sms-${member.id}'),
                  onPressed: onSendMessage,
                  icon: const Icon(Icons.sms_outlined),
                  tooltip: 'Send ${member.fullName} an SMS',
                  // 48dp target, flush to the edge so the status and dues
                  // above it keep one right margin.
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                )
              else
                const SizedBox(width: Brand.spaceMd),
            ],
          ),
        ),
      ),
    );
  }

  /// The part that may be truncated: the plan's own name.
  static String _planName(MemberOverview member) =>
      member.currentPlanName ?? 'No plan';

  /// The part that must survive: when it ends, or what is left of it.
  static String _planTail(MemberOverview member) {
    if (member.currentPlanName == null) {
      return '';
    }
    final DateTime? ends = member.membershipEndDate;
    if (ends != null) {
      // A `date` column: formatted with no timezone shift, because a calendar
      // day moved by an offset is simply the wrong day (see plain_date.dart).
      return ' · ends ${formatPlainDate(ends)}';
    }
    final int? sessions = member.sessionsRemaining;
    if (sessions != null) {
      return ' · $sessions sessions left';
    }
    return ' · no end date';
  }
}
