// The corrective actions for one member and their current membership.
//
// Mounted by the member detail screen; it takes the rows it acts on rather
// than fetching them, so it stays a widget and never builds a query
// (PLANNING.md §6 -- widgets call controllers, controllers call
// repositories).
//
// ---------------------------------------------------------------------------
// EVERY GATE IN THIS FILE IS UX ONLY. NONE OF THEM IS ACCESS CONTROL.
//
// CLAUDE.md: "Role gates the shell, RLS gates the data. Client-side role
// checks are UX only. Never treat a hidden button as an access control."
//
// This screen is exactly where that gets forgotten, because hiding "Refund"
// from a front desk *looks* like it stops a front desk refunding. It does
// not. `refund_payment`, `cancel_membership` and the rest are guarded in
// Postgres against the claims on the caller's JWT, and a modified client
// reaches them regardless. What this file decides is only what a person is
// *offered*.
//
// The corollary is the part that has to survive review: because the database
// refuses independently, its refusal must always reach the screen. Every
// action below routes its failure through `showFailureSnackBar`, which gives
// a `42501` the refusal treatment rather than a generic "something went
// wrong". Pairing a gate here with a silent catch is how the web console
// shipped its 2026-09-07 bug; see `lib/features/common/failure_view.dart`.
// ---------------------------------------------------------------------------
//
// The capabilities themselves are PLANNING.md §4 transcribed once, in
// `lib/features/staff/staff_capabilities.dart`. §4 gives freezes,
// cancellations and refunds to `manager` and up, which means a front desk is
// offered none of the actions on this panel.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/data/members/member.dart';
import 'package:logfitness_flutter/data/members/member_rpc_results.dart';
import 'package:logfitness_flutter/data/memberships/membership.dart';
import 'package:logfitness_flutter/data/memberships/membership_rpc_results.dart';
import 'package:logfitness_flutter/data/payments/payment.dart';
import 'package:logfitness_flutter/data/payments/payment_rpc_results.dart';
import 'package:logfitness_flutter/data/payments/payment_with_collector.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/format/dates.dart';
import 'package:logfitness_flutter/domain/format/money.dart';
import 'package:logfitness_flutter/domain/format/plain_date.dart';
import 'package:logfitness_flutter/features/common/failure_snackbar.dart';
import 'package:logfitness_flutter/features/memberships/membership_action_labels.dart';
import 'package:logfitness_flutter/features/memberships/membership_actions_controller.dart';
import 'package:logfitness_flutter/features/memberships/refund_payment_screen.dart';
import 'package:logfitness_flutter/features/staff/staff_capabilities.dart';

/// Widget keys the tests assert on, so a refactor cannot quietly start
/// offering a front desk something PLANNING.md §4 does not give them.
const Key freezeActionKey = Key('membership-action-freeze');
const Key unfreezeActionKey = Key('membership-action-unfreeze');
const Key cancelActionKey = Key('membership-action-cancel');
const Key adjustDatesActionKey = Key('membership-action-adjust-dates');
const Key markLeftActionKey = Key('membership-action-mark-left');
const Key reactivateActionKey = Key('membership-action-reactivate');
const Key refundActionKey = Key('membership-action-refund');
const Key reverseActionKey = Key('membership-action-reverse');

/// The corrective actions available on [member] and [membership].
///
/// [membership] is the member's current membership, or null when they have
/// never been sold one. [payments] is their payment history; refund and
/// reversal act on a row from it, and the panel does not read it itself
/// because the member detail screen already has it.
///
/// [onChanged] is called after any write lands, so the mounting screen can
/// re-read. It is how this panel avoids owning providers that belong to the
/// member and payment features.
///
/// Renders as an unscrollable [Column] so it composes into the member detail
/// screen's own scroll view rather than nesting a second scrollable inside
/// it. **The host must place it in something that scrolls** -- eight
/// three-line tiles do not fit a phone screen, and a bare [Column] that
/// overflows is a rendering error, not a cosmetic one.
class MembershipActionPanel extends ConsumerWidget {
  const MembershipActionPanel({
    required this.member,
    this.membership,
    this.payments = const <PaymentWithCollector>[],
    this.onChanged,
    super.key,
  });

  final Member member;
  final Membership? membership;
  final List<PaymentWithCollector> payments;
  final VoidCallback? onChanged;

