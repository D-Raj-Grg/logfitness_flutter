// One member's profile -- the console's `/members/[id]` on a phone.
//
// The header answers the questions asked at a counter with the person
// standing there (who is this, are they paid up, when does it end), and the
// tabs are the history behind those answers: what was sold, what was billed,
// what was collected, when they came in, and what the gym has told them.
//
// A widget that builds a PostgREST query is a review failure (PLANNING.md §6):
// every read here goes through `member_detail_controller.dart`.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/data/members/member.dart';
import 'package:logfitness_flutter/data/members/member_overview.dart';
import 'package:logfitness_flutter/data/memberships/membership.dart';
import 'package:logfitness_flutter/data/payments/invoice.dart';
import 'package:logfitness_flutter/data/payments/payment.dart';
import 'package:logfitness_flutter/data/payments/payment_with_collector.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/format/dates.dart';
import 'package:logfitness_flutter/domain/format/money.dart';
import 'package:logfitness_flutter/features/common/async_value_view.dart';
import 'package:logfitness_flutter/features/documents/document_actions_sheet.dart';
import 'package:logfitness_flutter/features/documents/document_service.dart';
import 'package:logfitness_flutter/data/attendance/attendance_detail.dart';
import 'package:logfitness_flutter/data/attendance/attendance_repository.dart';
import 'package:logfitness_flutter/features/members/member_admin_panel.dart';
import 'package:logfitness_flutter/features/memberships/membership_action_panel.dart';
import 'package:logfitness_flutter/features/members/member_detail_controller.dart';
import 'package:logfitness_flutter/features/members/widgets/member_avatar.dart';
import 'package:logfitness_flutter/features/members/member_labels.dart';
import 'package:logfitness_flutter/features/notifications/member_message_sheet.dart';
import 'package:logfitness_flutter/features/notifications/member_messages_tab.dart';
import 'package:logfitness_flutter/features/staff/branch_scope.dart';
import 'package:logfitness_flutter/features/payments/record_payment_screen.dart';
import 'package:logfitness_flutter/features/payments/renew_membership_screen.dart';
import 'package:logfitness_flutter/features/staff/staff_capabilities.dart';

class MemberDetailScreen extends ConsumerWidget {
  const MemberDetailScreen({required this.memberId, super.key});

  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<MemberProfile?> profile = ref.watch(
      memberProfileProvider(memberId),
    );

    // UX only. `member_message_target` gates on {owner, manager, front_desk}
    // and refuses a trainer itself; hiding the action is a courtesy, and the
    // refusal still reaches the screen if it is reached anyway (CLAUDE.md).
    final bool canSendMessage = ref
        .watch(staffCapabilitiesProvider)
        .contains(StaffCapability.sendMemberMessage);
    final String? fullName = profile.value?.overview.fullName;

