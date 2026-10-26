// Settings -> Fees -> add or edit a fee (owner only).
//
// Port of the console's `components/settings/fee-form.tsx`. Validation is pure
// (`lib/domain/validation/fee_form.dart`); the write is
// `FeesRepository.createFee` / `updateFee`. Role gating is UX only: the RLS
// policies on `fees` are the boundary, and a refusal reaches the screen as a
// sentence, never as a silent "saved".
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/data/fees/fee.dart';
import 'package:logfitness_flutter/data/fees/fees_repository.dart';
import 'package:logfitness_flutter/data/plans/membership_plan.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/domain/format/money.dart';
import 'package:logfitness_flutter/domain/validation/fee_form.dart';
import 'package:logfitness_flutter/features/common/failure_snackbar.dart';
import 'package:logfitness_flutter/features/common/picker_field.dart';
import 'package:logfitness_flutter/features/settings/catalogue/fee_providers.dart';
import 'package:logfitness_flutter/features/settings/catalogue/plan_providers.dart';
import 'package:logfitness_flutter/supabase/app_claims.dart';
import 'package:logfitness_flutter/supabase/supabase_providers.dart';

class FeeFormScreen extends ConsumerStatefulWidget {
  /// Pass [fee] to edit it; leave it null to add a new one.
  const FeeFormScreen({this.fee, super.key});

  final Fee? fee;

  @override
  ConsumerState<FeeFormScreen> createState() => _FeeFormScreenState();
}

class _FeeFormScreenState extends ConsumerState<FeeFormScreen> {
  late final TextEditingController _name;
  late final TextEditingController _amount;

  late FeeChargeRule _rule;
  late bool _allPlans;
  late Set<String> _planIds;
  late bool _isActive;
  Map<FeeField, String> _errors = <FeeField, String>{};
  bool _saving = false;

  bool get _editing => widget.fee != null;

