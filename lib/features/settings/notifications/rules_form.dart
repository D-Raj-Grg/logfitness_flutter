// When reminders go out, and to whom.
//
// Port of `logfitness_saas/components/notifications/rules-form.tsx`. One row
// per `notification_rules` row, and the titles are `ruleTitle()`'s sentences
// copied verbatim -- T-7 and T-1 are not two events but two rows of one
// `renewal_reminder` with different `offset_days`, and the only thing that
// tells an owner which row is which is the sentence.
//
// Money is integer paisa (CLAUDE.md). The field is edited in rupees because
// that is what an owner thinks in, and the conversion happens exactly once, at
// this render boundary, in integer arithmetic. No `double` touches it: a
// threshold that drifts by a paisa is a member chased over a rounding error.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/data/notifications/notification_rule.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/features/common/async_value_view.dart';
import 'package:logfitness_flutter/features/common/failure_snackbar.dart';
import 'package:logfitness_flutter/features/settings/notifications/notification_settings_actions.dart';
import 'package:logfitness_flutter/features/settings/notifications/notification_settings_controllers.dart';

/// The sentence describing one rule. `ruleTitle()` upstream, verbatim.
String notificationRuleTitle(NotificationRule rule) => switch (rule.event) {
  NotificationEvent.renewalReminder =>
    rule.offsetDays == 1
        ? 'The day before a membership ends'
        : '${rule.offsetDays} days before a membership ends',
  NotificationEvent.duesReminder =>
    rule.offsetDays == 0
        ? 'As soon as money is outstanding'
        : 'When money has been outstanding for ${rule.offsetDays} days',
  NotificationEvent.birthdayGreeting => 'On a member’s birthday',
  NotificationEvent.visitorWelcome =>
    'As soon as a visitor is logged at the desk',
  NotificationEvent.visitorFollowUp =>
    rule.offsetDays == 1
        ? 'The day after a visit, if they have not joined'
        : '${rule.offsetDays} days after a visit, if they have not joined',
  NotificationEvent.memberWelcome =>
    'When somebody buys their first membership',
  NotificationEvent.paymentReceived => 'Every time money is handed over',
  NotificationEvent.duesCleared =>
    'When a member has nothing left outstanding',
  _ => rule.event.wire.replaceAll('_', ' '),
};

/// The highest dues threshold this form will save.
///
/// The console caps its rupee input at 10,000,000. This app applies the ceiling
/// in paisa -- the unit the column is actually in, and the only unit money is
/// allowed to travel in below the render boundary (CLAUDE.md) -- which puts the
/// practical limit at Rs 100,000 of outstanding dues before a member is chased.
/// **A deliberate deviation from the console's number, recorded here rather
/// than discovered later.**
const int kMinAmountCeilingPaisa = 10000000;

/// Rupees, as typed, into the integer paisa the column stores.
///
/// Integer arithmetic throughout: the whole rupees and the paisa are parsed as
/// separate integers and combined, so nothing is ever multiplied as a double.
/// `null` for anything that is typed but is not an amount.
///
/// **A blank field is 0, not null** -- it reads as "no minimum", which is what
/// the column defaults to and what `min_amount_paisa = 0` means to the dues
/// sweep: chase any outstanding amount. The console lands in the same place by
/// a different route (`z.coerce.number().catch(0).default(0)` on an empty
/// string), so the two clients agree. The consequence is worth knowing: an
/// owner who clears the box and saves has not cancelled the edit, they have
/// removed the floor.
int? rupeesFieldToPaisa(String value) {
  final String trimmed = value.trim().replaceAll(',', '');
  if (trimmed.isEmpty) return 0;

  final List<String> parts = trimmed.split('.');
  if (parts.length > 2) return null;

  final int? rupees = int.tryParse(parts.first);
  if (rupees == null || rupees < 0) return null;

  int paisa = 0;
  if (parts.length == 2) {
    // Pad "5" to "50" and truncate "567" to "56": a third decimal place is not
    // money here, and rounding it would invent a paisa the owner did not type.
    final String fraction = parts[1].padRight(2, '0').substring(0, 2);
    final int? parsed = int.tryParse(fraction);
    if (parsed == null || parsed < 0) return null;
    paisa = parsed;
  }

  return rupees * 100 + paisa;
}

/// Integer paisa back into the rupee string the field is edited as. The inverse
/// of [rupeesFieldToPaisa], and equally free of doubles.
String paisaToRupeesField(int paisa) {
  final int rupees = paisa ~/ 100;
  final int remainder = paisa % 100;
  if (remainder == 0) return '$rupees';
  return '$rupees.${remainder.toString().padLeft(2, '0')}';
}

