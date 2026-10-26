// Selling a member their next period.
//
// A renewal **inserts** a new `memberships` row -- it never edits the one
// running now. Financial history is append-only (CLAUDE.md), so the previous
// membership stays exactly as it was sold, the new row points back at it, and
// the strip on the member's profile stays a record of what happened rather
// than a mutable current state.
//
// Money is integer paisa in `int`. Rupees are converted exactly once, here at
// the input boundary, by `paisaOrZero`. Nothing downstream sees a double.
//
// A widget that builds a PostgREST query is a review failure (PLANNING.md
// §6): every read on this screen comes from `payment_queries.dart`.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/data/memberships/membership.dart';
import 'package:logfitness_flutter/data/plans/membership_plan.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/domain/format/dates.dart';
import 'package:logfitness_flutter/domain/format/money.dart';
import 'package:logfitness_flutter/features/common/async_value_view.dart';
import 'package:logfitness_flutter/domain/format/plan_pricing.dart';
import 'package:logfitness_flutter/features/common/failure_snackbar.dart';
import 'package:logfitness_flutter/features/documents/document_actions_sheet.dart';
import 'package:logfitness_flutter/features/documents/document_service.dart';
import 'package:logfitness_flutter/features/common/payment_status_choice.dart';
import 'package:logfitness_flutter/features/common/picker_field.dart';
import 'package:logfitness_flutter/features/members/member_labels.dart'
    show discountReasonLabel;
import 'package:logfitness_flutter/features/members/widgets/sale_form_kit.dart';
import 'package:logfitness_flutter/features/payments/payment_formatting.dart';
import 'package:logfitness_flutter/data/fees/fees_repository.dart' show FeeSetup;
import 'package:logfitness_flutter/features/payments/payment_queries.dart';
import 'package:logfitness_flutter/features/settings/catalogue/fee_providers.dart';
import 'package:logfitness_flutter/features/payments/renew_membership_controller.dart';
import 'package:logfitness_flutter/features/staff/branch_scope.dart';

/// What the new membership will look like if the database agrees.
///
/// A *projection*, and the screen says so. The final answer comes from
/// `renew_membership`, which resolves the start date against `org_today` --
/// the gym's own day, not the device's. This exists so nobody is asked to
/// take money for a period nobody has seen.
class RenewalProjection {
  const RenewalProjection({
    required this.startDate,
    required this.endDate,
    required this.subtotalPaisa,
    required this.fees,
    required this.discountPaisa,
    required this.totalPaisa,
    required this.amountPaidPaisa,
    required this.duePaisa,
  });

  final DateTime startDate;

  /// Null for a session pack, which has no validity window.
  final DateTime? endDate;

  final int subtotalPaisa;

  /// The fee lines this sale carries, and what they add to the plan price.
  final FeeQuote fees;
  final int discountPaisa;
  final int totalPaisa;
  final int amountPaidPaisa;
  final int duePaisa;
}

