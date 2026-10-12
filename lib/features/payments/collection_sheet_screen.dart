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
  int get txnCount =>
      rows.fold(0, (int a, DailyCollectionRow r) => a + r.txnCount);
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

  int get txnCount =>
      rows.fold(0, (int a, DailyCollectionRow r) => a + r.txnCount);

  /// What the cash box should hold: every cash line, takings and money back
  /// alike. Digital rails never touch the box.
  int get cashInBoxPaisa => _sumMethod(rows, PaymentMethod.cash);
}

int _sumMethod(List<DailyCollectionRow> rows, PaymentMethod method) => rows
    .where((DailyCollectionRow r) => r.method == method)
    .fold(0, (int a, DailyCollectionRow r) => a + r.amountPaisa);

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
      () =>
          BranchCollection(branchId: row.branchId, branchName: row.branchName),
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
    ..sort(
      (BranchCollection a, BranchCollection b) =>
          a.branchName.compareTo(b.branchName),
    );
  for (final BranchCollection branch in ordered) {
    branch.collectors.sort(
      (CollectorLines a, CollectorLines b) =>
          (a.staffName ?? '~').compareTo(b.staffName ?? '~'),
    );
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
        Brand.spaceSm,
        Brand.spaceSm,
        0,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              on == null ? 'Today' : formatPlainDate(on!),
              style: theme.textTheme.titleLarge,
              overflow: TextOverflow.ellipsis,
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

/// The figures one drawer summary shows, whether for a branch or for all of
/// them. [keyPrefix] keeps the value keys stable per scope.
class _Totals {
  const _Totals({
    required this.title,
    required this.keyPrefix,
    required this.collected,
    required this.refunded,
    required this.neverReceived,
    required this.net,
    required this.cash,
    required this.txnCount,
    required this.rows,
  });

  factory _Totals.ofBranch(BranchCollection b) => _Totals(
    title: b.branchName,
    keyPrefix: 'collection-${b.branchId}',
    collected: b.collectedPaisa,
    refunded: b.refundedPaisa,
    neverReceived: b.neverReceivedPaisa,
    net: b.netPaisa,
    cash: b.cashInBoxPaisa,
    txnCount: b.txnCount,
    rows: b.rows,
  );

  factory _Totals.ofAll(List<BranchCollection> all) {
    int fold(int Function(BranchCollection) pick) =>
        all.fold(0, (int a, BranchCollection b) => a + pick(b));
    return _Totals(
      title: 'All branches in scope',
      keyPrefix: 'collection-total',
      collected: fold((BranchCollection b) => b.collectedPaisa),
      refunded: fold((BranchCollection b) => b.refundedPaisa),
      neverReceived: fold((BranchCollection b) => b.neverReceivedPaisa),
      net: fold((BranchCollection b) => b.netPaisa),
      cash: fold((BranchCollection b) => b.cashInBoxPaisa),
      txnCount: fold((BranchCollection b) => b.txnCount),
      rows: <DailyCollectionRow>[
        for (final BranchCollection b in all) ...b.rows,
      ],
    );
  }

  final String title;
  final String keyPrefix;
  final int collected;
  final int refunded;
  final int neverReceived;
  final int net;
  final int cash;
  final int txnCount;
  final List<DailyCollectionRow> rows;
}

class _Sheet extends StatelessWidget {
  const _Sheet({required this.branches});

  final List<BranchCollection> branches;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(Brand.spaceMd),
      children: <Widget>[
        // The org-wide figure leads when more than one branch is in scope.
        if (branches.length > 1) ...<Widget>[
          _Summary(
            key: const ValueKey<String>('collection-grand-total'),
            totals: _Totals.ofAll(branches),
          ),
          const SizedBox(height: Brand.spaceLg),
        ],
        for (final BranchCollection branch in branches) ...<Widget>[
          _Summary(
            key: ValueKey<String>('collection-branch-${branch.branchId}'),
            totals: _Totals.ofBranch(branch),
            collectors: branch.collectors,
          ),
          const SizedBox(height: Brand.spaceLg),
        ],
      ],
    );
  }
}