class RulesForm extends ConsumerWidget {
  const RulesForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AsyncValue<List<NotificationRule>> rules = ref.watch(
      notificationRulesProvider,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Brand.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Reminders', style: theme.textTheme.titleMedium),
            const SizedBox(height: Brand.spaceXs),
            Text(
              'Worked out once a night at 02:30. A reminder set for earlier than '
              'that goes out the following morning. Nothing is sent, and nothing '
              'is charged, until a gateway is connected above.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Brand.spaceSm),
            AsyncValueView<List<NotificationRule>>(
              value: rules,
              onRetry: () => ref.invalidate(notificationRulesProvider),
              isEmpty: (List<NotificationRule> rows) => rows.isEmpty,
              emptyMessage: 'No reminders are set up for this gym yet.',
              data: (List<NotificationRule> rows) => Column(
                children: <Widget>[
                  for (final NotificationRule rule in rows)
                    _RuleRow(
                      // Rebuilt from the saved row after a write, rather than
                      // keeping whatever was typed: the database is what
                      // decides the row's final contents.
                      key: ValueKey<String>('${rule.id}-${rule.updatedAt}'),
                      rule: rule,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RuleRow extends ConsumerStatefulWidget {
  const _RuleRow({required this.rule, super.key});

  final NotificationRule rule;

  @override
  ConsumerState<_RuleRow> createState() => _RuleRowState();
}

class _RuleRowState extends ConsumerState<_RuleRow> {
  late bool _enabled;
  late TimeOfDay _sendAt;
  late final TextEditingController _minAmount;
  late final TextEditingController _repeatAfterDays;

  @override
  void initState() {
    super.initState();
    _enabled = widget.rule.enabled;
    _sendAt = widget.rule.sendAt;
    _minAmount = TextEditingController(
      text: paisaToRupeesField(widget.rule.minAmountPaisa),
    );
    _repeatAfterDays = TextEditingController(
      text: '${widget.rule.repeatAfterDays}',
    );
  }

  @override
  void dispose() {
    _minAmount.dispose();
    _repeatAfterDays.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final NotificationRule rule = widget.rule;
    final bool saving = ref.watch(notificationSettingsActionsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Brand.spaceSm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CheckboxListTile(
            key: ValueKey<String>('rule-enabled-${rule.id}'),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: _enabled,
            title: Text(notificationRuleTitle(rule)),
            onChanged: (bool? value) =>
                setState(() => _enabled = value ?? false),
          ),

          if (rule.isImmediate)
            // No hour to choose. These rules ride a trigger on the row that
            // causes them -- the walk-in, the sale, the payment -- so offering
            // a time here would promise a schedule that does not exist.
            Padding(
              padding: const EdgeInsets.only(left: Brand.spaceLg),
              child: Text(
                'Goes out within a minute',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(left: Brand.spaceLg),
              child: OutlinedButton.icon(
                key: ValueKey<String>('rule-time-${rule.id}'),
                icon: const Icon(Icons.schedule_outlined, size: 18),
                label: Text('Send at ${sendAtToWire(_sendAt)}'),
                onPressed: () => unawaited(_pickTime()),
              ),
            ),

          if (rule.hasMinAmount || rule.hasRepeat) ...<Widget>[
            const SizedBox(height: Brand.spaceSm),
            Padding(
              padding: const EdgeInsets.only(left: Brand.spaceLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (rule.hasMinAmount)
                    TextField(
                      key: ValueKey<String>('rule-min-amount-${rule.id}'),
                      controller: _minAmount,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Only over (Rs)',
                      ),
                    ),
                  if (rule.hasMinAmount && rule.hasRepeat)
                    const SizedBox(height: Brand.spaceSm),
                  if (rule.hasRepeat)
                    TextField(
                      key: ValueKey<String>('rule-repeat-${rule.id}'),
                      controller: _repeatAfterDays,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Ask again after (days)',
                      ),
                    ),
                ],
              ),
            ),
          ],

          const SizedBox(height: Brand.spaceSm),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: Brand.spaceLg),
              child: OutlinedButton(
                key: ValueKey<String>('rule-save-${rule.id}'),
                onPressed: saving ? null : () => unawaited(_save()),
                child: const Text('Save'),
              ),
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _sendAt,
    );
    if (picked != null && mounted) {
      setState(() => _sendAt = picked);
    }
  }

  Future<void> _save() async {
    final NotificationRule rule = widget.rule;

    final int? paisa = rupeesFieldToPaisa(_minAmount.text);
    if (paisa == null) {
      showFailureSnackBar(
        context,
        const AppFailure(FailureKind.invalid, 'That is not an amount.'),
      );
      return;
    }
    if (paisa > kMinAmountCeilingPaisa) {
      showFailureSnackBar(
        context,
        AppFailure(
          FailureKind.invalid,
          'The most this can be is Rs ${paisaToRupeesField(kMinAmountCeilingPaisa)}.',
        ),
      );
      return;
    }

    final int repeat = int.tryParse(_repeatAfterDays.text.trim()) ?? 0;
    if (repeat < 1 || repeat > 365) {
      showFailureSnackBar(
        context,
        const AppFailure(
          FailureKind.invalid,
          'Ask again somewhere between 1 and 365 days.',
        ),
      );
      return;
    }

    final SettingsActionResult result = await ref
        .read(notificationSettingsActionsProvider.notifier)
        .saveRule(
          ruleId: rule.id,
          enabled: _enabled,
          minAmountPaisa: paisa,
          repeatAfterDays: repeat,
          // `HH:MM` text, never a `DateTime`. A `time` column has no date and
          // no zone; parsing it into an instant invents both, and the org's
          // timezone is not the phone's.
          sendAtLocal: sendAtToWire(_sendAt),
        );
    if (!mounted) return;

    switch (result) {
      case SettingsActionSucceeded(:final String message):
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      case SettingsActionFailed(:final AppFailure failure):
        showFailureSnackBar(context, failure);
    }
  }
}