  /// Only a real payment can be corrected. A refund or a reversal is already
  /// a correction, and correcting one of those is a second original entry's
  /// problem -- the console draws the same line
  /// (`payment.kind === 'payment' && payment.amount_paisa > 0`).
  List<PaymentWithCollector> get _correctable => payments
      .where((PaymentWithCollector row) =>
          row.payment.kind == PaymentKind.payment &&
          row.payment.amountPaisa > 0)
      .toList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final Set<StaffCapability> capabilities =
        ref.watch(staffCapabilitiesProvider);
    final bool busy = ref.watch(membershipActionsProvider);

    // UX only -- see the banner at the top of this file. §4 gives all three
    // of these to `manager` and above, so a front desk holds none of them and
    // this panel renders empty for them.
    final bool canFreeze =
        capabilities.contains(StaffCapability.freezeMembership);
    final bool canCancel =
        capabilities.contains(StaffCapability.cancelMembership);
    final bool canRefund =
        capabilities.contains(StaffCapability.refundPayment);
    // Adjusting a sold membership's window is free days, and free days are
    // money. §4 puts it under member management rather than under freezes,
    // and the console agrees -- `member-action-panel.tsx` gates "Adjust
    // dates" on owner-or-manager with the comment "Free days are money".
    final bool canAdjustDates =
        capabilities.contains(StaffCapability.manageMembers);

    final Membership? current = membership;
    final MembershipStatus? status = current?.status;
    final bool hasLeft = member.status == MemberStatus.left;

    final List<Widget> membershipActions = <Widget>[
      if (canFreeze && status == MembershipStatus.active)
        _ActionTile(
          actionKey: freezeActionKey,
          icon: Icons.pause_circle_outline,
          title: 'Freeze membership',
          subtitle: 'The end date stops moving until it is unfrozen. The days '
              'paused are added back on at the end.',
          enabled: !busy,
          onTap: () => _freeze(context, ref, current!),
        ),
      if (canFreeze && status == MembershipStatus.frozen)
        _ActionTile(
          actionKey: unfreezeActionKey,
          icon: Icons.play_circle_outline,
          title: 'Unfreeze membership',
          subtitle: 'Starts the clock again and pushes the end date out by '
              'however long the freeze lasted.',
          enabled: !busy,
          onTap: () => _unfreeze(context, ref, current!),
        ),
      if (canAdjustDates &&
          current != null &&
          status != MembershipStatus.cancelled)
        _ActionTile(
          actionKey: adjustDatesActionKey,
          icon: Icons.event_repeat_outlined,
          title: 'Adjust the dates',
          // Stated as a correction, because that is what it is for. A
          // routine extension is a renewal, which is a different screen and
          // raises an invoice.
          subtitle: 'A correction, not a renewal. Moves the window and '
              'records the reason. The plan, the price and the invoice do '
              'not move.',
          enabled: !busy,
          onTap: () => _adjustDates(context, ref, current),
        ),
      if (canCancel &&
          (status == MembershipStatus.active ||
              status == MembershipStatus.frozen))
        _ActionTile(
          actionKey: cancelActionKey,
          icon: Icons.cancel_outlined,
          title: 'Cancel membership',
          // The date rule stated plainly: a cancellation counts on the day it
          // was cancelled, whatever end date the row still carries.
          subtitle: 'Closes the plan today. It counts as cancelled on the day '
              'you cancel it, not on the end date it still shows.',
          destructive: true,
          enabled: !busy,
          onTap: () => _cancel(context, ref, current!),
        ),
    ];

    final List<Widget> memberActions = <Widget>[
      if (canCancel && !hasLeft)
        _ActionTile(
          actionKey: markLeftActionKey,
          icon: Icons.logout,
          title: 'Mark as left',
          subtitle: 'Records the day they left. Their history and anything '
              'they still owe are kept.',
          destructive: true,
          enabled: !busy,
          onTap: () => _markLeft(context, ref),
        ),
      if (canCancel && hasLeft)
        _ActionTile(
          actionKey: reactivateActionKey,
          icon: Icons.person_add_alt,
          title: 'Reactivate',
          // Says what actually happens rather than promising "active": the
          // status is trigger-derived, and a member with no live membership
          // comes back as expired.
          subtitle: 'Reopens the record. They will show as expired until a '
              'new plan is sold.',
          enabled: !busy,
          onTap: () => _reactivate(context, ref),
        ),
    ];

