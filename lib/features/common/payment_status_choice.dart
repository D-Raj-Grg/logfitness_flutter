// What the member actually handed over.
//
// The Dart mirror of the console's
// `components/memberships/payment-status-choice.tsx`, and it exists for the
// same reason: the QR fails, the card machine is down, or they say they will
// pay on Sunday -- and the desk still has to register them. Without it the
// amount box is just an amount box, and the quickest path through the form
// (type the price, tap Register) records a payment that never happened.
//
// Not a submitted value. The choice drives which inputs are shown and what
// the amount is prefilled with; what reaches the RPC is the amount itself. An
// unpaid sale still raises the invoice, so the dues show on the profile and in
// the arrears report.
import 'package:flutter/material.dart';

import 'package:logfitness_flutter/app/brand.dart';

/// Mirrors the console's `PaymentStatus` union.
enum PaymentStatus { full, part, unpaid }

/// The console's own words, so a manager reading the web and a desk reading
/// the phone describe the same sale the same way.
String paymentStatusLabel(PaymentStatus status) => switch (status) {
  PaymentStatus.full => 'Paid in full',
  PaymentStatus.part => 'Part paid',
  PaymentStatus.unpaid => 'Unpaid',
};

String paymentStatusHint(PaymentStatus status) => switch (status) {
  PaymentStatus.full => 'Nothing outstanding',
  PaymentStatus.part => 'Type what came in',
  PaymentStatus.unpaid => 'Bill it, collect later',
};

const Key paymentStatusChoiceKey = Key('payment-status-choice');

/// Key for one option, for tests and for driving the choice from elsewhere.
Key paymentStatusKey(PaymentStatus status) =>
    Key('payment-status-${status.name}');

/// Three cards, one tap. Not a dropdown: this is the sale's most consequential
/// field and it has three options, so hiding it behind a menu would cost a tap
/// and let it be skipped by not being looked at.
class PaymentStatusChoice extends StatelessWidget {
  const PaymentStatusChoice({
    required this.value,
    required this.onChanged,
    this.enabled = true,
    super.key,
  });

  final PaymentStatus value;
  final ValueChanged<PaymentStatus> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      key: paymentStatusChoiceKey,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: Brand.spaceSm),
          child: Text('Payment', style: theme.textTheme.labelLarge),
        ),
        for (final PaymentStatus status in PaymentStatus.values)
          Padding(
            padding: const EdgeInsets.only(bottom: Brand.spaceSm),
            child: _StatusCard(
              status: status,
              selected: status == value,
              enabled: enabled,
              onTap: () => onChanged(status),
            ),
          ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.status,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final PaymentStatus status;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Material(
        color: selected ? colors.primaryContainer : colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: selected ? colors.primary : colors.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          key: paymentStatusKey(status),
          borderRadius: BorderRadius.circular(12),
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.all(Brand.spaceMd),
            child: Row(
              children: <Widget>[
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: selected ? colors.primary : colors.onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(width: Brand.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        paymentStatusLabel(status),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w500,
                          color: selected
                              ? colors.onPrimaryContainer
                              : colors.onSurface,
                        ),
                      ),
                      Text(
                        paymentStatusHint(status),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: selected
                              ? colors.onPrimaryContainer
                              : colors.onSurfaceVariant,
                        ),
                      ),
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
