// "Share / Print PDF": a bottom sheet over one invoice and/or one receipt.
//
// The sheet renders on demand -- fetch, build, then print or share -- and
// reports a failure in place. A document that cannot be built says so; it
// never prints a half-empty sheet.
import 'package:flutter/material.dart';

import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/features/common/failure_snackbar.dart';
import 'package:logfitness_flutter/features/documents/document_service.dart';

/// Opens the sheet. Give an [invoiceId], a [paymentId], or both.
///
/// [actions] is passed in rather than read from a `WidgetRef` so a snackbar
/// action can open the sheet after the screen that raised it has been popped.
Future<void> showDocumentActionsSheet(
  BuildContext context, {
  required DocumentActions actions,
  String? invoiceId,
  String? paymentId,
  String? invoiceNo,
}) {
  assert(invoiceId != null || paymentId != null);
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (BuildContext sheetContext) => _DocumentActionsSheet(
      actions: actions,
      invoiceId: invoiceId,
      paymentId: paymentId,
      invoiceNo: invoiceNo,
    ),
  );
}

class _DocumentActionsSheet extends StatefulWidget {
  const _DocumentActionsSheet({
    required this.actions,
    this.invoiceId,
    this.paymentId,
    this.invoiceNo,
  });

  final DocumentActions actions;
  final String? invoiceId;
  final String? paymentId;
  final String? invoiceNo;

  @override
  State<_DocumentActionsSheet> createState() => _DocumentActionsSheetState();
}

enum _Op { share, print }

class _DocumentActionsSheetState extends State<_DocumentActionsSheet> {
  String? _busy; // "<kind>-<op>" while one is in flight

  Future<void> _run({
    required String kind,
    required _Op op,
    required Future<RenderedDocument> Function() render,
  }) async {
    if (_busy != null) return;
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final BuildContext messengerContext = context;
    final Rect? origin = _originFor(context);
    setState(() => _busy = '$kind-${op.name}');
    try {
      final RenderedDocument doc = await render();
      if (op == _Op.print) {
        await widget.actions.print(doc);
      } else {
        await widget.actions.share(doc, origin: origin);
      }
    } catch (error, stackTrace) {
      final AppFailure failure = error is AppFailure
          ? error
          : mapError(error, stackTrace);
      if (messengerContext.mounted) {
        showFailureSnackBar(messengerContext, failure);
      } else {
        messenger.showSnackBar(SnackBar(content: Text(failure.message)));
      }
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  /// iPad needs an anchor for the share popover.
  static Rect? _originFor(BuildContext context) {
    final RenderObject? box = context.findRenderObject();
    if (box is RenderBox && box.hasSize) {
      return box.localToGlobal(Offset.zero) & box.size;
    }
    return null;
  }

  Widget _section(
    String title,
    String kind,
    Future<RenderedDocument> Function() render,
  ) {
    final bool working = _busy?.startsWith('$kind-') ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              if (working)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
        ),
        ListTile(
          key: ValueKey<String>('document-$kind-share'),
          leading: const Icon(Icons.ios_share),
          title: const Text('Share PDF'),
          enabled: _busy == null,
          onTap: () => _run(kind: kind, op: _Op.share, render: render),
        ),
        ListTile(
          key: ValueKey<String>('document-$kind-print'),
          leading: const Icon(Icons.print_outlined),
          title: const Text('Print'),
          enabled: _busy == null,
          onTap: () => _run(kind: kind, op: _Op.print, render: render),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? invoiceId = widget.invoiceId;
    final String? paymentId = widget.paymentId;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (paymentId != null)
            _section(
              'Receipt',
              'receipt',
              () => widget.actions.renderReceipt(paymentId),
            ),
          if (invoiceId != null)
            _section(
              widget.invoiceNo == null
                  ? 'Invoice'
                  : 'Invoice ${widget.invoiceNo}',
              'invoice',
              () => widget.actions.renderInvoice(invoiceId),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
