import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/data/memberships/membership.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/format/dates.dart';
import 'package:logfitness_flutter/domain/format/money.dart';
import 'package:logfitness_flutter/features/common/async_value_view.dart';
import 'package:logfitness_flutter/features/member/bookings/member_bookings_screen.dart';
import 'package:logfitness_flutter/features/member/home/member_providers.dart';
import 'package:logfitness_flutter/features/member/messages/member_messages_screen.dart';

String _statusLabel(MemberStatus s) => switch (s) {
  MemberStatus.active => 'Active',
  MemberStatus.expired => 'Expired',
  MemberStatus.frozen => 'Frozen',
  MemberStatus.left => 'Left',
};

/// Plan status, expiry, days remaining and dues. `members.status` is read
/// as the database derived it, never recomputed from dates here.
class MemberHomeScreen extends ConsumerWidget {
  const MemberHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<MemberHomeData> async = ref.watch(memberHomeProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.mail_outline),
            tooltip: 'Messages',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const MemberMessagesScreen(),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(memberHomeProvider);
          await ref.read(memberHomeProvider.future);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(Brand.spaceMd),
          children: <Widget>[
            AsyncValueView<MemberHomeData>(
              value: async,
              onRetry: () => ref.invalidate(memberHomeProvider),
              data: (d) => _HomeBody(data: d),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({required this.data});

  final MemberHomeData data;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Membership? m = data.membership;
    final DateTime? end = m?.endDate;
    final int? days = end == null ? null : daysUntil(end);

    String daysText;
    if (m == null) {
      daysText = 'No membership yet';
    } else if (end == null) {
      daysText = 'No expiry date';
    } else if (days! > 0) {
      daysText = '$days day${days == 1 ? '' : 's'} remaining';
    } else if (days == 0) {
      daysText = 'Expires today';
    } else {
      daysText = 'Expired ${-days} day${days == -1 ? '' : 's'} ago';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Hi, ${data.member.fullName}',
          style: theme.textTheme.titleLarge,
        ),
        Text(data.member.orgName, style: theme.textTheme.bodyMedium),
        const SizedBox(height: Brand.spaceMd),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(Brand.spaceMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        m?.planName ?? 'Membership',
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    Chip(label: Text(_statusLabel(data.member.status))),
                  ],
                ),
                const SizedBox(height: Brand.spaceSm),
                Text(
                  end == null
                      ? 'Expiry: none'
                      : 'Expires ${formatPlainDate(end)}',
                  style: theme.textTheme.bodyLarge,
                ),
                Text(daysText, style: theme.textTheme.bodyMedium),
                if (m?.sessionsRemaining != null)
                  Text(
                    '${m!.sessionsRemaining} sessions left',
                    style: theme.textTheme.bodyMedium,
                  ),
                if (m != null && m.status == MembershipStatus.frozen)
                  const Text('Your membership is frozen.'),
              ],
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: Icon(
              data.duePaisa > 0
                  ? Icons.warning_amber_rounded
                  : Icons.check_circle_outline,
              color: data.duePaisa > 0
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
            ),
            title: Text(
              data.duePaisa > 0
                  ? 'Dues outstanding: ${formatMoney(data.duePaisa, currency: data.member.currency)}'
                  : 'No dues outstanding',
            ),
            subtitle: data.openInvoices > 0
                ? Text(
                    '${data.openInvoices} unpaid invoice'
                    '${data.openInvoices == 1 ? '' : 's'}',
                  )
                : null,
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.event_available_outlined),
            title: const Text('My bookings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const MemberBookingsScreen(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
