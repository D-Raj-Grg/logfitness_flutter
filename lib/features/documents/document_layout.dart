// The pure part of the documents: which lines, totals and savings a document
// shows. Mirrors `lib/print/line-items.ts` and the totals logic in
// `invoice-document.tsx` / `receipt-document.tsx`, kept free of any PDF types
// so it can be tested without rendering.
//
// Money stays integer paisa here; `format` closures are applied only when a
// line is turned into text by the PDF widgets.
import 'package:logfitness_flutter/data/documents/document_models.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/format/dates.dart';
import 'package:logfitness_flutter/domain/format/org_formatters.dart';
import 'package:logfitness_flutter/features/documents/document_strings.dart';
import 'package:logfitness_flutter/features/members/member_labels.dart';

class DocumentLine {
  const DocumentLine({
    required this.description,
    required this.amountPaisa,
    this.detail,
  });

  final String description;
  final String? detail;
  final int amountPaisa;
}

enum TotalTone { quiet, total }

class TotalRow {
  const TotalRow(this.label, this.value, {this.tone = TotalTone.quiet});

  final String label;
  final String value;
  final TotalTone tone;
}

class SavingsItem {
  const SavingsItem(this.label, this.amountPaisa);

  final String label;
  final int amountPaisa;
}

/// A credit reads as "- NPR 500", never "NPR -500".
String signedAmount(int paisa, String Function(int paisa) format) =>
    paisa < 0 ? '- ${format(-paisa)}' : format(paisa);

/// The balance an invoice shows. `due_paisa` is a generated column and so
/// nullable in the type; the fallback is the web's. Never derived from the
/// payments list, which RLS can empty.
int dueFor({required int totalPaisa, required int paidPaisa, int? duePaisa}) =>
    duePaisa ?? (totalPaisa - paidPaisa < 0 ? 0 : totalPaisa - paidPaisa);

OrgFormatters formattersFor(DocumentOrg org) =>
    orgFormatters(currency: org.currency, timezone: org.timezone);

/// An invoice is one membership sale; the only split is the registration fee.
/// Older rows carry `signup_fee_paisa = 0` and print as a single line -- the
/// split is never recovered from the plan, which may have been repriced.
/// A fee that applied and was not charged prints as the fee, then the same
/// amount back off with a minus, so the body lines still sum to the subtotal.
List<DocumentLine> invoiceLines(InvoiceForPrint invoice) {
  final DocumentStrings t = documentStrings;
  // Plain `date` columns: formatPlainDate, no timezone shift.
  final DocumentMembership? membership = invoice.membership;
  final int signupFee = membership?.signupFeePaisa ?? 0;
  final int feeOff = membership?.signupFeeWaivedPaisa ?? 0;

  String? detail;
  if (membership != null) {
    if (membership.planType == PlanType.sessionPack) {
      final List<String> parts = <String>[
        if ((membership.sessionsTotal ?? 0) > 0)
          t.sessions(membership.sessionsTotal!),
        if (membership.endDate != null)
          t.validTo(formatPlainDate(membership.endDate!)),
      ];
      detail = parts.join(' · ');
    } else {
      detail =
          '${formatPlainDate(membership.startDate)} – '
          '${membership.endDate != null ? formatPlainDate(membership.endDate!) : t.openEnded}';
    }
    if (detail.isEmpty) detail = null;
  }

  return <DocumentLine>[
    DocumentLine(
      description: membership?.planName ?? t.membershipDues,
      detail: detail,
      amountPaisa: invoice.subtotalPaisa - signupFee,
    ),
    if (signupFee > 0)
      DocumentLine(description: t.registrationFee, amountPaisa: signupFee),
    if (feeOff > 0) ...<DocumentLine>[
      DocumentLine(description: t.registrationFee, amountPaisa: feeOff),
      DocumentLine(
        description: t.registrationFeeOff,
        detail: membership?.previousMembershipId != null
            ? t.alreadyPaidOnJoining
            : t.coveredByPlan,
        amountPaisa: -feeOff,
      ),
    ],
  ];
}

