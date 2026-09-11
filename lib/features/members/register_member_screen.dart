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
import 'package:logfitness_flutter/data/orgs/orgs_repository.dart';
import 'package:logfitness_flutter/data/plans/plans_repository.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/domain/format/dates.dart';
import 'package:logfitness_flutter/domain/format/money.dart';
import 'package:logfitness_flutter/domain/format/plan_pricing.dart';
import 'package:logfitness_flutter/features/common/failure_snackbar.dart';
import 'package:logfitness_flutter/features/common/payment_status_choice.dart';
import 'package:logfitness_flutter/features/common/picker_field.dart';
import 'package:logfitness_flutter/features/members/member_labels.dart';
import 'package:logfitness_flutter/features/members/register_member_controller.dart';
// Only the reference rule: `paymentMethodLabel` lives in `member_labels.dart`
// and both libraries export it.
import 'package:logfitness_flutter/features/payments/payment_formatting.dart'
    show methodNeedsReference;
import 'package:logfitness_flutter/features/staff/branch_scope.dart';

/// Plans sellable at one branch.
final branchPlansProvider = FutureProvider.family<List<MembershipPlan>, String>(
  (ref, String branchId) {
    return ref.watch(plansRepositoryProvider).listPlansForBranch(branchId);
  },
);

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

  late final TextEditingController _name = TextEditingController(
    text: widget.prefillName ?? '',
  );
  late final TextEditingController _phone = TextEditingController(
    text: widget.prefillPhone ?? '',
  );
  final TextEditingController _email = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _emergencyName = TextEditingController();
  final TextEditingController _emergencyPhone = TextEditingController();
  final TextEditingController _notes = TextEditingController();
  final TextEditingController _discount = TextEditingController();
  final TextEditingController _amountPaid = TextEditingController();
  final TextEditingController _reference = TextEditingController();
  final TextEditingController _discountNote = TextEditingController();

  MemberGender? _gender;
  DateTime? _dateOfBirth;
  String? _branchId;

  bool _sellPlan = false;
  MembershipPlan? _plan;
  PaymentStatus _payment = PaymentStatus.full;
  DiscountReason? _discountReason;
  PaymentMethod _method = PaymentMethod.cash;
  DateTime? _startDate;

  @override
  void dispose() {
    for (final TextEditingController c in <TextEditingController>[
      _name,
      _phone,
      _email,
      _address,
      _emergencyName,
      _emergencyPhone,
      _notes,
      _discount,
      _amountPaid,
      _reference,
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

  /// The price before the discount: the plan plus the joining fee, which a
  /// member being registered always pays (`renew_membership` charges it on a
  /// member's first membership, and this is that membership).
  int get _grossPaisa {
    final plan = _plan;
    return plan == null ? 0 : plan.pricePaisa + plan.signupFeePaisa;
  }

  /// The discount that is actually sent.
  ///
  /// Clamped, because the RPC raises `Discount cannot exceed the price` rather
  /// than clamping it itself — the console's form clamps for the same reason.
  /// Sending the typed figure turned a mistyped discount into a refused
  /// registration instead of a corrected number.
  int get _discountAppliedPaisa {
    final int typed = _discountPaisa;
    return typed > _grossPaisa ? _grossPaisa : typed;
  }

  int get _totalPaisa => _grossPaisa - _discountAppliedPaisa;

  /// What is actually being recorded as received. Unpaid sends nothing at
  /// all, and a typed amount never exceeds the total — the RPC refuses a
  /// payment above the due, and the summary must not promise one either.
  int get _paidPaisa {
    if (_payment == PaymentStatus.unpaid) {
      return 0;
    }
    final int paid = _amountPaidPaisa;
    return paid > _totalPaisa ? _totalPaisa : paid;
  }

  int get _duePaisa {
    final due = _totalPaisa - _paidPaisa;
    return due < 0 ? 0 : due;
  }

  @override
  Widget build(BuildContext context) {
    final scope = ref.watch(branchScopeProvider);
    final names = ref.watch(branchNamesProvider);
    final saving = ref.watch(registerMemberProvider);

    final options = scope.options;
    _branchId ??=
        scope.selectedBranchId ?? (options.length == 1 ? options.single : null);

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
              decoration: const InputDecoration(
                labelText: 'Address (optional)',
              ),
            ),
            const SizedBox(height: Brand.spaceMd),
            TextFormField(
              controller: _emergencyName,
              decoration: const InputDecoration(
                labelText: 'Emergency contact name',
              ),
            ),
            const SizedBox(height: Brand.spaceMd),
            TextFormField(
              controller: _emergencyPhone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Emergency contact phone',
              ),
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
                  _discountReason = null;
                  _discountNote.clear();
                  _amountPaid.clear();
                  _reference.clear();
                  _startDate = null;
                  _payment = PaymentStatus.full;
                }
              }),
              title: const Text('Sell a plan now'),
              subtitle: const Text(
                'Leave off to register without a membership',
              ),
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
    final bool takingMoney = _payment != PaymentStatus.unpaid;

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
        // Two ways the list is legitimately empty, and neither should be
        // rendered as a picker with nothing in it: the branch is not chosen
        // yet (nothing was queried), and the branch genuinely sells nothing.
        // Both used to look identical to a failed load.
        data: (List<MembershipPlan> rows) => _branchId == null
            ? const _SaleNote('Pick a home branch to see its plans.')
            : rows.isEmpty
            ? const _SaleNote(
                'No plans are on sale at this branch. Add one on the web '
                'console, or turn the sale off and register only.',
              )
            : PickerField<MembershipPlan>(
                // Keyed by branch: a FormField keeps its own value after the
                // first build, so switching branch — which clears `_plan`
                // because the catalogue is per branch — has to rebuild the
                // field rather than leave the old plan's name sitting in it.
                key: ValueKey<String>('register-plan-$_branchId'),
                label: 'Plan',
                sheetTitle: 'Pick a plan',
                hint: 'Pick a plan',
                value: _plan,
                options: <PickerOption<MembershipPlan>>[
                  for (final MembershipPlan plan in rows)
                    PickerOption<MembershipPlan>(
                      value: plan,
                      label: plan.name,
                      // The console puts the term and the price beside the
                      // name for the same reason: two plans in a catalogue
                      // routinely differ only by duration.
                      subtitle: <String>[
                        planTermLabel(plan),
                        formatMoney(plan.pricePaisa),
                        if (plan.signupFeePaisa > 0)
                          '+ ${formatMoney(plan.signupFeePaisa)} joining fee',
                      ].join(' · '),
                    ),
                ],
                onChanged: _choosePlan,
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
        onChanged: _changeDiscount,
        validator: _moneyValidator,
      ),
      // Only once money is actually coming off. An empty reason sitting beside
      // an empty amount is a question nobody asked — and the RPC refuses a
      // reason without a discount just as firmly as the reverse.
      if (_discountAppliedPaisa > 0) ...<Widget>[
        const SizedBox(height: Brand.spaceMd),
        PickerField<DiscountReason>(
          key: const ValueKey<String>('register-discount-reason'),
          label: 'Reason for the discount',
          sheetTitle: 'Why the discount?',
          hint: 'Pick a reason',
          value: _discountReason,
          options: <PickerOption<DiscountReason>>[
            for (final DiscountReason reason in DiscountReason.values)
              PickerOption<DiscountReason>(
                value: reason,
                label: discountReasonLabel(reason),
              ),
          ],
          onChanged: (DiscountReason? value) =>
              setState(() => _discountReason = value),
          validator: (DiscountReason? v) => v == null
              ? 'A discount the gym cannot explain later is one nobody can '
                    'question now.'
              : null,
        ),
      ],
      if (_discountAppliedPaisa > 0 &&
          _discountReason == DiscountReason.other) ...[
        const SizedBox(height: Brand.spaceMd),
        TextFormField(
          controller: _discountNote,
          maxLength: 120,
          decoration: const InputDecoration(
            labelText: 'Describe the reason',
            helperText: 'Prints on the invoice',
          ),
          validator: (String? v) => (v?.trim().isEmpty ?? true)
              ? 'Describe the discount reason.'
              : null,
        ),
      ],
      const SizedBox(height: Brand.spaceMd),
      PaymentStatusChoice(value: _payment, onChanged: _choosePayment),
      if (!takingMoney)
        // Nothing is sent, so nothing is recorded: the RPC raises the invoice
        // with the full amount outstanding, and it shows as due on the profile
        // and in the arrears report the moment the desk looks.
        const _SaleNote(
          'The invoice is raised in full and the whole amount shows as due. '
          'Record the payment from their profile when it comes in.',
        )
      else ...<Widget>[
        TextFormField(
          key: const ValueKey<String>('register-amount-paid'),
          controller: _amountPaid,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          // Paid in full means the price after the discount, and the field
          // follows the choice rather than the other way round — so a cashier
          // cannot leave a stale part-payment behind by switching back to
          // full.
          readOnly: _payment == PaymentStatus.full,
          decoration: InputDecoration(
            labelText: 'Paid now',
            prefixText: 'NPR ',
            helperText: _payment == PaymentStatus.full
                ? 'The full price after any discount'
                : 'What actually came in',
          ),
          onChanged: (_) => setState(() {}),
          validator: _moneyValidator,
        ),
        const SizedBox(height: Brand.spaceMd),
        PickerField<PaymentMethod>(
          key: const ValueKey<String>('register-method'),
          label: 'Payment method',
          sheetTitle: 'How did it come in?',
          value: _method,
          options: <PickerOption<PaymentMethod>>[
            for (final PaymentMethod m in PaymentMethod.values)
              // `eSewa`, not `esewa`: the label the console prints on the
              // receipt, from `member_labels.dart`. The wire value was showing
              // through here.
              PickerOption<PaymentMethod>(
                value: m,
                label: paymentMethodLabel(m),
                icon: _methodIcon(m),
              ),
          ],
          onChanged: (PaymentMethod? v) =>
              setState(() => _method = v ?? PaymentMethod.cash),
        ),
        // Every digital rail issues a transaction id, and that id is the only
        // thing that reconciles this drawer against the wallet's statement —
        // so it is required once money has actually moved, and absent for
        // cash, where there is nothing to reconcile against.
        if (methodNeedsReference(_method) && _paidPaisa > 0) ...<Widget>[
          const SizedBox(height: Brand.spaceMd),
          TextFormField(
            controller: _reference,
            decoration: InputDecoration(
              labelText: '${paymentMethodLabel(_method)} reference no.',
            ),
            validator: (String? v) => (v?.trim().isEmpty ?? true)
                ? 'A ${paymentMethodLabel(_method)} payment needs its '
                      'transaction reference.'
                : null,
          ),
        ],
      ],
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
          plan: _plan!,
          // A member being registered has never paid a joining fee, so it
          // always applies — no equivalent of the renew form's
          // isFirstMembership flag is needed here.
          feeSplit: signupFeeSplit(
            planSignupFeePaisa: _plan!.signupFeePaisa,
            // Zero while the read is in flight or if it failed: the waiver is
            // a memo, and a sale must not wait on it or break without it.
            orgStandardFeePaisa:
                ref.watch(orgStandardSignupFeeProvider).value ?? 0,
            isFirstMembership: true,
          ),
          discountPaisa: _discountAppliedPaisa,
          totalPaisa: _totalPaisa,
          paidPaisa: _paidPaisa,
          duePaisa: _duePaisa,
        ),
      ],
    ];
  }

  /// An icon per rail, so the sheet is scannable at a counter rather than six
  /// lines of similar-length words.
  static IconData _methodIcon(PaymentMethod method) => switch (method) {
    PaymentMethod.cash => Icons.payments_outlined,
    PaymentMethod.card => Icons.credit_card,
    PaymentMethod.bank => Icons.account_balance_outlined,
    PaymentMethod.esewa ||
    PaymentMethod.khalti ||
    PaymentMethod.fonepay => Icons.smartphone_outlined,
  };

  /// Picking a plan prefills the amount with its full price, because paid in
  /// full at the desk is the common case and retyping the price the form
  /// already knows is how a cashier mistypes it.
  void _choosePlan(MembershipPlan? plan) {
    setState(() {
      _plan = plan;
      if (_payment == PaymentStatus.full) _fillFullAmount();
    });
  }

  void _changeDiscount(String _) {
    setState(() {
      if (_discountAppliedPaisa == 0) {
        // The RPC refuses a reason with no discount to explain, so clearing
        // the amount has to clear the reason with it.
        _discountReason = null;
        _discountNote.clear();
      }
      if (_payment == PaymentStatus.full) _fillFullAmount();
    });
  }

  /// The amount follows the choice: full refills it, unpaid empties it, and
  /// part leaves whatever is there for the cashier to correct — so switching
  /// back and forth never leaves a stale number behind.
  void _choosePayment(PaymentStatus next) {
    setState(() {
      _payment = next;
      switch (next) {
        case PaymentStatus.full:
          _fillFullAmount();
        case PaymentStatus.unpaid:
          _amountPaid.clear();
          _reference.clear();
        case PaymentStatus.part:
          break;
      }
    });
  }

  void _fillFullAmount() {
    final MembershipPlan? plan = _plan;
    _amountPaid.text = plan == null ? '' : fromPaisa(_totalPaisa);
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

    // The sale's invariants are checked here, not only by the field
    // validators, for two independent reasons.
    //
    // The Plan picker carries the "pick a plan" validator, and it is replaced
    // by a note when no branch is chosen or the branch sells nothing — so the
    // form validates clean with the sale switched on, and registering only,
    // silently, is the one outcome that must not follow from that.
    //
    // And `Form.validate()` only reaches mounted fields. This form is a
    // ListView, which does not build what is off screen, so scrolling down to
    // Register can unmount the very field being validated. That is how a
    // discount with no reason got through in testing: refused by Postgres
    // (`check_violation`, `20260910130100_discount_reason_rpcs.sql`) and shown
    // to the desk as a failed registration rather than a missing answer.
    final AppFailure? saleGap = _sellPlan ? _saleGap() : null;
    if (saleGap != null) {
      showFailureSnackBar(context, saleGap);
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

    final outcome = await ref
        .read(registerMemberProvider.notifier)
        .submit(
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
          discountPaisa: _sellPlan ? _discountAppliedPaisa : 0,
          discountReason: _sellPlan && _discountAppliedPaisa > 0
              ? _discountReason
              : null,
          discountNote:
              _sellPlan &&
                  _discountAppliedPaisa > 0 &&
                  _discountReason == DiscountReason.other
              ? _blankToNull(_discountNote.text)
              : null,
          amountPaidPaisa: _sellPlan ? _paidPaisa : 0,
          method: _method,
          referenceNo: _sellPlan && _payment != PaymentStatus.unpaid
              ? _blankToNull(_reference.text)
              : null,
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

  /// What is missing from the sale, in the words the desk needs. Null when it
  /// is complete.
  AppFailure? _saleGap() {
    if (_plan == null) {
      return const AppFailure(
        FailureKind.invalid,
        'Pick a plan, or turn the sale off and register only.',
      );
    }
    if (_discountAppliedPaisa > 0 && _discountReason == null) {
      return const AppFailure(
        FailureKind.invalid,
        'Choose a reason for the discount.',
      );
    }
    if (_discountAppliedPaisa > 0 &&
        _discountReason == DiscountReason.other &&
        _discountNote.text.trim().isEmpty) {
      return const AppFailure(
        FailureKind.invalid,
        'Describe the discount reason.',
      );
    }
    if (_payment != PaymentStatus.unpaid &&
        methodNeedsReference(_method) &&
        _paidPaisa > 0 &&
        _reference.text.trim().isEmpty) {
      return AppFailure(
        FailureKind.invalid,
        'A ${paymentMethodLabel(_method)} payment needs its transaction '
        'reference.',
      );
    }
    return null;
  }

  static String? _blankToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

class _SaleSummary extends StatelessWidget {
  const _SaleSummary({
    required this.plan,
    required this.feeSplit,
    required this.discountPaisa,
    required this.totalPaisa,
    required this.paidPaisa,
    required this.duePaisa,
  });

  final MembershipPlan plan;
  final ({int charged, int waived}) feeSplit;
  final int discountPaisa;
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
            _row(theme, plan.name, formatMoney(plan.pricePaisa)),
            if (feeSplit.charged > 0)
              _row(theme, 'Joining fee', formatMoney(feeSplit.charged)),
            // The waiver is a memo: it nets to nothing and leaves the total
            // alone. It is shown so the desk can say out loud what the invoice
            // will print — the console's summary does the same.
            if (feeSplit.waived > 0) ...<Widget>[
              _row(theme, 'Joining fee', formatMoney(feeSplit.waived)),
              _row(
                theme,
                'Joining fee waived',
                '-${formatMoney(feeSplit.waived)}',
              ),
            ],
            if (discountPaisa > 0)
              _row(theme, 'Discount', '-${formatMoney(discountPaisa)}'),
            const Divider(),
            _row(theme, 'Total', formatMoney(totalPaisa)),
            _row(theme, 'Paid now', formatMoney(paidPaisa)),
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

  Widget _row(
    ThemeData theme,
    String label,
    String value, {
    bool emphasis = false,
  }) {
    final style = emphasis
        ? theme.textTheme.titleMedium
        : theme.textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Brand.spaceXs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }
}

/// A sentence where the Plan dropdown would be, for the cases where there is
/// nothing to choose between and nothing went wrong.
class _SaleNote extends StatelessWidget {
  const _SaleNote(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(Brand.spaceMd),
      child: Text(
        message,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
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