    final List<PaymentWithCollector> correctable = _correctable;

    final List<Widget> moneyActions = <Widget>[
      if (canRefund)
        _ActionTile(
          actionKey: refundActionKey,
          icon: Icons.currency_exchange,
          title: 'Refund a payment',
          subtitle: correctable.isEmpty
              ? 'Nothing collected yet, so there is nothing to refund.'
              : 'Money goes back to the member. Recorded as a separate '
                  'negative line — the original payment is never deleted or '
                  'edited.',
          destructive: true,
          enabled: !busy && correctable.isNotEmpty,
          onTap: () => _refund(context, ref, correctable),
        ),
      if (canRefund)
        _ActionTile(
          actionKey: reverseActionKey,
          // A different icon as well as different words, so the two are not
          // told apart by reading alone.
          icon: Icons.money_off_csred_outlined,
          title: 'Mark a payment as never received',
          subtitle: correctable.isEmpty
              ? 'Nothing collected yet, so there is nothing to take back.'
              : 'For an entry that was rung up but never arrived. Nothing '
                  'left the drawer, so this is not a refund — the invoice '
                  'owes it again.',
          destructive: true,
          enabled: !busy && correctable.isNotEmpty,
          onTap: () => _reverse(context, ref, correctable),
        ),
    ];

    if (membershipActions.isEmpty &&
        memberActions.isEmpty &&
        moneyActions.isEmpty) {
      // Nothing offered. Said out loud rather than rendered as blank space,
      // because a front desk looking for "Refund" needs to know it is a role
      // boundary and not a loading state. It is still not the control -- see
      // the banner above.
      return Padding(
        padding: const EdgeInsets.all(Brand.spaceMd),
        child: Text(
          'Freezes, cancellations and refunds are handled by a manager.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (membershipActions.isNotEmpty)
          _Section(title: 'Membership', children: membershipActions),
        if (memberActions.isNotEmpty)
          _Section(title: 'This member', children: memberActions),
        if (moneyActions.isNotEmpty)
          // Its own heading, because the two entries under it are the only
          // things on this panel that move money.
          _Section(title: 'Corrections to money', children: moneyActions),
      ],
    );
  }

  // --- actions ------------------------------------------------------------

  Future<void> _freeze(
    BuildContext context,
    WidgetRef ref,
    Membership current,
  ) async {
    // `freeze_membership` takes a note, not a date range: it stamps the start
    // from `org_today` and measures the elapsed days at unfreeze. There is no
    // end date to ask for, so the form does not invent one.
    final String? notes = await _showReasonDialog(
      context,
      title: 'Freeze this membership?',
      body: 'The end date stops moving from today until it is unfrozen, and '
          'the days paused are added back on at the end. Nothing is charged '
          'and nothing is refunded.',
      fieldLabel: 'Note',
      hint: 'Travelling, injury, medical leave…',
      confirmLabel: 'Freeze',
      required: false,
    );
    if (notes == null || !context.mounted) {
      return;
    }

    await _perform<FreezeMembershipResult>(
      context,
      ref,
      () => ref
          .read(membershipActionsProvider.notifier)
          .freeze(current.id, notes: notes.isEmpty ? null : notes),
      // `frozenOn` is the gym's own today, stamped by the function. Read back
      // rather than assumed, because this phone's date is not it.
      (FreezeMembershipResult value) =>
          'Frozen from ${formatPlainDate(value.frozenOn)}. '
          'The clock stops until it is unfrozen.',
    );
  }

  Future<void> _unfreeze(
    BuildContext context,
    WidgetRef ref,
    Membership current,
  ) async {
    final bool confirmed = await _confirm(
      context,
      title: 'Unfreeze this membership?',
      body: 'The membership becomes active again from today, and the end date '
          'moves out by however long the freeze lasted. The exact number of '
          'days is worked out by the gym’s own calendar, not this phone.',
      confirmLabel: 'Unfreeze',
      cancelLabel: 'Keep frozen',
    );
    if (!confirmed || !context.mounted) {
      return;
    }

    await _perform<UnfreezeMembershipResult>(
      context,
      ref,
      () => ref.read(membershipActionsProvider.notifier).unfreeze(current.id),
      // `pausedDays` is read back rather than computed here: the function
      // measured it against the org's own today.
      (UnfreezeMembershipResult value) => value.pausedDays == 0
          ? 'Active again.'
          : 'Active again. The end date moved out by '
              '${dayCount(value.pausedDays)}.',
    );
  }

