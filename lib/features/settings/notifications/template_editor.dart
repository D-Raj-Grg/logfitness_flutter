// What the messages actually say.
//
// Port of `logfitness_saas/components/notifications/template-editor.tsx`: the
// per-event variable list, the sample values and the rough preview are copied
// from it, so a gym that drafts its renewal reminder on a laptop and reads it
// back on a phone sees the same sentence both times.
//
// Two things this screen is careful about.
//
// **The preview is rough, and says so.** The message that actually goes out is
// rendered in Postgres by `render_notification_template`, which is what makes
// the nightly sweep, the console and this app agree; substituting here is only
// to show the shape while someone is typing.
//
// **It counts segments, not characters.** Segments are what turn into money. A
// Devanagari body is UCS-2, so a segment is 70 characters instead of 160 and a
// reminder that fits in one English message is usually three Nepali ones
// (`logfitness_saas/docs/notifications.md` §1). That is the entire reason
// `smsSegments` exists.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/data/notifications/notification_template.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/domain/format/sms_segments.dart';
import 'package:logfitness_flutter/features/common/async_value_view.dart';
import 'package:logfitness_flutter/features/common/failure_snackbar.dart';
import 'package:logfitness_flutter/features/notifications/notification_labels.dart';
import 'package:logfitness_flutter/features/settings/notifications/notification_settings_actions.dart';
import 'package:logfitness_flutter/features/settings/notifications/notification_settings_controllers.dart';

/// Which placeholders actually carry a value for each reason. `VARIABLES`
/// upstream. Offering one that resolves to nothing is how a reminder ships with
/// a blank where a date should be.
const Map<NotificationEvent, List<String>> kTemplateVariables =
    <NotificationEvent, List<String>>{
      NotificationEvent.renewalReminder: <String>[
        'member_name',
        'gym_name',
        'branch_name',
        'plan_name',
        'end_date',
        'days_left',
      ],
      NotificationEvent.duesReminder: <String>[
        'member_name',
        'gym_name',
        'branch_name',
        'due_amount',
      ],
      NotificationEvent.birthdayGreeting: <String>[
        'member_name',
        'gym_name',
        'branch_name',
      ],
      NotificationEvent.visitorWelcome: <String>[
        'visitor_name',
        'gym_name',
        'branch_name',
        'plan_name',
        'visited_on',
      ],
      NotificationEvent.visitorFollowUp: <String>[
        'visitor_name',
        'gym_name',
        'branch_name',
        'plan_name',
        'visited_on',
      ],
      NotificationEvent.memberWelcome: <String>[
        'member_name',
        'gym_name',
        'branch_name',
        'plan_name',
        'start_date',
        'end_date',
      ],
      // `due_amount` here is what is left on that invoice *after* the payment,
      // which on the last instalment is Rs 0.
      NotificationEvent.paymentReceived: <String>[
        'member_name',
        'gym_name',
        'branch_name',
        'amount',
        'due_amount',
        'invoice_no',
        'paid_on',
      ],
      NotificationEvent.duesCleared: <String>[
        'member_name',
        'gym_name',
        'branch_name',
        'amount',
        'invoice_no',
      ],
    };

/// What the rough preview substitutes. `SAMPLE` upstream, verbatim.
const Map<String, String> kTemplateSampleValues = <String, String>{
  'member_name': 'Ram Thapa',
  'gym_name': 'Lord of Gyms',
  'branch_name': 'Thamel',
  'plan_name': 'Monthly',
  'end_date': '16 Sep 2026',
  'days_left': '7',
  'due_amount': 'Rs 2,000',
  'visitor_name': 'Bina Gurung',
  'visited_on': '12 Sep 2026',
  'start_date': '20 Sep 2026',
  'amount': 'Rs 2,500',
  'invoice_no': 'INV000241',
  'paid_on': '20 Sep 2026',
};

