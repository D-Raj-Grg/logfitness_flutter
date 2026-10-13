// A confirmation dialog that also collects a reason.
//
// Shared by every action whose RPC wants one -- cancelling or freezing a
// membership, revoking an access card. A [StatefulWidget] on purpose: the
// dialog owns its [TextEditingController] and disposes it with its own state,
// after the route has finished animating out. A caller that created the
// controller itself and disposed it when `showDialog` resolved would tear it
// down while the closing transition was still building the field against it.
import 'package:flutter/material.dart';

import 'package:logfitness_flutter/app/brand.dart';

const Key confirmReasonFieldKey = Key('reason-dialog-field');
const Key confirmSubmitKey = Key('reason-dialog-submit');

/// Confirmation that also collects a reason.
///
/// Returns the reason on confirm (possibly empty when [required] is false),
/// or null when the desk backed out. Empty-string-versus-null is the
/// difference between "confirmed with no note" and "did not confirm", and
/// collapsing the two would fire the action on a dismissed dialog.
Future<String?> showReasonDialog(
  BuildContext context, {
  required String title,
  required String body,
  required String fieldLabel,
  required String hint,
  required String confirmLabel,
  String cancelLabel = 'Cancel',
  bool destructive = false,
  bool required = true,
}) {
  return showDialog<String>(
    context: context,
    builder: (BuildContext context) => _ReasonDialog(
      title: title,
      body: body,
      fieldLabel: fieldLabel,
      hint: hint,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      destructive: destructive,
      required: required,
    ),
  );
}

class _ReasonDialog extends StatefulWidget {
  const _ReasonDialog({
    required this.title,
    required this.body,
    required this.fieldLabel,
    required this.hint,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.destructive,
    required this.required,
  });

  final String title;
  final String body;
  final String fieldLabel;
  final String hint;
  final String confirmLabel;
  final String cancelLabel;
  final bool destructive;
  final bool required;

  @override
  State<_ReasonDialog> createState() => _ReasonDialogState();
}

class _ReasonDialogState extends State<_ReasonDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final String value = _controller.text.trim();
    if (widget.required && value.isEmpty) {
      // The database refuses a blank reason too -- `cancel_membership` and
      // `revoke_member_card` both raise. Catching it here saves a round trip;
      // it is not the rule.
      setState(() => _error = 'A reason is required.');
      return;
    }
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(widget.body),
            const SizedBox(height: Brand.spaceMd),
            TextField(
              key: confirmReasonFieldKey,
              controller: _controller,
              autofocus: true,
              minLines: 2,
              maxLines: 4,
              maxLength: 500,
              decoration: InputDecoration(
                labelText: widget.required
                    ? widget.fieldLabel
                    : '${widget.fieldLabel} (optional)',
                hintText: widget.hint,
                errorText: _error,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) {
                if (_error != null) {
                  setState(() => _error = null);
                }
              },
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(widget.cancelLabel),
        ),
        FilledButton(
          key: confirmSubmitKey,
          onPressed: _submit,
          style: widget.destructive
              ? FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                )
              : null,
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
