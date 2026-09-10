// Today's drawer.
//
// The sheet exists to be reconciled against cash in a till, so its central
// rule is that it **never nets a refund or a reversal silently into one
// number**. They are different facts about different problems:
//
//   - a refund says cash left the drawer — the till is short by that much and
//     there is a member who was given money back;
//   - a reversal says a note that was rung up never arrived — the till is not
//     short at all, the entry was wrong.
//
// A branch whose net is 20,000 short has one problem if that is refunds and a
// completely different one if it is reversals, and a single "net collected"
// figure hides which. So every branch shows all four figures — collected,
// refunded, never received, net — even when three of them are zero, and every
// line in the detail carries its kind.
//
// That reasoning is recorded upstream in the console's revenue report, and
// `PaymentKind.reversal` in `postgres_enums.dart` carries the other half of
// the story: the value was missing from the Dart enum until 2026-09-09, and
// because `fromDb` throws on an unknown value, a single reversed entry took
// out this screen and that member's whole payment history with it.
//
// A widget that builds a PostgREST query is a review failure (PLANNING.md
// §6): the read comes from `payment_queries.dart`.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/data/payments/payment_rpc_results.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/format/dates.dart';
import 'package:logfitness_flutter/domain/format/money.dart';
import 'package:logfitness_flutter/features/common/async_value_view.dart';
import 'package:logfitness_flutter/features/payments/payment_formatting.dart';
import 'package:logfitness_flutter/features/payments/payment_queries.dart';
import 'package:logfitness_flutter/features/staff/branch_scope.dart';

/// One collector's lines within a branch.
class CollectorLines {
  CollectorLines({required this.staffId, required this.staffName});

  /// Null for a payment whose collector has since been removed, or one taken
  /// by a function rather than a person.
  final String? staffId;
  final String? staffName;

  final List<DailyCollectionRow> rows = <DailyCollectionRow>[];

  int get netPaisa => _sum(rows);
  int get txnCount => rows.fold(0, (int a, DailyCollectionRow r) => a + r.txnCount);
}

/// One branch's sheet: the three kinds kept apart, and the net that follows
/// from them.
class BranchCollection {
  BranchCollection({required this.branchId, required this.branchName});

  final String branchId;
  final String branchName;

  final List<CollectorLines> collectors = <CollectorLines>[];
  final List<DailyCollectionRow> rows = <DailyCollectionRow>[];

  /// Money that came in. Positive.
  int get collectedPaisa => _sumOf(rows, PaymentKind.payment);

  /// Money handed back. Negative, as the RPC returns it.
  int get refundedPaisa => _sumOf(rows, PaymentKind.refund);

  /// Money that was rung up but never arrived. Negative.
  int get neverReceivedPaisa => _sumOf(rows, PaymentKind.reversal);

  /// What the drawer should hold. Derived from the three above rather than
  /// summed independently, so the figures on screen can never disagree.
  int get netPaisa => collectedPaisa + refundedPaisa + neverReceivedPaisa;

  int get txnCount => rows.fold(0, (int a, DailyCollectionRow r) => a + r.txnCount);
}

int _sum(List<DailyCollectionRow> rows) =>
    rows.fold(0, (int a, DailyCollectionRow r) => a + r.amountPaisa);

int _sumOf(List<DailyCollectionRow> rows, PaymentKind kind) => rows
    .where((DailyCollectionRow r) => r.kind == kind)
    .fold(0, (int a, DailyCollectionRow r) => a + r.amountPaisa);

/// Branch -> collector -> method/kind lines, mirroring the console's
/// `groupRows` in `components/payments/collection-sheet.tsx`.
List<BranchCollection> groupCollection(List<DailyCollectionRow> rows) {
  final Map<String, BranchCollection> branches = <String, BranchCollection>{};

  for (final DailyCollectionRow row in rows) {
    final BranchCollection branch = branches.putIfAbsent(
      row.branchId,
      () => BranchCollection(
        branchId: row.branchId,
        branchName: row.branchName,
      ),
    );
    branch.rows.add(row);

    CollectorLines? collector;
    for (final CollectorLines candidate in branch.collectors) {
      if (candidate.staffId == row.staffId) {
        collector = candidate;
        break;
      }
    }
    if (collector == null) {
      collector = CollectorLines(
        staffId: row.staffId,
        staffName: row.staffName,
      );
      branch.collectors.add(collector);
    }
    collector.rows.add(row);
  }

  final List<BranchCollection> ordered = branches.values.toList()
    ..sort((BranchCollection a, BranchCollection b) =>
        a.branchName.compareTo(b.branchName));
  for (final BranchCollection branch in ordered) {
    branch.collectors.sort((CollectorLines a, CollectorLines b) =>
        (a.staffName ?? '~').compareTo(b.staffName ?? '~'));
  }
  return ordered;
}

