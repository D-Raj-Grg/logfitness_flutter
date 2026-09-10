// Walk-in registration, with the sale in the same breath.
//
// Field-for-field with the console's member form, minus the photo — deferred
// by an explicit scope decision (TASKS.md, "Staff parity programme") so a
// failed upload can never cost the member or the payment taken with them.
//
// Money is integer paisa in `int`. Rupees are converted exactly once, here at
// the input boundary, with `toPaisa`. Nothing downstream sees a double.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/data/plans/membership_plan.dart';
import 'package:logfitness_flutter/data/plans/plans_repository.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/domain/format/dates.dart';
import 'package:logfitness_flutter/domain/format/money.dart';
import 'package:logfitness_flutter/features/common/failure_snackbar.dart';
import 'package:logfitness_flutter/features/members/member_labels.dart';
import 'package:logfitness_flutter/features/members/register_member_controller.dart';
import 'package:logfitness_flutter/features/staff/branch_scope.dart';

/// Plans sellable at one branch.
final branchPlansProvider =
    FutureProvider.family<List<MembershipPlan>, String>((ref, String branchId) {
  return ref.watch(plansRepositoryProvider).listPlansForBranch(branchId);
});

class RegisterMemberScreen extends ConsumerStatefulWidget {
  const RegisterMemberScreen({
    this.prefillName,
    this.prefillPhone,
    this.visitorId,
    super.key,
  });

  final String? prefillName;
  final String? prefillPhone;

  /// The walk-in this registration came from. When set, a successful
  /// registration also points that visitor row at the new member — the
  /// console's own member form takes a `visitorId` for exactly this.
  final String? visitorId;

  @override
  ConsumerState<RegisterMemberScreen> createState() =>
      _RegisterMemberScreenState();
}

