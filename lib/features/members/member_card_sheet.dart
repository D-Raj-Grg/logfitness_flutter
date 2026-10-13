// Handing a member an access card.
//
// Enrolment is deliberately tap-first: the member taps their new card on the
// reader at the door, the reader does not know it and `rfid_check_in` files
// it under `unassigned_card_scans`, and the desk picks that tap here. Typing
// the number in is the fallback, for a card with the UID printed on it or a
// reader that is offline.
//
// The recent taps are scoped to the branches the shell is looking at
// (`branchScopeProvider`), and RLS bounds them again independently.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/data/members/unassigned_card_scan.dart';
import 'package:logfitness_flutter/domain/format/dates.dart';
import 'package:logfitness_flutter/features/common/async_value_view.dart';
import 'package:logfitness_flutter/features/common/failure_snackbar.dart';
import 'package:logfitness_flutter/features/members/member_admin_controller.dart';

/// Opens the sheet. Resolves to the success message when a card was
/// assigned, `null` when the desk backed out.
///
/// [currentCardUid] is the card the member already holds, if any; assigning
/// then replaces it, and the sheet says so before anything is pressed.
Future<String?> showMemberCardSheet(
  BuildContext context, {
  required String memberId,
  required String fullName,
  String? currentCardUid,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (BuildContext sheetContext) => MemberCardSheet(
      memberId: memberId,
      fullName: fullName,
      currentCardUid: currentCardUid,
    ),
  );
}

/// The sheet's contents. Public so a test can pump it without a navigator.
class MemberCardSheet extends ConsumerStatefulWidget {
  const MemberCardSheet({
    required this.memberId,
    required this.fullName,
    this.currentCardUid,
    super.key,
  });

  final String memberId;
  final String fullName;
  final String? currentCardUid;

  @override
  ConsumerState<MemberCardSheet> createState() => _MemberCardSheetState();
}

class _MemberCardSheetState extends ConsumerState<MemberCardSheet> {
  final TextEditingController _uid = TextEditingController();

  @override
  void dispose() {
    _uid.dispose();
    super.dispose();
  }

  Future<void> _assign(String cardUid) async {
    final outcome = await ref
        .read(memberAdminProvider.notifier)
        .assignCard(
          memberId: widget.memberId,
          cardUid: cardUid,
          replace: widget.currentCardUid != null,
        );
    if (!mounted) {
      return;
    }
    switch (outcome) {
      case MemberAdminSucceeded(:final message):
        Navigator.of(context).pop(message ?? 'Card assigned');
      case MemberAdminFailed(:final failure):
        showFailureSnackBar(context, failure);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final bool busy = ref.watch(memberAdminProvider);
    final AsyncValue<List<UnassignedCardScan>> scans = ref.watch(
      unassignedCardScansProvider,
    );

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          Brand.spaceMd,
          0,
          Brand.spaceMd,
          Brand.spaceMd,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              widget.currentCardUid == null
                  ? 'Assign an access card'
                  : 'Replace access card',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: Brand.spaceXs),
            Text(
              widget.currentCardUid == null
                  ? 'Ask ${widget.fullName} to tap the new card on the reader, '
                        'then pick it below.'
                  : 'Card ${widget.currentCardUid} stops working the moment '
                        'the new one is assigned.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Brand.spaceMd),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Recent unknown taps',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                IconButton(
                  key: const ValueKey<String>('member-card-refresh'),
                  tooltip: 'Check for new taps',
                  icon: const Icon(Icons.refresh),
                  onPressed: () => ref.invalidate(unassignedCardScansProvider),
                ),
              ],
            ),
            AsyncValueView<List<UnassignedCardScan>>(
              value: scans,
              onRetry: () => ref.invalidate(unassignedCardScansProvider),
              isEmpty: (List<UnassignedCardScan> rows) => rows.isEmpty,
              emptyMessage:
                  'No unknown cards tapped lately. Tap the card on a reader, '
                  'then refresh.',
              data: (List<UnassignedCardScan> rows) => Column(
                children: <Widget>[
                  for (final UnassignedCardScan scan in rows)
                    ListTile(
                      key: ValueKey<String>('member-card-scan-${scan.id}'),
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.contactless_outlined),
                      title: Text(scan.cardUid),
                      subtitle: Text(
                        <String>[
                          if (scan.deviceName != null) scan.deviceName!,
                          formatDateTime(scan.lastSeenAt),
                          if (scan.scanCount > 1) '${scan.scanCount} taps',
                        ].join(' · '),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: busy ? null : () => _assign(scan.cardUid),
                    ),
                ],
              ),
            ),
            const SizedBox(height: Brand.spaceMd),
            Text(
              'Or type the number',
              style: theme.textTheme.titleSmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Brand.spaceSm),
            TextField(
              key: const ValueKey<String>('member-card-uid'),
              controller: _uid,
              textCapitalization: TextCapitalization.characters,
              autocorrect: false,
              decoration: const InputDecoration(
                labelText: 'Card number',
                hintText: '04:A3:1B:2C',
                helperText: '8 to 20 characters, 0-9 and A-F',
              ),
              onSubmitted: busy ? null : _assign,
            ),
            const SizedBox(height: Brand.spaceMd),
            FilledButton(
              key: const ValueKey<String>('member-card-assign'),
              onPressed: busy ? null : () => _assign(_uid.text),
              child: Text(
                widget.currentCardUid == null ? 'Assign card' : 'Replace card',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