  Future<void> _cancel(
    BuildContext context,
    WidgetRef ref,
    Membership current,
  ) async {
    final String? reason = await _showReasonDialog(
      context,
      title: 'Cancel this membership?',
      // Three separate facts, all of which the desk gets wrong otherwise:
      // when it counts from, that the money stays, and that a refund is a
      // separate decision.
      body: 'It closes today and counts as cancelled on today’s date, not on '
          'the ${current.endDate == null ? 'end of the pack' : formatPlainDate(current.endDate!)} '
          'it still shows.\n\n'
          'Money already taken stays on the invoice. Nothing is refunded by '
          'cancelling — record a refund separately if any is going back.',
      fieldLabel: 'Reason',
      hint: 'Why the membership is being cancelled',
      confirmLabel: 'Cancel membership',
      destructive: true,
      cancelLabel: 'Keep it',
    );
    if (reason == null || !context.mounted) {
      return;
    }

    await _perform<MembershipStatusResult>(
      context,
      ref,
      () => ref
          .read(membershipActionsProvider.notifier)
          .cancel(current.id, reason),
      (MembershipStatusResult value) =>
          'Membership ${membershipStatusLabel(value.status).toLowerCase()}. '
          'Money already taken stays on the invoice.',
    );
  }

  Future<void> _adjustDates(
    BuildContext context,
    WidgetRef ref,
    Membership current,
  ) async {
    final _AdjustDatesInput? input = await showDialog<_AdjustDatesInput>(
      context: context,
      builder: (BuildContext context) =>
          _AdjustDatesDialog(membership: current),
    );
    if (input == null || !context.mounted) {
      return;
    }

    await _perform<AdjustMembershipDatesResult>(
      context,
      ref,
      () => ref.read(membershipActionsProvider.notifier).adjustDates(
            membershipId: current.id,
            startDate: input.startDate,
            endDate: input.endDate,
            reason: input.reason,
          ),
      // The RPC returns signed day counts computed in Postgres. Reported as
      // they came back rather than recomputed from the state this screen was
      // holding before the round trip.
      (AdjustMembershipDatesResult value) {
        final int moved = value.daysMoved;
        final int changed = value.daysChanged;
        final String start = formatPlainDate(value.startDate);
        final DateTime? end = value.endDate;
        final String window =
            end == null ? 'Starts $start.' : 'Runs $start to ${formatPlainDate(end)}.';
        final String movedText = moved == 0
            ? ''
            : ' Moved ${moved > 0 ? 'later' : 'earlier'} by ${dayCount(moved)}.';
        final String changedText = changed == 0
            ? ''
            : ' ${changed > 0 ? 'Gained' : 'Lost'} ${dayCount(changed)}.';
        return '$window$movedText$changedText';
      },
    );
  }

  Future<void> _markLeft(BuildContext context, WidgetRef ref) async {
    final String? reason = await _showReasonDialog(
      context,
      title: 'Mark ${member.fullName} as left?',
      body: 'Records today as the day they left, and they drop out of the '
          'active list. Their history and anything they still owe are kept — '
          'nothing is deleted.',
      fieldLabel: 'Reason',
      hint: 'Moved away, joined another gym…',
      confirmLabel: 'Mark as left',
      destructive: true,
      required: false,
    );
    if (reason == null || !context.mounted) {
      return;
    }

    await _perform<MemberStatusResult>(
      context,
      ref,
      // `leftOn` is deliberately not passed: omitting it lets the RPC use the
      // gym's own today rather than this device's. A late-logged departure is
      // the only case that would pass one, and this panel is not that screen.
      () => ref.read(membershipActionsProvider.notifier).markLeft(
            member.id,
            reason: reason.isEmpty ? null : reason,
          ),
      // The status is read back, never assumed: `members.status` is
      // trigger-derived and is never written from the client (CLAUDE.md).
      (MemberStatusResult value) => 'Marked as left. They now show as '
          '${memberStatusLabel(value.status).toLowerCase()}.',
    );
  }