  @override
  void initState() {
    super.initState();
    final Fee? f = widget.fee;
    _name = TextEditingController(text: f?.name ?? '');
    _amount = TextEditingController(
      text: f == null || f.amountPaisa == 0 ? '' : fromPaisa(f.amountPaisa),
    );
    _rule = f?.chargeRule ?? FeeChargeRule.once;
    // A new fee starts on for every plan: the common case is registration or a
    // card fee on everything, and unticking is one tap.
    _allPlans = f?.allPlans ?? true;
    _planIds = <String>{...?f?.planIds};
    _isActive = f?.isActive ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final AppClaims? claims = ref.read(claimsProvider);
    if (claims == null) {
      showFailureSnackBar(
        context,
        const AppFailure(
          FailureKind.unauthenticated,
          'Your session has expired. Sign in again to continue.',
        ),
      );
      return;
    }

    final FeeValidation result = validateFee(
      name: _name.text,
      amount: _amount.text,
      chargeRule: _rule,
      allPlans: _allPlans,
      planIds: _planIds.toList(),
      isActive: _editing ? _isActive : true,
    );
    setState(() => _errors = result.errors);
    if (!result.isValid) return;

    setState(() => _saving = true);
    final FeesRepository repo = ref.read(feesRepositoryProvider);
    try {
      if (_editing) {
        await repo.updateFee(widget.fee!.id, result.values!);
      } else {
        await repo.createFee(orgId: claims.orgId, values: result.values!);
      }
    } catch (error, stackTrace) {
      final AppFailure failure = mapError(error, stackTrace);
      if (!mounted) return;
      setState(() {
        _saving = false;
        if (failure.kind == FailureKind.duplicate) {
          _errors = <FeeField, String>{FeeField.name: failure.message};
        }
      });
      showFailureSnackBar(context, failure);
      return;
    }
    refreshFeeProviders(ref);
    if (!mounted) return;
    final String saved = _editing
        ? 'Fee saved. It applies to new sales only.'
        : '${result.values!.name} was added.';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(saved)));
    Navigator.of(context).pop(true);
  }

  InputDecoration _decoration(
    String label,
    FeeField field, {
    String? helper,
    String? prefix,
  }) => InputDecoration(
    labelText: label,
    helperText: helper,
    helperMaxLines: 3,
    errorText: _errors[field],
    errorMaxLines: 3,
    prefixText: prefix,
    border: const OutlineInputBorder(),
  );

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<MembershipPlan> plans =
        ref.watch(planCatalogueProvider).value ?? const <MembershipPlan>[];

    return Scaffold(
      appBar: AppBar(title: Text(_editing ? 'Edit fee' : 'New fee')),
      bottomNavigationBar: Material(
        color: theme.colorScheme.surface,
        child: SafeArea(
          top: false,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: Brand.spaceMd,
              vertical: Brand.spaceSm,
            ),
            // A Row, not an Align: Align fills the height it is given, and a
            // bottomNavigationBar is given the whole screen.
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FilledButton(
                  key: const ValueKey<String>('fee-form-save'),
                  onPressed: _saving ? null : () => unawaited(_save()),
                  child: Text(
                    _saving
                        ? 'Saving…'
                        : (_editing ? 'Save changes' : 'Add fee'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(
          Brand.spaceMd,
          Brand.spaceMd,
          Brand.spaceMd,
          Brand.spaceLg,
        ),
        children: <Widget>[
          TextField(
            key: const ValueKey<String>('fee-name'),
            controller: _name,
            enabled: !_saving,
            maxLength: kMaxFeeNameLength,
            textCapitalization: TextCapitalization.sentences,
            decoration: _decoration(
              'Fee name',
              FeeField.name,
              helper: 'For example Registration fee, Card fee or Locker.',
            ).copyWith(counterText: ''),
          ),
          const SizedBox(height: Brand.spaceMd),
          TextField(
            key: const ValueKey<String>('fee-amount'),
            controller: _amount,
            enabled: !_saving,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _decoration('Amount', FeeField.amount, prefix: 'NPR '),
          ),
          const SizedBox(height: Brand.spaceMd),
          PickerField<FeeChargeRule>(
            key: const ValueKey<String>('fee-rule'),
            label: 'When it is charged',
            value: _rule,
            enabled: !_saving,
            options: const <PickerOption<FeeChargeRule>>[
              PickerOption<FeeChargeRule>(
                value: FeeChargeRule.once,
                label: 'Once, on the first membership',
                subtitle:
                    'A member pays it once. Later renewals show it taken back off.',
                icon: Icons.looks_one_outlined,
              ),
              PickerOption<FeeChargeRule>(
                value: FeeChargeRule.everySale,
                label: 'On every sale',
                subtitle: 'Charged again on every sale and renewal.',
                icon: Icons.repeat,
              ),
            ],
            onChanged: (FeeChargeRule? r) {
              if (r != null) setState(() => _rule = r);
            },
          ),
          const SizedBox(height: Brand.spaceLg),
          Padding(
            padding: const EdgeInsets.only(bottom: Brand.spaceSm),
            child: Semantics(
              header: true,
              child: Text('Applies to', style: theme.textTheme.titleMedium),
            ),
          ),
          SwitchListTile(
            key: const ValueKey<String>('fee-all-plans'),
            contentPadding: EdgeInsets.zero,
            title: const Text('All plans'),
            subtitle: const Text('Includes plans you add later.'),
            value: _allPlans,
            onChanged: _saving
                ? null
                : (bool v) => setState(() => _allPlans = v),
          ),
          if (!_allPlans) ...<Widget>[
            Text(
              'Pick the plans that carry this fee. A plan added later needs it '
              'ticked here.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Brand.spaceSm),
            if (plans.isEmpty)
              Text('No plans to choose from.', style: theme.textTheme.bodySmall)
            else
              Wrap(
                spacing: Brand.spaceSm,
                runSpacing: Brand.spaceSm,
                children: <Widget>[
                  for (final MembershipPlan p in plans)
                    FilterChip(
                      key: ValueKey<String>('fee-plan-${p.id}'),
                      label: Text(p.isActive ? p.name : '${p.name} (inactive)'),
                      selected: _planIds.contains(p.id),
                      onSelected: _saving
                          ? null
                          : (bool on) => setState(() {
                              if (on) {
                                _planIds.add(p.id);
                              } else {
                                _planIds.remove(p.id);
                              }
                            }),
                    ),
                ],
              ),
          ],
          if (_errors[FeeField.planIds] != null)
            Padding(
              padding: const EdgeInsets.only(top: Brand.spaceSm),
              child: Text(
                _errors[FeeField.planIds]!,
                key: const ValueKey<String>('fee-plans-error'),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          if (_editing) ...<Widget>[
            const SizedBox(height: Brand.spaceMd),
            SwitchListTile(
              key: const ValueKey<String>('fee-active'),
              contentPadding: EdgeInsets.zero,
              title: const Text('Active'),
              subtitle: const Text(
                'Turn off to stop charging it. Sales already made are not changed.',
              ),
              value: _isActive,
              onChanged: _saving
                  ? null
                  : (bool v) => setState(() => _isActive = v),
            ),
          ],
        ],
      ),
    );
  }
}
