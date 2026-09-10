// Giving money back, with the payment it is correcting shown above the form.
//
// The original is on the screen because a refund is a correction to a
// specific entry, and the desk has to be able to see *which* one before
// agreeing to it. The console does the same thing in
// `logfitness_saas/components/memberships/refund-form.tsx`: "Refunding the
// cash payment of NPR 4,000 taken 12 Sep 2026, 6:14 pm".
//
// What this screen never does is edit or delete that original. A refund is an
// additive negative `payments` row with a reason (CLAUDE.md: "Financial
// history is append-only. ... The app never deletes or edits a payment"), so
// the original is rendered read-only, as a fact, not as a form.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/data/payments/payment.dart';
import 'package:logfitness_flutter/data/payments/payment_with_collector.dart';
import 'package:logfitness_flutter/domain/format/dates.dart';
import 'package:logfitness_flutter/domain/format/money.dart';
import 'package:logfitness_flutter/features/common/failure_snackbar.dart';
import 'package:logfitness_flutter/features/memberships/membership_actions_controller.dart';
import 'package:logfitness_flutter/features/memberships/membership_action_labels.dart';

const Key refundAmountFieldKey = Key('refund-amount-field');
const Key refundReasonFieldKey = Key('refund-reason-field');
const Key refundSubmitKey = Key('refund-submit');
const Key refundOriginalPaymentKey = Key('refund-original-payment');

/// Records a refund against [payment].
///
/// Pops `true` once the refund is written, so the screen that pushed it knows
/// to re-read. Pops nothing when the desk backs out.
class RefundPaymentScreen extends ConsumerStatefulWidget {
  const RefundPaymentScreen({required this.payment, super.key});

  /// The entry being corrected, with whoever took it.
  final PaymentWithCollector payment;

  @override
  ConsumerState<RefundPaymentScreen> createState() =>
      _RefundPaymentScreenState();
}

class _RefundPaymentScreenState extends ConsumerState<RefundPaymentScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _amount;
  final TextEditingController _reason = TextEditingController();

  Payment get _original => widget.payment.payment;

  @override
  void initState() {
    super.initState();
    // Prefilled with the whole payment, because refunding all of it is the
    // common case. Rupees here, paisa on the wire -- the single conversion
    // happens in [_submit] via `toPaisa` (CLAUDE.md: "convert to a decimal
    // exactly once, in the formatter at the render boundary").
    _amount = TextEditingController(
      text: formatMoney(_original.amountPaisa, withSymbol: false),
    );
  }

  @override
  void dispose() {
    _amount.dispose();
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final busy = ref.watch(membershipActionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Refund payment')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(Brand.spaceMd),
          children: <Widget>[
            _OriginalPaymentCard(payment: widget.payment),
            const SizedBox(height: Brand.spaceMd),
            Text(
              // The sentence that says what kind of record this makes. It is
              // the whole difference between this screen and an edit form.
              'The refund is recorded as a separate line. The original '
              'payment stays on the books exactly as it is.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Brand.spaceLg),
            TextFormField(
              key: refundAmountFieldKey,
              controller: _amount,
              enabled: !busy,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              decoration: const InputDecoration(
                labelText: 'Amount going back (NPR)',
                border: OutlineInputBorder(),
              ),
              validator: _validateAmount,
            ),
            const SizedBox(height: Brand.spaceMd),
            TextFormField(
              key: refundReasonFieldKey,
              controller: _reason,
              enabled: !busy,
              minLines: 2,
              maxLines: 4,
              maxLength: 500,
              decoration: const InputDecoration(
                labelText: 'Reason',
                hintText: 'Why the money is going back',
                helperText:
                    'Written onto the refund. It is the only explanation '
                    'anyone reading this back will have.',
                helperMaxLines: 3,
                border: OutlineInputBorder(),
              ),
              // Required by `refund_payment` itself, not only by this form.
              // Validating here saves a round trip; it does not replace the
              // rule, which lives in the migration.
              validator: (String? value) =>
                  (value ?? '').trim().isEmpty ? 'A reason is required.' : null,
            ),
            const SizedBox(height: Brand.spaceLg),
            FilledButton.icon(
              key: refundSubmitKey,
              onPressed: busy ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
              icon: const Icon(Icons.currency_exchange),
              label: Text(busy ? 'Saving…' : 'Record refund'),
            ),
          ],
        ),
      ),
    );
  }

  String? _validateAmount(String? value) {
    final String text = (value ?? '').trim();
    if (text.isEmpty) {
      return 'Enter how much is going back.';
    }
    final int paisa;
    try {
      paisa = toPaisa(text);
    } on FormatException {
      return 'That is not an amount.';
    }
    if (paisa <= 0) {
      return 'A refund of nothing is not a correction.';
    }
    // A courtesy check only. The real ceiling is what the invoice still
    // holds, which `refund_payment` knows and this screen does not -- a
    // refund already taken against this payment would make the original
    // amount the wrong bound. The RPC's refusal is the authority.
    if (paisa > _original.amountPaisa) {
      return 'That is more than the '
          '${formatMoney(_original.amountPaisa)} that was taken.';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final result = await ref.read(membershipActionsProvider.notifier).refund(
          paymentId: _original.id,
          // The one conversion from rupees to integer paisa.
          amountPaisa: toPaisa(_amount.text.trim()),
          reason: _reason.text,
          // Deliberately not collected. A null method means "back the way it
          // came": `refund_payment` defaults to the original payment's
          // method, which is a better answer than anything this screen could
          // guess, and asking invites a mismatch with how the money actually
          // moved.
        );

    if (!mounted) {
      return;
    }

    switch (result) {
      case MembershipActionSucceeded(:final value):
        // `amountPaisa` comes back negative -- it is the row that was
        // written. Shown with its sign flipped because "NPR 4,000 refunded"
        // is the sentence, not "NPR -4,000 refunded".
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('${formatMoney(value.amountPaisa.abs())} refunded.'),
            ),
          );
        Navigator.of(context).pop(true);
      case MembershipActionFailed(:final failure):
        // Never swallowed. A refusal here means the panel offered an action
        // this role was never allowed to take, and the snackbar says so
        // rather than reading as a transient glitch.
        showFailureSnackBar(context, failure);
    }
  }
}

/// The entry being corrected, read-only.
class _OriginalPaymentCard extends StatelessWidget {
  const _OriginalPaymentCard({required this.payment});

  final PaymentWithCollector payment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Payment original = payment.payment;

    return Card(
      key: refundOriginalPaymentKey,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(Brand.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Correcting this payment',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Brand.spaceSm),
            Text(
              formatMoney(original.amountPaisa),
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: Brand.spaceXs),
            Text(
              '${paymentMethodLabel(original.method)} · '
              '${formatDateTime(original.paidAt)}',
              style: theme.textTheme.bodyMedium,
            ),
            if (payment.collectorName != null) ...<Widget>[
              const SizedBox(height: Brand.spaceXs),
              Text(
                'Taken by ${payment.collectorName}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (original.referenceNo != null &&
                original.referenceNo!.trim().isNotEmpty) ...<Widget>[
              const SizedBox(height: Brand.spaceXs),
              Text(
                'Reference ${original.referenceNo}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
