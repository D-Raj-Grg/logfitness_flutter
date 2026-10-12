// The administrative actions for one member: edit, archive or restore, invite
// into the member app, and the access card they tap at the door.
//
// Deliberately separate from the membership lifecycle panel. Those actions
// change what a member *has*; these change what the gym *knows about* them or
// whether they appear in a list. Putting them in one stack would make
// archiving look like the same class of action as cancelling a membership,
// which it is not.
//
// Composes into a scrolling host — see the note on the class.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/data/members/member.dart';
import 'package:logfitness_flutter/data/members/member_card.dart';
import 'package:logfitness_flutter/data/members/member_cards_repository.dart';
import 'package:logfitness_flutter/domain/format/dates.dart';
import 'package:logfitness_flutter/features/common/failure_snackbar.dart';
import 'package:logfitness_flutter/features/members/member_admin_controller.dart';
import 'package:logfitness_flutter/features/members/member_card_sheet.dart';
import 'package:logfitness_flutter/features/members/member_edit_screen.dart';
import 'package:logfitness_flutter/features/staff/staff_capabilities.dart';

/// Actions for one member.
///
/// **Mounting contract:** this is a [Column], not a scrollable. Place it
/// inside something that scrolls — nesting a scrollable inside another one is
/// the alternative and it is worse.
class MemberAdminPanel extends ConsumerWidget {
  const MemberAdminPanel({required this.member, super.key});

  final Member member;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capabilities = ref.watch(staffCapabilitiesProvider);
    final busy = ref.watch(memberAdminProvider);

    // UX only. RLS is the boundary and refuses independently; a hidden button
    // is a courtesy, never an access control (CLAUDE.md).
    final canManage = capabilities.contains(StaffCapability.manageMembers);
    // A card is a way of checking in, so whoever may check a member in may
    // hand them one: front desk and up, as `jwt_can_serve_members()` says.
    final canIssueCard = capabilities.contains(StaffCapability.checkIn);

    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    final List<Widget> tiles = <Widget>[
      ListTile(
        key: const ValueKey<String>('member-edit'),
        leading: const Icon(Icons.edit_outlined),
        title: const Text('Edit details'),
        subtitle: const Text('Name, phone, contact and message consent'),
        onTap: busy ? null : () => _edit(context),
      ),
      if (member.email != null && member.email!.trim().isNotEmpty)
        ListTile(
          key: const ValueKey<String>('member-invite'),
          leading: const Icon(Icons.phone_iphone),
          title: Text(
            member.hasPendingInvite
                ? 'Resend app invitation'
                : 'Invite to the member app',
          ),
          subtitle: Text(
            member.acceptedAt != null ? 'Already using the app' : member.email!,
          ),
          // Already linked means there is nothing to send.
          onTap: busy || member.acceptedAt != null
              ? null
              : () => _invite(context, ref),
        ),
      if (canIssueCard) _accessCardTile(context, ref, busy),
      if (canManage && member.isArchived)
        ListTile(
          key: const ValueKey<String>('member-restore'),
          leading: const Icon(Icons.unarchive_outlined),
          title: const Text('Restore to the working list'),
          subtitle: Text(
            member.archivedReason == null
                ? 'Archived'
                : 'Archived: ${member.archivedReason}',
          ),
          onTap: busy ? null : () => _restore(context, ref),
        )
      else if (canManage)
        ListTile(
          key: const ValueKey<String>('member-archive'),
          leading: const Icon(Icons.archive_outlined),
          title: const Text('Archive'),
          // Says what it does, because "archive" next to "cancel" reads
          // like a delete to someone moving quickly.
          subtitle: const Text(
            'Hides them from lists. No membership, invoice or payment is '
            'touched, and it can be undone.',
          ),
          onTap: busy ? null : () => _archive(context, ref),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Brand.spaceXs,
            Brand.spaceMd,
            Brand.spaceXs,
            Brand.spaceSm,
          ),
          child: Text(
            'Member record',
            style: theme.textTheme.titleSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
        Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          clipBehavior: Clip.antiAlias,
          color: scheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Brand.radiusMedium),
            side: BorderSide(color: scheme.outlineVariant),
          ),
          child: Column(
            children: <Widget>[
              for (int i = 0; i < tiles.length; i++) ...<Widget>[
                if (i > 0) const Divider(height: 1),
                tiles[i],
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _accessCardTile(BuildContext context, WidgetRef ref, bool busy) {
    final AsyncValue<MemberCard?> card = ref.watch(
      memberLiveCardProvider(member.id),
    );
    final MemberCard? live = card.value;

    final String subtitle = switch (card) {
      AsyncData(value: final MemberCard c) =>
        'Card ${c.cardUid} · since ${formatDate(c.assignedAt)}',
      AsyncData() => 'No card. Tap to assign one.',
      AsyncError() => 'Could not load the card. Tap to retry.',
      _ => 'Loading…',
    };

    return ListTile(
      key: const ValueKey<String>('member-access-card'),
      leading: const Icon(Icons.contactless_outlined),
      title: const Text('Access card'),
      subtitle: Text(subtitle),
      trailing: live == null
          ? null
          : PopupMenuButton<_CardAction>(
              key: const ValueKey<String>('member-access-card-menu'),
              enabled: !busy,
              tooltip: 'Card actions',
              onSelected: (_CardAction action) => switch (action) {
                _CardAction.replace => _assignCard(context, live.cardUid),
                _CardAction.revoke => _revokeCard(context, ref, live.cardUid),
              },
              itemBuilder: (BuildContext context) =>
                  const <PopupMenuEntry<_CardAction>>[
                    PopupMenuItem<_CardAction>(
                      value: _CardAction.replace,
                      child: Text('Replace card'),
                    ),
                    PopupMenuItem<_CardAction>(
                      value: _CardAction.revoke,
                      child: Text('Revoke card'),
                    ),
                  ],
            ),
      onTap: busy || card.isLoading
          ? null
          : card.hasError
          ? () => ref.invalidate(memberLiveCardProvider(member.id))
          : () => _assignCard(context, live?.cardUid),
    );
  }

  Future<void> _assignCard(BuildContext context, String? currentCardUid) async {
    final message = await showMemberCardSheet(
      context,
      memberId: member.id,
      fullName: member.fullName,
      currentCardUid: currentCardUid,
    );
    if (message == null || !context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _revokeCard(
    BuildContext context,
    WidgetRef ref,
    String cardUid,
  ) async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Revoke card $cardUid?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'It stops opening the door for ${member.fullName} straight '
              'away. The record of the card is kept.',
            ),
            const SizedBox(height: Brand.spaceMd),
            TextField(
              key: const ValueKey<String>('member-card-revoke-reason'),
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Reason',
                hintText: 'Lost, damaged, returned…',
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );
    final reason = controller.text;
    controller.dispose();

    if (confirmed != true || !context.mounted) {
      return;
    }

    final outcome = await ref
        .read(memberAdminProvider.notifier)
        .revokeCard(memberId: member.id, reason: reason);
    if (!context.mounted) {
      return;
    }
    switch (outcome) {
      case MemberAdminSucceeded(:final message):
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message ?? 'Card revoked')));
      case MemberAdminFailed(:final failure):
        showFailureSnackBar(context, failure);
    }
  }