final RegExp _placeholder = RegExp(r'\{\{([a-z_]+)\}\}');
final RegExp _runsOfSpaces = RegExp(' {2,}');

/// A rough local preview. See the file header: the real render happens in
/// Postgres, and this is here to show the shape while someone types.
String previewTemplateBody(String body) {
  return body
      .replaceAllMapped(
        _placeholder,
        (Match match) => kTemplateSampleValues[match.group(1)] ?? '',
      )
      .replaceAll(_runsOfSpaces, ' ')
      .trim();
}

class TemplateEditor extends ConsumerWidget {
  const TemplateEditor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Brand.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('What the message says', style: theme.textTheme.titleMedium),
            const SizedBox(height: Brand.spaceXs),
            Text(
              'Editing this changes messages queued from now on. Anything already '
              'in the log keeps the words it was sent with.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            for (final NotificationEvent event in kEditableTemplateEvents)
              _TemplateSlot(event: event),
          ],
        ),
      ),
    );
  }
}

/// One event's wording, resolved through the database.
class _TemplateSlot extends ConsumerWidget {
  const _TemplateSlot({required this.event});

  final NotificationEvent event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<NotificationTemplatePreview?> preview = ref.watch(
      notificationTemplatePreviewProvider(event),
    );
    final AsyncValue<String> locale = ref.watch(notificationLocaleProvider);

    return Padding(
      padding: const EdgeInsets.only(top: Brand.spaceMd),
      child: AsyncValueView<NotificationTemplatePreview?>(
        value: preview,
        onRetry: () =>
            ref.invalidate(notificationTemplatePreviewProvider(event)),
        // `notification_template_preview` returns the gym's own row or, failing
        // that, the built-in, so for an editable event this should never be
        // empty. Should never is not never: without this, a null resolves to a
        // blank editor with no explanation, and Save then answers "The message
        // cannot be empty" about a box the app emptied itself.
        isEmpty: (NotificationTemplatePreview? resolved) => resolved == null,
        emptyMessage:
            'There is no built-in wording for this reminder yet, so there is '
            'nothing to edit here.',
        data: (NotificationTemplatePreview? resolved) => _TemplateCard(
          // Rebuilt from whatever the database resolved after a save or a
          // reset, rather than keeping the text that was on screen: "reset to
          // built-in" is exactly the case where those two differ.
          key: ValueKey<String>(
            '${event.wire}-${resolved?.templateId}-${resolved?.body.length}',
          ),
          event: event,
          preview: resolved,
          // The locale the gym actually sends in, never a Dart-side `'en'`.
          // A Nepali gym previewing English while sending Nepali is a bug
          // nobody reports, because the preview looks right to the person
          // reading it.
          locale: locale.value,
        ),
      ),
    );
  }
}

class _TemplateCard extends ConsumerStatefulWidget {
  const _TemplateCard({
    required this.event,
    required this.preview,
    required this.locale,
    super.key,
  });

  final NotificationEvent event;
  final NotificationTemplatePreview? preview;

  /// Null while `org_notification_locale` is still in flight. Saving is held
  /// back until it lands rather than guessed at.
  final String? locale;

  @override
  ConsumerState<_TemplateCard> createState() => _TemplateCardState();
}

class _TemplateCardState extends ConsumerState<_TemplateCard> {
  late final TextEditingController _body;

  @override
  void initState() {
    super.initState();
    _body = TextEditingController(text: widget.preview?.body ?? '');
  }

  @override
  void dispose() {
    _body.dispose();
    super.dispose();
  }