class _RegisterMemberScreenState extends ConsumerState<RegisterMemberScreen> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  late final TextEditingController _name =
      TextEditingController(text: widget.prefillName ?? '');
  late final TextEditingController _phone =
      TextEditingController(text: widget.prefillPhone ?? '');
  final TextEditingController _email = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _emergencyName = TextEditingController();
  final TextEditingController _emergencyPhone = TextEditingController();
  final TextEditingController _notes = TextEditingController();
  final TextEditingController _discount = TextEditingController();
  final TextEditingController _amountPaid = TextEditingController();
  final TextEditingController _reference = TextEditingController();

  MemberGender? _gender;
  DateTime? _dateOfBirth;
  String? _branchId;

  bool _sellPlan = false;
  MembershipPlan? _plan;
  PaymentMethod _method = PaymentMethod.cash;
  DateTime? _startDate;

  @override
  void dispose() {
    for (final TextEditingController c in <TextEditingController>[
      _name, _phone, _email, _address, _emergencyName,
      _emergencyPhone, _notes, _discount, _amountPaid, _reference,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  int get _discountPaisa => _parsePaisa(_discount.text);
  int get _amountPaidPaisa => _parsePaisa(_amountPaid.text);

  /// Rupees to paisa, exactly once. An unparseable entry is treated as zero
  /// here and refused by the validator, so no half-parsed number reaches the
  /// RPC.
  int _parsePaisa(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return 0;
    }
    try {
      return toPaisa(trimmed);
    } on FormatException {
      return 0;
    }
  }

  int get _totalPaisa {
    final plan = _plan;
    if (plan == null) {
      return 0;
    }
    final gross = plan.pricePaisa + plan.signupFeePaisa;
    final net = gross - _discountPaisa;
    return net < 0 ? 0 : net;
  }

  int get _duePaisa {
    final due = _totalPaisa - _amountPaidPaisa;
    return due < 0 ? 0 : due;
  }

  @override
  Widget build(BuildContext context) {
    final scope = ref.watch(branchScopeProvider);
    final names = ref.watch(branchNamesProvider);
    final saving = ref.watch(registerMemberProvider);

    final options = scope.options;
    _branchId ??= scope.selectedBranchId ??
        (options.length == 1 ? options.single : null);

    final plans = _branchId == null
        ? const AsyncValue<List<MembershipPlan>>.data(<MembershipPlan>[])
        : ref.watch(branchPlansProvider(_branchId!));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.visitorId == null ? 'Register a member' : 'Register walk-in',
        ),
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
              validator: (String? v) =>
                  (v?.trim().isEmpty ?? true) ? 'A name is required.' : null,
            ),
            const SizedBox(height: Brand.spaceMd),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone',
                // The identity anchor: unique per org, and how a returning
                // member is found (PLANNING.md §5).
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
                onChanged: (String? value) => setState(() {
                  _branchId = value;
                  // The plan list is per branch, so a branch change
                  // invalidates a plan chosen at the previous one.
                  _plan = null;
                }),
                validator: (String? v) =>
                    v == null ? 'Pick a home branch.' : null,
              ),
            ],
            const SizedBox(height: Brand.spaceMd),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email (optional)'),
            ),
            const SizedBox(height: Brand.spaceMd),
            _DateField(
              label: 'Date of birth (optional)',
              value: _dateOfBirth,
              onPick: (DateTime? picked) =>
                  setState(() => _dateOfBirth = picked),
            ),
            const SizedBox(height: Brand.spaceMd),
            DropdownButtonFormField<MemberGender>(
              initialValue: _gender,
              decoration: const InputDecoration(labelText: 'Gender (optional)'),
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
              decoration: const InputDecoration(labelText: 'Address (optional)'),
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
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
            ),

            const Divider(height: Brand.spaceXl),
            SwitchListTile(
              key: const ValueKey<String>('register-sell-plan'),
              contentPadding: EdgeInsets.zero,
              value: _sellPlan,
              onChanged: (bool value) => setState(() {
                _sellPlan = value;
                if (!value) {
                  // A null plan registers only, and the RPC refuses money or a
                  // start date without one — so turning the sale off has to
                  // clear the sale, not just hide it.
                  _plan = null;
                  _discount.clear();
                  _amountPaid.clear();
                  _reference.clear();
                  _startDate = null;
                }
              }),
              title: const Text('Sell a plan now'),
              subtitle: const Text('Leave off to register without a membership'),
            ),

            if (_sellPlan) ..._saleFields(plans),

            const SizedBox(height: Brand.spaceLg),
            FilledButton(
              key: const ValueKey<String>('register-submit'),
              onPressed: saving ? null : _submit,
              child: Text(saving ? 'Saving…' : 'Register'),
            ),
            const SizedBox(height: Brand.spaceMd),
          ],
        ),
      ),
    );
  }

  List<Widget> _saleFields(AsyncValue<List<MembershipPlan>> plans) {
    return <Widget>[
      const SizedBox(height: Brand.spaceSm),
      plans.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(Brand.spaceMd),
          child: LinearProgressIndicator(),
        ),
        // A plan list that failed to load must not look like a gym with no
        // plans — that would push the desk into registering without a sale.
        error: (Object error, StackTrace stackTrace) => _InlineFailure(
          failure: mapError(error, stackTrace),
          onRetry: () => ref.invalidate(branchPlansProvider(_branchId!)),
        ),
        data: (List<MembershipPlan> rows) => DropdownButtonFormField<MembershipPlan>(
          key: const ValueKey<String>('register-plan'),
          initialValue: _plan,
          decoration: const InputDecoration(labelText: 'Plan'),
          items: <DropdownMenuItem<MembershipPlan>>[
            for (final MembershipPlan plan in rows)
              DropdownMenuItem<MembershipPlan>(
                value: plan,
                child: Text('${plan.name} · ${formatMoney(plan.pricePaisa)}'),
              ),
          ],
          onChanged: (MembershipPlan? value) => setState(() => _plan = value),
          validator: (MembershipPlan? v) =>
              v == null ? 'Pick a plan, or turn the sale off.' : null,
        ),
      ),
      const SizedBox(height: Brand.spaceMd),
      TextFormField(
        controller: _discount,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(
          labelText: 'Discount',
          prefixText: 'NPR ',
        ),
        onChanged: (_) => setState(() {}),
        validator: _moneyValidator,
      ),
      const SizedBox(height: Brand.spaceMd),
      TextFormField(
        key: const ValueKey<String>('register-amount-paid'),
        controller: _amountPaid,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(
          labelText: 'Amount paid now',
          prefixText: 'NPR ',
          helperText: 'Leave blank to raise an invoice to settle later',
        ),
        onChanged: (_) => setState(() {}),
        validator: _moneyValidator,
      ),
      const SizedBox(height: Brand.spaceMd),
      DropdownButtonFormField<PaymentMethod>(
        initialValue: _method,
        decoration: const InputDecoration(labelText: 'Payment method'),
        items: <DropdownMenuItem<PaymentMethod>>[
          for (final PaymentMethod m in PaymentMethod.values)
            // `eSewa`, not `esewa`: the label the console prints on the
            // receipt, from `member_labels.dart`. The wire value was showing
            // through here.
            DropdownMenuItem<PaymentMethod>(
              value: m,
              child: Text(paymentMethodLabel(m)),
            ),
        ],
        onChanged: (PaymentMethod? v) =>
            setState(() => _method = v ?? PaymentMethod.cash),
      ),
      const SizedBox(height: Brand.spaceMd),
      TextFormField(
        controller: _reference,
        decoration: const InputDecoration(
          labelText: 'Reference no. (optional)',
        ),
      ),
      const SizedBox(height: Brand.spaceMd),
      _DateField(
        label: 'Start date',
        helper: "Leave blank to start at this gym's own today",
        value: _startDate,
        allowFuture: true,
        onPick: (DateTime? picked) => setState(() => _startDate = picked),
      ),
      if (_plan != null) ...<Widget>[
        const SizedBox(height: Brand.spaceMd),
        _SaleSummary(
          totalPaisa: _totalPaisa,
          paidPaisa: _amountPaidPaisa,
          duePaisa: _duePaisa,
        ),
      ],
    ];
  }

  String? _moneyValidator(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return null;
    }
    try {
      final paisa = toPaisa(trimmed);
      return paisa < 0 ? 'That cannot be negative.' : null;
    } on FormatException {
      return 'Enter an amount in rupees.';
    }
  }

  Future<void> _submit() async {
    if (!(_form.currentState?.validate() ?? false)) {
      return;
    }

    final branchId = _branchId;
    if (branchId == null) {
      showFailureSnackBar(
        context,
        const AppFailure(
          FailureKind.unknown,
          'This session has no branch to register against. Sign out and back '
          'in, and tell whoever set up your account if it happens again.',
        ),
      );
      return;
    }

    final outcome = await ref.read(registerMemberProvider.notifier).submit(
          fullName: _name.text.trim(),
          phone: _phone.text.trim(),
          homeBranchId: branchId,
          email: _blankToNull(_email.text),
          dateOfBirth: _dateOfBirth,
          gender: _gender,
          address: _blankToNull(_address.text),
          emergencyContactName: _blankToNull(_emergencyName.text),
          emergencyContactPhone: _blankToNull(_emergencyPhone.text),
          notes: _blankToNull(_notes.text),
          // Every sale field is gated on the plan: the RPC refuses money or a
          // start date without one, so the UI must never send that shape.
          planId: _sellPlan ? _plan?.id : null,
          discountPaisa: _sellPlan ? _discountPaisa : 0,
          amountPaidPaisa: _sellPlan ? _amountPaidPaisa : 0,
          method: _method,
          referenceNo: _sellPlan ? _blankToNull(_reference.text) : null,
          startDate: _sellPlan ? _startDate : null,
          visitorId: widget.visitorId,
        );

    if (!mounted) {
      return;
    }

    switch (outcome) {
      case RegisterSucceeded(:final result, :final linkFailure):
        if (linkFailure != null) {
          // Say which half happened. "Registration failed" would be a lie and
          // would send the desk to register them a second time.
          showFailureSnackBar(
            context,
            AppFailure(
              linkFailure.kind,
              '${result.memberCode} was registered, but the walk-in could not '
              'be marked as joined: ${linkFailure.message}',
              cause: linkFailure.cause,
              code: linkFailure.code,
            ),
          );
        } else {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  result.sold
                      ? 'Registered ${result.memberCode}, '
                          '${formatMoney(result.duePaisa ?? 0)} outstanding'
                      : 'Registered ${result.memberCode}',
                ),
              ),
            );
        }
        Navigator.of(context).pop(result.memberId);
      case RegisterFailed(:final failure):
        // Nothing was saved, and the form keeps everything typed.
        showFailureSnackBar(context, failure);
    }
  }

  static String? _blankToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

}

