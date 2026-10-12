// The check-in console.
//
// The counter's busiest screen, so it is built around one thing: type a phone
// number, see who it is and what is true about them, check them in. The status
// banner is the point, not decoration — the database records the visit either
// way, and telling the desk that this member expired last week is the entire
// value the software adds at the door.
//
// A widget that builds a PostgREST query is a review failure (PLANNING.md §6).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/data/attendance/attendance_rpc_results.dart';
import 'package:logfitness_flutter/data/members/member_overview.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/format/money.dart';
import 'package:logfitness_flutter/features/attendance/check_in_controller.dart';
import 'package:logfitness_flutter/features/attendance/scan_check_in_screen.dart';
import 'package:logfitness_flutter/features/common/async_value_view.dart';
import 'package:logfitness_flutter/features/members/widgets/member_avatar.dart';
import 'package:logfitness_flutter/features/common/failure_snackbar.dart';
import 'package:logfitness_flutter/features/staff/branch_scope.dart';

/// What the desk is told, in words rather than enum names.
String checkInBannerLabel(CheckInBanner banner) => switch (banner) {
  CheckInBanner.active => 'Membership active',
  CheckInBanner.expiring => 'Expiring soon',
  CheckInBanner.upcoming => 'Membership not started yet',
  // Frozen is not expired, and saying so matters: a frozen member has not
  // lapsed, and telling them they have is a bad conversation to have at a
  // counter.
  CheckInBanner.frozen => 'Membership frozen',
  CheckInBanner.expired => 'Membership expired',
  CheckInBanner.none => 'No membership',
  CheckInBanner.left => 'This member has left',
};