    return DefaultTabController(
      // Messages sits after Attendance and before Actions: it is history, like
      // the four before it, and Actions stays last because it is the only tab
      // that changes anything.
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          // The name is the first line of the header below; saying it twice
          // would only push the page down.
          title: const Text('Member'),
          actions: <Widget>[
            // In the app bar as well as on the tab, because the desk chasing
            // dues is looking at the header -- the amount and the expiry -- and
            // should not have to find a tab to act on what it just read.
            if (canSendMessage && fullName != null)
              IconButton(
                key: const ValueKey<String>('member-detail-send-sms'),
                icon: const Icon(Icons.sms_outlined),
                tooltip: 'Send an SMS',
                onPressed: () => showMemberMessageSheet(
                  context,
                  memberId: memberId,
                  fullName: fullName,
                ),
              ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: <Widget>[
              Tab(text: 'Memberships'),
              Tab(text: 'Invoices'),
              Tab(text: 'Payments'),
              Tab(text: 'Attendance'),
              Tab(text: 'Messages'),
              Tab(text: 'Actions'),
            ],
          ),
        ),
        body: AsyncValueView<MemberProfile?>(
          value: profile,
          onRetry: () => ref.invalidate(memberProfileProvider(memberId)),
          // A member the policy will not disclose and a member who does not
          // exist read identically here, which is what RLS means.
          isEmpty: (MemberProfile? value) => value == null,
          emptyMessage: 'That member is not available to this account.',
          data: (MemberProfile? value) {
            final MemberProfile loaded = value!;
            return Column(
              children: <Widget>[
                // Capped, and scrollable inside the cap, so a large text size
                // on a narrow phone shrinks the tabs rather than overflowing.
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height * 0.5,
                  ),
                  child: SingleChildScrollView(child: _Header(profile: loaded)),
                ),
                Expanded(
                  child: TabBarView(
                    children: <Widget>[
                      _MembershipsTab(memberId: memberId),
                      _InvoicesTab(memberId: memberId),
                      _PaymentsTab(memberId: memberId),
                      _AttendanceTab(memberId: memberId),
                      MemberMessagesTab(
                        memberId: memberId,
                        memberName: loaded.overview.fullName,
                      ),
                      _ActionsTab(profile: loaded),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

const List<FontFeature> _tabular = <FontFeature>[FontFeature.tabularFigures()];

/// Who this is, the one plan state that matters right now, and the two things
/// a desk does about it: renew and take money. Dues, an archived record and an
/// outstanding app invitation follow as their own tinted blocks.
class _Header extends ConsumerWidget {
  const _Header({required this.profile});

  final MemberProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final MemberOverview overview = profile.overview;
    final Member member = profile.member;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Brand.spaceMd,
        Brand.spaceMd,
        Brand.spaceMd,
        Brand.spaceSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              MemberAvatar(
                fullName: overview.fullName,
                photoPath: member.photoPath,
                radius: 28,
              ),
              const SizedBox(width: Brand.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      overview.fullName,
                      style: theme.textTheme.titleLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${overview.memberCode} · ${overview.phone} · '
                      '${overview.homeBranchName}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: Brand.spaceXs),
                    Wrap(
                      spacing: Brand.spaceSm,
                      runSpacing: Brand.spaceXs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        MemberStatusBadge(
                          status: overview.status,
                          daysToExpiry: overview.daysToExpiry,
                          membershipStatus: overview.membershipStatus,
                          hasMembershipHistory: overview.hasMembershipHistory,
                        ),
                        Text(
                          // `joined_on` is a `date` column: no timezone shift,
                          // or the day moves for any org east of UTC (see
                          // plain_date.dart).
                          'Joined ${formatPlainDate(overview.joinedOn)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Brand.spaceMd),
          _PlanCard(profile: profile),
          if (overview.hasDues) ...<Widget>[
            const SizedBox(height: Brand.spaceSm),
            _Notice(
              // Dues are why a desk opens this screen with the person in
              // front of them, so they get the error container rather than a
              // line of muted text.
              background: scheme.errorContainer,
              foreground: scheme.onErrorContainer,
              title: 'Dues outstanding',
              // Money is integer paisa everywhere but here, the render
              // boundary (CLAUDE.md).
              detail: overview.oldestDueOn == null
                  ? formatMoney(overview.duePaisa)
                  : '${formatMoney(overview.duePaisa)} · oldest unpaid '
                        'invoice from ${formatPlainDate(overview.oldestDueOn!)}',
            ),
          ],
          if (member.isArchived) ...<Widget>[
            const SizedBox(height: Brand.spaceSm),
            _Notice(
              background: scheme.surfaceContainerHighest,
              foreground: scheme.onSurfaceVariant,
              title: 'Archived',
              detail: member.archivedReason == null
                  ? 'Hidden from the member list and search. Nothing else has '
                        'changed.'
                  : '${member.archivedReason} · hidden from the member list '
                        'and search.',
            ),
          ],
          if (member.hasPendingInvite) ...<Widget>[
            const SizedBox(height: Brand.spaceSm),
            _Notice(
              background: scheme.surfaceContainerHighest,
              foreground: scheme.onSurfaceVariant,
              title: 'App invite pending',
              // `invited_at` is an instant, so it takes the timezone-aware
              // formatter -- the opposite of the date columns above.
              detail:
                  'Invited ${formatDate(member.invitedAt!)}, not yet '
                  'accepted.',
            ),
          ],
        ],
      ),
    );
  }
}

/// The current plan, when it ends, and the primary actions.
class _PlanCard extends ConsumerWidget {
  const _PlanCard({required this.profile});

  final MemberProfile profile;

  /// "Ends 31 Aug 2026 · 12 days left", "Ended 3 days ago", or the sessions a
  /// pack has left. The day count is `member_overview.days_to_expiry`, the
  /// org's own today -- never recomputed from this phone's clock.
  static String _summary(MemberOverview overview) {
    final DateTime? end = overview.membershipEndDate;
    final int? days = overview.daysToExpiry;
    final List<String> parts = <String>[
      if (end != null)
        '${days != null && days < 0 ? 'Ended' : 'Ends'} '
            '${formatPlainDate(end)}',
      if (days != null)
        if (days > 1)
          '$days days left'
        else if (days == 1)
          '1 day left'
        else if (days == 0)
          'last day'
        else
          '${-days} day${days == -1 ? '' : 's'} ago',
      if (overview.currentPlanType == PlanType.sessionPack &&
          overview.sessionsRemaining != null)
        '${overview.sessionsRemaining} '
            'session${overview.sessionsRemaining == 1 ? '' : 's'} left',
    ];
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final MemberOverview overview = profile.overview;

    // UX only. `renew_membership` and `record_payment` are guarded in
    // Postgres and refuse independently (CLAUDE.md).
    final Set<StaffCapability> capabilities = ref.watch(
      staffCapabilitiesProvider,
    );
    final bool canRenew = capabilities.contains(
      StaffCapability.renewMembership,
    );
    final bool canCollect = capabilities.contains(
      StaffCapability.collectPayment,
    );

    final String? planName = overview.currentPlanName;
    final String summary = _summary(overview);

    void refresh() {
      final String id = profile.member.id;
      ref.invalidate(memberProfileProvider(id));
      ref.invalidate(memberMembershipsProvider(id));
      ref.invalidate(memberInvoicesProvider(id));
      ref.invalidate(memberPaymentsProvider(id));
    }

    Future<void> open(Widget screen) async {
      await Navigator.of(
        context,
      ).push<void>(MaterialPageRoute<void>(builder: (_) => screen));
      refresh();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Brand.spaceMd),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(Brand.radiusMedium),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            planName ?? 'No current plan',
            style: theme.textTheme.titleMedium,
          ),
          if (summary.isNotEmpty)
            Text(
              summary,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            )
          else if (planName == null)
            Text(
              overview.hasMembershipHistory
                  ? 'Their last plan has ended.'
                  : 'Nothing has been sold to them yet.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          if (canRenew || canCollect) ...<Widget>[
            const SizedBox(height: Brand.spaceMd),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (canRenew)
                  Expanded(
                    child: FilledButton(
                      key: const ValueKey<String>('member-detail-renew'),
                      onPressed: () => open(
                        RenewMembershipScreen(
                          memberId: profile.member.id,
                          memberName: overview.fullName,
                        ),
                      ),
                      child: Text(
                        overview.hasMembershipHistory ? 'Renew' : 'Sell a plan',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                if (canRenew && canCollect)
                  const SizedBox(width: Brand.spaceSm),
                if (canCollect)
                  Expanded(
                    child:
                        (canRenew && !overview.hasDues
                        ? OutlinedButton.new
                        : FilledButton.tonal)(
                          key: const ValueKey<String>(
                            'member-detail-record-payment',
                          ),
                          onPressed: () => open(
                            RecordPaymentScreen(
                              memberId: profile.member.id,
                              memberName: overview.fullName,
                            ),
                          ),
                          child: const Text(
                            'Record payment',
                            textAlign: TextAlign.center,
                          ),
                        ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({
    required this.background,
    required this.foreground,
    required this.title,
    required this.detail,
  });

  final Color background;
  final Color foreground;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: Brand.spaceMd,
        vertical: Brand.spaceSm,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(Brand.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: text.labelLarge?.copyWith(color: foreground)),
          Text(detail, style: text.bodySmall?.copyWith(color: foreground)),
        ],
      ),
    );
  }
}

// --- history rows ----------------------------------------------------------

/// One row of any history tab: a title and detail lines on the left, a status
/// and an amount on the right edge, and -- only when something went wrong --
/// a tinted block underneath. The same shape on every tab, so the eye learns
/// it once.
class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    required this.title,
    required this.lines,
    this.pill,
    this.amount,
    this.amountColor,
    this.callout,
    this.onTap,
  });

  final String title;
  final List<String> lines;

  /// When set the row opens "Share / Print PDF" and shows a share glyph.
  final VoidCallback? onTap;

  /// A small status chip, top right.
  final Widget? pill;

  /// Money, right-aligned and tabular so a column of them lines up.
  final String? amount;
  final Color? amountColor;

  /// The problem, in its own block.
  final Widget? callout;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Brand.spaceMd,
          vertical: Brand.spaceSm + Brand.spaceXs,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              title,
                              style: theme.textTheme.titleSmall,
                            ),
                          ),
                          if (onTap != null) ...<Widget>[
                            const SizedBox(width: Brand.spaceXs),
                            Icon(
                              Icons.ios_share,
                              size: 14,
                              semanticLabel: 'Share or print PDF',
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ],
                      ),
                      for (final String line in lines)
                        if (line.isNotEmpty)
                          Text(
                            line,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                    ],
                  ),
                ),
                if (pill != null || amount != null) ...<Widget>[
                  const SizedBox(width: Brand.spaceSm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      if (amount != null)
                        Text(
                          amount!,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: amountColor,
                            fontFeatures: _tabular,
                          ),
                        ),
                      if (pill != null && amount != null)
                        const SizedBox(height: Brand.spaceXs),
                      ?pill,
                    ],
                  ),
                ],
              ],
            ),
            if (callout != null) ...<Widget>[
              const SizedBox(height: Brand.spaceSm),
              callout!,
            ],
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Brand.spaceSm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(Brand.radiusSmall),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: foreground),
      ),
    );
  }
}

