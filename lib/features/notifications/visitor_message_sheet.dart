// One SMS to one walk-in.
//
// The member sheet's twin, and deliberately so: same preview-then-edit shape,
// same segment counter, same disabled Send carrying the reason. Mirrors
// `logfitness_saas/components/visitors/visitor-message-dialog.tsx`, and shares
// the member sheet's blocker sentences rather than restating them -- the
// number on file and the missing gateway are the same two facts about the same
// org.
//
// TWO DIFFERENCES FROM THE MEMBER SHEET, BOTH ABOUT WHAT A VISITOR IS
//
// **No opt-out branch.** `visitor_notification_preview` has no `opt_out`
// column to report, because a walk-in has no standing instruction: they gave
// the desk a number twenty minutes ago and have no history with the gym. The
// way the desk stops chasing someone is to mark them "not joining", which
// takes them out of the follow-up sweep.
//
// **Only offered while they are still a walk-in.** `send_visitor_notification`
// refuses a converted visitor -- they are a member now, with a member's record
// and a member's consent flag, and the message belongs on that row. Hiding the
// action for a converted visitor is a courtesy, not the gate.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/data/notifications/notification_previews.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/format/sms_segments.dart';
import 'package:logfitness_flutter/features/common/async_value_view.dart';
import 'package:logfitness_flutter/features/common/failure_snackbar.dart';
import 'package:logfitness_flutter/features/common/picker_field.dart';
import 'package:logfitness_flutter/features/notifications/member_message_sheet.dart';
import 'package:logfitness_flutter/features/notifications/notification_labels.dart';
import 'package:logfitness_flutter/features/notifications/send_message_controller.dart';

/// Opens the sheet. Returns true when something was actually sent.
Future<bool?> showVisitorMessageSheet(
  BuildContext context, {
  required String visitorId,
  required String fullName,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (BuildContext sheetContext) =>
        VisitorMessageSheet(visitorId: visitorId, fullName: fullName),
  );
}

/// The sheet's contents. Public so a test can pump it without a navigator.
class VisitorMessageSheet extends ConsumerStatefulWidget {
  const VisitorMessageSheet({
    required this.visitorId,
    required this.fullName,
    super.key,
  });

  final String visitorId;
  final String fullName;

  @override
  ConsumerState<VisitorMessageSheet> createState() =>
      _VisitorMessageSheetState();
}

class _VisitorMessageSheetState extends ConsumerState<VisitorMessageSheet> {
  /// The welcome leads, because the sheet is normally opened the same morning
  /// the person walked in. Same default as the console.
  NotificationEvent _event = NotificationEvent.visitorWelcome;

  final TextEditingController _body = TextEditingController();

  /// The reason whose wording is currently in [_body] -- see the member
  /// sheet's note; the mechanism is identical.
  NotificationEvent? _prefilledFor;

  @override
  void initState() {
    super.initState();
    _body.addListener(_onBodyChanged);
  }

  @override
  void dispose() {
    _body
      ..removeListener(_onBodyChanged)
      ..dispose();
    super.dispose();
  }

  void _onBodyChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AsyncValue<VisitorMessagePreview?> preview = ref.watch(
      visitorMessagePreviewProvider(widget.visitorId, _event),
    );
    final bool sending = ref.watch(sendMessageProvider);