class _SaleSummary extends StatelessWidget {
  const _SaleSummary({
    required this.totalPaisa,
    required this.paidPaisa,
    required this.duePaisa,
  });

  final int totalPaisa;
  final int paidPaisa;
  final int duePaisa;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Brand.spaceMd),
        child: Column(
          children: <Widget>[
            _row(theme, 'Total', formatMoney(totalPaisa)),
            _row(theme, 'Paid now', formatMoney(paidPaisa)),
            const Divider(),
            _row(
              theme,
              'Outstanding',
              formatMoney(duePaisa),
              emphasis: duePaisa > 0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(ThemeData theme, String label, String value,
      {bool emphasis = false}) {
    final style = emphasis
        ? theme.textTheme.titleMedium
        : theme.textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Brand.spaceXs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}

class _InlineFailure extends StatelessWidget {
  const _InlineFailure({required this.failure, required this.onRetry});

  final AppFailure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(Brand.spaceMd),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(Brand.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            failure.message,
            style: TextStyle(color: scheme.onErrorContainer),
          ),
          if (!failure.isRefusal)
            TextButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onPick,
    this.helper,
    this.allowFuture = false,
  });

  final String label;
  final String? helper;
  final DateTime? value;
  final bool allowFuture;
  final ValueChanged<DateTime?> onPick;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(labelText: label, helperText: helper),
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
                initialDate: value ?? now,
                firstDate: DateTime(now.year - 100),
                lastDate: allowFuture ? DateTime(now.year + 2) : now,
              );
              if (picked != null) {
                // Pinned to UTC midnight so no offset can move the day.
                onPick(DateTime.utc(picked.year, picked.month, picked.day));
              }
            },
          ),
        ],
      ),
    );
  }
}