/// A problem on a history row, in its own tinted block.
class _Callout extends StatelessWidget {
  const _Callout({required this.text, this.icon});

  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Brand.spaceSm + Brand.spaceXs,
        vertical: Brand.spaceSm,
      ),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(Brand.radiusSmall),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 18, color: scheme.onErrorContainer),
            const SizedBox(width: Brand.spaceSm),
          ],
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _historyList<T>(
  List<T> rows,
  Widget Function(BuildContext context, T row) build,
) => ListView.separated(
  itemCount: rows.length,
  separatorBuilder: (_, _) => const Divider(height: 1),
  itemBuilder: (BuildContext context, int index) => build(context, rows[index]),
);

class _MembershipsTab extends ConsumerWidget {
  const _MembershipsTab({required this.memberId});

  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Membership>> rows = ref.watch(
      memberMembershipsProvider(memberId),
    );
    final Map<String, String> branchNames = ref.watch(branchNamesProvider);

    return AsyncValueView<List<Membership>>(
      value: rows,
      onRetry: () => ref.invalidate(memberMembershipsProvider(memberId)),
      isEmpty: (List<Membership> value) => value.isEmpty,
      emptyMessage: 'No memberships yet.',
      data: (List<Membership> value) => _historyList<Membership>(value, (
        BuildContext context,
        Membership row,
      ) {
        final ColorScheme scheme = Theme.of(context).colorScheme;
        final String period = row.endDate == null
            ? '${formatPlainDate(row.startDate)} – open'
            : '${formatPlainDate(row.startDate)} – '
                  '${formatPlainDate(row.endDate!)}';
        final String sessions = row.planType == PlanType.sessionPack
            ? ' · ${row.sessionsRemaining ?? 0} of '
                  '${row.sessionsTotal ?? 0} sessions'
            : '';

        final (Color bg, Color fg) = switch (row.status) {
          MembershipStatus.active => (
            scheme.primaryContainer,
            scheme.onPrimaryContainer,
          ),
          MembershipStatus.frozen || MembershipStatus.upcoming => (
            scheme.secondaryContainer,
            scheme.onSecondaryContainer,
          ),
          MembershipStatus.expired || MembershipStatus.cancelled => (
            scheme.surfaceContainerHighest,
            scheme.onSurfaceVariant,
          ),
        };

        return _HistoryRow(
          title: row.planName,
          lines: <String>[
            '$period$sessions',
            '${branchNames[row.branchId] ?? 'Branch'}'
                '${row.discountPaisa > 0 ? ' · ${formatMoney(row.discountPaisa)} off' : ''}',
          ],
          amount: formatMoney(row.pricePaisa),
          pill: _Pill(
            label: membershipStatusLabel(row.status),
            background: bg,
            foreground: fg,
          ),
        );
      }),
    );
  }
}

