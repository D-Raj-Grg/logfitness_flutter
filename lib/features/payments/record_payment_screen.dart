// Taking money against an invoice that is already outstanding.
//
// The write is `record_payment` — one RPC that inserts the `payments` row and
// lets the trigger move `paid_paisa`, `due_paisa` and `status` in the same
// transaction. Nothing here edits an invoice, and nothing here edits or
// deletes a payment: financial history is append-only, and money going back
// out is a separate, additive act (CLAUDE.md).
//
// Money is integer paisa in `int`. Rupees are converted exactly once, here at
// the input boundary, by `paisaOrZero`.
//
// A widget that builds a PostgREST query is a review failure (PLANNING.md
// §6): every read on this screen comes from `payment_queries.dart`.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/data/payments/invoice.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/domain/format/dates.dart';
import 'package:logfitness_flutter/domain/format/money.dart';
import 'package:logfitness_flutter/features/common/async_value_view.dart';
import 'package:logfitness_flutter/features/common/failure_snackbar.dart';
import 'package:logfitness_flutter/features/documents/document_actions_sheet.dart';
import 'package:logfitness_flutter/features/documents/document_service.dart';
import 'package:logfitness_flutter/features/common/picker_field.dart';
import 'package:logfitness_flutter/features/members/widgets/sale_form_kit.dart';
import 'package:logfitness_flutter/features/payments/payment_formatting.dart';
import 'package:logfitness_flutter/features/payments/payment_queries.dart';
import 'package:logfitness_flutter/features/payments/record_payment_controller.dart';

class RecordPaymentScreen extends ConsumerStatefulWidget {
  const RecordPaymentScreen({
    required this.memberId,
    this.memberName,
    this.initialInvoiceId,
    super.key,
  });

  final String memberId;
  final String? memberName;

  /// The invoice the caller already had in hand — an arrears row, or the
  /// invoice a renewal just raised. Ignored if it is not outstanding.
  final String? initialInvoiceId;

  @override
  ConsumerState<RecordPaymentScreen> createState() =>
      _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends ConsumerState<RecordPaymentScreen> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final TextEditingController _amount = TextEditingController();
  final TextEditingController _reference = TextEditingController();
  final TextEditingController _notes = TextEditingController();

  String? _invoiceId;
  PaymentMethod _method = PaymentMethod.cash;

  /// Whether the invoice picker and the amount have been seeded from the
  /// loaded list. Once true the desk's own edits are never overwritten.
  bool _seeded = false;

