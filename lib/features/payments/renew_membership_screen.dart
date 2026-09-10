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
import 'package:logfitness_flutter/features/common/failure_snackbar.dart';
import 'package:logfitness_flutter/features/payments/payment_formatting.dart';
import 'package:logfitness_flutter/features/payments/payment_queries.dart';
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
    required this.signupFeePaisa,
    required this.discountPaisa,
    required this.totalPaisa,
    required this.amountPaidPaisa,
    required this.duePaisa,
  });

  final DateTime startDate;

  /// Null for a session pack, which has no validity window.
  final DateTime? endDate;

  final int subtotalPaisa;
  final int signupFeePaisa;
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
}) {
  // "The joining fee is charged once, on the member's first membership."
  final int signupFee = existing.isEmpty ? plan.signupFeePaisa : 0;
  final int subtotal = plan.pricePaisa + signupFee;

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
    signupFeePaisa: signupFee,
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

  String? _branchId;
  MembershipPlan? _plan;
  PaymentMethod _method = PaymentMethod.cash;
  DateTime? _startDate;

  @override
  void dispose() {
    for (final TextEditingController c in <TextEditingController>[
      _discount,
      _amountPaid,
      _reference,
      _notes,
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

    final List<String> options = scope.options;
    _branchId ??=
        scope.selectedBranchId ??
        (options.length == 1 ? options.single : null);

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
        data: (List<Membership> rows) => _buildForm(rows, options, names, saving),
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
    final RenewalProjection? projection = plan == null
        ? null
        : projectRenewal(
            plan: plan,
            existing: existing,
            today: _deviceToday(),
            chosenStartDate: _startDate,
            discountPaisa: paisaOrZero(_discount.text),
            amountPaidPaisa: paisaOrZero(_amountPaid.text),
          );

    return Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsets.all(Brand.spaceMd),
        children: <Widget>[
          _CurrentPeriod(current: _currentMembership(existing)),
          const SizedBox(height: Brand.spaceMd),

          if (options.length > 1) ...<Widget>[
            DropdownButtonFormField<String>(
              key: const ValueKey<String>('renew-branch'),
              initialValue: branchId,
              decoration: const InputDecoration(labelText: 'Branch'),
              items: <DropdownMenuItem<String>>[
                for (final String id in options)
                  DropdownMenuItem<String>(
                    value: id,
                    child: Text(names[id] ?? 'Branch ${id.substring(0, 8)}'),
                  ),
              ],
              onChanged: (String? value) => setState(() {
                _branchId = value;
                // The catalogue is per branch, so a branch change invalidates
                // a plan chosen at the previous one.
                _plan = null;
              }),
              validator: (String? v) => v == null ? 'Pick a branch.' : null,
            ),
            const SizedBox(height: Brand.spaceMd),
          ],

          plans.when(
            skipLoadingOnRefresh: false,
            loading: () => const Padding(
              padding: EdgeInsets.all(Brand.spaceMd),
              child: LinearProgressIndicator(),
            ),
            // A catalogue that failed to load must never look like a gym with
            // no plans -- that reads as "nothing to sell" and stops the sale
            // for the wrong reason.
            error: (Object error, StackTrace stackTrace) => _InlineFailure(
              failure: mapError(error, stackTrace),
              onRetry: branchId == null
                  ? null
                  : () => ref.invalidate(sellablePlansProvider(branchId)),
            ),
            data: (List<MembershipPlan> rows) => rows.isEmpty
                ? const EmptyView(
                    message: 'No plans are on sale at this branch.',
                    icon: Icons.sell_outlined,
                  )
                : DropdownButtonFormField<MembershipPlan>(
                    key: const ValueKey<String>('renew-plan'),
                    initialValue: _plan,
                    decoration: const InputDecoration(labelText: 'Plan'),
                    items: <DropdownMenuItem<MembershipPlan>>[
                      for (final MembershipPlan item in rows)
                        DropdownMenuItem<MembershipPlan>(
                          value: item,
                          child: Text(
                            '${item.name} · ${formatMoney(item.pricePaisa)}',
                          ),
                        ),
                    ],
                    onChanged: (MembershipPlan? value) =>
                        setState(() => _plan = value),
                    validator: (MembershipPlan? v) =>
                        v == null ? 'Pick a plan.' : null,
                  ),
          ),

          const SizedBox(height: Brand.spaceMd),
          TextFormField(
            key: const ValueKey<String>('renew-discount'),
            controller: _discount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Discount',
              prefixText: 'NPR ',
            ),
            onChanged: (_) => setState(() {}),
            validator: rupeeValidator,
          ),
          const SizedBox(height: Brand.spaceMd),
          TextFormField(
            key: const ValueKey<String>('renew-amount-paid'),
            controller: _amountPaid,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Amount paid now',
              prefixText: 'NPR ',
              helperText: 'Leave blank to invoice it and settle later',
            ),
            onChanged: (_) => setState(() {}),
            validator: rupeeValidator,
          ),
          const SizedBox(height: Brand.spaceMd),
          DropdownButtonFormField<PaymentMethod>(
            key: const ValueKey<String>('renew-method'),
            initialValue: _method,
            decoration: const InputDecoration(labelText: 'Payment method'),
            items: <DropdownMenuItem<PaymentMethod>>[
              for (final PaymentMethod m in PaymentMethod.values)
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
            key: const ValueKey<String>('renew-reference'),
            controller: _reference,
            decoration: InputDecoration(
              labelText: methodNeedsReference(_method)
                  ? 'Reference no.'
                  : 'Reference no. (optional)',
              helperText: methodNeedsReference(_method)
                  ? 'The transaction reference for the ${paymentMethodLabel(_method)} payment'
                  : null,
            ),
            validator: _referenceValidator,
          ),
          const SizedBox(height: Brand.spaceMd),
          TextFormField(
            controller: _notes,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'Notes (optional)'),
          ),
          const SizedBox(height: Brand.spaceMd),
          _StartDateField(
            value: _startDate,
            onPick: (DateTime? picked) => setState(() => _startDate = picked),
          ),

          if (projection != null) ...<Widget>[
            const SizedBox(height: Brand.spaceLg),
            _RenewalSummary(projection: projection),
          ],

          const SizedBox(height: Brand.spaceLg),
          FilledButton(
            key: const ValueKey<String>('renew-submit'),
            onPressed: saving ? null : () => _submit(existing),
            child: Text(saving ? 'Saving…' : 'Record renewal'),
          ),
          const SizedBox(height: Brand.spaceMd),
        ],
      ),
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
    if (paisaOrZero(_amountPaid.text) == 0) {
      // No money moving means no rail and no reference to give.
      return null;
    }
    return (value?.trim().isEmpty ?? true)
        ? 'Enter the transaction reference.'
        : null;
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

    // Sent exactly as shown. The projection already clamped the discount and
    // the payment the way the RPC would, so the figures in the summary are
    // the figures that go over the wire.
    final RenewalProjection projection = projectRenewal(
      plan: plan,
      existing: existing,
      today: _deviceToday(),
      chosenStartDate: _startDate,
      discountPaisa: paisaOrZero(_discount.text),
      amountPaidPaisa: paisaOrZero(_amountPaid.text),
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
          referenceNo: _blankToNull(_reference.text),
          notes: _blankToNull(_notes.text),
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
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
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
    final Membership? row = current;

    return Card(
      key: const ValueKey<String>('renew-current-period'),
      child: Padding(
        padding: const EdgeInsets.all(Brand.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Running now', style: theme.textTheme.labelLarge),
            const SizedBox(height: Brand.spaceXs),
            if (row == null)
              Text(
                'No membership running. This will be their first, so the '
                'joining fee applies.',
                style: theme.textTheme.bodyMedium,
              )
            else ...<Widget>[
              Text(row.planName, style: theme.textTheme.bodyLarge),
              Text(
                _periodLabel(row.startDate, row.endDate),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The sale, shown before it is recorded.
class _RenewalSummary extends StatelessWidget {
  const _RenewalSummary({required this.projection});

  final RenewalProjection projection;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      key: const ValueKey<String>('renew-summary'),
      child: Padding(
        padding: const EdgeInsets.all(Brand.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('New period', style: theme.textTheme.labelLarge),
            const SizedBox(height: Brand.spaceXs),
            Text(
              _periodLabel(projection.startDate, projection.endDate),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: Brand.spaceXs),
            Text(
              // Honest about who decides. The RPC resolves the start date
              // against the gym's own today, and a phone in the wrong
              // timezone must not be allowed to promise otherwise.
              'A projection. The gym\'s own calendar sets the final dates.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const Divider(height: Brand.spaceLg),
            _row(theme, 'Plan price', projection.subtotalPaisa - projection.signupFeePaisa),
            if (projection.signupFeePaisa > 0)
              _row(theme, 'Joining fee', projection.signupFeePaisa),
            if (projection.discountPaisa > 0)
              _row(theme, 'Discount', -projection.discountPaisa),
            _row(theme, 'Total', projection.totalPaisa),
            _row(theme, 'Paid now', projection.amountPaidPaisa),
            const Divider(),
            _row(
              theme,
              'Outstanding',
              projection.duePaisa,
              emphasis: projection.duePaisa > 0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(ThemeData theme, String label, int paisa, {bool emphasis = false}) {
    final TextStyle? style = emphasis
        ? theme.textTheme.titleMedium
        : theme.textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Brand.spaceXs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label, style: style),
          Text(formatMoney(paisa), style: style),
        ],
      ),
    );
  }
}

class _StartDateField extends StatelessWidget {
  const _StartDateField({required this.value, required this.onPick});

  final DateTime? value;
  final ValueChanged<DateTime?> onPick;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Start date',
        helperText:
            'Leave blank to follow on from the current membership, or start '
            "on this gym's own today",
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              value == null ? 'Decided by the gym' : formatPlainDate(value!),
            ),
          ),
          if (value != null)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Clear',
              onPressed: () => onPick(null),
            ),
          IconButton(
            key: const ValueKey<String>('renew-start-date'),
            icon: const Icon(Icons.calendar_today_outlined),
            tooltip: 'Pick a start date',
            onPressed: () async {
              final DateTime now = DateTime.now();
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: value ?? now,
                firstDate: DateTime(now.year - 2),
                lastDate: DateTime(now.year + 2),
              );
              if (picked != null) {
                // Pinned to UTC midnight so no offset can move the day
                // (`plain_date.dart`).
                onPick(DateTime.utc(picked.year, picked.month, picked.day));
              }
            },
          ),
        ],
      ),
    );
  }
}

/// A failure that replaces one field rather than the whole screen.
class _InlineFailure extends StatelessWidget {
  const _InlineFailure({required this.failure, required this.onRetry});

  final AppFailure failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(Brand.spaceMd),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(Brand.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(failure.message, style: TextStyle(color: scheme.onErrorContainer)),
          // A refusal repeats identically, so retrying it only implies the
          // desk did something wrong (`failure_snackbar.dart`).
          if (!failure.isRefusal && onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    );
  }
}