class _InvoicesTab extends ConsumerWidget {
  const _InvoicesTab({required this.memberId});

  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Invoice>> rows = ref.watch(
      memberInvoicesProvider(memberId),
    );

    return AsyncValueView<List<Invoice>>(
      value: rows,
      onRetry: () => ref.invalidate(memberInvoicesProvider(memberId)),
      isEmpty: (List<Invoice> value) => value.isEmpty,
      emptyMessage: 'No invoices. One is raised when a plan is assigned.',
      data: (List<Invoice> value) =>
          _historyList<Invoice>(value, (BuildContext context, Invoice row) {
            final ThemeData theme = Theme.of(context);
            final ColorScheme scheme = theme.colorScheme;
            final (Color bg, Color fg) = switch (row.status) {
              InvoiceStatus.paid => (
                scheme.primaryContainer,
                scheme.onPrimaryContainer,
              ),
              InvoiceStatus.partial => (
                scheme.secondaryContainer,
                scheme.onSecondaryContainer,
              ),
              InvoiceStatus.unpaid => (
                scheme.errorContainer,
                scheme.onErrorContainer,
              ),
              InvoiceStatus.voided => (
                scheme.surfaceContainerHighest,
                scheme.onSurfaceVariant,
              ),
            };

            return _HistoryRow(
              onTap: () => showDocumentActionsSheet(
                context,
                actions: ref.read(documentActionsProvider),
                invoiceId: row.id,
                invoiceNo: row.invoiceNo,
              ),
              title: row.invoiceNo,
              lines: <String>[
                'Issued ${formatPlainDate(row.issuedOn)} · '
                    '${formatMoney(row.totalPaisa)} total · '
                    '${formatMoney(row.paidPaisa)} paid',
              ],
              pill: _Pill(
                label: invoiceStatusLabel(row.status),
                background: bg,
                foreground: fg,
              ),
              callout: row.duePaisa > 0
                  ? _Callout(text: '${formatMoney(row.duePaisa)} due')
                  : null,
            );
          }),
    );
  }
}