class CheckInScreen extends ConsumerStatefulWidget {
  const CheckInScreen({super.key});

  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen> {
  final TextEditingController _search = TextEditingController();
  CheckInResult? _lastResult;

  /// This sitting's check-ins, newest first. Local and presentational: the
  /// attendance log is the record, this is just the desk's short memory.
  final List<CheckInResult> _recent = <CheckInResult>[];

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(checkInSearchProvider);
    final busy = ref.watch(checkInControllerProvider);

    final bool searching = _search.text.trim().isNotEmpty;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        // Unique hero tag: the staff shell keeps every destination mounted, so
        // two default-tagged FABs land in one route subtree and Flutter
        // asserts. Not a test artefact — it throws in the running app too.
        heroTag: 'check-in-scan-fab',
        // The reason to reach for the phone at all. Search stays the fallback
        // for a member whose screen is dead or who never opened the app.
        onPressed: () => Navigator.of(context).push<void>(
          MaterialPageRoute<void>(builder: (_) => const ScanCheckInScreen()),
        ),
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Scan'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Brand.spaceMd,
              Brand.spaceMd,
              Brand.spaceMd,
              Brand.spaceSm,
            ),
            child: TextField(
              controller: _search,
              // Deliberately not autofocused. The shell keeps every
              // destination mounted in an IndexedStack, so an autofocus here
              // fires on mount rather than on arrival: it raised the keypad
              // over whichever screen the shell had actually opened on, and
              // nothing put it away again. The desk taps the field.
              keyboardType: TextInputType.phone,
              // TextField only unfocuses on an outside tap on desktop by
              // default, so on a phone the keypad stayed up over the results
              // it was covering. Taps outside the field now dismiss it.
              onTapOutside: (_) => FocusScope.of(context).unfocus(),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                // Phone is the identity anchor (PLANNING.md §5) and what the
                // desk is told at the door.
                labelText: 'Phone, name or member code',
                suffixIcon: _search.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        tooltip: 'Clear search',
                        onPressed: () {
                          _search.clear();
                          ref.read(checkInSearchProvider.notifier).clear();
                          setState(() => _lastResult = null);
                        },
                      ),
              ),
              onChanged: (String value) {
                setState(() {});
                ref.read(checkInSearchProvider.notifier).search(value);
              },
            ),
          ),
          if (_lastResult != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Brand.spaceMd,
                Brand.spaceXs,
                Brand.spaceMd,
                Brand.spaceSm,
              ),
              child: CheckInOutcomeCard(
                result: _lastResult,
                onDismiss: () => setState(() => _lastResult = null),
              ),
            ),
          Expanded(
            child: searching
                ? AsyncValueView<List<MemberOverview>>(
                    value: results,
                    isEmpty: (List<MemberOverview> rows) => rows.isEmpty,
                    emptyMessage: 'Nobody matches that.',
                    data: (List<MemberOverview> rows) => ListView.separated(
                      // Scrolling the results is the other way the desk says
                      // it is done typing.
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(
                        Brand.spaceMd,
                        0,
                        Brand.spaceMd,
                        // Clear of the Scan button.
                        88,
                      ),
                      itemCount: rows.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: Brand.spaceSm),
                      itemBuilder: (BuildContext context, int index) {
                        final MemberOverview member = rows[index];
                        return _MemberCard(
                          member: member,
                          busy: busy,
                          large: rows.length == 1,
                          onCheckIn: () => _checkIn(member),
                        );
                      },
                    ),
                  )
                : _Recent(recent: _recent),
          ),
        ],
      ),
    );
  }

  Future<void> _checkIn(MemberOverview member, {String? overrideReason}) async {
    final scope = ref.read(branchScopeProvider);
    // The branch the desk is standing in. A selected branch wins; otherwise
    // the member's home branch, which is what a single-branch gym always
    // means.
    final branchId = scope.selectedBranchId ?? member.homeBranchId;

    final outcome = await ref
        .read(checkInControllerProvider.notifier)
        .checkIn(
          memberId: member.id,
          branchId: branchId,
          overrideReason: overrideReason,
        );

    if (!mounted) {
      return;
    }

    switch (outcome) {
      case CheckInRecorded(:final result):
        // Clear the box so the next person in the queue can be typed straight
        // away; the banner above stays until the next result replaces it.
        _search.clear();
        ref.read(checkInSearchProvider.notifier).clear();
        FocusScope.of(context).unfocus();
        setState(() {
          _lastResult = result;
          _recent.insert(0, result);
          if (_recent.length > 8) {
            _recent.removeLast();
          }
        });
      case CheckInDuplicate(:final result):
        final reason = await _askOverrideReason(context, result);
        if (reason != null && mounted) {
          await _checkIn(member, overrideReason: reason);
        }
      case CheckInFailed(:final failure):
        showFailureSnackBar(context, failure);
    }
  }

  Future<String?> _askOverrideReason(
    BuildContext context,
    CheckInResult result,
  ) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Already checked in today'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '${result.member?.fullName ?? 'This member'} has already been '
              'checked in today. Record a second visit?',
            ),
            const SizedBox(height: Brand.spaceMd),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Reason',
                // The database refuses an override without one. That is what
                // makes it auditable rather than invisible.
                helperText: 'Required — this is recorded against the visit',
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final reason = controller.text.trim();
              if (reason.isNotEmpty) {
                Navigator.of(context).pop(reason);
              }
            },
            child: const Text('Check in again'),
          ),
        ],
      ),
    );
  }
}

/// Colour, icon and words for each membership state. Strong and distinct so a
/// glance across a counter reads it: good, nearly over, stopped, or paused.
({Color bg, Color fg, IconData icon}) _tone(
  ColorScheme scheme,
  CheckInBanner? banner,
) => switch (banner) {
  CheckInBanner.active => (
    bg: scheme.tertiaryContainer,
    fg: scheme.onTertiaryContainer,
    icon: Icons.check_circle,
  ),
  CheckInBanner.expiring => (
    bg: scheme.primaryContainer,
    fg: scheme.onPrimaryContainer,
    icon: Icons.schedule,
  ),
  CheckInBanner.frozen || CheckInBanner.upcoming => (
    bg: scheme.secondaryContainer,
    fg: scheme.onSecondaryContainer,
    icon: Icons.pause_circle,
  ),
  CheckInBanner.expired || CheckInBanner.none || CheckInBanner.left => (
    bg: scheme.errorContainer,
    fg: scheme.onErrorContainer,
    icon: Icons.cancel,
  ),
  null => (
    bg: scheme.surfaceContainerHighest,
    fg: scheme.onSurfaceVariant,
    icon: Icons.help_outline,
  ),
};

