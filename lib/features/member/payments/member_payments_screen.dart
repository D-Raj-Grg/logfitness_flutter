import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/data/payments/invoice.dart';
import 'package:logfitness_flutter/data/payments/payment.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/format/dates.dart';
import 'package:logfitness_flutter/domain/format/money.dart';
import 'package:logfitness_flutter/features/common/async_value_view.dart';
import 'package:logfitness_flutter/features/member/home/member_providers.dart';
import 'package:logfitness_flutter/features/payments/payment_formatting.dart';

String _invoiceStatus(InvoiceStatus s) => switch (s) {
  InvoiceStatus.unpaid => 'Unpaid',
  InvoiceStatus.partial => 'Partly paid',
  InvoiceStatus.paid => 'Paid',
  InvoiceStatus.voided => 'Void',
};

/// Invoices and payments for the signed-in member. Refunds and reversals
/// arrive as negative `amount_paisa` and render as negative rows.
class MemberPaymentsScreen extends ConsumerWidget {
  const MemberPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(memberPaymentsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Payments')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(memberPaymentsProvider);
          await ref.read(memberPaymentsProvider.future);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(Brand.spaceMd),
          children: <Widget>[
            AsyncValueView<MemberPaymentsData>(
              value: async,
              onRetry: () => ref.invalidate(memberPaymentsProvider),
              isEmpty: (d) => d.invoices.isEmpty && d.payments.isEmpty,
              emptyMessage: 'No invoices or payments yet.',
              data: (d) => _Body(data: d),
            ),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.data});

  final MemberPaymentsData data;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    String money(int p) => formatMoney(p, currency: data.currency);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Invoices', style: theme.textTheme.titleMedium),
        if (data.invoices.isEmpty) const Text('None.'),
        for (final Invoice i in data.invoices)
          Card(
            child: ListTile(
              title: Text('${i.invoiceNo}  ·  ${money(i.totalPaisa)}'),
              subtitle: Text(
                'Issued ${formatPlainDate(i.issuedOn)}'
                '${i.duePaisa > 0 && i.status != InvoiceStatus.voided ? '  ·  Due ${money(i.duePaisa)}' : ''}',
              ),
              trailing: Text(_invoiceStatus(i.status)),
            ),
          ),
        const SizedBox(height: Brand.spaceMd),
        Text('Payments', style: theme.textTheme.titleMedium),
        if (data.payments.isEmpty) const Text('None.'),
        for (final Payment p in data.payments)
          Card(
            child: ListTile(
              title: Text(
                money(p.amountPaisa),
                style: p.amountPaisa < 0
                    ? TextStyle(color: theme.colorScheme.error)
                    : null,
              ),
              subtitle: Text(
                '${paymentKindLabel(p.kind)}  ·  '
                '${paymentMethodLabel(p.method)}\n${formatDateTime(p.paidAt)}',
              ),
              isThreeLine: true,
            ),
          ),
      ],
    );
  }
}