class _PaymentsTab extends ConsumerWidget {
  const _PaymentsTab({required this.memberId});

  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<PaymentWithCollector>> rows = ref.watch(
      memberPaymentsProvider(memberId),
    );

    return AsyncValueView<List<PaymentWithCollector>>(
      value: rows,
      onRetry: () => ref.invalidate(memberPaymentsProvider(memberId)),
      isEmpty: (List<PaymentWithCollector> value) => value.isEmpty,
      emptyMessage: 'No payments recorded.',
      data: (List<PaymentWithCollector> value) => _historyList<PaymentWithCollector>(
        value,
        (BuildContext context, PaymentWithCollector row) {
          final ColorScheme scheme = Theme.of(context).colorScheme;
          final Payment payment = row.payment;
          // Refunds and reversals are both negative rows; the label says
          // which, because "given back" and "never arrived" are not the
          // same event to anyone counting the drawer (CLAUDE.md: financial
          // history is append-only, so both stay on the record).
          final bool negative = payment.kind != PaymentKind.payment;

          return _HistoryRow(
            onTap: () => showDocumentActionsSheet(
              context,
              actions: ref.read(documentActionsProvider),
              paymentId: payment.id,
            ),
            // `paid_at` is an instant, so it takes the timezone-aware
            // formatter and lands on the org's wall clock.
            title: formatDate(payment.paidAt),
            lines: <String>[
              '${paymentMethodLabel(payment.method)}'
                  '${payment.referenceNo == null ? '' : ' · ${payment.referenceNo}'}'
                  '${row.collectorName == null ? '' : ' · ${row.collectorName}'}',
            ],
            // `amount_paisa` is already negative on the row, so the sign
            // comes from the data rather than from a rule restated here.
            amount: formatMoney(payment.amountPaisa),
            amountColor: negative ? scheme.error : null,
            callout: negative
                ? _Callout(
                    text:
                        '${paymentKindLabel(payment.kind)}'
                        '${payment.reason == null ? '' : ': ${payment.reason}'}',
                  )
                : null,
          );
        },
      ),
    );
  }
}