class CollectionSheetScreen extends ConsumerStatefulWidget {
  const CollectionSheetScreen({super.key});

  @override
  ConsumerState<CollectionSheetScreen> createState() =>
      _CollectionSheetScreenState();
}

class _CollectionSheetScreenState extends ConsumerState<CollectionSheetScreen> {
  /// Null means "the gym's own today", resolved inside `daily_collection`.
  ///
  /// Deliberately not seeded with the device's date: a phone in the wrong
  /// timezone would close the wrong day
  /// (`PaymentsRepository.dailyCollection`).
  DateTime? _on;

  @override
  Widget build(BuildContext context) {
    // The shell's branch selection is this sheet's filter — a filter, never a
    // permission. RLS bounds the rows either way (`branch_scope.dart`).
    final BranchScope scope = ref.watch(branchScopeProvider);
    final CollectionQuery query = CollectionQuery(
      on: _on,
      branchIds: scope.effectiveBranchIds,
    );
    final AsyncValue<List<DailyCollectionRow>> sheet = ref.watch(
      dailyCollectionProvider(query),
    );

    return Scaffold(
      body: Column(
        children: <Widget>[
          _DayBar(
            on: _on,
            onPick: (DateTime? picked) => setState(() => _on = picked),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async =>
                  ref.invalidate(dailyCollectionProvider(query)),
              child: AsyncValueView<List<DailyCollectionRow>>(
                value: sheet,
                onRetry: () => ref.invalidate(dailyCollectionProvider(query)),
                isEmpty: (List<DailyCollectionRow> rows) => rows.isEmpty,
                emptyMessage: _on == null
                    ? 'Nothing has been collected yet today.'
                    : 'Nothing was collected on ${formatPlainDate(_on!)}.',
                data: (List<DailyCollectionRow> rows) =>
                    _Sheet(branches: groupCollection(rows)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayBar extends StatelessWidget {
  const _DayBar({required this.on, required this.onPick});

  final DateTime? on;
  final ValueChanged<DateTime?> onPick;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Brand.spaceMd,
        Brand.spaceMd,
        Brand.spaceSm,
        0,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              on == null ? 'Today' : formatPlainDate(on!),
              style: theme.textTheme.titleLarge,
            ),
          ),
          if (on != null)
            TextButton(
              key: const ValueKey<String>('collection-today'),
              onPressed: () => onPick(null),
              child: const Text('Today'),
            ),
          IconButton(
            key: const ValueKey<String>('collection-pick-day'),
            icon: const Icon(Icons.calendar_today_outlined),
            tooltip: 'Pick a day',
            onPressed: () async {
              final DateTime now = DateTime.now();
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: on ?? now,
                firstDate: DateTime(now.year - 3),
                lastDate: now,
              );
              if (picked != null) {
                // Pinned to UTC midnight so no offset can move the day
                // (`plain_date.dart`).
                onPick(DateTime.utc(picked.year, picked.month, picked.day));
              }
            },
          ),
        ],
      ),
    );
  }
}

class _Sheet extends StatelessWidget {
  const _Sheet({required this.branches});

  final List<BranchCollection> branches;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(Brand.spaceMd),
      children: <Widget>[
        for (final BranchCollection branch in branches) ...<Widget>[
          _BranchCard(branch: branch),
          const SizedBox(height: Brand.spaceMd),
        ],
        if (branches.length > 1) _GrandTotal(branches: branches),
      ],
    );
  }
}

class _BranchCard extends StatelessWidget {
  const _BranchCard({required this.branch});