/// What the desk will be told once this member is checked in, worked out from
/// the overview row so the status is visible *before* the tap. The result
/// that comes back from `check_in_member` is still the authority; this only
/// mirrors its rules (expiring = within seven days of the end date).
CheckInBanner _bannerFor(MemberOverview m) {
  if (m.status == MemberStatus.left) {
    return CheckInBanner.left;
  }
  return switch (m.membershipStatus) {
    null => CheckInBanner.none,
    MembershipStatus.upcoming => CheckInBanner.upcoming,
    MembershipStatus.frozen => CheckInBanner.frozen,
    MembershipStatus.expired ||
    MembershipStatus.cancelled => CheckInBanner.expired,
    MembershipStatus.active =>
      (m.daysToExpiry != null && m.daysToExpiry! <= 7)
          ? CheckInBanner.expiring
          : CheckInBanner.active,
  };
}

/// A short, plain status for a result row: "Active", "Expires in 3 days".
String _statusLine(MemberOverview m, CheckInBanner banner) {
  final int? days = m.daysToExpiry;
  if (banner == CheckInBanner.expiring && days != null) {
    return switch (days) {
      0 => 'Expires today',
      1 => 'Expires tomorrow',
      _ => 'Expires in $days days',
    };
  }
  if (banner == CheckInBanner.expired && days != null && days < 0) {
    final int ago = -days;
    return 'Expired ${ago == 1 ? 'yesterday' : '$ago days ago'}';
  }
  return switch (banner) {
    CheckInBanner.active => 'Active',
    CheckInBanner.expiring => 'Expiring soon',
    CheckInBanner.upcoming => 'Not started yet',
    CheckInBanner.frozen => 'Frozen',
    CheckInBanner.expired => 'Expired',
    CheckInBanner.none => 'No membership',
    CheckInBanner.left => 'Has left',
  };
}

/// A search result: who, what is true about them, and one big way to check
/// them in. A lone result (the usual case after typing a phone number) gets
/// the full-width button.
class _MemberCard extends StatelessWidget {
  const _MemberCard({
    required this.member,
    required this.busy,
    required this.large,
    required this.onCheckIn,
  });

  final MemberOverview member;
  final bool busy;
  final bool large;
  final VoidCallback onCheckIn;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final CheckInBanner banner = _bannerFor(member);
    final tone = _tone(scheme, banner);
    final bool owes = member.duePaisa > 0;

    final Widget status = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Brand.spaceSm + Brand.spaceXs,
        vertical: Brand.spaceXs + 2,
      ),
      decoration: BoxDecoration(
        color: tone.bg,
        borderRadius: BorderRadius.circular(Brand.radiusLarge),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(tone.icon, size: 18, color: tone.fg),
          const SizedBox(width: Brand.spaceXs + 2),
          Flexible(
            child: Text(
              _statusLine(member, banner),
              style: theme.textTheme.labelLarge?.copyWith(color: tone.fg),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    final Widget dues = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Brand.spaceSm + Brand.spaceXs,
        vertical: Brand.spaceXs + 2,
      ),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(Brand.radiusSmall),
      ),
      child: Text(
        // Surfaced before the check-in, not after: the desk can ask for the
        // money while the member is standing there.
        '${formatMoney(member.duePaisa)} outstanding',
        style: theme.textTheme.labelLarge?.copyWith(
          color: scheme.onErrorContainer,
        ),
      ),
    );

    final Widget identity = Row(
      children: <Widget>[
        MemberAvatar(fullName: member.fullName, photoPath: member.photoPath),
        const SizedBox(width: Brand.spaceMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                member.fullName,
                style: large
                    ? theme.textTheme.titleLarge
                    : theme.textTheme.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${member.memberCode} · ${member.phone}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );

    final Widget button = SizedBox(
      width: large ? double.infinity : null,
      height: large ? 56 : null,
      child: FilledButton(
        onPressed: busy ? null : onCheckIn,
        style: large
            ? FilledButton.styleFrom(
                textStyle: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              )
            : null,
        child: const Text('Check in'),
      ),
    );

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(Brand.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            identity,
            const SizedBox(height: Brand.spaceSm + Brand.spaceXs),
            Wrap(
              spacing: Brand.spaceSm,
              runSpacing: Brand.spaceSm,
              children: <Widget>[status, if (owes) dues],
            ),
            const SizedBox(height: Brand.spaceMd),
            if (large)
              button
            else
              Align(alignment: Alignment.centerRight, child: button),
          ],
        ),
      ),
    );
  }
}

