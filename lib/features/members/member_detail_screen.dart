// One member's profile -- the console's `/members/[id]` on a phone.
//
// The header answers the questions asked at a counter with the person
// standing there (who is this, are they paid up, when does it end), and the
// four tabs are the history behind those answers: what was sold, what was
// billed, what was collected, and when they came in.
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
import 'package:logfitness_flutter/features/members/member_detail_controller.dart';
import 'package:logfitness_flutter/features/members/member_labels.dart';
import 'package:logfitness_flutter/features/staff/branch_scope.dart';

class MemberDetailScreen extends ConsumerWidget {
  const MemberDetailScreen({required this.memberId, super.key});

  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<MemberProfile?> profile = ref.watch(
      memberProfileProvider(memberId),
    );

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(profile.value?.overview.fullName ?? 'Member'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: <Widget>[
              Tab(text: 'Memberships'),
              Tab(text: 'Invoices'),
              Tab(text: 'Payments'),
              Tab(text: 'Attendance'),
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
                _Header(profile: loaded),
                Expanded(
                  child: TabBarView(
                    children: <Widget>[
                      _MembershipsTab(memberId: memberId),
                      _InvoicesTab(memberId: memberId),
                      _PaymentsTab(memberId: memberId),
                      const _AttendanceTab(),
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

/// Name, code, phone, status, home branch and dues -- and the two facts that
/// change what the desk should do next: an outstanding app invitation, and an
/// archived record.
class _Header extends StatelessWidget {
  const _Header({required this.profile});

  final MemberProfile profile;

  @override
  Widget build(BuildContext context) {
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
            children: <Widget>[
              Expanded(
                child: Text(
                  overview.fullName,
                  style: theme.textTheme.titleLarge,
                ),
              ),
              const SizedBox(width: Brand.spaceSm),
              MemberStatusBadge(
                status: overview.status,
                daysToExpiry: overview.daysToExpiry,
                membershipStatus: overview.membershipStatus,
                hasMembershipHistory: overview.hasMembershipHistory,
              ),
            ],
          ),
          const SizedBox(height: Brand.spaceXs),
          Text(
            '${overview.memberCode} · ${overview.phone} · '
            '${overview.homeBranchName}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          Text(
            // `joined_on` is a `date` column: no timezone shift, or the day
            // moves for any org east of UTC (see plain_date.dart).
            'Joined ${formatPlainDate(overview.joinedOn)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
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
              detail: 'Invited ${formatDate(member.invitedAt!)}, not yet '
                  'accepted.',
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
      padding: const EdgeInsets.all(Brand.spaceSm),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(Brand.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: text.labelLarge?.copyWith(color: foreground),
          ),
          Text(detail, style: text.bodySmall?.copyWith(color: foreground)),
        ],
      ),
    );
  }
}

class _MembershipsTab extends ConsumerWidget {
  const _MembershipsTab({required this.memberId});

  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Membership>> rows = ref.watch(
      memberMembershipsProvider(memberId),
    );
    final Map<String, String> branchNames = ref.watch(branchNamesProvider);
    final ThemeData theme = Theme.of(context);

    return AsyncValueView<List<Membership>>(
      value: rows,
      onRetry: () => ref.invalidate(memberMembershipsProvider(memberId)),
      isEmpty: (List<Membership> value) => value.isEmpty,
      emptyMessage: 'No memberships yet.',
      data: (List<Membership> value) => ListView.separated(
        itemCount: value.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (BuildContext context, int index) {
          final Membership row = value[index];
          final String period = row.endDate == null
              ? '${formatPlainDate(row.startDate)} – open'
              : '${formatPlainDate(row.startDate)} – '
                    '${formatPlainDate(row.endDate!)}';
          final String sessions = row.planType == PlanType.sessionPack
              ? ' · ${row.sessionsRemaining ?? 0} of '
                    '${row.sessionsTotal ?? 0} sessions'
              : '';

          return ListTile(
            title: Text(row.planName),
            subtitle: Text(
              '$period$sessions\n'
              '${branchNames[row.branchId] ?? 'Branch'} · '
              '${formatMoney(row.pricePaisa)}'
              '${row.discountPaisa > 0 ? ' · ${formatMoney(row.discountPaisa)} off' : ''}',
            ),
            isThreeLine: true,
            trailing: Text(
              membershipStatusLabel(row.status),
              style: theme.textTheme.labelMedium,
            ),
          );
        },
      ),
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
    final ThemeData theme = Theme.of(context);

    return AsyncValueView<List<Invoice>>(
      value: rows,
      onRetry: () => ref.invalidate(memberInvoicesProvider(memberId)),
      isEmpty: (List<Invoice> value) => value.isEmpty,
      emptyMessage: 'No invoices. One is raised when a plan is assigned.',
      data: (List<Invoice> value) => ListView.separated(
        itemCount: value.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (BuildContext context, int index) {
          final Invoice row = value[index];
          return ListTile(
            title: Text(row.invoiceNo),
            subtitle: Text(
              'Issued ${formatPlainDate(row.issuedOn)} · '
              '${formatMoney(row.totalPaisa)} total · '
              '${formatMoney(row.paidPaisa)} paid',
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  invoiceStatusLabel(row.status),
                  style: theme.textTheme.labelMedium,
                ),
                if (row.duePaisa > 0)
                  Text(
                    '${formatMoney(row.duePaisa)} due',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
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
    final ThemeData theme = Theme.of(context);

    return AsyncValueView<List<PaymentWithCollector>>(
      value: rows,
      onRetry: () => ref.invalidate(memberPaymentsProvider(memberId)),
      isEmpty: (List<PaymentWithCollector> value) => value.isEmpty,
      emptyMessage: 'No payments recorded.',
      data: (List<PaymentWithCollector> value) => ListView.separated(
        itemCount: value.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (BuildContext context, int index) {
          final PaymentWithCollector row = value[index];
          final Payment payment = row.payment;
          // Refunds and reversals are both negative rows; the label says
          // which, because "given back" and "never arrived" are not the same
          // event to anyone counting the drawer (CLAUDE.md: financial history
          // is append-only, so both stay on the record).
          final bool negative = payment.kind != PaymentKind.payment;

          return ListTile(
            // `paid_at` is an instant, so it takes the timezone-aware
            // formatter and lands on the org's wall clock.
            title: Text(formatDate(payment.paidAt)),
            subtitle: Text(
              '${paymentMethodLabel(payment.method)}'
              '${payment.referenceNo == null ? '' : ' · ${payment.referenceNo}'}'
              '${row.collectorName == null ? '' : ' · ${row.collectorName}'}'
              '${negative ? '\n${paymentKindLabel(payment.kind)}'
                    '${payment.reason == null ? '' : ': ${payment.reason}'}' : ''}',
            ),
            isThreeLine: negative,
            trailing: Text(
              // `amount_paisa` is already negative on the row, so the sign
              // comes from the data rather than from a rule restated here.
              formatMoney(payment.amountPaisa),
              style: theme.textTheme.labelLarge?.copyWith(
                color: negative ? theme.colorScheme.error : null,
                fontWeight: negative ? FontWeight.w600 : null,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Attendance has no repository yet.
///
/// `lib/data/` carries members, memberships, payments, plans, branches and
/// visitors, and nothing that reads `attendance` -- the console's
/// `listAttendanceForMember` has no Dart counterpart. Rather than invent a
/// query in a widget (a review failure, PLANNING.md §6) or leave a tab that
/// silently shows nothing, this says what is actually true: an empty
/// attendance tab and a missing one look identical to a desk, and only one of
/// them means "this member has never checked in".
class _AttendanceTab extends StatelessWidget {
  const _AttendanceTab();

  @override
  Widget build(BuildContext context) {
    return const EmptyView(
      icon: Icons.event_busy_outlined,
      message: 'Attendance is not available in the app yet. Check-in history '
          'is on the web console until the attendance data layer lands.',
    );
  }
}
