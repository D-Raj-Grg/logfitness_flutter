// The shared blocks of a printed sheet, mirroring `components/print/*.tsx`:
// letterhead, meta band, line-items table, savings banner, balance block and
// footer. A4, black on white, borders rather than fills -- the same rule the
// web sheet follows so a photocopy or a cheap printer still reads the amount.
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:logfitness_flutter/data/documents/document_models.dart';
import 'package:logfitness_flutter/features/documents/document_layout.dart';
import 'package:logfitness_flutter/features/documents/document_strings.dart';

const PdfColor kInk = PdfColor.fromInt(0xFF111111);
const PdfColor kMuted = PdfColor.fromInt(0xFF666666);
const PdfColor kRule = PdfColor.fromInt(0xFF999999);
const PdfColor kHairline = PdfColor.fromInt(0xFFD9D9D9);

pw.TextStyle _style(
  double size, {
  PdfColor color = kInk,
  bool bold = false,
  double spacing = 0,
}) => pw.TextStyle(
  fontSize: size,
  color: color,
  fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
  letterSpacing: spacing,
);

pw.Widget _gap(double mm) => pw.SizedBox(height: mm * PdfPageFormat.mm);

/// Decodes a logo, or null when the bytes are absent or not an image the PDF
/// package understands. A bad logo must never stop an invoice printing.
pw.MemoryImage? decodeLogo(Uint8List? bytes) {
  if (bytes == null || bytes.isEmpty) return null;
  try {
    return pw.MemoryImage(bytes);
  } catch (_) {
    return null;
  }
}

