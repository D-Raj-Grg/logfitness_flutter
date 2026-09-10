// Editing a member's details.
//
// Deliberately close to the register form's fields, minus the sale and minus
// the photo. What it adds is the one field registration does not carry:
// notification consent.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/data/members/member.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/format/dates.dart';
import 'package:logfitness_flutter/features/common/failure_snackbar.dart';
import 'package:logfitness_flutter/features/members/member_admin_controller.dart';
import 'package:logfitness_flutter/features/members/member_labels.dart';
import 'package:logfitness_flutter/features/staff/branch_scope.dart';

class MemberEditScreen extends ConsumerStatefulWidget {
  const MemberEditScreen({required this.member, super.key});

  final Member member;

  @override
  ConsumerState<MemberEditScreen> createState() => _MemberEditScreenState();
}

class _MemberEditScreenState extends ConsumerState<MemberEditScreen> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  late final TextEditingController _name =
      TextEditingController(text: widget.member.fullName);
  late final TextEditingController _phone =
      TextEditingController(text: widget.member.phone);
  late final TextEditingController _email =
      TextEditingController(text: widget.member.email ?? '');
  late final TextEditingController _address =
      TextEditingController(text: widget.member.address ?? '');
  late final TextEditingController _emergencyName =
      TextEditingController(text: widget.member.emergencyContactName ?? '');
  late final TextEditingController _emergencyPhone =
      TextEditingController(text: widget.member.emergencyContactPhone ?? '');
  late final TextEditingController _notes =
      TextEditingController(text: widget.member.notes ?? '');

  late MemberGender? _gender = widget.member.gender;
  late DateTime? _dateOfBirth = widget.member.dateOfBirth;
  late String _branchId = widget.member.homeBranchId;
  late bool _optOut = widget.member.notificationsOptOut;

  @override
  void dispose() {
    for (final TextEditingController c in <TextEditingController>[
      _name, _phone, _email, _address, _emergencyName, _emergencyPhone, _notes,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scope = ref.watch(branchScopeProvider);
    final names = ref.watch(branchNamesProvider);
    final saving = ref.watch(memberAdminProvider);

    // The member's current home branch stays offered even when this session
    // does not cover it: an edit form that silently moved someone to a branch
    // the editor happens to work at would be a data change nobody asked for.
    final options = <String>{..._branchIdOptions(scope.options), _branchId}
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(title: Text('Edit ${widget.member.fullName}')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(Brand.spaceMd),
          children: <Widget>[
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Full name'),
              validator: (String? v) =>
                  (v?.trim().isEmpty ?? true) ? 'A name is required.' : null,
            ),
            const SizedBox(height: Brand.spaceMd),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone',
                helperText: 'Unique for this gym',
              ),
              validator: (String? v) => (v?.trim().isEmpty ?? true)
                  ? 'A phone number is required.'
                  : null,
            ),
            if (options.length > 1) ...<Widget>[
              const SizedBox(height: Brand.spaceMd),
              DropdownButtonFormField<String>(
                initialValue: _branchId,
                decoration: const InputDecoration(labelText: 'Home branch'),
                items: <DropdownMenuItem<String>>[
                  for (final String id in options)
                    DropdownMenuItem<String>(
                      value: id,
                      child: Text(names[id] ?? 'Branch ${id.substring(0, 8)}'),
                    ),
                ],
                onChanged: (String? v) =>
                    setState(() => _branchId = v ?? _branchId),
              ),
            ],
            const SizedBox(height: Brand.spaceMd),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: Brand.spaceMd),
            _DobField(
              value: _dateOfBirth,
              onPick: (DateTime? v) => setState(() => _dateOfBirth = v),
            ),
            const SizedBox(height: Brand.spaceMd),
            DropdownButtonFormField<MemberGender>(
              initialValue: _gender,
              decoration: const InputDecoration(labelText: 'Gender'),
              items: <DropdownMenuItem<MemberGender>>[
                for (final MemberGender g in MemberGender.values)
                  DropdownMenuItem<MemberGender>(
                    value: g,
                    child: Text(memberGenderLabel(g)),
                  ),
              ],
              onChanged: (MemberGender? v) => setState(() => _gender = v),
            ),
            const SizedBox(height: Brand.spaceMd),
            TextFormField(
              controller: _address,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
            const SizedBox(height: Brand.spaceMd),
            TextFormField(
              controller: _emergencyName,
              decoration:
                  const InputDecoration(labelText: 'Emergency contact name'),
            ),
            const SizedBox(height: Brand.spaceMd),
            TextFormField(
              controller: _emergencyPhone,
              keyboardType: TextInputType.phone,
              decoration:
                  const InputDecoration(labelText: 'Emergency contact phone'),
            ),
            const SizedBox(height: Brand.spaceMd),
            TextFormField(
              controller: _notes,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Notes'),
            ),

            const Divider(height: Brand.spaceXl),
            SwitchListTile(
              key: const ValueKey<String>('member-notifications-opt-out'),
              contentPadding: EdgeInsets.zero,
              value: _optOut,
              onChanged: (bool v) => setState(() => _optOut = v),
              title: const Text('No automated messages'),
              // Consent, checked by every enqueue job upstream. Sending
              // automated SMS with no way to stop is not shippable, which is
              // why this field exists at all.
              subtitle: const Text(
                'Stops renewal reminders, dues chases and birthday greetings',
              ),
            ),

            const SizedBox(height: Brand.spaceLg),
            FilledButton(
              key: const ValueKey<String>('member-edit-save'),
              onPressed: saving ? null : _save,
              child: Text(saving ? 'Saving…' : 'Save changes'),
            ),
            const SizedBox(height: Brand.spaceMd),
          ],
        ),
      ),
    );
  }

  List<String> _branchIdOptions(List<String> options) => options;

  Future<void> _save() async {
    if (!(_form.currentState?.validate() ?? false)) {
      return;
    }

    final outcome = await ref.read(memberAdminProvider.notifier).save(
          memberId: widget.member.id,
          fullName: _name.text.trim(),
          phone: _phone.text.trim(),
          homeBranchId: _branchId,
          notificationsOptOut: _optOut,
          email: _blankToNull(_email.text),
          dateOfBirth: _dateOfBirth,
          gender: _gender,
          address: _blankToNull(_address.text),
          emergencyContactName: _blankToNull(_emergencyName.text),
          emergencyContactPhone: _blankToNull(_emergencyPhone.text),
          notes: _blankToNull(_notes.text),
        );

    if (!mounted) {
      return;
    }

    switch (outcome) {
      case MemberAdminSucceeded():
        Navigator.of(context).pop(true);
      case MemberAdminFailed(:final failure):
        // The form keeps everything typed.
        showFailureSnackBar(context, failure);
    }
  }

  static String? _blankToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

class _DobField extends StatelessWidget {
  const _DobField({required this.value, required this.onPick});

  final DateTime? value;
  final ValueChanged<DateTime?> onPick;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: const InputDecoration(labelText: 'Date of birth'),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(value == null ? 'Not set' : formatPlainDate(value!)),
          ),
          if (value != null)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Clear',
              onPressed: () => onPick(null),
            ),
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            tooltip: 'Pick a date',
            onPressed: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: value ?? DateTime(now.year - 25),
                firstDate: DateTime(now.year - 100),
                lastDate: now,
              );
              if (picked != null) {
                // UTC midnight so no offset can move the day.
                onPick(DateTime.utc(picked.year, picked.month, picked.day));
              }
            },
          ),
        ],
      ),
    );
  }
}
