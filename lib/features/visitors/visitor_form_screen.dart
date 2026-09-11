// Log a walk-in, or edit one already logged.
//
// One screen for both, because the fields are the same and the difference is
// whether an id already exists. The alternative -- two screens that drift --
// is how a "log" and an "edit" end up disagreeing about what a valid phone
// number is.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/data/visitors/visitor.dart';
import 'package:logfitness_flutter/data/plans/membership_plan.dart';
import 'package:logfitness_flutter/data/plans/plans_repository.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/domain/format/dates.dart';
import 'package:logfitness_flutter/features/common/failure_snackbar.dart';
import 'package:logfitness_flutter/features/staff/branch_scope.dart';
import 'package:logfitness_flutter/features/visitors/visitor_actions_controller.dart';
import 'package:logfitness_flutter/features/visitors/widgets/visitor_labels.dart';
import 'package:logfitness_flutter/supabase/supabase_providers.dart';

class VisitorFormScreen extends ConsumerStatefulWidget {
  const VisitorFormScreen({this.existing, super.key});

  /// The visitor being edited, or null to log a new walk-in.
  final Visitor? existing;

  bool get isEditing => existing != null;

  @override
  ConsumerState<VisitorFormScreen> createState() => _VisitorFormScreenState();
}

class _VisitorFormScreenState extends ConsumerState<VisitorFormScreen> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _note;

  late VisitorKind _kind;
  DateTime? _visitedOn;
  String? _branchId;
  String? _interestedPlanId;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _name = TextEditingController(text: existing?.fullName ?? '');
    _phone = TextEditingController(text: existing?.phone ?? '');
    _note = TextEditingController(text: existing?.note ?? '');
    _kind = existing?.kind ?? VisitorKind.enquiry;
    // Prefilled with the org's today, matching the console, so the desk can see
    // the date it is about to record rather than the word "Today".
    //
    // `todayInOrgTimezone()` and not `DateTime.now()`: at 00:30 in Kathmandu
    // the device's UTC date is still yesterday, and a walk-in logged then would
    // land on the wrong calendar day. Clearing the field still falls back to
    // the `set_visitor_defaults` trigger, which remains the safety net.
    _visitedOn = existing?.visitedOn ?? todayInOrgTimezone();
    _branchId = existing?.branchId;
    _interestedPlanId = existing?.interestedPlanId;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scope = ref.watch(branchScopeProvider);
    final names = ref.watch(branchNamesProvider);
    final saving = ref.watch(visitorActionsProvider);

    final branchOptions = scope.options;
    _branchId ??= scope.selectedBranchId ??
        (branchOptions.length == 1 ? branchOptions.single : null);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit walk-in' : 'Log a walk-in'),
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(Brand.spaceMd),
          children: <Widget>[
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Full name'),
              // Matches the upstream check constraint (1..120) rather than
              // guessing, so the form refuses what the database would.
              validator: (String? value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty) {
                  return 'A name is required.';
                }
                if (trimmed.length > 120) {
                  return 'That name is too long.';
                }
                return null;
              },
            ),
            const SizedBox(height: Brand.spaceMd),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone'),
              validator: (String? value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty) {
                  return 'A phone number is required.';
                }
                if (trimmed.length > 30) {
                  return 'That phone number is too long.';
                }
                return null;
              },
            ),
            const SizedBox(height: Brand.spaceMd),
            SegmentedButton<VisitorKind>(
              segments: <ButtonSegment<VisitorKind>>[
                for (final VisitorKind kind in VisitorKind.values)
                  ButtonSegment<VisitorKind>(
                    value: kind,
                    label: Text(visitorKindDescription(kind)),
                  ),
              ],
              selected: <VisitorKind>{_kind},
              onSelectionChanged: (Set<VisitorKind> selection) =>
                  setState(() => _kind = selection.first),
            ),
            if (branchOptions.length > 1) ...<Widget>[
              const SizedBox(height: Brand.spaceMd),
              DropdownButtonFormField<String>(
                initialValue: _branchId,
                decoration: const InputDecoration(labelText: 'Branch'),
                items: <DropdownMenuItem<String>>[
                  for (final String id in branchOptions)
                    DropdownMenuItem<String>(
                      value: id,
                      child: Text(names[id] ?? 'Branch ${id.substring(0, 8)}'),
                    ),
                ],
                onChanged: (String? value) => setState(() {
                  _branchId = value;
                  // The plan catalogue is per branch. Keeping a selection the
                  // new branch does not sell would submit an id that looks
                  // deliberate and is not, so it is dropped back to "not said"
                  // -- the console derives it the same way rather than holding
                  // an invalid value.
                  _interestedPlanId = null;
                }),
                validator: (String? value) =>
                    value == null ? 'Pick the branch they walked into.' : null,
              ),
            ],
            const SizedBox(height: Brand.spaceMd),
            _VisitedOnField(
              value: _visitedOn,
              onPick: (DateTime? picked) => setState(() => _visitedOn = picked),
            ),
            const SizedBox(height: Brand.spaceMd),
            _InterestedPlanField(
              branchId: _branchId,
              value: _interestedPlanId,
              onChanged: (String? planId) =>
                  setState(() => _interestedPlanId = planId),
            ),
            const SizedBox(height: Brand.spaceMd),
            TextFormField(
              controller: _note,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                hintText: 'What they asked about, when to call back.',
              ),
            ),
            const SizedBox(height: Brand.spaceLg),
            FilledButton(
              key: const ValueKey<String>('visitor-form-submit'),
              onPressed: saving ? null : _submit,
              child: Text(saving
                  ? 'Saving…'
                  : (widget.isEditing ? 'Save changes' : 'Log walk-in')),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_form.currentState?.validate() ?? false)) {
      return;
    }

    final claims = ref.read(claimsProvider);
    final orgId = claims?.orgId;
    // `_branchId` is already resolved in `build` — a lone branch is adopted
    // automatically and several force the picker, which validates. Reaching
    // here with nothing means the org has no branch this session can read,
    // which is a broken account rather than a missed field.
    final branchId = _branchId;

    if (orgId == null || branchId == null) {
      // Rare, and a bug rather than a user error -- but it still has to say
      // something rather than silently doing nothing, which is the failure
      // mode this app keeps designing against.
      showFailureSnackBar(
        context,
        const AppFailure(
          FailureKind.unknown,
          'No branch is set up for this gym yet, so there is nowhere to record '
          'a walk-in. Add a branch on the web console first.',
        ),
      );
      return;
    }

    final actions = ref.read(visitorActionsProvider.notifier);
    final VisitorActionResult result = widget.isEditing
        ? await actions.update(
            widget.existing!.id,
            fullName: _name.text.trim(),
            phone: _phone.text.trim(),
            kind: _kind,
            visitedOn: _visitedOn,
            note: _note.text.trim().isEmpty ? null : _note.text.trim(),
            // Explicit null clears it: "not said" is an answer, and an edit
            // that unsets the plan has to be able to say so.
            interestedPlanId: _interestedPlanId,
          )
        : await actions.log(
            orgId: orgId,
            branchId: branchId,
            fullName: _name.text.trim(),
            phone: _phone.text.trim(),
            kind: _kind,
            // Prefilled with the org's today and editable for a backdated log.
            // Cleared, the `set_visitor_defaults` trigger fills it instead.
            visitedOn: _visitedOn,
            note: _note.text.trim().isEmpty ? null : _note.text.trim(),
            interestedPlanId: _interestedPlanId,
          );

    if (!mounted) {
      return;
    }

    switch (result) {
      case VisitorActionSucceeded(:final String? visitorId):
        Navigator.of(context).pop(visitorId);
      case VisitorActionFailed(:final failure):
        // The form keeps everything typed. A refusal or a dropped connection
        // is not a reason to make someone re-enter a walk-in they are
        // standing in front of.
        showFailureSnackBar(context, failure);
    }
  }
}