/// The masthead. Every field is optional: an org that has never opened
/// Settings still has to print a usable document.
pw.Widget letterheadBlock({
  required DocumentOrg org,
  required String documentTitle,
  pw.MemoryImage? logo,
}) {
  final List<String> contact = <String>[
    if (org.phone != null && org.phone!.isNotEmpty) org.phone!,
    if (org.email != null && org.email!.isNotEmpty) org.email!,
  ];
  return pw.Container(
    padding: const pw.EdgeInsets.only(bottom: 3 * PdfPageFormat.mm),
    decoration: const pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(color: kInk, width: 1.5)),
    ),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: <pw.Widget>[
        pw.Expanded(
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: <pw.Widget>[
              if (logo != null) ...<pw.Widget>[
                pw.SizedBox(
                  height: 16 * PdfPageFormat.mm,
                  width: 42 * PdfPageFormat.mm,
                  child: pw.Image(
                    logo,
                    fit: pw.BoxFit.contain,
                    alignment: pw.Alignment.centerLeft,
                  ),
                ),
                pw.SizedBox(width: 4 * PdfPageFormat.mm),
              ],
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: <pw.Widget>[
                    pw.Text(org.displayName, style: _style(14, bold: true)),
                    pw.SizedBox(height: 1 * PdfPageFormat.mm),
                    if (org.address != null && org.address!.isNotEmpty)
                      pw.Text(org.address!, style: _style(9, color: kMuted)),
                    if (contact.isNotEmpty)
                      pw.Text(
                        contact.join(' · '),
                        style: _style(9, color: kMuted),
                      ),
                    if (org.panNo != null && org.panNo!.isNotEmpty)
                      pw.Text(
                        'PAN / VAT: ${org.panNo}',
                        style: _style(9, color: kMuted),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(width: 6 * PdfPageFormat.mm),
        pw.Text(
          documentTitle.toUpperCase(),
          style: _style(12, bold: true, spacing: 2.2),
        ),
      ],
    ),
  );
}

pw.Widget _eyebrow(String text) => pw.Text(
  text.toUpperCase(),
  style: _style(8, color: kMuted, bold: true, spacing: 1),
);

class MetaEntry {
  const MetaEntry(this.label, this.value);

  final String label;
  final String value;
}

/// Who it is for, which outlet issued it, and the document's own facts, as
/// one band across the sheet. The branch is not decoration: a chain's member
/// can pay at any branch and the document has to say who took the money.
pw.Widget documentMetaBand({
  required DocumentMember member,
  required DocumentBranch branch,
  required List<MetaEntry> entries,
  required String factsLabel,
}) {
  final DocumentStrings t = documentStrings;
  return pw.Container(
    margin: const pw.EdgeInsets.only(top: 7 * PdfPageFormat.mm),
    padding: const pw.EdgeInsets.symmetric(vertical: 4 * PdfPageFormat.mm),
    decoration: const pw.BoxDecoration(
      border: pw.Border(
        top: pw.BorderSide(color: kHairline, width: 0.8),
        bottom: pw.BorderSide(color: kHairline, width: 0.8),
      ),
    ),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.Expanded(
          flex: 125,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              _eyebrow(t.billedTo),
              _gap(1.5),
              pw.Text(member.fullName, style: _style(11.5, bold: true)),
              _gap(1),
              pw.Text(
                '${member.memberCode} · ${member.phone}',
                style: _style(9, color: kMuted),
              ),
              if (member.email != null && member.email!.isNotEmpty)
                pw.Text(member.email!, style: _style(9, color: kMuted)),
              if (member.address != null && member.address!.isNotEmpty)
                pw.Text(member.address!, style: _style(9, color: kMuted)),
            ],
          ),
        ),
        pw.SizedBox(width: 8 * PdfPageFormat.mm),
        pw.Expanded(
          flex: 100,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              _eyebrow(t.issuedAt),
              _gap(1.5),
              pw.Text(branch.name, style: _style(10, bold: true)),
              _gap(1),
              if (branch.address != null && branch.address!.isNotEmpty)
                pw.Text(branch.address!, style: _style(9, color: kMuted)),
              if (branch.phone != null && branch.phone!.isNotEmpty)
                pw.Text(branch.phone!, style: _style(9, color: kMuted)),
            ],
          ),
        ),
        pw.SizedBox(width: 8 * PdfPageFormat.mm),
        pw.Expanded(
          flex: 110,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              _eyebrow(factsLabel),
              _gap(1.5),
              for (final MetaEntry entry in entries)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(
                    bottom: 0.8 * PdfPageFormat.mm,
                  ),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: <pw.Widget>[
                      pw.Text(entry.label, style: _style(9.5, color: kMuted)),
                      pw.SizedBox(width: 4 * PdfPageFormat.mm),
                      pw.Flexible(
                        child: pw.Text(
                          entry.value,
                          textAlign: pw.TextAlign.right,
                          style: _style(9.5, bold: true),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

pw.Widget _headCell(String text, {bool right = false}) => pw.Text(
  text.toUpperCase(),
  textAlign: right ? pw.TextAlign.right : pw.TextAlign.left,
  style: _style(8, color: kMuted, bold: true, spacing: 0.8),
);

const pw.BoxDecoration _rowRule = pw.BoxDecoration(
  border: pw.Border(bottom: pw.BorderSide(color: kHairline, width: 0.6)),
);

/// Description / amount table with the totals under it.
pw.Widget lineItemsTable({
  required List<DocumentLine> lines,
  required List<TotalRow> totals,
  required String Function(int paisa) formatAmount,
}) {
  final DocumentStrings t = documentStrings;
  return pw.Container(
    margin: const pw.EdgeInsets.only(top: 8 * PdfPageFormat.mm),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: <pw.Widget>[
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(
            vertical: 2 * PdfPageFormat.mm,
          ),
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: kRule, width: 0.8)),
          ),
          child: pw.Row(
            children: <pw.Widget>[
              pw.Expanded(child: _headCell(t.description)),
              _headCell(t.amount, right: true),
            ],
          ),
        ),
        for (final DocumentLine line in lines)
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(
              vertical: 2.2 * PdfPageFormat.mm,
            ),
            decoration: _rowRule,
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: <pw.Widget>[
                      pw.Text(line.description, style: _style(10, bold: true)),
                      if (line.detail != null)
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(
                            top: 0.6 * PdfPageFormat.mm,
                          ),
                          child: pw.Text(
                            line.detail!,
                            style: _style(9, color: kMuted),
                          ),
                        ),
                    ],
                  ),
                ),
                pw.Text(
                  signedAmount(line.amountPaisa, formatAmount),
                  style: _style(10),
                ),
              ],
            ),
          ),
        pw.SizedBox(height: 1.5 * PdfPageFormat.mm),
        for (final TotalRow total in totals)
          total.tone == TotalTone.total
              ? pw.Container(
                  margin: const pw.EdgeInsets.only(top: 1 * PdfPageFormat.mm),
                  padding: const pw.EdgeInsets.only(
                    top: 2.5 * PdfPageFormat.mm,
                  ),
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                      top: pw.BorderSide(color: kRule, width: 0.8),
                    ),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: <pw.Widget>[
                      pw.Text(
                        total.label.toUpperCase(),
                        style: _style(10, bold: true, spacing: 0.8),
                      ),
                      pw.SizedBox(width: 6 * PdfPageFormat.mm),
                      pw.Text(total.value, style: _style(13, bold: true)),
                    ],
                  ),
                )
              : pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                    vertical: 0.8 * PdfPageFormat.mm,
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: <pw.Widget>[
                      pw.Text(total.label, style: _style(9.5, color: kMuted)),
                      pw.SizedBox(width: 6 * PdfPageFormat.mm),
                      pw.Text(total.value, style: _style(9.5)),
                    ],
                  ),
                ),
      ],
    ),
  );
}