/// One drawer summary: the net and the cash box first, then the four figures
/// in a grid, then how it was paid, then who took it.
///
/// Refunded and never-received are always shown, zero or not: dropping a zero
/// would make "no refunds today" look the same as "refunds not shown".
class _Summary extends StatelessWidget {
  const _Summary({required this.totals, this.collectors, super.key});

  final _Totals totals;
  final List<CollectorLines>? collectors;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final String p = totals.keyPrefix;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(Brand.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    totals.title,
                    style: theme.textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${totals.txnCount} '
                  '${totals.txnCount == 1 ? 'transaction' : 'transactions'}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Brand.spaceMd),

            Text(
              'Net collected',
              style: theme.textTheme.labelLarge?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  formatMoney(totals.net),
                  key: ValueKey<String>('$p-net'),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: totals.net < 0 ? scheme.error : null,
                    fontFeatures: const <FontFeature>[
                      FontFeature.tabularFigures(),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: Brand.spaceSm),

            // The number the person counting the till is actually after.
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Brand.spaceMd - Brand.spaceXs,
                vertical: Brand.spaceSm,
              ),
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(Brand.radiusMedium),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.payments_outlined,
                    size: 20,
                    color: scheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: Brand.spaceSm),
                  Expanded(
                    child: Text(
                      'Expected cash in box',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: Brand.spaceSm),
                  Text(
                    formatMoney(totals.cash),
                    key: ValueKey<String>('$p-cash'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: scheme.onPrimaryContainer,
                      fontFeatures: const <FontFeature>[
                        FontFeature.tabularFigures(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Brand.spaceMd),

            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: _Kpi(
                      label: 'Collected',
                      caption: 'money in',
                      paisa: totals.collected,
                      valueKey: '$p-collected',
                    ),
                  ),
                  const SizedBox(width: Brand.spaceSm),
                  Expanded(
                    child: _Kpi(
                      label: 'Refunded',
                      caption: 'cash left the drawer',
                      paisa: totals.refunded,
                      valueKey: '$p-refunded',
                      problem: totals.refunded != 0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Brand.spaceSm),
            _Kpi(
              label: 'Never received',
              caption: 'rung up, never arrived',
              paisa: totals.neverReceived,
              valueKey: '$p-reversal',
              problem: totals.neverReceived != 0,
              wide: true,
            ),

            const SizedBox(height: Brand.spaceLg),
            Text('By method', style: theme.textTheme.titleSmall),
            const SizedBox(height: Brand.spaceXs),
            _MethodBreakdown(rows: totals.rows),

            if (collectors != null && collectors!.isNotEmpty) ...<Widget>[
              const SizedBox(height: Brand.spaceLg),
              Text('By collector', style: theme.textTheme.titleSmall),
              const SizedBox(height: Brand.spaceXs),
              Theme(
                // ExpansionTile draws its own top/bottom rules; the card
                // already frames them.
                data: theme.copyWith(dividerColor: scheme.surface.withAlpha(0)),
                child: Column(
                  children: <Widget>[
                    for (final CollectorLines c in collectors!)
                      _CollectorTile(
                        collector: c,
                        initiallyExpanded: collectors!.length == 1,
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A figure tile. A negative one is tinted as a problem and carries its minus
/// sign: two signals, so a screenshot or a colour-blind reader still sees that
/// it took money out.
class _Kpi extends StatelessWidget {
  const _Kpi({
    required this.label,
    required this.caption,
    required this.paisa,
    required this.valueKey,
    this.problem = false,
    this.wide = false,
  });

  final String label;
  final String caption;
  final int paisa;
  final String valueKey;
  final bool problem;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final Color fg = problem ? scheme.onErrorContainer : scheme.onSurface;
    final Color sub = problem
        ? scheme.onErrorContainer
        : scheme.onSurfaceVariant;

    final Widget value = Text(
      formatMoney(paisa),
      key: ValueKey<String>(valueKey),
      style: theme.textTheme.titleMedium?.copyWith(
        color: fg,
        fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
      ),
    );
    final Widget labels = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: theme.textTheme.labelLarge?.copyWith(color: fg)),
        Text(caption, style: theme.textTheme.bodySmall?.copyWith(color: sub)),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(Brand.spaceMd - Brand.spaceXs),
      decoration: BoxDecoration(
        color: problem ? scheme.errorContainer : scheme.surface,
        borderRadius: BorderRadius.circular(Brand.radiusMedium),
      ),
      child: wide
          ? Row(
              children: <Widget>[
                Expanded(child: labels),
                const SizedBox(width: Brand.spaceSm),
                value,
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                labels,
                const SizedBox(height: Brand.spaceXs),
                FittedBox(fit: BoxFit.scaleDown, child: value),
              ],
            ),
    );
  }
}

/// Net per rail, with the money-back lines kept visible underneath rather than
/// netted away.
class _MethodBreakdown extends StatelessWidget {
  const _MethodBreakdown({required this.rows});

  final List<DailyCollectionRow> rows;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final List<PaymentMethod> methods = <PaymentMethod>[
      for (final PaymentMethod m in PaymentMethod.values)
        if (rows.any((DailyCollectionRow r) => r.method == m)) m,
    ];

    return Column(
      children: <Widget>[
        for (final PaymentMethod m in methods)
          Builder(
            builder: (BuildContext context) {
              final List<DailyCollectionRow> mine = rows
                  .where((DailyCollectionRow r) => r.method == m)
                  .toList();
              final int net = _sum(mine);
              final int txns = mine.fold(
                0,
                (int a, DailyCollectionRow r) => a + r.txnCount,
              );
              final int refunded = _sumOf(mine, PaymentKind.refund);
              final int reversed = _sumOf(mine, PaymentKind.reversal);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: Brand.spaceXs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(
                      paymentMethodIcon(m),
                      size: 20,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: Brand.spaceSm + Brand.spaceXs),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            paymentMethodLabel(m),
                            style: theme.textTheme.bodyMedium,
                          ),
                          Text(
                            '$txns ${txns == 1 ? 'transaction' : 'transactions'}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          if (refunded != 0)
                            Text(
                              'Refunded ${formatMoney(refunded)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.error,
                              ),
                            ),
                          if (reversed != 0)
                            Text(
                              'Never received ${formatMoney(reversed)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.error,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: Brand.spaceSm),
                    Text(
                      formatMoney(net),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: net < 0 ? scheme.error : null,
                        fontFeatures: const <FontFeature>[
                          FontFeature.tabularFigures(),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}

class _CollectorTile extends StatelessWidget {
  const _CollectorTile({
    required this.collector,
    required this.initiallyExpanded,
  });

  final CollectorLines collector;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final int net = collector.netPaisa;
    final int n = collector.txnCount;

    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: Brand.spaceSm),
      initiallyExpanded: initiallyExpanded,
      title: Text(
        // A payment with no collector is a real row — the staff member was
        // removed, or a function took it — and saying so beats a blank.
        collector.staffName ?? 'No collector recorded',
        style: theme.textTheme.bodyLarge,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text('$n ${n == 1 ? 'transaction' : 'transactions'}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            formatMoney(net),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: net < 0 ? scheme.error : null,
              fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
            ),
          ),
          const Icon(Icons.expand_more),
        ],
      ),
      children: <Widget>[
        for (final DailyCollectionRow row in collector.rows) _Line(row: row),
      ],
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
                // The kind rides on its own chip rather than being folded
                // into the method, so a refund can never be read as takings.
                if (isMoneyBack) _KindChip(kind: row.kind),
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
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: scheme.onErrorContainer),
      ),
    );
  }
}
