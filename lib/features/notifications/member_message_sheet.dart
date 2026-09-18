// One SMS to one member, now.
//
// Mirrors `logfitness_saas/components/members/member-message-dialog.tsx`
// sentence for sentence -- the blocker copy in particular is transcribed, not
// paraphrased, because a desk reading the console and a desk reading the phone
// are being told why the same member cannot be messaged.
//
// WHY A SHEET AND NOT AN `AlertDialog`
//
// The console has a dialog because it has a desktop. This has a reason picker,
// a five-line editor and a keyboard; on a phone an `AlertDialog` puts all
// three inside a box with ~200 logical pixels of usable height once the
// keyboard is up, and the Send button ends up behind it. A scroll-controlled
// modal sheet is the platform's answer: it takes the full height it needs,
// gets out of the keyboard's way, and is reachable one-handed. `PickerField`
// made the same call against `DropdownButtonFormField` for the same reason.
//
// TWO LOAD-BEARING FACTS
//
// **What is sent is what the log stores.** The wording is rendered in Postgres
// from the gym's own template and this member's real figures, then edited here
// if the desk wants -- and the edited text travels with the send rather than
// being re-rendered on the server. So the message the member receives and the
// row the log keeps are the same string, and nobody has to reconcile two
// renderings of "you owe Rs 3,400" a month later.
//
// **Opt-out is not overridable.** `send_member_notification` raises a
// `check_violation` for a member with `notifications_opt_out` set, and takes
// no argument that suppresses it. Consent is not something a button overrides.
// Send is disabled and says why, and if the button is reached anyway the
// database's refusal is rendered verbatim -- which is the whole rule in
// `staff_capabilities.dart`: hide the button, and still show the refusal.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/data/notifications/notification_previews.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/format/sms_segments.dart';
import 'package:logfitness_flutter/features/common/async_value_view.dart';
import 'package:logfitness_flutter/features/common/failure_snackbar.dart';
import 'package:logfitness_flutter/features/common/picker_field.dart';
import 'package:logfitness_flutter/features/notifications/notification_labels.dart';
import 'package:logfitness_flutter/features/notifications/send_message_controller.dart';

/// The three reasons a member cannot be messaged, in the order the console
/// checks them. Copied verbatim; see the file header.
const String kMemberOptOutBlocker =
    'This member has asked not to receive messages.';
const String kUnreachableBlocker =
    'The number on file is not a mobile number this can be sent to.';
const String kNoGatewayBlocker =
    'No SMS gateway is set up yet. An owner configures one in Settings.';

/// What the desk is told when the send lands. Not "Sent": it is queued, and
/// the sweep picks it up within a minute -- claiming delivery the gateway has
/// not confirmed is the one sentence the delivery log exists to correct.
const String kQueuedMessage = 'Queued. It goes out within a minute.';

/// Opens the sheet. Returns true when something was actually sent.
Future<bool?> showMemberMessageSheet(
  BuildContext context, {
  required String memberId,
  required String fullName,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (BuildContext sheetContext) =>
        MemberMessageSheet(memberId: memberId, fullName: fullName),
  );
}

/// The sheet's contents. Public so a test can pump it without a navigator.
class MemberMessageSheet extends ConsumerStatefulWidget {
  const MemberMessageSheet({
    required this.memberId,
    required this.fullName,
    super.key,
  });

  final String memberId;
  final String fullName;

  @override
  ConsumerState<MemberMessageSheet> createState() => _MemberMessageSheetState();
}

class _MemberMessageSheetState extends ConsumerState<MemberMessageSheet> {
  /// Dues first, because chasing money is why this screen exists and why the
  /// desk is holding the phone. Same default as the console.
  NotificationEvent _event = NotificationEvent.duesReminder;

  final TextEditingController _body = TextEditingController();

  /// The reason whose wording is currently in [_body]. Changing the picker
  /// makes this stale, which is what triggers the re-fill -- and keeping it
  /// means a rebuild for any other cause (the keyboard, a character typed)
  /// never overwrites what the desk has edited.
  NotificationEvent? _prefilledFor;

