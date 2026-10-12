// The receipt as an A4 PDF. Mirrors `components/print/receipt-document.tsx`.
// One payment row: a refund or a reversal is a negative payment, so the same
// document prints all three -- the heading and the amount label switch and the
// figure is shown unsigned, with the direction stated in words.
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:logfitness_flutter/data/documents/document_models.dart';
import 'package:logfitness_flutter/domain/format/dates.dart';
import 'package:logfitness_flutter/domain/format/org_formatters.dart';
import 'package:logfitness_flutter/features/documents/document_layout.dart';
import 'package:logfitness_flutter/features/documents/document_strings.dart';
import 'package:logfitness_flutter/features/documents/document_widgets.dart';
import 'package:logfitness_flutter/features/members/member_labels.dart';

Future<Uint8List> buildReceiptPdf(
  PaymentForPrint payment, {
  Uint8List? logoBytes,
}) async {
  final DocumentStrings t = documentStrings;
  final OrgFormatters fmt = formattersFor(payment.org);
  final pw.MemoryImage? logo = decodeLogo(logoBytes);
  final String title = receiptTitle(payment.kind);
  final DocumentMembership? membership = payment.membership;
  final DocumentInvoiceSummary? invoice = payment.invoice;

  final String? towards = membership == null
      ? null
      : '${t.towards} ${membership.planName}'
            '${membership.endDate != null ? ' · ${formatPlainDate(membership.startDate)} – ${formatPlainDate(membership.endDate!)}' : ''}';

  final pw.Document doc = pw.Document(
    title: '$title ${receiptNumber(payment.id)}',
    author: payment.org.displayName,
  );

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(
        horizontal: 16 * PdfPageFormat.mm,
        vertical: 14 * PdfPageFormat.mm,
      ),
      build: (pw.Context context) => <pw.Widget>[
        letterheadBlock(org: payment.org, documentTitle: title, logo: logo),
        documentMetaBand(
          member: payment.member,
          branch: payment.branch,
          factsLabel: title,
          entries: <MetaEntry>[
            MetaEntry(t.receiptNo, receiptNumber(payment.id)),
            MetaEntry(t.date, fmt.dateTime(payment.paidAt)),
            MetaEntry(t.method, paymentMethodLabel(payment.method)),
            if (payment.referenceNo != null)
              MetaEntry(t.reference, payment.referenceNo!),
            if (payment.collectorName != null)
              MetaEntry(
                receiptCollectorLabel(payment.kind),
                payment.collectorName!,
              ),
          ],
        ),
        bigAmountBand(
          label: receiptAmountLabel(payment.kind),
          towards: towards,
          amount: fmt.money(payment.amountPaisa.abs()),
        ),
        savingsBanner(items: receiptSavings(payment), formatAmount: fmt.money),
        if (invoice != null)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 7 * PdfPageFormat.mm),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: <pw.Widget>[
                summaryRow(t.againstInvoice, invoice.invoiceNo),
                if (invoice.discountPaisa > 0)
                  summaryRow(
                    t.discount,
                    '- ${fmt.money(invoice.discountPaisa)}',
                  ),
                summaryRow(t.invoiceTotal, fmt.money(invoice.totalPaisa)),
                summaryRow(t.paidToDate, fmt.money(invoice.paidPaisa)),
                pw.Container(
                  margin: const pw.EdgeInsets.only(top: 0.5 * PdfPageFormat.mm),
                  padding: const pw.EdgeInsets.only(
                    top: 1.5 * PdfPageFormat.mm,
                  ),
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                      top: pw.BorderSide(color: kRule, width: 0.6),
                    ),
                  ),
                  child: summaryRow(
                    t.balanceDue,
                    receiptBalanceText(invoice, fmt),
                    strong: true,
                  ),
                ),
              ],
            ),
          ),
        if (payment.reason != null && payment.reason!.isNotEmpty)
          mutedNote('${t.reason}: ${payment.reason}'),
        if (payment.notes != null && payment.notes!.isNotEmpty)
          mutedNote(payment.notes!, topMm: 2),
        documentFooter(
          org: payment.org,
          // Nobody signs for a correction as if they had received money.
          signatureLabel: receiptSignatureLabel(payment.kind),
        ),
      ],
    ),
  );

  return doc.save();
}