/// One member's visit history.
///
/// Reads `lib/data/attendance/` -- the Dart counterpart of the console's
/// `listAttendanceForMember` -- through a provider, never a query built in
/// the widget (a review failure, PLANNING.md §6). The empty state says
/// "never checked in" and means it: this tab shipped as a stub for exactly
/// as long as the repository was missing, because an empty attendance tab
/// and a missing one look identical to a desk and only one of them is a
/// claim about the member.
class _AttendanceTab extends ConsumerWidget {
  const _AttendanceTab({required this.memberId});

  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visits = ref.watch(memberAttendanceProvider(memberId));

    return AsyncValueView<List<AttendanceDetail>>(
      value: visits,
      onRetry: () => ref.invalidate(memberAttendanceProvider(memberId)),
      isEmpty: (List<AttendanceDetail> rows) => rows.isEmpty,
      emptyMessage: 'No visits recorded.',
      data: (List<AttendanceDetail> rows) => _historyList<AttendanceDetail>(
        rows,
        (BuildContext context, AttendanceDetail visit) => _HistoryRow(
          title: visit.attendedOn == null
              ? 'Visit'
              : formatPlainDate(visit.attendedOn!),
          lines: <String>[
            <String>[
              if (visit.branchName != null) visit.branchName!,
              if (visit.checkedInAt != null) formatTime(visit.checkedInAt!),
              if (visit.isOpen) 'still inside',
            ].join(' · '),
            // Who let them in -- a person, or the card reader that took the
            // tap.
            if (visit.checkedInByLabel != null) visit.checkedInByLabel!,
          ],
          // The row a manager looks for when a month's numbers do not add
          // up: someone let in despite the membership saying no.
          callout: visit.wasOverridden
              ? Tooltip(
                  message: visit.overrideReason ?? 'Let in on an override',
                  child: _Callout(
                    icon: Icons.report_gmailerrorred_outlined,
                    text: visit.overrideReason == null
                        ? 'Let in on an override'
                        : 'Let in on an override: ${visit.overrideReason}',
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

/// Everything a desk can *do* to this member, in one scrolling column.
///
/// Renew and Record payment live in the header; what is left here is the
/// corrective and administrative set, grouped by what it changes. Both panels
/// below are plain `Column`s by design — nesting a scrollable inside another
/// one is the alternative and it is worse — so this tab is the scrolling host
/// their mounting contracts require.
class _ActionsTab extends ConsumerWidget {
  const _ActionsTab({required this.profile});

  final MemberProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberships = ref.watch(memberMembershipsProvider(profile.member.id));
    final payments = ref.watch(memberPaymentsProvider(profile.member.id));

    return ListView(
      padding: const EdgeInsets.all(Brand.spaceMd),
      children: <Widget>[
        MembershipActionPanel(
          member: profile.member,
          // The membership the lifecycle actions act on is the current one;
          // an expired row from two years ago is history, not a thing to
          // freeze.
          membership: memberships.value?.firstOrNull,
          payments: payments.value ?? const <PaymentWithCollector>[],
          onChanged: () {
            ref.invalidate(memberProfileProvider(profile.member.id));
            ref.invalidate(memberMembershipsProvider(profile.member.id));
            ref.invalidate(memberPaymentsProvider(profile.member.id));
          },
        ),
        MemberAdminPanel(member: profile.member),
      ],
    );
  }
}
