// Fetch, render, then print or share. The one place a document's data, its
// logo and its output meet.
//
// Any staff role may do this: the web print routes only `requireStaff`, and
// RLS already limits what the signed-in user can read.
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import 'package:logfitness_flutter/data/documents/document_models.dart';
import 'package:logfitness_flutter/data/documents/documents_repository.dart';
import 'package:logfitness_flutter/data/orgs/orgs_repository.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/features/documents/document_layout.dart';
import 'package:logfitness_flutter/features/documents/invoice_pdf.dart';
import 'package:logfitness_flutter/features/documents/receipt_pdf.dart';

/// A rendered document: the bytes and a file-safe name.
class RenderedDocument {
  const RenderedDocument({required this.bytes, required this.fileName});

  final Uint8List bytes;

  /// Without extension, safe as a file name.
  final String fileName;
}

typedef LogoFetcher = Future<Uint8List?> Function(String url);

const int _maxLogoBytes = 2 * 1024 * 1024; // the bucket's own limit

/// Fetches a public logo URL once. Any failure -- offline, 404, oversize --
/// is "no logo": a document must still print.
Future<Uint8List?> fetchLogoBytes(String url) async {
  final HttpClient client = HttpClient()
    ..connectionTimeout = const Duration(seconds: 6);
  try {
    final HttpClientRequest request = await client
        .getUrl(Uri.parse(url))
        .timeout(const Duration(seconds: 8));
    final HttpClientResponse response = await request.close().timeout(
      const Duration(seconds: 8),
    );
    if (response.statusCode != 200 ||
        (response.contentLength > _maxLogoBytes)) {
      await response.drain<void>();
      return null;
    }
    final BytesBuilder builder = BytesBuilder(copy: false);
    await for (final List<int> chunk in response.timeout(
      const Duration(seconds: 8),
    )) {
      builder.add(chunk);
      if (builder.length > _maxLogoBytes) return null;
    }
    return builder.takeBytes();
  } catch (_) {
    return null;
  } finally {
    client.close(force: true);
  }
}

/// Characters that are unsafe in a file name become dashes.
String safeFileName(String raw) {
  final String cleaned = raw
      .replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '-')
      .replaceAll(RegExp(r'-{2,}'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
  return cleaned.isEmpty ? 'document' : cleaned;
}

class DocumentActions {
  DocumentActions({
    required DocumentsRepository repository,
    required String? Function(String? path) logoUrl,
    LogoFetcher? fetchLogo,
  }) : _repository = repository,
       _logoUrl = logoUrl,
       _fetchLogo = fetchLogo ?? fetchLogoBytes;

  final DocumentsRepository _repository;
  final String? Function(String? path) _logoUrl;
  final LogoFetcher _fetchLogo;

  Future<Uint8List?> _logo(DocumentOrg org) async {
    final String? url = _logoUrl(org.logoPath);
    return url == null ? null : _fetchLogo(url);
  }

  /// Throws [AppFailure] when the invoice cannot be read.
  Future<RenderedDocument> renderInvoice(String invoiceId) async {
    final InvoiceForPrint? invoice = await _repository.invoiceForPrint(
      invoiceId,
    );
    if (invoice == null) {
      throw const AppFailure(
        FailureKind.notFound,
        'That invoice is not available.',
      );
    }
    final Uint8List? logo = await _logo(invoice.org);
    return RenderedDocument(
      bytes: await buildInvoicePdf(invoice, logoBytes: logo),
      fileName: safeFileName('Invoice-${invoice.invoiceNo}'),
    );
  }

  /// Throws [AppFailure] when the payment cannot be read.
  Future<RenderedDocument> renderReceipt(String paymentId) async {
    final PaymentForPrint? payment = await _repository.paymentForPrint(
      paymentId,
    );
    if (payment == null) {
      throw const AppFailure(
        FailureKind.notFound,
        'That receipt is not available.',
      );
    }
    final Uint8List? logo = await _logo(payment.org);
    return RenderedDocument(
      bytes: await buildReceiptPdf(payment, logoBytes: logo),
      fileName: safeFileName('Receipt-${receiptNumber(payment.id)}'),
    );
  }

  /// Opens the system print dialog.
  Future<void> print(RenderedDocument doc) async {
    await Printing.layoutPdf(
      name: doc.fileName,
      onLayout: (_) async => doc.bytes,
    );
  }

  /// Writes the PDF to a temp file and opens the share sheet.
  Future<void> share(RenderedDocument doc, {Rect? origin}) async {
    final Directory dir = await getTemporaryDirectory();
    final File file = File('${dir.path}/${doc.fileName}.pdf');
    await file.writeAsBytes(doc.bytes, flush: true);
    await SharePlus.instance.share(
      ShareParams(
        files: <XFile>[XFile(file.path, mimeType: 'application/pdf')],
        subject: doc.fileName,
        sharePositionOrigin: origin,
      ),
    );
  }
}

final Provider<DocumentActions> documentActionsProvider =
    Provider<DocumentActions>((Ref ref) {
      final OrgsRepository orgs = ref.watch(orgsRepositoryProvider);
      return DocumentActions(
        repository: ref.watch(documentsRepositoryProvider),
        logoUrl: orgs.logoUrl,
      );
    });
