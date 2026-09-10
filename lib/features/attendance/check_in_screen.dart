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
import 'package:logfitness_flutter/domain/format/money.dart';
import 'package:logfitness_flutter/features/attendance/check_in_controller.dart';
import 'package:logfitness_flutter/features/attendance/scan_check_in_screen.dart';
import 'package:logfitness_flutter/features/common/async_value_view.dart';
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

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(checkInSearchProvider);
    final busy = ref.watch(checkInControllerProvider);

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
            padding: const EdgeInsets.all(Brand.spaceMd),
            child: TextField(
              controller: _search,
              autofocus: true,
              keyboardType: TextInputType.phone,
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
            _ResultBanner(
              result: _lastResult!,
              onDismiss: () => setState(() => _lastResult = null),
            ),
          Expanded(
            child: AsyncValueView<List<MemberOverview>>(
              value: results,
              isEmpty: (List<MemberOverview> rows) => rows.isEmpty,
              emptyMessage: _search.text.trim().isEmpty
                  ? 'Type a phone number to find a member.'
                  : 'Nobody matches that.',
              data: (List<MemberOverview> rows) => ListView.separated(
                itemCount: rows.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (BuildContext context, int index) {
                  final MemberOverview member = rows[index];
                  return _MemberRow(
                    member: member,
                    busy: busy,
                    onCheckIn: () => _checkIn(member),
                  );
                },
              ),
            ),
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

    final outcome = await ref.read(checkInControllerProvider.notifier).checkIn(
          memberId: member.id,
          branchId: branchId,
          overrideReason: overrideReason,
        );

    if (!mounted) {
      return;
    }

    switch (outcome) {
      case CheckInRecorded(:final result):
        setState(() => _lastResult = result);
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

class _MemberRow extends StatelessWidget {
  const _MemberRow({
    required this.member,
    required this.busy,
    required this.onCheckIn,
  });

  final MemberOverview member;
  final bool busy;
  final VoidCallback onCheckIn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final owes = member.duePaisa > 0;

    return ListTile(
      title: Text(member.fullName),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('${member.memberCode} · ${member.phone}'),
          if (owes)
            Text(
              // Surfaced before the check-in, not after: the desk can ask for
              // the money while the member is standing there.
              '${formatMoney(member.duePaisa)} outstanding',
              style: TextStyle(color: theme.colorScheme.error),
            ),
        ],
      ),
      isThreeLine: owes,
      trailing: FilledButton(
        onPressed: busy ? null : onCheckIn,
        child: const Text('Check in'),
      ),
    );
  }
}

class _ResultBanner extends StatelessWidget {
  const _ResultBanner({required this.result, required this.onDismiss});

  final CheckInResult result;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final attention = result.needsAttention;

    final (Color background, Color foreground) = attention
        ? (scheme.errorContainer, scheme.onErrorContainer)
        : (scheme.primaryContainer, scheme.onPrimaryContainer);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: Brand.spaceMd),
      padding: const EdgeInsets.all(Brand.spaceMd),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(Brand.radiusMedium),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            attention ? Icons.warning_amber_rounded : Icons.check_circle_outline,
            color: foreground,
          ),
          const SizedBox(width: Brand.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${result.member?.fullName ?? 'Member'} checked in',
                  style: TextStyle(
                    color: foreground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (result.banner != null)
                  Text(
                    checkInBannerLabel(result.banner!),
                    style: TextStyle(color: foreground),
                  ),
                if (result.duePaisa > 0)
                  Text(
                    '${formatMoney(result.duePaisa)} outstanding',
                    style: TextStyle(color: foreground),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: foreground),
            onPressed: onDismiss,
            tooltip: 'Dismiss',
          ),
        ],
      ),
    );
  }
}