/// One figure for everything the member did not pay. Outlined, not filled.
/// Nothing at all when there is nothing to say.
pw.Widget savingsBanner({
  required List<SavingsItem> items,
  required String Function(int paisa) formatAmount,
}) {
  final ({List<SavingsItem> items, int total}) savings = realSavings(items);
  if (savings.total <= 0) return pw.SizedBox();

  final String summary = savings.items.length == 1
      ? savings.items.first.label
      : savings.items
            .map((SavingsItem i) => '${i.label} ${formatAmount(i.amountPaisa)}')
            .join('  ·  ');

  return pw.Container(
    margin: const pw.EdgeInsets.only(top: 6 * PdfPageFormat.mm),
    padding: const pw.EdgeInsets.symmetric(
      horizontal: 4 * PdfPageFormat.mm,
      vertical: 2.5 * PdfPageFormat.mm,
    ),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: kInk, width: 0.8),
    ),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: <pw.Widget>[
        pw.Text(
          documentStrings.youSaved.toUpperCase(),
          style: _style(8, bold: true, spacing: 1.2),
        ),
        pw.SizedBox(width: 6 * PdfPageFormat.mm),
        pw.Expanded(
          child: pw.Text(
            summary,
            textAlign: pw.TextAlign.right,
            style: _style(9, color: kMuted),
          ),
        ),
        pw.SizedBox(width: 4 * PdfPageFormat.mm),
        pw.Text(formatAmount(savings.total), style: _style(13, bold: true)),
      ],
    ),
  );
}

/// What the member still owes, set so it cannot be missed. The amount is large
/// black type over a heavy rule; the filled label is emphasis, never what the
/// amount depends on.
pw.Widget balanceBlock({
  required int duePaisa,
  required String Function(int paisa) formatAmount,
}) {
  final DocumentStrings t = documentStrings;
  if (duePaisa == 0) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 6 * PdfPageFormat.mm),
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(
          horizontal: 3 * PdfPageFormat.mm,
          vertical: 1.2 * PdfPageFormat.mm,
        ),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: kInk, width: 0.8),
        ),
        child: pw.Text(
          t.paidInFull.toUpperCase(),
          style: _style(9, bold: true, spacing: 1.4),
        ),
      ),
    );
  }

  final bool isCredit = duePaisa < 0;
  return pw.Container(
    margin: const pw.EdgeInsets.only(top: 6 * PdfPageFormat.mm),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: <pw.Widget>[
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(
            horizontal: 3 * PdfPageFormat.mm,
            vertical: 1.4 * PdfPageFormat.mm,
          ),
          color: kInk,
          child: pw.Text(
            (isCredit ? t.creditBalance : t.balanceDue).toUpperCase(),
            style: _style(9, color: PdfColors.white, bold: true, spacing: 1.4),
          ),
        ),
        pw.SizedBox(width: 6 * PdfPageFormat.mm),
        pw.Container(
          constraints: const pw.BoxConstraints(minWidth: 45 * PdfPageFormat.mm),
          padding: const pw.EdgeInsets.only(bottom: 1.5 * PdfPageFormat.mm),
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: kInk, width: 2.5)),
          ),
          child: pw.Text(
            formatAmount(duePaisa.abs()),
            textAlign: pw.TextAlign.right,
            style: _style(20, bold: true),
          ),
        ),
      ],
    ),
  );
}

