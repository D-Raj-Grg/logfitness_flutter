// The invoice as an A4 PDF. Mirrors `components/print/invoice-document.tsx`.
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:logfitness_flutter/data/documents/document_models.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/format/dates.dart';
import 'package:logfitness_flutter/domain/format/org_formatters.dart';
import 'package:logfitness_flutter/features/documents/document_layout.dart';
import 'package:logfitness_flutter/features/documents/document_strings.dart';
import 'package:logfitness_flutter/features/documents/document_widgets.dart';
import 'package:logfitness_flutter/features/members/member_labels.dart';

/// Builds the invoice PDF. [logoBytes] is the org logo, already fetched; null
/// or undecodable bytes simply mean no logo.
Future<Uint8List> buildInvoicePdf(
  InvoiceForPrint invoice, {
  Uint8List? logoBytes,
}) async {
  final DocumentStrings t = documentStrings;
  final OrgFormatters fmt = formattersFor(invoice.org);
  final pw.MemoryImage? logo = decodeLogo(logoBytes);

  final pw.Document doc = pw.Document(
    title: '${t.invoiceTitle} ${invoice.invoiceNo}',
    author: invoice.org.displayName,
  );

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(
        horizontal: 16 * PdfPageFormat.mm,
        vertical: 14 * PdfPageFormat.mm,
      ),
      build: (pw.Context context) => <pw.Widget>[
        letterheadBlock(
          org: invoice.org,
          documentTitle: t.invoiceTitle,
          logo: logo,
        ),
        documentMetaBand(
          member: invoice.member,
          branch: invoice.branch,
          factsLabel: t.invoiceTitle,
          entries: <MetaEntry>[
            MetaEntry(t.invoiceNo, invoice.invoiceNo),
            MetaEntry(t.issued, formatPlainDate(invoice.issuedOn)),
            if (invoice.membership?.sellerName != null)
              MetaEntry(t.soldBy, invoice.membership!.sellerName!),
          ],
        ),
        lineItemsTable(
          lines: invoiceLines(invoice),
          totals: invoiceTotals(invoice),
          formatAmount: fmt.money,
        ),
        savingsBanner(items: invoiceSavings(invoice), formatAmount: fmt.money),
        balanceBlock(duePaisa: invoiceDue(invoice), formatAmount: fmt.money),
        if (invoice.payments.isNotEmpty) ...<pw.Widget>[
          sectionEyebrow(t.paymentsReceived),
          paymentsTable(
            payments: invoice.payments,
            date: fmt.date,
            money: fmt.money,
            methodText: (DocumentPaymentLine p) =>
                '${paymentMethodLabel(p.method)}'
                '${p.kind == PaymentKind.refund ? ' · ${t.refundSuffix}' : ''}'
                '${p.kind == PaymentKind.reversal ? ' · ${t.reversalSuffix}' : ''}',
          ),
        ],
        // RLS can empty `payments` on an invoice that is genuinely paid; say
        // so rather than letting it read as "never paid".
        if (invoicePaymentsHidden(invoice))
          mutedNote(t.paymentsLimitedToBranch),
        if (invoice.notes != null && invoice.notes!.isNotEmpty)
          mutedNote(invoice.notes!),
        documentFooter(org: invoice.org),
      ],
    ),
  );

  return doc.save();
}