    if (preview.hasValue && _prefilledFor != _event) {
      _prefilledFor = _event;
      final String text = preview.value?.body ?? '';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _body.text = text;
      });
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          Brand.spaceMd,
          0,
          Brand.spaceMd,
          Brand.spaceMd,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Send an SMS', style: theme.textTheme.titleLarge),
            const SizedBox(height: Brand.spaceXs),
            Text(
              'To ${widget.fullName}, now.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Brand.spaceMd),

            PickerField<NotificationEvent>(
              key: const ValueKey<String>('visitor-message-event'),
              label: 'Reason',
              sheetTitle: 'What is this about?',
              value: _event,
              enabled: !sending,
              // Three, and only three. A renewal or a dues reminder has no
              // membership and no balance to put in the sentence for someone
              // who has not joined, and `send_visitor_notification` refuses
              // both.
              options: <PickerOption<NotificationEvent>>[
                for (final NotificationEvent option in kManualVisitorEvents)
                  PickerOption<NotificationEvent>(
                    value: option,
                    label: manualVisitorEventLabel(option),
                  ),
              ],
              onChanged: (NotificationEvent? picked) {
                if (picked == null || picked == _event) return;
                setState(() => _event = picked);
              },
            ),
            const SizedBox(height: Brand.spaceMd),

            AsyncValueView<VisitorMessagePreview?>(
              value: preview,
              onRetry: () => ref.invalidate(
                visitorMessagePreviewProvider(widget.visitorId, _event),
              ),
              isEmpty: (VisitorMessagePreview? value) => value == null,
              emptyMessage: 'That visitor is not in your gym.',
              data: (VisitorMessagePreview? value) =>
                  _Editor(state: this, preview: value!, sending: sending),
            ),
          ],
        ),
      ),
    );
  }

  /// Two reasons, not three. There is no consent flag on a walk-in to honour.
  String? blockerFor(VisitorMessagePreview preview) {
    if (!preview.reachable) return kUnreachableBlocker;
    if (!preview.hasGateway) return kNoGatewayBlocker;
    return null;
  }

  Future<void> send() async {
    final SendMessageResult result = await ref
        .read(sendMessageProvider.notifier)
        .toVisitor(
          visitorId: widget.visitorId,
          event: _event,
          body: _body.text,
        );
    if (!mounted) return;

    switch (result) {
      case SendMessageSucceeded():
        final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
        await Navigator.of(context).maybePop(true);
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text(kQueuedMessage)));
      case SendMessageFailed(:final failure):
        // Verbatim, sheet left open. "That visitor is a member now" is the
        // whole answer, and so is the two-minute guard's refusal.
        showFailureSnackBar(context, failure);
    }
  }
}

class _Editor extends StatelessWidget {
  const _Editor({
    required this.state,
    required this.preview,
    required this.sending,
  });

  final _VisitorMessageSheetState state;
  final VisitorMessagePreview preview;
  final bool sending;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final String body = state._body.text;
    final SmsSegments segments = smsSegments(body);
    final String? blocker = state.blockerFor(preview);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          <String>[
            if (preview.toAddress != null) 'To ${preview.toAddress}',
            '${body.length} characters',
            '${segments.count} SMS${segments.unicode ? ' (Nepali)' : ''}',
          ].join(' · '),
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: Brand.spaceSm),

        TextField(
          key: const ValueKey<String>('visitor-message-body'),
          controller: state._body,
          enabled: !sending,
          minLines: 5,
          maxLines: 8,
          maxLength: kNotificationBodyMaxLength,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Message',
            hintText: 'What should this visitor be told?',
            alignLabelWithHint: true,
          ),
        ),
        Text(
          'Sent as written. Edit it for this one person if you need to; the '
          'gym’s template is not changed.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),

        if (blocker != null) ...<Widget>[
          const SizedBox(height: Brand.spaceMd),
          VisitorMessageBlockerBanner(message: blocker),
        ],

        const SizedBox(height: Brand.spaceMd),
        FilledButton.icon(
          key: const ValueKey<String>('visitor-message-send'),
          onPressed: sending || blocker != null || body.trim().isEmpty
              ? null
              : state.send,
          icon: const Icon(Icons.send_outlined),
          label: Text(sending ? 'Sending…' : 'Send SMS'),
        ),
      ],
    );
  }
}

/// Why this will not go out. The member sheet's banner has the same job and
/// the same look; it is private to that file, so the twin lives here rather
/// than one of them reaching into the other.
class VisitorMessageBlockerBanner extends StatelessWidget {
  const VisitorMessageBlockerBanner({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(Brand.spaceSm),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(Brand.radiusMedium),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.info_outline, size: 20, color: scheme.onSurfaceVariant),
          const SizedBox(width: Brand.spaceSm),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