  Future<void> _reactivate(BuildContext context, WidgetRef ref) async {
    final bool confirmed = await _confirm(
      context,
      title: 'Reactivate ${member.fullName}?',
      body: 'Clears the leaving date so their record reopens. It does not '
          'sell them anything — they will show as expired until a new plan '
          'is sold.',
      confirmLabel: 'Reactivate',
    );
    if (!confirmed || !context.mounted) {
      return;
    }

    await _perform<MemberStatusResult>(
      context,
      ref,
      () => ref.read(membershipActionsProvider.notifier).reactivate(member.id),
      // Read back, never assumed: `members.status` is trigger-derived and a
      // member with no live membership comes back `expired`, not `active`.
      (MemberStatusResult value) => 'Reactivated. They now show as '
          '${memberStatusLabel(value.status).toLowerCase()}.',
    );
  }

  Future<void> _refund(
    BuildContext context,
    WidgetRef ref,
    List<PaymentWithCollector> correctable,
  ) async {
    final PaymentWithCollector? chosen = await _pickPayment(
      context,
      correctable,
      title: 'Which payment is being refunded?',
    );
    if (chosen == null || !context.mounted) {
      return;
    }

    // A full screen, not a dialog. A refund needs an amount, a reason and the
    // original in view at the same time, and it is the one action here that
    // hands money over.
    final bool? refunded = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => RefundPaymentScreen(payment: chosen),
      ),
    );
    if (refunded == true) {
      onChanged?.call();
    }
  }

  Future<void> _reverse(
    BuildContext context,
    WidgetRef ref,
    List<PaymentWithCollector> correctable,
  ) async {
    final PaymentWithCollector? chosen = await _pickPayment(
      context,
      correctable,
      title: 'Which entry never arrived?',
    );
    if (chosen == null || !context.mounted) {
      return;
    }

    final _ReverseInput? input = await showDialog<_ReverseInput>(
      context: context,
      builder: (BuildContext context) => _ReverseDialog(payment: chosen),
    );
    if (input == null || !context.mounted) {
      return;
    }

    await _perform<ReversePaymentResult>(
      context,
      ref,
      () => ref.read(membershipActionsProvider.notifier).reverse(
            paymentId: chosen.payment.id,
            reason: input.reason,
            amountPaisa: input.amountPaisa,
          ),
      (ReversePaymentResult value) {
        // Negative on the wire, like a refund. Shown positive because "NPR
        // 4,000 taken back" is the sentence.
        final int taken = value.amountPaisa.abs();
        final int? due = value.duePaisa;
        return due == null
            ? '${formatMoney(taken)} taken back. It no longer counts '
                'against the drawer.'
            : '${formatMoney(taken)} taken back. The invoice owes '
                '${formatMoney(due)} again.';
      },
    );
  }

  // --- plumbing -----------------------------------------------------------

  /// Runs [action], reports what happened, and tells the host to re-read.
  ///
  /// There is no path through this that says nothing. A success states what
  /// changed using the numbers the RPC returned; a failure goes to
  /// `showFailureSnackBar`, which gives a refusal its own treatment.
  Future<void> _perform<T>(
    BuildContext context,
    WidgetRef ref,
    Future<MembershipActionResult<T>> Function() action,
    String Function(T value) describe,
  ) async {
    final MembershipActionResult<T> result = await action();
    if (!context.mounted) {
      return;
    }
    switch (result) {
      case MembershipActionSucceeded<T>(:final T value):
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(describe(value))));
        onChanged?.call();
      case MembershipActionFailed<T>(:final failure):
        // Never swallowed, and never softened into "something went wrong".
        // A `42501` here means this panel offered an action the caller was
        // never allowed to take -- the gates above are UX only -- and
        // `showFailureSnackBar` gives that its own treatment.
        showFailureSnackBar(context, failure);
    }
  }

  Future<PaymentWithCollector?> _pickPayment(
    BuildContext context,
    List<PaymentWithCollector> rows, {
    required String title,
  }) async {
    if (rows.length == 1) {
      return rows.single;
    }
    return showDialog<PaymentWithCollector>(
      context: context,
      builder: (BuildContext context) => SimpleDialog(
        title: Text(title),
        children: <Widget>[
          for (final PaymentWithCollector row in rows)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(row),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(formatMoney(row.payment.amountPaisa)),
                subtitle: Text(
                  '${paymentMethodLabel(row.payment.method)} · '
                  '${formatDateTime(row.payment.paidAt)}',
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A titled group of actions.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Brand.spaceMd,
            Brand.spaceLg,
            Brand.spaceMd,
            Brand.spaceSm,
          ),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}

/// One action. The subtitle is not decoration -- it is where the panel says
/// what the action does to the record, which is the whole point of this
/// screen.
class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.actionKey,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.destructive = false,
    this.enabled = true,
  });

  final Key actionKey;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool destructive;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Destructive actions take the theme's error colour. No colour is
    // invented here (PLANNING.md §6), so it holds in light and dark.
    final Color foreground = destructive
        ? theme.colorScheme.error
        : theme.colorScheme.onSurface;

    return ListTile(
      key: actionKey,
      enabled: enabled,
      leading: Icon(icon, color: enabled ? foreground : null),
      title: Text(
        title,
        style: theme.textTheme.titleMedium
            ?.copyWith(color: enabled ? foreground : null),
      ),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
      isThreeLine: true,
      onTap: enabled ? onTap : null,
    );
  }
}