/// The desk's short memory, shown when the search box is empty.
class _Recent extends StatelessWidget {
  const _Recent({required this.recent});

  final List<CheckInResult> recent;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    if (recent.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(Brand.spaceXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.dialpad, size: 40, color: scheme.onSurfaceVariant),
            const SizedBox(height: Brand.spaceMd),
            Text(
              'Type a phone number to find a member.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 88),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Brand.spaceMd,
            Brand.spaceSm,
            Brand.spaceMd,
            Brand.spaceXs,
          ),
          child: Text(
            'Checked in this session',
            style: theme.textTheme.titleSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
        for (final CheckInResult r in recent)
          Builder(
            builder: (BuildContext context) {
              final tone = _tone(scheme, r.banner);
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Brand.spaceMd,
                  vertical: Brand.spaceSm,
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: tone.bg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(tone.icon, size: 18, color: tone.fg),
                    ),
                    const SizedBox(width: Brand.spaceMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            r.member?.fullName ?? 'Member',
                            style: theme.textTheme.titleSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            <String>[
                              if (r.banner != null)
                                checkInBannerLabel(r.banner!),
                              if (r.member?.memberCode != null)
                                r.member!.memberCode!,
                            ].join(' · '),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (r.duePaisa > 0) ...<Widget>[
                      const SizedBox(width: Brand.spaceSm),
                      Text(
                        formatMoney(r.duePaisa),
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: scheme.error,
                          fontFeatures: const <FontFeature>[
                            FontFeature.tabularFigures(),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}

/// The big answer after a check-in: who, and the state of their membership in
/// the colour and size a desk can read from across the counter, with any dues
/// in their own block. Also carries a plain message (a refused scan, a
/// duplicate) when there is no result to show.
class CheckInOutcomeCard extends StatelessWidget {
  const CheckInOutcomeCard({
    required this.onDismiss,
    this.result,
    this.message,
    super.key,
  });

  final CheckInResult? result;
  final String? message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    // A message with no result is a refusal or a duplicate: stop-colour.
    final tone = message != null
        ? _tone(scheme, CheckInBanner.expired)
        : _tone(scheme, result?.banner);
    final String name = result?.member?.fullName ?? 'Member';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Brand.spaceMd),
      decoration: BoxDecoration(
        color: tone.bg,
        borderRadius: BorderRadius.circular(Brand.radiusLarge),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(tone.icon, size: 40, color: tone.fg),
          const SizedBox(width: Brand.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (message != null)
                  Text(
                    message!,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: tone.fg,
                    ),
                  )
                else ...<Widget>[
                  Text(
                    '$name checked in',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: tone.fg,
                    ),
                  ),
                  if (result?.banner != null)
                    Text(
                      checkInBannerLabel(result!.banner!),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: tone.fg,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  if ((result?.duePaisa ?? 0) > 0) ...<Widget>[
                    const SizedBox(height: Brand.spaceSm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Brand.spaceSm + Brand.spaceXs,
                        vertical: Brand.spaceXs + 2,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.error,
                        borderRadius: BorderRadius.circular(Brand.radiusSmall),
                      ),
                      child: Text(
                        '${formatMoney(result!.duePaisa)} outstanding',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: scheme.onError,
                        ),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: tone.fg),
            onPressed: onDismiss,
            tooltip: 'Dismiss',
          ),
        ],
      ),
    );
  }
}