  void _append(String variable) {
    final String next = '${_body.text}{{$variable}}';
    _body.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: next.length),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final NotificationEvent event = widget.event;
    final bool orgOwned = widget.preview?.isOrgOwned ?? false;
    final bool saving = ref.watch(notificationSettingsActionsProvider);
    final SmsSegments segments = smsSegments(_body.text);
    final bool visitor =
        event == NotificationEvent.visitorWelcome ||
        event == NotificationEvent.visitorFollowUp;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                notificationEventLabel(event),
                style: theme.textTheme.titleSmall,
              ),
            ),
            Chip(
              key: ValueKey<String>('template-ownership-${event.wire}'),
              label: Text(orgOwned ? 'Your wording' : 'Standard wording'),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        const SizedBox(height: Brand.spaceSm),

        Wrap(
          spacing: Brand.spaceXs,
          runSpacing: Brand.spaceXs,
          children: <Widget>[
            for (final String variable
                in kTemplateVariables[event] ?? const <String>[])
              ActionChip(
                key: ValueKey<String>('template-var-${event.wire}-$variable'),
                label: Text('{{$variable}}'),
                visualDensity: VisualDensity.compact,
                onPressed: () => _append(variable),
              ),
          ],
        ),
        const SizedBox(height: Brand.spaceSm),

        TextField(
          key: ValueKey<String>('template-body-${event.wire}'),
          controller: _body,
          minLines: 3,
          maxLines: 6,
          // The database writes `left(btrim(body), 1000)`, so a longer message
          // is silently shortened server-side. Capping here means the person
          // typing sees the limit instead of discovering it in the log.
          maxLength: kNotificationBodyMaxLength,
          onChanged: (String _) => setState(() {}),
          decoration: const InputDecoration(labelText: 'Message'),
        ),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(Brand.spaceSm),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(Brand.radiusSmall),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                visitor ? 'A visitor would read' : 'A member would read',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: Brand.spaceXs),
              Text(
                previewTemplateBody(_body.text),
                key: ValueKey<String>('template-preview-${event.wire}'),
              ),
              const SizedBox(height: Brand.spaceXs),
              Text(
                segments.unicode
                    ? '${segments.count} SMS (Nepali text sends as Unicode, so a message is '
                          '${segments.perSegment} characters and costs more)'
                    : '${segments.count} SMS',
                key: ValueKey<String>('template-segments-${event.wire}'),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: Brand.spaceXs),
              Text(
                'A rough preview. The message that goes out is put together by the '
                'database, so the nightly reminders and this screen always use the '
                'same wording.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: Brand.spaceSm),
        Wrap(
          spacing: Brand.spaceSm,
          children: <Widget>[
            OutlinedButton(
              key: ValueKey<String>('template-save-${event.wire}'),
              onPressed: (saving || widget.locale == null)
                  ? null
                  : () => unawaited(_save()),
              child: const Text('Save wording'),
            ),
            // Offered only when the gym has its own row. There is nothing to
            // reset when the built-in is already what is being used, and a
            // button that deletes nothing is a button that looks broken.
            if (orgOwned)
              TextButton(
                key: ValueKey<String>('template-reset-${event.wire}'),
                onPressed: saving ? null : () => unawaited(_reset()),
                child: const Text('Use the standard wording'),
              ),
          ],
        ),
        const Divider(),
      ],
    );
  }

  Future<void> _save() async {
    final String? locale = widget.locale;
    if (locale == null) return;

    await _report(
      ref
          .read(notificationSettingsActionsProvider.notifier)
          .saveTemplate(
            event: widget.event,
            // SMS only, as on the console: Viber and email reuse the SMS
            // wording until a gym asks for a second draft.
            channel: NotificationChannel.sms,
            locale: locale,
            body: _body.text,
          ),
    );
  }

  Future<void> _reset() async {
    final String? templateId = widget.preview?.templateId;
    if (templateId == null) return;
    await _report(
      ref
          .read(notificationSettingsActionsProvider.notifier)
          .resetTemplate(templateId),
    );
  }

  Future<void> _report(Future<SettingsActionResult> pending) async {
    final SettingsActionResult result = await pending;
    if (!mounted) return;

    switch (result) {
      case SettingsActionSucceeded(:final String message):
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      case SettingsActionFailed(:final AppFailure failure):
        showFailureSnackBar(context, failure);
    }
  }
}