// --- confirmation dialogs --------------------------------------------------

/// Plain yes/no, where [body] states what the action does.
Future<bool> _confirm(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  String cancelLabel = 'Cancel',
  bool destructive = false,
}) async {
  final theme = Theme.of(context);
  final bool? answer = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: destructive
              ? FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                )
              : null,
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return answer ?? false;
}

const Key confirmReasonFieldKey = Key('membership-confirm-reason');
const Key confirmSubmitKey = Key('membership-confirm-submit');

/// Confirmation that also collects a reason.
///
/// Returns the reason on confirm (possibly empty when [required] is false),
/// or null when the desk backed out. Empty-string-versus-null is the
/// difference between "confirmed with no note" and "did not confirm", and
/// collapsing the two would fire the action on a dismissed dialog.
Future<String?> _showReasonDialog(
  BuildContext context, {
  required String title,
  required String body,
  required String fieldLabel,
  required String hint,
  required String confirmLabel,
  String cancelLabel = 'Cancel',
  bool destructive = false,
  bool required = true,
}) {
  return showDialog<String>(
    context: context,
    builder: (BuildContext context) => _ReasonDialog(
      title: title,
      body: body,
      fieldLabel: fieldLabel,
      hint: hint,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      destructive: destructive,
      required: required,
    ),
  );
}

class _ReasonDialog extends StatefulWidget {
  const _ReasonDialog({
    required this.title,
    required this.body,
    required this.fieldLabel,
    required this.hint,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.destructive,
    required this.required,
  });

  final String title;
  final String body;
  final String fieldLabel;
  final String hint;
  final String confirmLabel;
  final String cancelLabel;
  final bool destructive;
  final bool required;

  @override
  State<_ReasonDialog> createState() => _ReasonDialogState();
}

class _ReasonDialogState extends State<_ReasonDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final String value = _controller.text.trim();
    if (widget.required && value.isEmpty) {
      // The database refuses a blank reason too -- `cancel_membership` raises
      // a check violation. Catching it here saves a round trip; it is not the
      // rule.
      setState(() => _error = 'A reason is required.');
      return;
    }
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(widget.body),
            const SizedBox(height: Brand.spaceMd),
            TextField(
              key: confirmReasonFieldKey,
              controller: _controller,
              autofocus: true,
              minLines: 2,
              maxLines: 4,
              maxLength: 500,
              decoration: InputDecoration(
                labelText: widget.required
                    ? widget.fieldLabel
                    : '${widget.fieldLabel} (optional)',
                hintText: widget.hint,
                errorText: _error,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) {
                if (_error != null) {
                  setState(() => _error = null);
                }
              },
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(widget.cancelLabel),
        ),
        FilledButton(
          key: confirmSubmitKey,
          onPressed: _submit,
          style: widget.destructive
              ? FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                )
              : null,
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}

// --- adjust dates ----------------------------------------------------------

/// What the adjust-dates dialog collected.
class _AdjustDatesInput {
  const _AdjustDatesInput({
    required this.startDate,
    required this.endDate,
    required this.reason,
  });