/// The tax note, the gym's terms, the computer-generated line and somewhere to
/// sign.
pw.Widget documentFooter({required DocumentOrg org, String? signatureLabel}) {
  final DocumentStrings t = documentStrings;
  return pw.Container(
    margin: const pw.EdgeInsets.only(top: 12 * PdfPageFormat.mm),
    padding: const pw.EdgeInsets.only(top: 3 * PdfPageFormat.mm),
    decoration: const pw.BoxDecoration(
      border: pw.Border(top: pw.BorderSide(color: kRule, width: 0.6)),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        if (org.taxNote != null && org.taxNote!.isNotEmpty)
          pw.Text(org.taxNote!, style: _style(9, color: kMuted)),
        if (org.invoiceTerms != null && org.invoiceTerms!.isNotEmpty)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 2 * PdfPageFormat.mm),
            child: pw.Text(org.invoiceTerms!, style: _style(9, color: kMuted)),
          ),
        pw.SizedBox(height: 14 * PdfPageFormat.mm),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: <pw.Widget>[
            pw.Text(t.computerGenerated, style: _style(8, color: kMuted)),
            pw.Container(
              width: 55 * PdfPageFormat.mm,
              padding: const pw.EdgeInsets.only(top: 1 * PdfPageFormat.mm),
              decoration: const pw.BoxDecoration(
                border: pw.Border(top: pw.BorderSide(color: kInk, width: 0.6)),
              ),
              child: pw.Text(
                signatureLabel ?? t.authorisedSignature,
                textAlign: pw.TextAlign.center,
                style: _style(8, color: kMuted),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

/// A muted paragraph under the body (notes, the branch-limited line, a reason).
pw.Widget mutedNote(String text, {double topMm = 6}) => pw.Padding(
  padding: pw.EdgeInsets.only(top: topMm * PdfPageFormat.mm),
  child: pw.Text(text, style: _style(9, color: kMuted)),
);

pw.Widget summaryRow(String label, String value, {bool strong = false}) =>
    pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 1 * PdfPageFormat.mm),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: <pw.Widget>[
          pw.Text(
            label,
            style: strong
                ? _style(9.5, bold: true)
                : _style(9.5, color: kMuted),
          ),
          pw.Text(value, style: _style(9.5, bold: strong)),
        ],
      ),
    );

pw.Widget sectionEyebrow(String text, {double topMm = 9}) => pw.Padding(
  padding: pw.EdgeInsets.only(top: topMm * PdfPageFormat.mm),
  child: _eyebrow(text),
);

pw.Widget bigAmountBand({
  required String label,
  required String? towards,
  required String amount,
}) => pw.Container(
  margin: const pw.EdgeInsets.only(top: 9 * PdfPageFormat.mm),
  padding: const pw.EdgeInsets.only(bottom: 3 * PdfPageFormat.mm),
  decoration: const pw.BoxDecoration(
    border: pw.Border(bottom: pw.BorderSide(color: kInk, width: 1.5)),
  ),
  child: pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.end,
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: <pw.Widget>[
      pw.Expanded(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: <pw.Widget>[
            _eyebrow(label),
            if (towards != null)
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 2 * PdfPageFormat.mm),
                child: pw.Text(towards, style: _style(10, color: kMuted)),
              ),
          ],
        ),
      ),
      pw.SizedBox(width: 8 * PdfPageFormat.mm),
      pw.Text(amount, style: _style(24, bold: true)),
    ],
  ),
);

pw.Widget textCell(
  String text, {
  bool muted = false,
  bool right = false,
  double size = 10,
}) => pw.Text(
  text,
  textAlign: right ? pw.TextAlign.right : pw.TextAlign.left,
  style: _style(muted ? 9 : size, color: muted ? kMuted : kInk),
);

pw.Widget paymentsTable({
  required List<DocumentPaymentLine> payments,
  required String Function(Object) date,
  required String Function(int) money,
  required String Function(DocumentPaymentLine) methodText,
}) {
  final DocumentStrings t = documentStrings;
  pw.Widget cell(int flex, pw.Widget child) =>
      pw.Expanded(flex: flex, child: child);
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: <pw.Widget>[
      pw.Container(
        margin: const pw.EdgeInsets.only(top: 2 * PdfPageFormat.mm),
        padding: const pw.EdgeInsets.symmetric(vertical: 2 * PdfPageFormat.mm),
        decoration: const pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(color: kRule, width: 0.8)),
        ),
        child: pw.Row(
          children: <pw.Widget>[
            cell(22, _headCell(t.date)),
            cell(26, _headCell(t.method)),
            cell(22, _headCell(t.reference)),
            cell(22, _headCell(t.receivedBy)),
            cell(18, _headCell(t.amount, right: true)),
          ],
        ),
      ),
      for (final DocumentPaymentLine p in payments)
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(
            vertical: 2.2 * PdfPageFormat.mm,
          ),
          decoration: _rowRule,
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              cell(22, textCell(date(p.paidAt))),
              cell(26, textCell(methodText(p))),
              cell(22, textCell(p.referenceNo ?? '—', muted: true)),
              cell(22, textCell(p.collectorName ?? '—', muted: true)),
              cell(18, textCell(money(p.amountPaisa), right: true)),
            ],
          ),
        ),
    ],
  );
}