  @override
  void dispose() {
    for (final TextEditingController c in <TextEditingController>[
      _amount,
      _reference,
      _notes,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Invoice>> invoices = ref.watch(
      openInvoicesProvider(widget.memberId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Take a payment'),
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
      body: AsyncValueView<List<Invoice>>(
        value: invoices,
        onRetry: () => ref
          ..invalidate(memberInvoicesProvider(widget.memberId))
          ..invalidate(openInvoicesProvider(widget.memberId)),
        // A settled member is not an error and not a blank screen. Distinct
        // from a failure by design (`async_value_view.dart`).
        isEmpty: (List<Invoice> rows) => rows.isEmpty,
        emptyMessage: 'Nothing outstanding. Every invoice is settled.',
        data: _buildForm,
      ),
    );
  }

  Widget _buildForm(List<Invoice> invoices) {
    if (!_seeded) {
      _seeded = true;
      final Invoice seed = invoices.firstWhere(
        (Invoice invoice) => invoice.id == widget.initialInvoiceId,
        orElse: () => invoices.first,
      );
      _invoiceId = seed.id;
      // The common case is settling the balance, so the amount starts at the
      // outstanding figure and the cashier only edits it for a part payment.
      // This is the one divide by 100 on this screen, and it is undone by
      // `paisaOrZero` before anything is sent.
      _amount.text = rupeesFromPaisa(seed.duePaisa);
    }

    final Invoice? invoice = _invoiceFor(invoices, _invoiceId);
    final int amountPaisa = paisaOrZero(_amount.text);
    final bool saving = ref.watch(recordPaymentProvider);
    final bool overpaying = invoice != null && amountPaisa > invoice.duePaisa;

    final int afterPaisa = invoice == null
        ? 0
        : (invoice.duePaisa - amountPaisa).clamp(0, invoice.duePaisa);

    final SaleFigures figures = SaleFigures(
      emptyHint: 'Pick an invoice to see what is owed.',
      headline: invoice?.invoiceNo,
      detail: invoice == null
          ? null
          : 'Issued ${formatPlainDate(invoice.issuedOn)}',
      totalLabel: 'Owed',
      paidLabel: 'Taking now',
      dueLabel: 'Left after',
      totalPaisa: invoice?.duePaisa,
      paidPaisa: amountPaisa,
      duePaisa: afterPaisa,
      lines: invoice == null
          ? const <SummaryLine>[]
          : <SummaryLine>[
              SummaryLine('Invoice total', invoice.totalPaisa),
              SummaryLine('Paid so far', invoice.paidPaisa),
            ],
    );

    final Widget form = Form(
      key: _form,
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(Brand.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            FormSection(
              title: 'Invoice',
              children: <Widget>[
                PickerField<String>(
                  key: const ValueKey<String>('payment-invoice'),
                  label: 'Invoice',
                  sheetTitle: 'Which invoice is this for?',
                  hint: 'Pick an invoice',
                  value: _invoiceId,
                  options: <PickerOption<String>>[
                    for (final Invoice item in invoices)
                      PickerOption<String>(
                        value: item.id,
                        label: item.invoiceNo,
                        subtitle:
                            '${formatPlainDate(item.issuedOn)} · '
                            '${formatMoney(item.duePaisa)} due',
                      ),
                  ],
                  onChanged: (String? value) => setState(() {
                    _invoiceId = value;
                    final Invoice? next = _invoiceFor(invoices, value);
                    if (next != null) {
                      _amount.text = rupeesFromPaisa(next.duePaisa);
                    }
                  }),
                  validator: (String? v) =>
                      v == null ? 'Pick an invoice.' : null,
                ),
              ],
            ),
            sectionGap,
            FormSection(
              title: 'Payment',
              children: <Widget>[
                TextFormField(
                  key: const ValueKey<String>('payment-amount'),
                  controller: _amount,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Amount taken',
                    prefixText: 'NPR ',
                    helperText:
                        'Starts at the full balance. Lower it for a part payment.',
                    helperMaxLines: 2,
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (String? value) {
                    final String? shape = rupeeValidator(value);
                    if (shape != null) {
                      return shape;
                    }
                    return paisaOrZero(value ?? '') <= 0
                        // Matches the RPC: "A payment must be a positive
                        // amount; use refund_payment to give money back."
                        ? 'Enter the amount taken.'
                        : null;
                  },
                ),
                // Said, not enforced. The console's record-payment form does
                // not clamp the amount either: `record_payment` raises
                // "Payment exceeds the … outstanding on invoice …" as a
                // `check_violation`, and that sentence — written for a person,
                // naming the invoice and the figure — is better than anything
                // this form could substitute. So the warning is a warning and
                // the database stays the authority.
                if (overpaying)
                  const FormProblem(
                    message:
                        'That is more than this invoice has outstanding. The '
                        'gym will refuse it.',
                  ),
                PickerField<PaymentMethod>(
                  key: const ValueKey<String>('payment-method'),
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
                TextFormField(
                  key: const ValueKey<String>('payment-reference'),
                  controller: _reference,
                  decoration: InputDecoration(
                    labelText: methodNeedsReference(_method)
                        ? 'Reference no.'
                        : 'Reference no. (optional)',
                    helperText: methodNeedsReference(_method)
                        ? 'The transaction id for the '
                              '${paymentMethodLabel(_method)} payment'
                        : null,
                  ),
                  validator: (String? value) =>
                      methodNeedsReference(_method) &&
                          (value?.trim().isEmpty ?? true)
                      ? 'Enter the transaction reference.'
                      : null,
                ),
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
          key: const ValueKey<String>('payment-outstanding'),
          submitKey: const ValueKey<String>('payment-submit'),
          submitLabel: 'Record payment',
          busy: saving,
          onSubmit: () => _submit(invoices),
          figures: figures,
        ),
      ],
    );
  }

  /// An icon per rail, so the sheet is scannable at a counter.
  static IconData _methodIcon(PaymentMethod method) => switch (method) {
    PaymentMethod.cash => Icons.payments_outlined,
    PaymentMethod.card => Icons.credit_card,
    PaymentMethod.bank => Icons.account_balance_outlined,
    PaymentMethod.esewa ||
    PaymentMethod.khalti ||
    PaymentMethod.fonepay => Icons.smartphone_outlined,
  };

  static Invoice? _invoiceFor(List<Invoice> invoices, String? id) {
    for (final Invoice invoice in invoices) {
      if (invoice.id == id) {
        return invoice;
      }
    }
    return null;
  }

  Future<void> _submit(List<Invoice> invoices) async {
    if (!(_form.currentState?.validate() ?? false)) {
      return;
    }

    final Invoice? invoice = _invoiceFor(invoices, _invoiceId);
    if (invoice == null) {
      showFailureSnackBar(
        context,
        const AppFailure(
          FailureKind.invalid,
          'Pick the invoice this payment settles.',
        ),
      );
      return;
    }

    final RecordPaymentOutcome outcome = await ref
        .read(recordPaymentProvider.notifier)
        .submit(
          invoiceId: invoice.id,
          // Converted exactly once, right here.
          amountPaisa: paisaOrZero(_amount.text),
          method: _method,
          referenceNo: _blankToNull(_reference.text),
          notes: _blankToNull(_notes.text),
        );

    if (!mounted) {
      return;
    }

    switch (outcome) {
      case RecordPaymentSucceeded(:final result):
        // The invoice list is stale the moment this lands.
        ref
          ..invalidate(memberInvoicesProvider(widget.memberId))
          ..invalidate(openInvoicesProvider(widget.memberId));
        // Captured before the pop: the snackbar outlives this screen, and its
        // action must not touch a disposed `ref` or `context`.
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
                    paymentId: result.paymentId,
                    invoiceId: result.invoiceId,
                    invoiceNo: invoice.invoiceNo,
                  );
                },
              ),
              content: Text(
                // The figures come back from the invoice as the trigger left
                // it, not from adding the amount to what this screen was
                // holding: a concurrent collection at another counter makes
                // the local sum wrong.
                result.duePaisa == 0
                    ? 'Recorded ${formatMoney(paisaOrZero(_amount.text))}. '
                          '${invoice.invoiceNo} is settled.'
                    : 'Recorded ${formatMoney(paisaOrZero(_amount.text))}. '
                          '${formatMoney(result.duePaisa)} still outstanding '
                          'on ${invoice.invoiceNo}.',
              ),
            ),
          );
        Navigator.of(context).pop(result);
      case RecordPaymentFailed(:final failure):
        // Nothing was taken. There is no local write queue by design
        // (CLAUDE.md), so an offline attempt must never read as success —
        // `FailureKind.offline` says so in as many words.
        showFailureSnackBar(context, failure);
    }
  }

  static String? _blankToNull(String value) {
    final String trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
