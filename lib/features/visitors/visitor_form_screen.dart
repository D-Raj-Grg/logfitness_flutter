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

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _name = TextEditingController(text: existing?.fullName ?? '');
    _phone = TextEditingController(text: existing?.phone ?? '');
    _note = TextEditingController(text: existing?.note ?? '');
    _kind = existing?.kind ?? VisitorKind.enquiry;
    // Only carried when editing. On a new row it stays null so the
    // `set_visitor_defaults` trigger fills the org's own today -- Kathmandu's
    // day is not UTC's, and the database is the only thing that knows the
    // org's timezone.
    _visitedOn = existing?.visitedOn;
    _branchId = existing?.branchId;
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
                    label: Text(visitorKindLabel(kind)),
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
                onChanged: (String? value) => setState(() => _branchId = value),
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
            TextFormField(
              controller: _note,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Note',
                hintText: 'What did they ask about?',
              ),
            ),
            const SizedBox(height: Brand.spaceLg),
            FilledButton(
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
    final branchId = _branchId ??
        (ref.read(branchScopeProvider).options.isNotEmpty
            ? ref.read(branchScopeProvider).options.first
            : null);

    if (orgId == null || branchId == null) {
      // Rare, and a bug rather than a user error -- but it still has to say
      // something rather than silently doing nothing, which is the failure
      // mode this app keeps designing against.
      showFailureSnackBar(
        context,
        const AppFailure(
          FailureKind.unknown,
          'This session has no branch to log a walk-in against. Sign out and '
          'back in, and tell whoever set up your account if it happens again.',
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
          )
        : await actions.log(
            orgId: orgId,
            branchId: branchId,
            fullName: _name.text.trim(),
            phone: _phone.text.trim(),
            kind: _kind,
            // Null unless the desk deliberately backdated: the trigger fills
            // the org's today, which is the only correct answer here.
            visitedOn: _visitedOn,
            note: _note.text.trim().isEmpty ? null : _note.text.trim(),
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
