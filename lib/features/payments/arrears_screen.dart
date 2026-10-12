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
import 'package:url_launcher/url_launcher.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/data/payments/payment_rpc_results.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/domain/format/dates.dart';
import 'package:logfitness_flutter/domain/format/money.dart';
import 'package:logfitness_flutter/features/common/async_value_view.dart';
import 'package:logfitness_flutter/features/common/failure_snackbar.dart';
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
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(arrearsProvider(query)),
        child: AsyncValueView<List<ArrearsRow>>(
          value: report,
          onRetry: () => ref.invalidate(arrearsProvider(query)),
          // Empty means nobody owes at all. An empty *bucket* keeps the filter
          // row on screen so the desk can move to another one.
          isEmpty: (List<ArrearsRow> rows) => rows.isEmpty,
          emptyMessage: 'Nobody owes anything. Every invoice is settled.',
          data: (List<ArrearsRow> rows) => _Body(
            all: rows,
            bucket: _bucket,
            onSelect: (String? bucket) => setState(() => _bucket = bucket),
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.all,
    required this.bucket,
    required this.onSelect,
  });

  final List<ArrearsRow> all;
  final String? bucket;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    // Biggest debt first — that is the order a desk works the list in.
    final List<ArrearsRow> rows =
        (bucket == null
              ? List<ArrearsRow>.of(all)
              : all.where((ArrearsRow r) => r.bucket == bucket).toList())
          ..sort(
            (ArrearsRow a, ArrearsRow b) => b.duePaisa.compareTo(a.duePaisa),
          );
    final int total = rows.fold(0, (int a, ArrearsRow r) => a + r.duePaisa);

    return ListView(
      padding: const EdgeInsets.only(bottom: Brand.spaceXl),
      children: <Widget>[
        _BucketRow(all: all, selected: bucket, onSelect: onSelect),
        // One results line: who and how much, for the filter above.
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Brand.spaceMd,
            Brand.spaceXs,
            Brand.spaceMd,
            Brand.spaceSm,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '${rows.length} ${rows.length == 1 ? 'member' : 'members'} '
                  'owing',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              Text(
                formatMoney(total),
                key: const ValueKey<String>('arrears-total'),
                style: theme.textTheme.titleLarge?.copyWith(
                  color: scheme.error,
                  fontFeatures: const <FontFeature>[
                    FontFeature.tabularFigures(),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        if (rows.isEmpty)
          Padding(
            padding: const EdgeInsets.all(Brand.spaceXl),
            child: Text(
              'Nobody is $bucket days behind.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        for (final ArrearsRow row in rows) ...<Widget>[
          _ArrearsTile(row: row),
          const Divider(height: 1, indent: Brand.spaceMd),
        ],
      ],
    );
  }
}

/// Age buckets as one filter row, each with what it holds. Replaces the chip
/// row plus a separate total: the amounts say where the money is before a
/// bucket is even tapped.
class _BucketRow extends StatelessWidget {
  const _BucketRow({
    required this.all,
    required this.selected,
    required this.onSelect,
  });

  final List<ArrearsRow> all;
  final String? selected;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    int sum(String? b) => all
        .where((ArrearsRow r) => b == null || r.bucket == b)
        .fold(0, (int a, ArrearsRow r) => a + r.duePaisa);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(Brand.spaceMd),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Brand.spaceSm,
          children: <Widget>[
            _BucketTile(
              label: 'Everyone',
              paisa: sum(null),
              selected: selected == null,
              onTap: () => onSelect(null),
            ),
            for (final String bucket in arrearsBuckets)
              _BucketTile(
                key: ValueKey<String>('arrears-bucket-$bucket'),
                label: '$bucket days',
                paisa: sum(bucket),
                selected: selected == bucket,
                onTap: () => onSelect(bucket),
              ),
          ],
        ),
      ),
    );
  }
}