  Future<void> _edit(BuildContext context) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => MemberEditScreen(member: member)),
    );
  }

  Future<void> _invite(BuildContext context, WidgetRef ref) async {
    final outcome = await ref
        .read(memberAdminProvider.notifier)
        .inviteToApp(memberId: member.id, email: member.email!.trim());
    if (!context.mounted) {
      return;
    }
    switch (outcome) {
      case MemberAdminSucceeded(:final message):
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          // Says which address it went to: a typo is otherwise only discovered
          // when the member says they never got it.
          ..showSnackBar(SnackBar(content: Text(message ?? 'Invitation sent')));
      case MemberAdminFailed(:final failure):
        showFailureSnackBar(context, failure);
    }
  }

  Future<void> _archive(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Archive ${member.fullName}?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'They stop appearing in lists and searches. Their memberships, '
              'invoices and payments are all kept, and this can be undone.',
            ),
            const SizedBox(height: Brand.spaceMd),
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Reason (optional)'),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Archive'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final reason = controller.text.trim();
    final outcome = await ref
        .read(memberAdminProvider.notifier)
        .archive(member.id, reason: reason.isEmpty ? null : reason);
    if (!context.mounted) {
      return;
    }
    switch (outcome) {
      case MemberAdminSucceeded():
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text('${member.fullName} archived')),
          );
      case MemberAdminFailed(:final failure):
        showFailureSnackBar(context, failure);
    }
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    final outcome = await ref
        .read(memberAdminProvider.notifier)
        .restore(member.id);
    if (!context.mounted) {
      return;
    }
    switch (outcome) {
      case MemberAdminSucceeded():
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text('${member.fullName} restored')),
          );
      case MemberAdminFailed(:final failure):
        showFailureSnackBar(context, failure);
    }
  }
}

enum _CardAction { replace, revoke }