  @override
  void initState() {
    super.initState();
    // The counter line is derived from the text, so it has to rebuild with it.
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
    final AsyncValue<MemberMessagePreview?> preview = ref.watch(
      memberMessagePreviewProvider(widget.memberId, _event),
    );
    final bool sending = ref.watch(sendMessageProvider);

    // Re-fill when the reason changes, and only then. Deferred to after the
    // frame because writing a controller during build is how a "setState
    // during build" crash is written by accident.
    if (preview.hasValue && _prefilledFor != _event) {
      _prefilledFor = _event;
      final String text = preview.value?.body ?? '';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _body.text = text;
      });
    }

    return Padding(
      // The keyboard's height, so the editor and the Send button stay above it.
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
              key: const ValueKey<String>('member-message-event'),
              label: 'Reason',
              sheetTitle: 'What is this about?',
              value: _event,
              enabled: !sending,
              options: <PickerOption<NotificationEvent>>[
                for (final NotificationEvent option in kManualMemberEvents)
                  PickerOption<NotificationEvent>(
                    value: option,
                    label: manualMemberEventLabel(option),
                  ),
              ],
              onChanged: (NotificationEvent? picked) {
                if (picked == null || picked == _event) return;
                // `_prefilledFor` is now stale, which is the whole mechanism:
                // the new reason is a different provider, and its answer
                // replaces the editor's contents when it arrives.
                setState(() => _event = picked);
              },
            ),
            const SizedBox(height: Brand.spaceMd),

            // The preview's own failure gets the shared treatment rather than
            // a hand-rolled `.when(error:)` -- a refusal has to read as a
            // refusal (CLAUDE.md, and `failure_view.dart`'s 2026-09-07 note).
            AsyncValueView<MemberMessagePreview?>(
              value: preview,
              onRetry: () => ref.invalidate(
                memberMessagePreviewProvider(widget.memberId, _event),
              ),
              // Absent and hidden by RLS are the same answer from outside.
              isEmpty: (MemberMessagePreview? value) => value == null,
              emptyMessage: 'That member is not in your gym.',
              data: (MemberMessagePreview? value) =>
                  _Editor(state: this, preview: value!, sending: sending),
            ),
          ],
        ),
      ),
    );
  }

  /// The first reason this would not go out, or null if it would.
  ///
  /// Order matters and matches the console: an opted-out member is told about
  /// their consent, not about the gateway, because the consent is the answer
  /// even after an owner configures one.
  String? blockerFor(MemberMessagePreview preview) {
    if (preview.optOut) return kMemberOptOutBlocker;
    if (!preview.reachable) return kUnreachableBlocker;
    if (!preview.hasGateway) return kNoGatewayBlocker;
    return null;
  }

  Future<void> send() async {
    final SendMessageResult result = await ref
        .read(sendMessageProvider.notifier)
        .toMember(
          memberId: widget.memberId,
          event: _event,
          body: _body.text,
        );
    if (!mounted) return;

    switch (result) {
      case SendMessageSucceeded():
        // The messenger is read before the pop, because after it this
        // context's Scaffold is gone.
        final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
        await Navigator.of(context).maybePop(true);
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text(kQueuedMessage)));
      case SendMessageFailed(:final failure):
        // Verbatim, and the sheet stays open. The two-minute guard raises
        // `unique_violation` -- "That message is already queued for this
        // member" -- and `member_message_target` refuses a trainer, another
        // gym's member, an archived member and a member outside the sender's
        // branches. Every one of those is a whole sentence, and none of them
        // is something to retry, so no retry is offered for a refusal.
        showFailureSnackBar(context, failure);
    }
  }
}

/// The recipient line, the editable wording, the blocker banner and Send.
class _Editor extends StatelessWidget {
  const _Editor({
    required this.state,
    required this.preview,
    required this.sending,
  });

  final _MemberMessageSheetState state;
  final MemberMessagePreview preview;
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
        // Recipient, length and cost on one line. Segments rather than
        // characters is the number that turns into money, and "(Nepali)" is
        // the explanation for why 80 characters just became two messages.
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
          key: const ValueKey<String>('member-message-body'),
          controller: state._body,
          enabled: !sending,
          minLines: 5,
          maxLines: 8,
          // The database writes `left(btrim(body), 1000)`, so a longer message
          // is silently shortened server-side. Capping here shows the limit to
          // the person typing instead of hiding it in the log.
          maxLength: kNotificationBodyMaxLength,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Message',
            hintText: 'What should this member be told?',
            alignLabelWithHint: true,
          ),
        ),
        Text(
          'Sent as written. Edit the standard wording if this member needs '
          'something else; the gym’s template is not changed.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),

        if (blocker != null) ...<Widget>[
          const SizedBox(height: Brand.spaceMd),
          _BlockerBanner(message: blocker),
        ],

        const SizedBox(height: Brand.spaceMd),
        FilledButton.icon(
          key: const ValueKey<String>('member-message-send'),
          // Blocked, blank or already sending: three ways of having nothing to
          // do, and none of them is worth a round trip the database refuses.
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

/// Why this will not go out. Not an error treatment: an opted-out member is a
/// correct outcome the desk needs to read, not a fault to be recovered from.
class _BlockerBanner extends StatelessWidget {
  const _BlockerBanner({required this.message});

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