/// Plans sellable at one branch.
///
/// Declared here rather than imported from the register screen: a visitors
/// screen reaching into a members *screen* for a provider is the wrong
/// direction, and `listPlansForBranch` already encodes the rule the console
/// applies client-side — active plans whose `branch_ids` is empty (org-wide) or
/// contains this branch.
final visitorBranchPlansProvider =
    FutureProvider.family<List<MembershipPlan>, String>((ref, String branchId) {
  return ref.watch(plansRepositoryProvider).listPlansForBranch(branchId);
});

/// "Interested in" — which plan they asked about.
///
/// Optional, and the single most useful thing on an enquiry: it is the callback
/// script. Offered per branch, because a plan that is not on sale where they
/// walked in is not a thing they can be sold.
class _InterestedPlanField extends ConsumerWidget {
  const _InterestedPlanField({
    required this.branchId,
    required this.value,
    required this.onChanged,
  });

  final String? branchId;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branch = branchId;
    if (branch == null) {
      return const SizedBox.shrink();
    }

    final plans = ref.watch(visitorBranchPlansProvider(branch));

    return plans.when(
      loading: () => const InputDecorator(
        decoration: InputDecoration(labelText: 'Interested in (optional)'),
        child: LinearProgressIndicator(),
      ),
      // A plan list that failed to load must not look like a gym with no
      // plans. It is optional either way, so the field simply stands down
      // rather than claiming there is nothing to choose.
      error: (Object _, StackTrace _) => const SizedBox.shrink(),
      data: (List<MembershipPlan> rows) {
        // A plan the branch does not sell -- carried over from an edit, or from
        // a branch change -- is not offered and not kept.
        final bool known = rows.any((MembershipPlan p) => p.id == value);
        return DropdownButtonFormField<String?>(
          key: const ValueKey<String>('visitor-interested-plan'),
          initialValue: known ? value : null,
          decoration: const InputDecoration(
            labelText: 'Interested in (optional)',
          ),
          items: <DropdownMenuItem<String?>>[
            const DropdownMenuItem<String?>(child: Text(kNoPlanSaid)),
            for (final MembershipPlan plan in rows)
              DropdownMenuItem<String?>(
                value: plan.id,
                child: Text(plan.name),
              ),
          ],
          onChanged: onChanged,
        );
      },
    );
  }
}

class _VisitedOnField extends StatelessWidget {
  const _VisitedOnField({required this.value, required this.onPick});

  final DateTime? value;
  final ValueChanged<DateTime?> onPick;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Visited on',
        // Says out loud why leaving it blank is the right default.
        helperText: "Leave blank for today at this gym's own reckoning",
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              value == null ? 'Today' : formatPlainDate(value!),
            ),
          ),
          if (value != null)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Use today',
              onPressed: () => onPick(null),
            ),
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            tooltip: 'Pick a date',
            onPressed: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: value ?? now,
                // Backdating only. A walk-in that has not happened yet is not
                // a walk-in.
                firstDate: DateTime(now.year - 2),
                lastDate: now,
              );
              if (picked != null) {
                onPick(DateTime.utc(picked.year, picked.month, picked.day));
              }
            },
          ),
        ],
      ),
    );
  }
}