/// Subtotal, discount, total, paid. The discount row only appears when there
/// is one and the paid row only when something was paid.
List<TotalRow> invoiceTotals(InvoiceForPrint invoice) {
  final OrgFormatters fmt = formattersFor(invoice.org);
  final DocumentStrings t = documentStrings;
  return <TotalRow>[
    TotalRow(t.subtotal, fmt.money(invoice.subtotalPaisa)),
    if (invoice.discountPaisa > 0)
      TotalRow(t.discount, '- ${fmt.money(invoice.discountPaisa)}'),
    TotalRow(t.total, fmt.money(invoice.totalPaisa), tone: TotalTone.total),
    if (invoice.paidPaisa > 0) TotalRow(t.paid, fmt.money(invoice.paidPaisa)),
  ];
}

int invoiceDue(InvoiceForPrint invoice) => dueFor(
  totalPaisa: invoice.totalPaisa,
  paidPaisa: invoice.paidPaisa,
  duePaisa: invoice.duePaisa,
);

/// Payments are branch-scoped by RLS: an empty list on an invoice with money
/// paid means "you cannot see them", not "never paid".
bool invoicePaymentsHidden(InvoiceForPrint invoice) =>
    invoice.payments.isEmpty && invoice.paidPaisa > 0;

/// Both credits, one figure: the registration fee came off inside the
/// subtotal and the discount after it. Zero entries are dropped by the
/// banner itself.
List<SavingsItem> invoiceSavings(InvoiceForPrint invoice) => <SavingsItem>[
  SavingsItem(
    documentStrings.registrationFee,
    invoice.membership?.signupFeeWaivedPaisa ?? 0,
  ),
  SavingsItem(
    discountLabel(invoice.discountReason, invoice.discountNote),
    invoice.discountPaisa,
  ),
];

/// A receipt only has savings to report for a plain payment; a refund or a
/// correction is money going the other way.
List<SavingsItem> receiptSavings(PaymentForPrint payment) {
  if (payment.kind != PaymentKind.payment) return const <SavingsItem>[];
  return <SavingsItem>[
    SavingsItem(
      documentStrings.registrationFee,
      payment.membership?.signupFeeWaivedPaisa ?? 0,
    ),
    SavingsItem(
      discountLabel(
        payment.invoice?.discountReason,
        payment.invoice?.discountNote,
      ),
      payment.invoice?.discountPaisa ?? 0,
    ),
  ];
}

/// Only the credits that are real, and their sum. Empty / zero means the
/// banner is not drawn -- never "You saved 0".
({List<SavingsItem> items, int total}) realSavings(List<SavingsItem> items) {
  final List<SavingsItem> real = items
      .where((SavingsItem i) => i.amountPaisa > 0)
      .toList();
  final int total = real.fold(0, (int s, SavingsItem i) => s + i.amountPaisa);
  return (items: real, total: total);
}

String receiptTitle(PaymentKind kind) => switch (kind) {
  PaymentKind.reversal => documentStrings.correctionTitle,
  PaymentKind.refund => documentStrings.refundTitle,
  PaymentKind.payment => documentStrings.receiptTitle,
};

String receiptAmountLabel(PaymentKind kind) => switch (kind) {
  PaymentKind.reversal => documentStrings.amountReversed,
  PaymentKind.refund => documentStrings.amountRefunded,
  PaymentKind.payment => documentStrings.amountReceived,
};

String receiptCollectorLabel(PaymentKind kind) => switch (kind) {
  PaymentKind.reversal => documentStrings.correctedBy,
  PaymentKind.refund => documentStrings.refundedBy,
  PaymentKind.payment => documentStrings.receivedBy,
};

/// Nobody signs for a correction as if they had received money.
String receiptSignatureLabel(PaymentKind kind) => kind == PaymentKind.payment
    ? documentStrings.receivedBy
    : documentStrings.authorisedSignature;

/// The web's receipt number: the first eight characters of the payment id.
String receiptNumber(String paymentId) {
  final String head = paymentId.length < 8
      ? paymentId
      : paymentId.substring(0, 8);
  return head.toUpperCase();
}

/// The balance line on a receipt, e.g. `NPR 0 · Paid`.
String receiptBalanceText(DocumentInvoiceSummary invoice, OrgFormatters fmt) {
  final int due = dueFor(
    totalPaisa: invoice.totalPaisa,
    paidPaisa: invoice.paidPaisa,
    duePaisa: invoice.duePaisa,
  );
  return '${fmt.money(due)} · ${invoiceStatusLabel(invoice.status)}';
}