class _BucketTile extends StatelessWidget {
  const _BucketTile({
    required this.label,
    required this.paisa,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final int paisa;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final Color fg = selected
        ? scheme.onPrimaryContainer
        : scheme.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected
            ? scheme.primaryContainer
            : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(Brand.radiusMedium),
        child: InkWell(
          borderRadius: BorderRadius.circular(Brand.radiusMedium),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Brand.spaceMd,
              vertical: Brand.spaceSm + Brand.spaceXs,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(color: fg),
                ),
                const SizedBox(height: 2),
                Text(
                  formatMoney(paisa),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: selected ? fg : scheme.onSurface,
                    fontFeatures: const <FontFeature>[
                      FontFeature.tabularFigures(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The round mark on the left: how many days overdue, tinted by how bad.
class _AgeMark extends StatelessWidget {
  const _AgeMark({required this.days});

  final int? days;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final int d = days ?? 0;
    final (Color bg, Color fg) = d > 90
        ? (scheme.error, scheme.onError)
        : d > 30
        ? (scheme.errorContainer, scheme.onErrorContainer)
        : (scheme.tertiaryContainer, scheme.onTertiaryContainer);

    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: days == null
          ? Icon(Icons.schedule, size: 20, color: fg)
          : FittedBox(
              child: Padding(
                padding: const EdgeInsets.all(Brand.spaceXs),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      '$d',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: fg,
                        height: 1,
                      ),
                    ),
                    Text(
                      'days',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: fg,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
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
    final ColorScheme scheme = theme.colorScheme;

    return InkWell(
      key: ValueKey<String>('arrears-${row.memberId}'),
      onTap: () => _showActions(context, ref),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Brand.spaceMd,
          vertical: Brand.spaceSm + Brand.spaceXs,
        ),
        child: Row(
          children: <Widget>[
            _AgeMark(days: row.ageDays),
            const SizedBox(width: Brand.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    row.fullName,
                    style: theme.textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    <String>[row.memberCode, row.homeBranchName].join(' · '),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (row.oldestDueOn != null)
                    Text(
                      'since ${formatPlainDate(row.oldestDueOn!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: Brand.spaceSm),
            Text(
              formatMoney(row.duePaisa),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.error,
                fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// One tap on the row, one tap on the action: call first, because chasing
  /// the money is what this list is for.
  Future<void> _showActions(BuildContext context, WidgetRef ref) {
    // UX only. This decides what is *offered*; what the person can actually
    // write is decided in Postgres against the claims on their JWT, and its
    // refusal still reaches the screen (`staff_capabilities.dart`).
    final Set<StaffCapability> capabilities = ref.read(
      staffCapabilitiesProvider,
    );
    final bool canCollect = capabilities.contains(
      StaffCapability.collectPayment,
    );
    final bool canRenew = capabilities.contains(
      StaffCapability.renewMembership,
    );

    void open(Widget screen) {
      Navigator.of(context).pop();
      Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => screen));
    }

    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: Text(
                row.fullName,
                style: Theme.of(sheetContext).textTheme.titleMedium,
              ),
              subtitle: Text('${formatMoney(row.duePaisa)} owed'),
            ),
            ListTile(
              key: ValueKey<String>('arrears-call-${row.memberId}'),
              leading: const Icon(Icons.call_outlined),
              title: Text('Call ${row.phone}'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _call(context);
              },
            ),
            if (canCollect)
              ListTile(
                key: ValueKey<String>('arrears-actions-${row.memberId}'),
                leading: const Icon(Icons.payments_outlined),
                title: const Text('Take a payment'),
                onTap: () => open(
                  RecordPaymentScreen(
                    memberId: row.memberId,
                    memberName: row.fullName,
                  ),
                ),
              ),
            if (canRenew)
              ListTile(
                leading: const Icon(Icons.autorenew),
                title: const Text('Renew membership'),
                onTap: () => open(
                  RenewMembershipScreen(
                    memberId: row.memberId,
                    memberName: row.fullName,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _call(BuildContext context) async {
    final bool opened = await launchUrl(
      Uri(scheme: 'tel', path: row.phone),
    ).catchError((Object _) => false);
    if (!opened && context.mounted) {
      showFailureSnackBar(
        context,
        AppFailure(
          FailureKind.unknown,
          'Could not start a call to ${row.phone}.',
        ),
      );
    }
  }
}
