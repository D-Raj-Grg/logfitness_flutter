// Settings -> Plans -> add or edit a plan (owner and manager).
//
// Port of `logfitness_saas/components/plans/plan-form.tsx`. Validation is
// pure (`lib/domain/validation/plan_form.dart`); the write is
// `PlansRepository.createPlan` / `updatePlan`. Role gating is UX only: the
// RLS policies on `membership_plans` are the boundary, and a refusal reaches
// the screen as a sentence, never as a silent "saved".
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/data/branches/branch.dart';
import 'package:logfitness_flutter/data/branches/branches_repository.dart';
import 'package:logfitness_flutter/data/plans/membership_plan.dart';
import 'package:logfitness_flutter/data/plans/plans_repository.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/domain/format/money.dart';
import 'package:logfitness_flutter/domain/validation/plan_form.dart';
import 'package:logfitness_flutter/features/common/failure_snackbar.dart';
import 'package:logfitness_flutter/features/common/picker_field.dart';
import 'package:logfitness_flutter/features/settings/catalogue/plan_providers.dart';
import 'package:logfitness_flutter/features/staff/staff_capabilities.dart';
import 'package:logfitness_flutter/supabase/app_claims.dart';
import 'package:logfitness_flutter/supabase/supabase_providers.dart';

String planTypeName(PlanType type) =>
    type == PlanType.sessionPack ? 'Session pack' : 'Time-based';

class PlanFormScreen extends ConsumerStatefulWidget {
  /// Pass [plan] to edit it; leave it null to add a new one.
  const PlanFormScreen({this.plan, super.key});

  final MembershipPlan? plan;

  @override
  ConsumerState<PlanFormScreen> createState() => _PlanFormScreenState();
}

class _PlanFormScreenState extends ConsumerState<PlanFormScreen> {
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _price;
  late final TextEditingController _fee;
  late final TextEditingController _days;
  late final TextEditingController _sessions;

  late PlanType _type;
  late Set<String> _branchIds;
  late bool _isActive;
  Map<PlanField, String> _errors = <PlanField, String>{};
  bool _saving = false;

  bool get _editing => widget.plan != null;

