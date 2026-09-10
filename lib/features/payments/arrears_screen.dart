// Who owes money.
//
// `arrears_report` does the ageing in Postgres, against `org_today` — the
// gym's own day. The bucket and the age in days are read off the row, never
// recomputed here: a device clock in the wrong timezone would put a member in
// the wrong bucket and change who gets chased today
// (`payment_rpc_results.dart`, `ArrearsRow`).
//
// A widget that builds a PostgREST query is a review failure (PLANNING.md
// §6): the read comes from `payment_queries.dart`. The bucket chips filter a
// list already in hand — no round trip, no query.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/data/payments/payment_rpc_results.dart';
import 'package:logfitness_flutter/domain/format/dates.dart';
import 'package:logfitness_flutter/domain/format/money.dart';
import 'package:logfitness_flutter/features/common/async_value_view.dart';
import 'package:logfitness_flutter/features/payments/payment_queries.dart';
import 'package:logfitness_flutter/features/payments/record_payment_screen.dart';
import 'package:logfitness_flutter/features/payments/renew_membership_screen.dart';
import 'package:logfitness_flutter/features/staff/branch_scope.dart';
import 'package:logfitness_flutter/features/staff/staff_capabilities.dart';

/// The buckets the report assigns, in the order a collections call goes down
/// the list. Free text from the function rather than a Postgres enum, so they
/// are matched as strings.
const List<String> arrearsBuckets = <String>['0-30', '31-60', '61-90', '90+'];

class ArrearsScreen extends ConsumerStatefulWidget {
  const ArrearsScreen({super.key});

  @override
  ConsumerState<ArrearsScreen> createState() => _ArrearsScreenState();
}

class _ArrearsScreenState extends ConsumerState<ArrearsScreen> {
  String? _bucket;

  @override
  Widget build(BuildContext context) {
    // A filter, never a permission — RLS bounds the rows either way
    // (`branch_scope.dart`).
    final BranchScope scope = ref.watch(branchScopeProvider);
    final ArrearsQuery query = ArrearsQuery(
      branchIds: scope.effectiveBranchIds,
    );
    final AsyncValue<List<ArrearsRow>> report = ref.watch(
      arrearsProvider(query),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Arrears')),
      body: Column(
        children: <Widget>[
          _BucketChips(
            selected: _bucket,
            onSelect: (String? bucket) => setState(() => _bucket = bucket),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(arrearsProvider(query)),
              child: AsyncValueView<List<ArrearsRow>>(
                value: report,
                onRetry: () => ref.invalidate(arrearsProvider(query)),
                isEmpty: (List<ArrearsRow> rows) => _visible(rows).isEmpty,
                emptyMessage: _bucket == null
                    ? 'Nobody owes anything. Every invoice is settled.'
                    : 'Nobody is $_bucket days behind.',
                data: (List<ArrearsRow> rows) => _List(rows: _visible(rows)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<ArrearsRow> _visible(List<ArrearsRow> rows) {
    final List<ArrearsRow> filtered = _bucket == null
        ? List<ArrearsRow>.of(rows)
        : rows.where((ArrearsRow r) => r.bucket == _bucket).toList();
    // Biggest debt first — that is the order a desk works the list in.
    filtered.sort((ArrearsRow a, ArrearsRow b) =>
        b.duePaisa.compareTo(a.duePaisa));
    return filtered;
  }
}

class _BucketChips extends StatelessWidget {
  const _BucketChips({required this.selected, required this.onSelect});

  final String? selected;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: Brand.spaceMd,
        vertical: Brand.spaceSm,
      ),
      child: Row(
        spacing: Brand.spaceSm,
        children: <Widget>[
          ChoiceChip(
            label: const Text('Everyone'),
            selected: selected == null,
            onSelected: (_) => onSelect(null),
          ),
          for (final String bucket in arrearsBuckets)
            ChoiceChip(
              key: ValueKey<String>('arrears-bucket-$bucket'),
              label: Text('$bucket days'),
              selected: selected == bucket,
              onSelected: (_) => onSelect(bucket),
            ),
        ],
      ),
    );
  }
}

class _List extends StatelessWidget {
  const _List({required this.rows});

  final List<ArrearsRow> rows;

  @override
  Widget build(BuildContext context) {
    final int totalPaisa = rows.fold(
      0,
      (int a, ArrearsRow r) => a + r.duePaisa,
    );

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: Brand.spaceXl),
      itemCount: rows.length + 1,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return _TotalHeader(count: rows.length, totalPaisa: totalPaisa);
        }
        return _ArrearsTile(row: rows[index - 1]);
      },
    );
  }
}

class _TotalHeader extends StatelessWidget {
  const _TotalHeader({required this.count, required this.totalPaisa});

  final int count;
  final int totalPaisa;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(Brand.spaceMd),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              '$count ${count == 1 ? 'member' : 'members'} owing',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            formatMoney(totalPaisa),
            key: const ValueKey<String>('arrears-total'),
            style: theme.textTheme.titleLarge?.copyWith(
              fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _ArrearsTile extends ConsumerWidget {
  const _ArrearsTile({required this.row});

  final ArrearsRow row;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);

    // UX only. This decides what is *offered*; what the person can actually
    // write is decided in Postgres against the claims on their JWT, and its
    // refusal still reaches the screen (`staff_capabilities.dart`).
    final Set<StaffCapability> capabilities = ref.watch(
      staffCapabilitiesProvider,
    );
    final bool canCollect = capabilities.contains(
      StaffCapability.collectPayment,
    );
    final bool canRenew = capabilities.contains(
      StaffCapability.renewMembership,
    );

    return ListTile(
      key: ValueKey<String>('arrears-${row.memberId}'),
      title: Text(row.fullName),
      subtitle: Text(
        <String>[
          row.memberCode,
          row.homeBranchName,
          if (row.oldestDueOn != null)
            'oldest ${formatPlainDate(row.oldestDueOn!)}',
          if (row.ageDays != null) '${row.ageDays} days',
        ].join(' · '),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            formatMoney(row.duePaisa),
            style: theme.textTheme.titleMedium?.copyWith(
              fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
            ),
          ),
          if (canCollect || canRenew)
            PopupMenuButton<String>(
              key: ValueKey<String>('arrears-actions-${row.memberId}'),
              onSelected: (String action) {
                final Widget screen = action == 'renew'
                    ? RenewMembershipScreen(
                        memberId: row.memberId,
                        memberName: row.fullName,
                      )
                    : RecordPaymentScreen(
                        memberId: row.memberId,
                        memberName: row.fullName,
                      );
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => screen),
                );
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                if (canCollect)
                  const PopupMenuItem<String>(
                    value: 'pay',
                    child: Text('Take a payment'),
                  ),
                if (canRenew)
                  const PopupMenuItem<String>(
                    value: 'renew',
                    child: Text('Renew membership'),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