  final BranchCollection branch;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      key: ValueKey<String>('collection-branch-${branch.branchId}'),
      child: Padding(
        padding: const EdgeInsets.all(Brand.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(branch.branchName, style: theme.textTheme.titleMedium),
            const SizedBox(height: Brand.spaceSm),

            // All four, always. Dropping the zero rows would make "no refunds
            // today" look identical to "refunds not shown", which is the
            // confusion this screen exists to prevent.
            _Figure(
              label: 'Collected',
              paisa: branch.collectedPaisa,
              valueKey: 'collection-${branch.branchId}-collected',
            ),
            _Figure(
              label: 'Refunded (cash left the drawer)',
              paisa: branch.refundedPaisa,
              valueKey: 'collection-${branch.branchId}-refunded',
            ),
            _Figure(
              label: 'Never received (rung up, never arrived)',
              paisa: branch.neverReceivedPaisa,
              valueKey: 'collection-${branch.branchId}-reversal',
            ),
            const Divider(),
            _Figure(
              label: 'Net in the drawer',
              paisa: branch.netPaisa,
              emphasis: true,
              valueKey: 'collection-${branch.branchId}-net',
            ),

            const SizedBox(height: Brand.spaceMd),
            Text(
              '${branch.txnCount} '
              '${branch.txnCount == 1 ? 'transaction' : 'transactions'}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Brand.spaceSm),

            for (final CollectorLines collector in branch.collectors)
              _CollectorBlock(collector: collector),
          ],
        ),
      ),
    );
  }
}

class _CollectorBlock extends StatelessWidget {
  const _CollectorBlock({required this.collector});

  final CollectorLines collector;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: Brand.spaceSm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            // A payment with no collector is a real row — the staff member was
            // removed, or a function took it — and saying so beats a blank.
            collector.staffName ?? 'No collector recorded',
            style: theme.textTheme.labelLarge,
          ),
          for (final DailyCollectionRow row in collector.rows)
            _Line(row: row),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.row});

  final DailyCollectionRow row;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isMoneyBack = row.kind != PaymentKind.payment;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Brand.spaceXs),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Wrap(
              spacing: Brand.spaceSm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                Text(
                  paymentMethodLabel(row.method),
                  style: theme.textTheme.bodyMedium,
                ),
                // The kind rides on its own line rather than being folded
                // into the method, so a refund can never be read as takings.
                if (isMoneyBack)
                  _KindChip(kind: row.kind),
              ],
            ),
          ),
          Text(
            '${row.txnCount}×',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: Brand.spaceMd),
          Text(
            formatMoney(row.amountPaisa),
            style: theme.textTheme.bodyMedium?.copyWith(
              // Two signals, not one: the minus sign and the error colour.
              // A screenshot, a colour-blind reader and a dark theme each
              // still show that this line took money out.
              color: isMoneyBack ? theme.colorScheme.error : null,
              fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _KindChip extends StatelessWidget {
  const _KindChip({required this.kind});

  final PaymentKind kind;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Brand.spaceSm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(Brand.radiusSmall),
      ),
      child: Text(
        paymentKindLabel(kind).toLowerCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: scheme.onErrorContainer,
        ),
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({
    required this.label,
    required this.paisa,
    required this.valueKey,
    this.emphasis = false,
  });

  final String label;
  final int paisa;
  final String valueKey;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle? style = emphasis
        ? theme.textTheme.titleMedium
        : theme.textTheme.bodyMedium;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Brand.spaceXs),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label, style: style)),
          Text(
            formatMoney(paisa),
            key: ValueKey<String>(valueKey),
            style: style?.copyWith(
              color: paisa < 0 ? theme.colorScheme.error : null,
              fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

/// The org-wide figures, when more than one branch is in scope. Still four
/// numbers, for the same reason.
class _GrandTotal extends StatelessWidget {
  const _GrandTotal({required this.branches});

  final List<BranchCollection> branches;

  @override
  Widget build(BuildContext context) {
    int fold(int Function(BranchCollection) pick) =>
        branches.fold(0, (int a, BranchCollection b) => a + pick(b));

    return Card(
      key: const ValueKey<String>('collection-grand-total'),
      child: Padding(
        padding: const EdgeInsets.all(Brand.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'All branches in scope',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: Brand.spaceSm),
            _Figure(
              label: 'Collected',
              paisa: fold((BranchCollection b) => b.collectedPaisa),
              valueKey: 'collection-total-collected',
            ),
            _Figure(
              label: 'Refunded',
              paisa: fold((BranchCollection b) => b.refundedPaisa),
              valueKey: 'collection-total-refunded',
            ),
            _Figure(
              label: 'Never received',
              paisa: fold((BranchCollection b) => b.neverReceivedPaisa),
              valueKey: 'collection-total-reversal',
            ),
            const Divider(),
            _Figure(
              label: 'Net',
              paisa: fold((BranchCollection b) => b.netPaisa),
              emphasis: true,
              valueKey: 'collection-total-net',
            ),
          ],
        ),
      ),
    );
  }
}