  @override
  void initState() {
    super.initState();
    final MembershipPlan? p = widget.plan;
    _name = TextEditingController(text: p?.name ?? '');
    _description = TextEditingController(text: p?.description ?? '');
    _price = TextEditingController(
      text: p == null || p.pricePaisa == 0 ? '' : fromPaisa(p.pricePaisa),
    );
    _fee = TextEditingController(
      text: p == null || p.signupFeePaisa == 0
          ? ''
          : fromPaisa(p.signupFeePaisa),
    );
    _days = TextEditingController(text: p?.durationDays?.toString() ?? '');
    _sessions = TextEditingController(text: p?.sessionCount?.toString() ?? '');
    _type = p?.planType ?? PlanType.time;
    _branchIds = <String>{...?p?.branchIds};
    _isActive = p?.isActive ?? true;

    // A manager with exactly one branch has nothing to choose: start there.
    if (p == null) {
      final AppClaims? claims = ref.read(claimsProvider);
      final StaffRole? role = ref.read(staffRoleProvider);
      if (role != null &&
          role != StaffRole.owner &&
          claims != null &&
          claims.branchIds.length == 1) {
        _branchIds = <String>{claims.branchIds.first};
      }
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _price.dispose();
    _fee.dispose();
    _days.dispose();
    _sessions.dispose();
    super.dispose();
  }

  bool get _blockedByScope {
    final MembershipPlan? p = widget.plan;
    final StaffRole? role = ref.read(staffRoleProvider);
    final AppClaims? claims = ref.read(claimsProvider);
    if (p == null || role == null) return false;
    return !canScopePlan(
      role,
      claims?.branchIds ?? const <String>[],
      p.branchIds,
    );
  }

  Future<void> _save() async {
    final StaffRole? role = ref.read(staffRoleProvider);
    final AppClaims? claims = ref.read(claimsProvider);
    if (role == null || claims == null) {
      showFailureSnackBar(
        context,
        const AppFailure(
          FailureKind.unauthenticated,
          'Your session has expired. Sign in again to continue.',
        ),
      );
      return;
    }

    final PlanValidation result = validatePlan(
      name: _name.text,
      description: _description.text,
      planType: _type,
      durationDays: _days.text,
      sessionCount: _sessions.text,
      price: _price.text,
      signupFee: _fee.text,
      branchIds: _branchIds.toList(),
      role: role,
      actorBranchIds: claims.branchIds,
      isActive: _editing ? _isActive : true,
    );
    setState(() => _errors = result.errors);
    if (!result.isValid) return;

    setState(() => _saving = true);
    final PlansRepository repo = ref.read(plansRepositoryProvider);
    try {
      if (_editing) {
        await repo.updatePlan(widget.plan!.id, result.values!);
      } else {
        await repo.createPlan(orgId: claims.orgId, values: result.values!);
      }
    } catch (error, stackTrace) {
      final AppFailure failure = mapError(error, stackTrace);
      if (!mounted) return;
      setState(() {
        _saving = false;
        if (failure.kind == FailureKind.duplicate) {
          _errors = <PlanField, String>{PlanField.name: failure.message};
        }
      });
      showFailureSnackBar(context, failure);
      return;
    }
    refreshPlanProviders(ref);
    if (!mounted) return;
    final String saved = _editing
        ? 'Plan saved.'
        : '${result.values!.name} was added to the catalogue.';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(saved)));
    Navigator.of(context).pop(true);
  }

  InputDecoration _decoration(
    String label,
    PlanField field, {
    String? hint,
    String? helper,
    String? prefix,
  }) => InputDecoration(
    labelText: label,
    hintText: hint,
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
    final StaffRole? role = ref.watch(staffRoleProvider);
    final AppClaims? claims = ref.watch(claimsProvider);
    final bool isOwner = role == StaffRole.owner;
    final List<Branch> allBranches =
        ref.watch(branchesProvider).value ?? const <Branch>[];
    final List<Branch> choices = isOwner
        ? allBranches
        : allBranches
              .where((Branch b) => claims?.branchIds.contains(b.id) ?? false)
              .toList();
    final bool blocked = _blockedByScope;
    final bool isPack = _type == PlanType.sessionPack;

    return Scaffold(
      appBar: AppBar(title: Text(_editing ? 'Edit plan' : 'New plan')),
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
                  key: const ValueKey<String>('plan-form-save'),
                  onPressed: _saving || blocked
                      ? null
                      : () => unawaited(_save()),
                  child: Text(
                    _saving
                        ? 'Saving…'
                        : (_editing ? 'Save changes' : 'Add plan'),
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
          if (blocked) ...<Widget>[
            _Notice(message: kPlanEditOutOfScope),
            const SizedBox(height: Brand.spaceMd),
          ],
          const _SectionTitle('Basics'),
          TextField(
            key: const ValueKey<String>('plan-name'),
            controller: _name,
            enabled: !_saving,
            maxLength: kMaxPlanNameLength,
            textCapitalization: TextCapitalization.words,
            decoration: _decoration(
              'Plan name',
              PlanField.name,
            ).copyWith(counterText: ''),
          ),
          const SizedBox(height: Brand.spaceMd),
          TextField(
            key: const ValueKey<String>('plan-description'),
            controller: _description,
            enabled: !_saving,
            minLines: 2,
            maxLines: 4,
            maxLength: kMaxPlanDescriptionLength,
            textCapitalization: TextCapitalization.sentences,
            decoration: _decoration(
              'Description (optional)',
              PlanField.description,
            ).copyWith(counterText: ''),
          ),
          const SizedBox(height: Brand.spaceMd),
          PickerField<PlanType>(
            key: const ValueKey<String>('plan-type'),
            label: 'Plan type',
            value: _type,
            enabled: !_saving,
            options: const <PickerOption<PlanType>>[
              PickerOption<PlanType>(
                value: PlanType.time,
                label: 'Time-based',
                subtitle: 'Runs for a number of days',
                icon: Icons.calendar_month_outlined,
              ),
              PickerOption<PlanType>(
                value: PlanType.sessionPack,
                label: 'Session pack',
                subtitle: 'A set number of visits, optionally with an expiry',
                icon: Icons.confirmation_number_outlined,
              ),
            ],
            onChanged: (PlanType? t) {
              if (t != null) setState(() => _type = t);
            },
          ),
          if (_editing) ...<Widget>[
            const SizedBox(height: Brand.spaceSm),
            SwitchListTile(
              key: const ValueKey<String>('plan-active'),
              contentPadding: EdgeInsets.zero,
              title: const Text('Active (on sale)'),
              subtitle: const Text(
                'Turn off to stop selling this plan. Memberships already sold are not changed.',
              ),
              value: _isActive,
              onChanged: _saving
                  ? null
                  : (bool v) => setState(() => _isActive = v),
            ),
          ],
          const SizedBox(height: Brand.spaceLg),
          const _SectionTitle('Price'),
          TextField(
            key: const ValueKey<String>('plan-price'),
            controller: _price,
            enabled: !_saving,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _decoration('Price', PlanField.price, prefix: 'NPR '),
          ),
          const SizedBox(height: Brand.spaceMd),
          TextField(
            key: const ValueKey<String>('plan-fee'),
            controller: _fee,
            enabled: !_saving,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _decoration(
              'Joining fee (optional)',
              PlanField.signupFee,
              prefix: 'NPR ',
              helper: 'Charged once, on a member\'s first membership.',
            ),
          ),
          const SizedBox(height: Brand.spaceLg),
          const _SectionTitle('Term'),
          if (isPack) ...<Widget>[
            TextField(
              key: const ValueKey<String>('plan-sessions'),
              controller: _sessions,
              enabled: !_saving,
              keyboardType: TextInputType.number,
              decoration: _decoration(
                'Number of sessions',
                PlanField.sessionCount,
              ),
            ),
            const SizedBox(height: Brand.spaceMd),
          ],
          TextField(
            key: const ValueKey<String>('plan-days'),
            controller: _days,
            enabled: !_saving,
            keyboardType: TextInputType.number,
            decoration: _decoration(
              isPack ? 'Valid for, in days (optional)' : 'Duration in days',
              PlanField.durationDays,
              helper: isPack
                  ? 'Leave blank if the sessions never expire.'
                  : null,
            ),
          ),
          const SizedBox(height: Brand.spaceLg),
          const _SectionTitle('Where it is sold'),
          Text(
            isOwner
                ? 'Leave all unselected to sell it at every branch.'
                : 'Pick at least one of your branches.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Brand.spaceSm),
          if (choices.isEmpty)
            Text(
              'No branches to choose from.',
              style: theme.textTheme.bodySmall,
            )
          else
            Wrap(
              spacing: Brand.spaceSm,
              runSpacing: Brand.spaceSm,
              children: <Widget>[
                for (final Branch b in choices)
                  FilterChip(
                    key: ValueKey<String>('plan-branch-${b.id}'),
                    label: Text(b.name),
                    selected: _branchIds.contains(b.id),
                    onSelected: _saving
                        ? null
                        : (bool on) => setState(() {
                            if (on) {
                              _branchIds.add(b.id);
                            } else {
                              _branchIds.remove(b.id);
                            }
                          }),
                  ),
              ],
            ),
          if (isOwner && _branchIds.isEmpty && choices.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: Brand.spaceSm),
              child: Text(
                'Sold at every branch.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          if (_errors[PlanField.branchIds] != null)
            Padding(
              padding: const EdgeInsets.only(top: Brand.spaceSm),
              child: Text(
                _errors[PlanField.branchIds]!,
                key: const ValueKey<String>('plan-branches-error'),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Brand.spaceSm),
      child: Semantics(
        header: true,
        child: Text(text, style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      key: const ValueKey<String>('plan-scope-notice'),
      padding: const EdgeInsets.all(Brand.spaceMd),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(Brand.radiusMedium),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.block, color: scheme.onErrorContainer),
          const SizedBox(width: Brand.spaceSm),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: scheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}