  final DateTime startDate;

  /// Null for a session pack with no validity window. Passed through as an
  /// explicit null, which the repository distinguishes from "unchanged".
  final DateTime? endDate;
  final String reason;
}

const Key adjustStartDateKey = Key('membership-adjust-start');
const Key adjustEndDateKey = Key('membership-adjust-end');
const Key adjustReasonKey = Key('membership-adjust-reason');
const Key adjustSubmitKey = Key('membership-adjust-submit');

class _AdjustDatesDialog extends StatefulWidget {
  const _AdjustDatesDialog({required this.membership});

  final Membership membership;

  @override
  State<_AdjustDatesDialog> createState() => _AdjustDatesDialogState();
}

class _AdjustDatesDialogState extends State<_AdjustDatesDialog> {
  late DateTime _start;
  late DateTime? _end;
  final TextEditingController _reason = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    _start = widget.membership.startDate;
    _end = widget.membership.endDate;
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _pick({required bool isStart}) async {
    final DateTime initial = (isStart ? _start : _end) ?? _start;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      // Wide enough to correct a date typed wrong last year and to push one
      // out for a long pack. Not a business rule -- the RPC owns those.
      firstDate: DateTime.utc(initial.year - 3),
      lastDate: DateTime.utc(initial.year + 3),
    );
    if (picked == null) {
      return;
    }
    setState(() {
      // Normalised to UTC midnight the moment it leaves the picker, because
      // these are `date` columns and a local-midnight value drifts by the
      // org's offset on the way to Postgres (see plain_date.dart).
      final DateTime normalised = plainDate(picked);
      if (isStart) {
        _start = normalised;
      } else {
        _end = normalised;
      }
    });
  }

  void _submit() {
    if (_reason.text.trim().isEmpty) {
      setState(() => _error = 'A reason is required.');
      return;
    }
    final DateTime? end = _end;
    if (end != null && !end.isAfter(_start)) {
      setState(() => _error = 'The end date has to come after the start date.');
      return;
    }
    Navigator.of(context).pop(
      _AdjustDatesInput(
        startDate: _start,
        endDate: _end,
        reason: _reason.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // A pack with no validity window has no end date to move, and inventing
    // one would change what was sold.
    final bool hasWindow = widget.membership.endDate != null;

    return AlertDialog(
      title: const Text('Adjust the dates'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'This is the correction path — for a start date entered wrong, '
              'or days owed back for a closure. It is not a renewal: the '
              'plan, the price and the invoice do not move, and nothing is '
              'charged.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: Brand.spaceMd),
            ListTile(
              key: adjustStartDateKey,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: const Text('Start date'),
              subtitle: Text(formatPlainDate(_start)),
              trailing: const Icon(Icons.edit_calendar_outlined),
              onTap: () => _pick(isStart: true),
            ),
            ListTile(
              key: adjustEndDateKey,
              contentPadding: EdgeInsets.zero,
              enabled: hasWindow,
              leading: const Icon(Icons.event_available_outlined),
              title: const Text('End date'),
              subtitle: Text(
                hasWindow
                    ? formatPlainDate(_end!)
                    : 'This pack runs until the sessions are used up.',
              ),
              trailing: hasWindow
                  ? const Icon(Icons.edit_calendar_outlined)
                  : null,
              onTap: hasWindow ? () => _pick(isStart: false) : null,
            ),
            const SizedBox(height: Brand.spaceSm),
            TextField(
              key: adjustReasonKey,
              controller: _reason,
              minLines: 2,
              maxLines: 4,
              maxLength: 500,
              decoration: InputDecoration(
                labelText: 'Reason',
                hintText: 'Why the dates are being corrected',
                errorText: _error,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) {
                if (_error != null) {
                  setState(() => _error = null);
                }
              },
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: adjustSubmitKey,
          onPressed: _submit,
          child: const Text('Save dates'),
        ),
      ],
    );
  }
}

// --- reverse ---------------------------------------------------------------

/// What the reversal dialog collected.
class _ReverseInput {
  const _ReverseInput({required this.reason, this.amountPaisa});

  final String reason;

  /// Null takes the whole entry back; a value reverses part of it.
  final int? amountPaisa;
}

const Key reverseWholeKey = Key('membership-reverse-whole');
const Key reversePartKey = Key('membership-reverse-part');
const Key reverseReceivedKey = Key('membership-reverse-received');
const Key reverseReasonKey = Key('membership-reverse-reason');
const Key reverseSubmitKey = Key('membership-reverse-submit');

/// "This was rung up and never arrived" — deliberately not the refund dialog.
///
/// It asks a different question (how much *did* arrive, not how much is going
/// back), collects no payment method because no money moves, and says in as
/// many words that this is not a refund.
class _ReverseDialog extends StatefulWidget {
  const _ReverseDialog({required this.payment});

  final PaymentWithCollector payment;

  @override
  State<_ReverseDialog> createState() => _ReverseDialogState();
}

class _ReverseDialogState extends State<_ReverseDialog> {
  bool _partial = false;
  final TextEditingController _received = TextEditingController();
  final TextEditingController _reason = TextEditingController();
  String? _error;

  Payment get _original => widget.payment.payment;

  @override
  void dispose() {
    _received.dispose();
    _reason.dispose();
    super.dispose();
  }

  void _submit() {
    if (_reason.text.trim().isEmpty) {
      setState(() => _error = 'A reason is required.');
      return;
    }

    int? takenBack;
    if (_partial) {
      final int received;
      try {
        received = toPaisa(_received.text.trim());
      } on FormatException {
        setState(() => _error = 'That is not an amount.');
        return;
      }
      if (received <= 0 || received >= _original.amountPaisa) {
        setState(() {
          _error = 'Enter what the member actually gave — less than '
              '${formatMoney(_original.amountPaisa)}. For the whole entry, '
              'pick “None of it came in”.';
        });
        return;
      }
      takenBack = _original.amountPaisa - received;
    }

    Navigator.of(context).pop(
      _ReverseInput(reason: _reason.text.trim(), amountPaisa: takenBack),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Payment never received'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'The ${paymentMethodLabel(_original.method)} entry of '
              '${formatMoney(_original.amountPaisa)} recorded '
              '${formatDateTime(_original.paidAt)}.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: Brand.spaceSm),
            Text(
              // The sentence that separates this from a refund. Both write a
              // negative row; only one of them means cash left the drawer.
              'Use this for an entry recorded in error — the member said they '
              'would pay and did not, or handed over less than was rung up. '
              'Nothing left the drawer, so this is not a refund. What comes '
              'off goes on the drawer sheet beside the original, and the '
              'invoice owes it again.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Brand.spaceMd),
            // `RadioGroup` rather than a `groupValue` on each tile: the
            // per-tile form is deprecated as of Flutter 3.32 and CLAUDE.md
            // says to heed the deprecation notices rather than carry them.
            RadioGroup<bool>(
              groupValue: _partial,
              onChanged: (bool? value) =>
                  setState(() => _partial = value ?? false),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  RadioListTile<bool>(
                    key: reverseWholeKey,
                    contentPadding: EdgeInsets.zero,
                    value: false,
                    title: Text('None of it came in'),
                    subtitle: Text('Take the whole entry back'),
                  ),
                  RadioListTile<bool>(
                    key: reversePartKey,
                    contentPadding: EdgeInsets.zero,
                    value: true,
                    title: Text('Only part came in'),
                    subtitle: Text('Type what the member actually gave'),
                  ),
                ],
              ),
            ),
            if (_partial) ...<Widget>[
              const SizedBox(height: Brand.spaceSm),
              TextField(
                key: reverseReceivedKey,
                controller: _received,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Amount actually received (NPR)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) {
                  if (_error != null) {
                    setState(() => _error = null);
                  }
                },
              ),
            ],
            const SizedBox(height: Brand.spaceSm),
            TextField(
              key: reverseReasonKey,
              controller: _reason,
              minLines: 2,
              maxLines: 4,
              maxLength: 500,
              decoration: InputDecoration(
                labelText: 'Reason',
                hintText: 'Said they would pay tomorrow, cheque bounced…',
                errorText: _error,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) {
                if (_error != null) {
                  setState(() => _error = null);
                }
              },
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: reverseSubmitKey,
          onPressed: _submit,
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
          ),
          child: const Text('Mark as never paid'),
        ),
      ],
    );
  }
}