/// Works out what [plan] would sell for, following
/// `20260906120100_membership_signup_fee.sql` clause for clause.
///
/// Restated here only to *show* the sale before it is recorded; the database
/// is still the one that decides. Where the two could disagree -- the start
/// date, which the RPC takes from `org_today` -- the screen labels its answer
/// a projection rather than pretending to certainty.
RenewalProjection projectRenewal({
  required MembershipPlan plan,
  required List<Membership> existing,
  required DateTime today,
  required DateTime? chosenStartDate,
  required int discountPaisa,
  required int amountPaidPaisa,
  // How this org charges. The legacy path (the plan's own joining fee) until
  // the catalogue is switched on, which is also what an unread setup means.
  FeeSetup feeSetup = FeeSetup.legacy,
}) {
  // The fees the plan carries. A once-fee is charged on the member's first
  // membership -- "does this member have any membership at all", the RPC's own
  // test -- and shown taken back off on every later one.
  final FeeQuote fees = feeQuote(
    plan: plan,
    fees: feeSetup.fees,
    catalogueEnabled: feeSetup.catalogueEnabled,
    standardSignupFeePaisa: feeSetup.standardSignupFeePaisa,
    isFirstMembership: existing.isEmpty,
  );
  final int subtotal = plan.pricePaisa + fees.chargedPaisa;

  // The RPC refuses a discount above the price and a payment above the due.
  // The console's renew form clamps both rather than letting the desk type a
  // number the database will bounce, and this matches it.
  final int discount = discountPaisa > subtotal ? subtotal : discountPaisa;
  final int total = subtotal - discount;
  final int paid = amountPaidPaisa > total ? total : amountPaidPaisa;

  // "A renewal taken early must not start until the current one runs out."
  final Membership? current = _currentMembership(existing);
  final DateTime start =
      chosenStartDate ??
      (current?.endDate != null && !current!.endDate!.isBefore(today)
          ? current.endDate!.add(const Duration(days: 1))
          : today);

  // "A 30-day plan starting on the 1st runs through the 30th, not the 31st."
  final DateTime? end = plan.durationDays == null
      ? null
      : start.add(Duration(days: plan.durationDays! - 1));

  return RenewalProjection(
    startDate: start,
    endDate: end,
    subtotalPaisa: subtotal,
    fees: fees,
    discountPaisa: discount,
    totalPaisa: total,
    amountPaidPaisa: paid,
    duePaisa: total - paid,
  );
}

/// The membership a renewal follows: the latest that has not lapsed.
Membership? _currentMembership(List<Membership> rows) {
  Membership? best;
  for (final Membership row in rows) {
    if (row.status != MembershipStatus.active &&
        row.status != MembershipStatus.upcoming &&
        row.status != MembershipStatus.frozen) {
      continue;
    }
    if (best == null) {
      best = row;
      continue;
    }
    // Mirrors the RPC's ordering: furthest end date first, an open-ended
    // membership beating every dated one, then the later start date.
    final DateTime a = row.endDate ?? DateTime.utc(9999, 12, 31);
    final DateTime b = best.endDate ?? DateTime.utc(9999, 12, 31);
    if (a.isAfter(b) || (a == b && row.startDate.isAfter(best.startDate))) {
      best = row;
    }
  }
  return best;
}

class RenewMembershipScreen extends ConsumerStatefulWidget {
  const RenewMembershipScreen({
    required this.memberId,
    this.memberName,
    super.key,
  });

  final String memberId;

  /// Shown in the app bar so the cashier can see they are selling to the
  /// person standing in front of them. Optional: a caller that only has an id
  /// still gets a working screen.
  final String? memberName;

  @override
  ConsumerState<RenewMembershipScreen> createState() =>
      _RenewMembershipScreenState();
}

class _RenewMembershipScreenState extends ConsumerState<RenewMembershipScreen> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final TextEditingController _discount = TextEditingController();
  final TextEditingController _amountPaid = TextEditingController();
  final TextEditingController _reference = TextEditingController();
  final TextEditingController _notes = TextEditingController();

  final TextEditingController _discountNote = TextEditingController();

  String? _branchId;
  MembershipPlan? _plan;
  PaymentMethod _method = PaymentMethod.cash;
  PaymentStatus _payment = PaymentStatus.full;
  DiscountReason? _discountReason;
  DateTime? _startDate;

  @override
  void dispose() {
    for (final TextEditingController c in <TextEditingController>[
      _discount,
      _amountPaid,
      _reference,
      _notes,
      _discountNote,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final BranchScope scope = ref.watch(branchScopeProvider);
    final Map<String, String> names = ref.watch(branchNamesProvider);
    final bool saving = ref.watch(renewMembershipProvider);

    // Kept loaded for the life of the screen, and the "paid in full" amount is
    // refilled if the fees arrive after a plan was already chosen (the prefilled
    // plan on a renewal is the usual case), so the figure the desk sees and the
    // figure the RPC charges cannot disagree.
    ref.watch(feeSetupProvider);
    ref.listen<AsyncValue<FeeSetup>>(feeSetupProvider, (_, AsyncValue<FeeSetup> next) {
      if (next.hasValue && _plan != null && _payment == PaymentStatus.full) {
        setState(_fillFullAmount);
      }
    });

    final List<String> options = scope.options;
    _branchId ??=
        scope.selectedBranchId ?? (options.length == 1 ? options.single : null);

    final AsyncValue<List<Membership>> memberships = ref.watch(
      memberMembershipsProvider(widget.memberId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Renew membership'),
        bottom: widget.memberName == null
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(28),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: Brand.spaceMd,
                    bottom: Brand.spaceSm,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.memberName!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ),
      ),
      body: AsyncValueView<List<Membership>>(
        value: memberships,
        onRetry: () =>
            ref.invalidate(memberMembershipsProvider(widget.memberId)),
        data: (List<Membership> rows) =>
            _buildForm(rows, options, names, saving),
      ),
    );
  }

  Widget _buildForm(
    List<Membership> existing,
    List<String> options,
    Map<String, String> names,
    bool saving,
  ) {
    final String? branchId = _branchId;
    final AsyncValue<List<MembershipPlan>> plans = branchId == null
        ? const AsyncValue<List<MembershipPlan>>.data(<MembershipPlan>[])
        : ref.watch(sellablePlansProvider(branchId));

    final MembershipPlan? plan = _plan;
    // Legacy while the read is in flight or if it failed: a sale must not wait
    // on it or break without it.
    final FeeSetup feeSetup =
        ref.watch(feeSetupProvider).value ?? FeeSetup.legacy;
    final RenewalProjection? projection = plan == null
        ? null
        : projectRenewal(
            plan: plan,
            existing: existing,
            today: _deviceToday(),
            chosenStartDate: _startDate,
            discountPaisa: paisaOrZero(_discount.text),
            amountPaidPaisa: _paidPaisa,
            feeSetup: feeSetup,
          );

    final SaleFigures figures = SaleFigures(
      emptyHint: 'Pick a plan to see the total.',
      headline: plan == null ? null : '${plan.name} · ${planTermLabel(plan)}',
      detail: projection == null
          ? null
          : 'New period ${_periodLabel(projection.startDate, projection.endDate)}',
      totalPaisa: projection?.totalPaisa,
      paidPaisa: projection?.amountPaidPaisa,
      duePaisa: projection?.duePaisa,
      lines: projection == null
          ? const <SummaryLine>[]
          : <SummaryLine>[
              SummaryLine(
                'Plan price',
                projection.subtotalPaisa - projection.fees.chargedPaisa,
              ),
              for (final SaleFee fee in projection.fees.rows) ...<SummaryLine>[
                if (fee.chargedPaisa > 0)
                  SummaryLine(fee.name, fee.chargedPaisa),
                // A fee taken back off is a memo: it nets to nothing and leaves
                // the total alone. It is shown so the desk can say out loud
                // what the invoice will print.
                if (fee.waivedPaisa > 0) ...<SummaryLine>[
                  SummaryLine(fee.name, fee.waivedPaisa),
                  SummaryLine(
                    '${fee.name} off',
                    fee.waivedPaisa,
                    negative: true,
                  ),
                ],
              ],
              if (projection.discountPaisa > 0)
                SummaryLine(
                  'Discount',
                  projection.discountPaisa,
                  negative: true,
                ),
            ],
    );

    final Widget form = Form(
      key: _form,
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(Brand.spaceMd),
        // A column, not a lazy list: every field stays mounted, so
        // `Form.validate()` reaches all of them however far the desk scrolled.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _CurrentPeriod(current: _currentMembership(existing)),
            const SizedBox(height: Brand.spaceLg),
            FormSection(
              title: 'Plan',
              children: <Widget>[
                if (options.length > 1)
                  PickerField<String>(
                    key: const ValueKey<String>('renew-branch'),
                    label: 'Branch',
                    sheetTitle: 'Which branch is this sold at?',
                    hint: 'Pick a branch',
                    value: branchId,
                    options: <PickerOption<String>>[
                      for (final String id in options)
                        PickerOption<String>(
                          value: id,
                          label: names[id] ?? 'Branch ${id.substring(0, 8)}',
                        ),
                    ],
                    onChanged: (String? value) => setState(() {
                      _branchId = value;
                      // The catalogue is per branch, so a branch change
                      // invalidates a plan chosen at the previous one.
                      _plan = null;
                    }),
                    validator: (String? v) =>
                        v == null ? 'Pick a branch.' : null,
                  ),
                plans.when(
                  skipLoadingOnRefresh: false,
                  loading: () => const Padding(
                    padding: EdgeInsets.all(Brand.spaceMd),
                    child: LinearProgressIndicator(),
                  ),
                  // A catalogue that failed to load must never look like a gym
                  // with no plans -- that reads as "nothing to sell" and stops
                  // the sale for the wrong reason.
                  error: (Object error, StackTrace stackTrace) {
                    final AppFailure failure = mapError(error, stackTrace);
                    return FormProblem(
                      message: failure.message,
                      // A refusal repeats identically, so retrying it only
                      // implies the desk did something wrong.
                      onRetry: branchId == null || failure.isRefusal
                          ? null
                          : () =>
                                ref.invalidate(sellablePlansProvider(branchId)),
                    );
                  },
                  data: (List<MembershipPlan> rows) => rows.isEmpty
                      ? const EmptyView(
                          message: 'No plans are on sale at this branch.',
                          icon: Icons.sell_outlined,
                        )
                      : PickerField<MembershipPlan>(
                          // Keyed by branch: a FormField keeps its own value
                          // after the first build, so a branch change — which
                          // clears `_plan` — has to rebuild the field rather
                          // than leave the old plan's name sitting in it.
                          key: ValueKey<String>('renew-plan-$branchId'),
                          label: 'Plan',
                          sheetTitle: 'Pick a plan',
                          hint: 'Pick a plan',
                          value: _plan,
                          options: <PickerOption<MembershipPlan>>[
                            for (final MembershipPlan item in rows)
                              PickerOption<MembershipPlan>(
                                value: item,
                                label: item.name,
                                subtitle: <String>[
                                  planTermLabel(item),
                                  formatMoney(item.pricePaisa),
                                  for (final SaleFee fee in feeQuote(
                                    plan: item,
                                    fees: feeSetup.fees,
                                    catalogueEnabled: feeSetup.catalogueEnabled,
                                    standardSignupFeePaisa:
                                        feeSetup.standardSignupFeePaisa,
                                    isFirstMembership: existing.isEmpty,
                                  ).rows)
                                    if (fee.chargedPaisa > 0)
                                      '+ ${formatMoney(fee.chargedPaisa)} ${fee.name.toLowerCase()}',
                                ].join(' · '),
                              ),
                          ],
                          onChanged: _choosePlan,
                          validator: (MembershipPlan? v) =>
                              v == null ? 'Pick a plan.' : null,
                        ),
                ),
                PlainDateField(
                  label: 'Start date',
                  helper:
                      'Leave blank to follow on from the current membership, '
                      "or start on this gym's own today. The gym's calendar "
                      'sets the final dates.',
                  emptyText: 'Decided by the gym',
                  allowFuture: true,
                  yearsBack: 2,
                  pickKey: const ValueKey<String>('renew-start-date'),
                  value: _startDate,
                  onPick: (DateTime? picked) =>
                      setState(() => _startDate = picked),
                ),
              ],
            ),
            sectionGap,
            FormSection(
              title: 'Payment',
              children: <Widget>[
                TextFormField(
                  key: const ValueKey<String>('renew-discount'),
                  controller: _discount,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Discount',
                    helperText: 'Optional. Taken off the price.',
                    prefixText: 'NPR ',
                  ),
                  onChanged: _changeDiscount,
                  validator: rupeeValidator,
                ),
                // Only once money is actually coming off. The RPC refuses a
                // discount without a reason and a reason without a discount
                // with equal force (`20260910130100_discount_reason_rpcs.sql`),
                // so the field appears and disappears with the amount.
                if (paisaOrZero(_discount.text) > 0)
                  PickerField<DiscountReason>(
                    key: const ValueKey<String>('renew-discount-reason'),
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
                        ? 'A discount the gym cannot explain later is one '
                              'nobody can question now.'
                        : null,
                  ),
                if (paisaOrZero(_discount.text) > 0 &&
                    _discountReason == DiscountReason.other)
                  TextFormField(
                    key: const ValueKey<String>('renew-discount-note'),
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
                PaymentStatusChoice(value: _payment, onChanged: _choosePayment),
                if (_payment == PaymentStatus.unpaid)
                  // Nothing is sent, so nothing is recorded: the RPC raises the
                  // invoice with the whole amount outstanding, and it shows on
                  // the profile and in the arrears report straight away.
                  const FormNote(
                    'The invoice is raised in full and the whole amount shows '
                    'as due. Record the payment from their profile when it '
                    'comes in.',
                  )
                else ...<Widget>[
                  TextFormField(
                    key: const ValueKey<String>('renew-amount-paid'),
                    controller: _amountPaid,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    // Paid in full means the price after the discount, and the
                    // field follows the choice rather than the other way round
                    // — so a cashier cannot leave a stale part-payment behind
                    // by switching back to full.
                    readOnly: _payment == PaymentStatus.full,
                    decoration: InputDecoration(
                      labelText: 'Paid now',
                      prefixText: 'NPR ',
                      helperText: _payment == PaymentStatus.full
                          ? 'The full price after any discount'
                          : 'What actually came in',
                    ),
                    onChanged: (_) => setState(() {}),
                    validator: rupeeValidator,
                  ),
                  PickerField<PaymentMethod>(
                    key: const ValueKey<String>('renew-method'),
                    label: 'Payment method',
                    sheetTitle: 'How did it come in?',
                    value: _method,
                    options: <PickerOption<PaymentMethod>>[
                      for (final PaymentMethod m in PaymentMethod.values)
                        PickerOption<PaymentMethod>(
                          value: m,
                          label: paymentMethodLabel(m),
                          icon: _methodIcon(m),
                        ),
                    ],
                    onChanged: (PaymentMethod? v) =>
                        setState(() => _method = v ?? PaymentMethod.cash),
                  ),
                  // Required only once money has actually moved on a rail that
                  // issues a transaction id — that id is what reconciles this
                  // drawer against the wallet's statement.
                  if (methodNeedsReference(_method) &&
                      paisaOrZero(_amountPaid.text) > 0)
                    TextFormField(
                      key: const ValueKey<String>('renew-reference'),
                      controller: _reference,
                      decoration: InputDecoration(
                        labelText:
                            '${paymentMethodLabel(_method)} reference no.',
                        helperText:
                            'The transaction id from the wallet or bank',
                      ),
                      validator: _referenceValidator,
                    ),
                ],
                TextFormField(
                  controller: _notes,
                  minLines: 2,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                  ),
                ),
              ],
            ),
            sectionGap,
            SaleSummarySection(figures: figures),
            const SizedBox(height: Brand.spaceMd),
          ],
        ),
      ),
    );

    return Column(
      children: <Widget>[
        Expanded(child: form),
        SaleSummaryBar(
          key: const ValueKey<String>('renew-summary'),
          submitKey: const ValueKey<String>('renew-submit'),
          submitLabel: 'Record renewal',
          busy: saving,
          onSubmit: () => _submit(existing),
          figures: figures,
        ),
      ],
    );
  }

  /// The device's calendar day, used only to *project* a start date. The RPC
  /// resolves the real one from `org_today`.
  DateTime _deviceToday() {
    final DateTime now = DateTime.now();
    return DateTime.utc(now.year, now.month, now.day);
  }

  String? _referenceValidator(String? value) {
    if (!methodNeedsReference(_method)) {
      return null;
    }
    if (_paidPaisa == 0) {
      // No money moving means no rail and no reference to give.
      return null;
    }
    return (value?.trim().isEmpty ?? true)
        ? 'Enter the transaction reference.'
        : null;
  }

  /// What is actually being recorded as received. Unpaid sends nothing at
  /// all; the projection clamps the rest to the total the way the RPC does.
  int get _paidPaisa =>
      _payment == PaymentStatus.unpaid ? 0 : paisaOrZero(_amountPaid.text);

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

  /// Picking a plan prefills the amount with what it sells for, because paid
  /// in full at the desk is the common case and retyping a price the form
  /// already knows is how a cashier mistypes it.
  void _choosePlan(MembershipPlan? plan) {
    setState(() {
      _plan = plan;
      if (_payment == PaymentStatus.full) _fillFullAmount();
    });
  }

  void _changeDiscount(String _) {
    setState(() {
      if (paisaOrZero(_discount.text) == 0) {
        // The RPC refuses a reason with no discount to explain, so clearing
        // the amount has to clear the reason with it.
        _discountReason = null;
        _discountNote.clear();
      }
      if (_payment == PaymentStatus.full) _fillFullAmount();
    });
  }

  /// The amount follows the choice: full refills it, unpaid empties it, and
  /// part leaves whatever is there for the cashier to correct.
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

  /// The total this sale comes to, from the same projection the summary shows
  /// — including the registration and card fees, which a first membership pays
  /// and a renewal does not.
  void _fillFullAmount() {
    final MembershipPlan? plan = _plan;
    if (plan == null) {
      _amountPaid.text = '';
      return;
    }
    final List<Membership> existing =
        ref.read(memberMembershipsProvider(widget.memberId)).value ??
        const <Membership>[];
    final RenewalProjection projection = projectRenewal(
      plan: plan,
      existing: existing,
      today: _deviceToday(),
      chosenStartDate: _startDate,
      discountPaisa: paisaOrZero(_discount.text),
      amountPaidPaisa: 0,
      feeSetup: ref.read(feeSetupProvider).value ?? FeeSetup.legacy,
    );
    _amountPaid.text = fromPaisa(projection.totalPaisa);
  }

  Future<void> _submit(List<Membership> existing) async {
    if (!(_form.currentState?.validate() ?? false)) {
      return;
    }

    final String? branchId = _branchId;
    final MembershipPlan? plan = _plan;
    if (branchId == null || plan == null) {
      showFailureSnackBar(
        context,
        const AppFailure(
          FailureKind.invalid,
          'Pick a branch and a plan before recording the renewal.',
        ),
      );
      return;
    }

    // Checked here as well as by the field validators: `Form.validate()` only
    // reaches mounted fields, and this form is a ListView, which does not
    // build what is off screen — so scrolling down to the button can unmount
    // the field being validated. The RPC refuses a discount with no reason
    // (`check_violation`), and that refusal reaching the desk as a failed
    // renewal instead of a missing answer is the outcome to avoid.
    final AppFailure? gap = _saleGap();
    if (gap != null) {
      showFailureSnackBar(context, gap);
      return;
    }

    // Sent exactly as shown. The projection already clamped the discount and
    // the payment the way the RPC would, so the figures in the summary are
    // the figures that go over the wire.
    final RenewalProjection projection = projectRenewal(
      plan: plan,
      existing: existing,
      today: _deviceToday(),
      chosenStartDate: _startDate,
      discountPaisa: paisaOrZero(_discount.text),
      amountPaidPaisa: _paidPaisa,
      feeSetup: ref.read(feeSetupProvider).value ?? FeeSetup.legacy,
    );

    final RenewOutcome outcome = await ref
        .read(renewMembershipProvider.notifier)
        .submit(
          memberId: widget.memberId,
          planId: plan.id,
          branchId: branchId,
          startDate: _startDate,
          discountPaisa: projection.discountPaisa,
          amountPaidPaisa: projection.amountPaidPaisa,
          method: _method,
          referenceNo: _payment == PaymentStatus.unpaid
              ? null
              : _blankToNull(_reference.text),
          notes: _blankToNull(_notes.text),
          discountReason: projection.discountPaisa > 0 ? _discountReason : null,
          discountNote: _discountReason == DiscountReason.other
              ? _blankToNull(_discountNote.text)
              : null,
        );

    if (!mounted) {
      return;
    }

    switch (outcome) {
      case RenewSucceeded(:final result):
        // The membership strip and the invoice list both just changed.
        ref
          ..invalidate(memberMembershipsProvider(widget.memberId))
          ..invalidate(memberInvoicesProvider(widget.memberId));
        // Captured before the pop: the snackbar outlives this screen.
        final DocumentActions documents = ref.read(documentActionsProvider);
        final BuildContext rootContext = Navigator.of(
          context,
          rootNavigator: true,
        ).context;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 8),
              action: SnackBarAction(
                label: 'Share / Print',
                onPressed: () {
                  if (!rootContext.mounted) {
                    return;
                  }
                  showDocumentActionsSheet(
                    rootContext,
                    actions: documents,
                    invoiceId: result.invoiceId,
                    invoiceNo: result.invoiceNo,
                  );
                },
              ),
              content: Text(
                result.duePaisa == 0
                    ? 'Renewed to ${_periodLabel(result.startDate, result.endDate)} '
                          'on ${result.invoiceNo}, paid in full'
                    : 'Renewed to ${_periodLabel(result.startDate, result.endDate)} '
                          'on ${result.invoiceNo}, '
                          '${formatMoney(result.duePaisa)} outstanding',
              ),
            ),
          );
        Navigator.of(context).pop(result);
      case RenewFailed(:final failure):
        // Nothing was written, and the form keeps everything typed. Never an
        // optimistic success -- there is no local write queue by design
        // (CLAUDE.md), so an offline renewal really did not happen.
        showFailureSnackBar(context, failure);
    }
  }

  /// What is missing from the sale, in the words the cashier needs. Null when
  /// it is complete.
  AppFailure? _saleGap() {
    final int discount = paisaOrZero(_discount.text);
    if (discount > 0 && _discountReason == null) {
      return const AppFailure(
        FailureKind.invalid,
        'Choose a reason for the discount.',
      );
    }
    if (discount > 0 &&
        _discountReason == DiscountReason.other &&
        _discountNote.text.trim().isEmpty) {
      return const AppFailure(
        FailureKind.invalid,
        'Describe the discount reason.',
      );
    }
    if (methodNeedsReference(_method) &&
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
    final String trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

String _periodLabel(DateTime start, DateTime? end) => end == null
    ? 'from ${formatPlainDate(start)}'
    : '${formatPlainDate(start)} – ${formatPlainDate(end)}';

/// What the member has now, so nobody sells a second membership over a live
/// one without seeing it.
class _CurrentPeriod extends StatelessWidget {
  const _CurrentPeriod({required this.current});

  final Membership? current;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final Membership? row = current;

    return Container(
      key: const ValueKey<String>('renew-current-period'),
      padding: const EdgeInsets.all(Brand.spaceMd),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(Brand.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Running now',
            style: theme.textTheme.labelLarge?.copyWith(
              color: scheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(height: Brand.spaceXs),
          if (row == null)
            Text(
              'No membership running. This will be their first, so the '
              'registration and card fees apply.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSecondaryContainer,
              ),
            )
          else ...<Widget>[
            Text(
              row.planName,
              style: theme.textTheme.titleSmall?.copyWith(
                color: scheme.onSecondaryContainer,
              ),
            ),
            Text(
              _periodLabel(row.startDate, row.endDate),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSecondaryContainer,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
