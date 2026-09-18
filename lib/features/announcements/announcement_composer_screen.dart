// Composing one broadcast.
//
// Mirrors `components/announcements/announcement-composer.tsx`, field for field
// and in the same order, with the console's wording carried over rather than
// paraphrased.
//
// A pushed route rather than a bottom sheet, which is the house split: a short
// one-decision form is a sheet (`member_message_sheet.dart`), a long one is a
// screen (`visitor_form_screen.dart`, `renew_membership_screen.dart`). This has
// eight controls and a keyboard-heavy body field.
//
// The number above the button is the load-bearing thing on this screen. It
// comes from the same function the send uses to build its audience, so it is
// the number of messages the gym is about to pay for rather than an estimate
// that agrees with the send most of the time.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/data/announcements/announcement_audience_count.dart';
import 'package:logfitness_flutter/data/announcements/announcement_queries.dart';
import 'package:logfitness_flutter/data/branches/branch.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/domain/format/dates.dart';
import 'package:logfitness_flutter/domain/format/sms_segments.dart';
import 'package:logfitness_flutter/data/branches/branches_repository.dart';
import 'package:logfitness_flutter/features/announcements/announcement_audience_controller.dart';
import 'package:logfitness_flutter/features/announcements/announcement_labels.dart';
import 'package:logfitness_flutter/features/announcements/send_announcement_controller.dart';
import 'package:logfitness_flutter/features/common/docked_action.dart';
import 'package:logfitness_flutter/features/common/failure_snackbar.dart';
import 'package:logfitness_flutter/features/common/picker_field.dart';
import 'package:logfitness_flutter/features/staff/branch_scope.dart';

class AnnouncementComposerScreen extends ConsumerStatefulWidget {
  const AnnouncementComposerScreen({super.key});

  @override
  ConsumerState<AnnouncementComposerScreen> createState() =>
      _AnnouncementComposerScreenState();
}

class _AnnouncementComposerScreenState
    extends ConsumerState<AnnouncementComposerScreen> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _body = TextEditingController();
  final TextEditingController _testTo = TextEditingController();

  DateTime? _scheduledFor;
  bool _later = false;

  @override
  void initState() {
    super.initState();
    // A second announcement starts blank rather than carrying the first one's
    // filters -- the console gets this from remounting the form under a new
    // `key`, this is the same reset. Deferred past the first frame because
    // modifying a provider during a build is not allowed.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.invalidate(announcementDraftProvider);
    });
    // The counters under the body and the Send label both read the text, so
    // every keystroke has to rebuild.
    _title.addListener(_onTextChanged);
    _body.addListener(_onTextChanged);
    _testTo.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _title
      ..removeListener(_onTextChanged)
      ..dispose();
    _body
      ..removeListener(_onTextChanged)
      ..dispose();
    _testTo
      ..removeListener(_onTextChanged)
      ..dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    final AnnouncementAudienceQuery draft = ref.watch(announcementDraftProvider);
    final AsyncValue<AnnouncementAudienceCount> count = ref.watch(
      announcementAudienceCountProvider,
    );
    final bool sending = ref.watch(sendAnnouncementProvider);
    final BranchScope scope = ref.watch(branchScopeProvider);
    final List<Branch> branches =
        ref.watch(branchesProvider).value ?? const <Branch>[];

    final SmsSegments segments = smsSegments(_body.text);
    final AnnouncementAudienceCount? loaded = count.value;

    return Scaffold(
      appBar: AppBar(title: const Text('Announce something')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Brand.spaceMd,
          Brand.spaceMd,
          Brand.spaceMd,
          Brand.spaceXl,
        ),
        children: <Widget>[
          Text(
            'One message to everybody you pick. Sent now, or held until a date '
            'you set.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Brand.spaceMd),

          TextField(
            key: const ValueKey<String>('announcement-title'),
            controller: _title,
            enabled: !sending,
            maxLength: 120,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Title',
              helperText: 'For your own log. It is not part of the message.',
            ),
          ),
          const SizedBox(height: Brand.spaceSm),

          PickerField<AnnouncementAudience>(
            key: const ValueKey<String>('announcement-audience'),
            label: 'Send to',
            value: draft.audience,
            enabled: !sending,
            options: <PickerOption<AnnouncementAudience>>[
              for (final AnnouncementAudience audience
                  in AnnouncementAudience.values)
                PickerOption<AnnouncementAudience>(
                  value: audience,
                  label: announcementAudienceLabel(audience),
                ),
            ],
            onChanged: (AnnouncementAudience? audience) {
              if (audience != null) {
                ref
                    .read(announcementDraftProvider.notifier)
                    .setAudience(audience);
              }
            },
          ),
          const SizedBox(height: Brand.spaceSm),

          // Only when there is more than one thing to pick between. A desk at
          // one branch has nothing to choose, and the database resolves their
          // scope from their own claim anyway.
          if (scope.canSwitch && branches.length > 1) ...<Widget>[
            PickerField<String?>(
              key: const ValueKey<String>('announcement-branch'),
              label: 'Branch',
              // The absent value is a real choice rather than a cleared field,
              // so the hint carries the same words the option does -- see
              // `notification_filter_sheet.dart`, where a null value renders as
              // the hint and a picker with no way back to it is a trap.
              hint: kEveryBranchLabel,
              value: draft.branchId,
              enabled: !sending,
              options: <PickerOption<String?>>[
                const PickerOption<String?>(
                  value: null,
                  label: kEveryBranchLabel,
                ),
                for (final Branch branch in branches)
                  PickerOption<String?>(value: branch.id, label: branch.name),
              ],
              onChanged: (String? branchId) => ref
                  .read(announcementDraftProvider.notifier)
                  .setBranchId(branchId),
            ),
            const SizedBox(height: Brand.spaceSm),
          ],

          if (draft.audience != AnnouncementAudience.visitors) ...<Widget>[
            Text('Members', style: theme.textTheme.labelLarge),
            const SizedBox(height: Brand.spaceXs),
            Wrap(
              spacing: Brand.spaceSm,
              children: <Widget>[
                for (final MemberStatus status in kAnnouncementMemberStatuses)
                  FilterChip(
                    key: ValueKey<String>('announcement-status-${status.name}'),
                    label: Text(announcementMemberStatusLabel(status)),
                    selected: draft.memberStatuses.contains(status),
                    onSelected: sending
                        ? null
                        : (_) => ref
                              .read(announcementDraftProvider.notifier)
                              .toggleStatus(status),
                  ),
              ],
            ),
            const SizedBox(height: Brand.spaceXs),
            Text(
              'None ticked means everyone who has not left. Members who opted '
              'out of messages are never included.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Brand.spaceSm),
          ],

          if (draft.audience != AnnouncementAudience.members) ...<Widget>[
            PickerField<int?>(
              key: const ValueKey<String>('announcement-visitor-window'),
              label: 'Visitors',
              // Same reason as the branch above: the default is "every open
              // visitor", and a field that looks unset when that is what is
              // selected reads as a question nobody answered.
              hint: kVisitorWindows.first.$2,
              value: draft.visitorDays,
              enabled: !sending,
              helperText:
                  'Walk-ins marked "not joining" are never included, and one '
                  'who has since joined is counted once, as a member.',
              options: <PickerOption<int?>>[
                for (final (int? days, String label) in kVisitorWindows)
                  PickerOption<int?>(value: days, label: label),
              ],
              onChanged: (int? days) => ref
                  .read(announcementDraftProvider.notifier)
                  .setVisitorDays(days),
            ),
            const SizedBox(height: Brand.spaceSm),
          ],

          // Segments rather than characters is the number that turns into
          // money, and "(Nepali)" is why 80 characters just became two
          // messages.
          Text(
            '${_body.text.length} characters · ${segments.count} SMS'
            '${segments.unicode ? ' (Nepali)' : ''}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Brand.spaceXs),
          TextField(
            key: const ValueKey<String>('announcement-body'),
            controller: _body,
            enabled: !sending,
            minLines: 4,
            maxLines: 8,
            maxLength: kNotificationBodyMaxLength,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Message',
              helperText:
                  '{{name}}, {{gym_name}} and {{branch_name}} are filled in '
                  'per person.',
            ),
          ),
          const SizedBox(height: Brand.spaceSm),

          SwitchListTile(
            key: const ValueKey<String>('announcement-later'),
            contentPadding: EdgeInsets.zero,
            title: const Text('Send it later'),
            subtitle: Text(
              _later && _scheduledFor != null
                  ? 'Goes out ${formatDateTime(_scheduledFor!)}'
                  : 'Hold it until a date and time you pick.',
            ),
            value: _later,
            onChanged: sending
                ? null
                : (bool on) {
                    setState(() {
                      _later = on;
                      if (!on) _scheduledFor = null;
                    });
                    if (on) _pickSchedule();
                  },
          ),
          if (_later)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                key: const ValueKey<String>('announcement-pick-time'),
                onPressed: sending ? null : _pickSchedule,
                icon: const Icon(Icons.schedule_outlined),
                label: Text(
                  _scheduledFor == null ? 'Pick a time' : 'Change the time',
                ),
              ),
            ),
          const SizedBox(height: Brand.spaceSm),

          _AudiencePanel(
            count: count,
            segments: segments.count,
            hasBody: _body.text.trim().isNotEmpty,
          ),
          const SizedBox(height: Brand.spaceMd),

          _TestSendBlock(
            controller: _testTo,
            enabled: !sending && _body.text.trim().isNotEmpty,
            onSend: _sendTest,
          ),
        ],
      ),
      bottomNavigationBar: DockedAction(
        label: sending
            ? 'Queueing…'
            : _later
            ? 'Schedule it'
            : 'Send to ${loaded?.reachable ?? 0}',
        icon: Icons.campaign_outlined,
        onPressed: _canSend(loaded, sending) ? _send : null,
      ),
    );
  }

  /// Whether pressing Send could do anything.
  ///
  /// UX only. The RPC is what refuses, and every refusal is rendered with the
  /// database's own sentence -- a disabled button is a courtesy, not the
  /// boundary (CLAUDE.md).
  ///
  /// A *stale* count while a new one loads deliberately does not disable: the
  /// button would flicker on every filter change. Only the first load does,
  /// because until it lands there is no number to send to.
  bool _canSend(AnnouncementAudienceCount? loaded, bool sending) {
    if (sending) return false;
    if (_title.text.trim().isEmpty || _body.text.trim().isEmpty) return false;
    if (loaded == null) return false;
    if (loaded.nothingToSend) return false;
    if (_later && _scheduledFor == null) return false;
    return true;
  }

  /// Fire and forget: the pickers write to state when they come back, and
  /// nothing after the call depends on them.
  void _pickSchedule() {
    unawaited(_pickScheduleAsync());
  }

  Future<void> _pickScheduleAsync() async {
    final DateTime now = DateTime.now();
    final DateTime? day = await showDatePicker(
      context: context,
      initialDate: _scheduledFor ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    if (!mounted) return;
    if (day == null) return _abandonSchedule();

    final TimeOfDay? time = await showTimeOfDay(context, _scheduledFor);
    if (!mounted) return;
    if (time == null) return _abandonSchedule();

    setState(() {
      // A device-local instant. The repository converts with `.toUtc()`, which
      // is the only correct thing to send for a `timestamptz` -- see the note
      // there about Kathmandu being 5h45m off.
      _scheduledFor = DateTime(
        day.year,
        day.month,
        day.day,
        time.hour,
        time.minute,
      );
    });
  }

  /// Backing out of either picker turns the switch off again.
  ///
  /// Leaving it on with no time behind it disables Send and says nothing about
  /// why -- a dead end reached by dismissing a dialog, which is the easiest
  /// thing in the world to do by accident.
  void _abandonSchedule() {
    if (_scheduledFor != null) return;
    setState(() => _later = false);
  }

  static Future<TimeOfDay?> showTimeOfDay(
    BuildContext context,
    DateTime? current,
  ) {
    return showTimePicker(
      context: context,
      initialTime: current == null
          ? TimeOfDay.now()
          : TimeOfDay(hour: current.hour, minute: current.minute),
    );
  }

  Future<void> _send() async {
    final AnnouncementAudienceQuery draft = ref.read(announcementDraftProvider);

    final AnnouncementActionResult result = await ref
        .read(sendAnnouncementProvider.notifier)
        .send(
          title: _title.text,
          body: _body.text,
          audience: draft.audience,
          branchId: draft.branchId,
          memberStatuses: draft.memberStatuses,
          visitorDays: draft.visitorDays,
          scheduledFor: _later ? _scheduledFor : null,
        );
    if (!mounted) return;

    switch (result) {
      case AnnouncementFailed(:final AppFailure failure):
        showFailureSnackBar(context, failure);
      case AnnouncementSent(:final String message):
        // The messenger is read before the pop, because after it this
        // context's Scaffold is gone -- the house pattern, and the comment, are
        // `member_message_sheet.dart`'s.
        final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
        await Navigator.of(context).maybePop();
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      case AnnouncementTested():
      case AnnouncementCancelled():
        break;
    }
  }

  Future<void> _sendTest() async {
    final AnnouncementActionResult result = await ref
        .read(sendAnnouncementProvider.notifier)
        .test(body: _body.text, to: _testTo.text, title: _title.text);
    if (!mounted) return;

    switch (result) {
      case AnnouncementFailed(:final AppFailure failure):
        showFailureSnackBar(context, failure);
      case AnnouncementTested(:final String message):
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      case AnnouncementSent():
      case AnnouncementCancelled():
        break;
    }
  }
}

/// Who it is going to, and what that costs.
class _AudiencePanel extends StatelessWidget {
  const _AudiencePanel({
    required this.count,
    required this.segments,
    required this.hasBody,
  });

  final AsyncValue<AnnouncementAudienceCount> count;
  final int segments;
  final bool hasBody;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    // A failed count is not swallowed. It is the number the gym is about to
    // spend money against, so it says so where the number would have been.
    final Object? error = count.error;
    final AnnouncementAudienceCount? loaded = count.value;

    final String headline;
    if (error != null) {
      headline = error is AppFailure
          ? error.message
          : 'Could not count the audience.';
    } else if (loaded == null) {
      headline = 'Counting…';
    } else if (loaded.nothingToSend) {
      headline = 'Nobody matches that audience yet.';
    } else {
      headline = hasBody
          ? '${loaded.reachable} will be texted · about '
                '${loaded.reachable * segments} SMS credits'
          : '${loaded.reachable} will be texted';
    }

    return Container(
      key: const ValueKey<String>('announcement-audience-panel'),
      width: double.infinity,
      padding: const EdgeInsets.all(Brand.spaceMd),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(Brand.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            headline,
            style: theme.textTheme.titleSmall?.copyWith(
              color: error != null ? scheme.error : null,
            ),
          ),
          if (loaded != null && error == null) ...<Widget>[
            const SizedBox(height: Brand.spaceXs),
            Text(
              <String>[
                '${loaded.members} members',
                '${loaded.visitors} visitors',
                if (loaded.unusable > 0)
                  '${loaded.unusable} with no usable number, logged as not sent',
              ].join(' · '),
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// One number, typed by hand, before four hundred.
class _TestSendBlock extends StatelessWidget {
  const _TestSendBlock({
    required this.controller,
    required this.enabled,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(Brand.spaceMd),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Brand.radiusMedium),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Send yourself one first', style: theme.textTheme.titleSmall),
          const SizedBox(height: Brand.spaceXs),
          Text(
            'A variable that renders empty, or a Nepali sentence that arrives '
            'as three messages, is obvious on a handset and invisible here.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Brand.spaceSm),
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  key: const ValueKey<String>('announcement-test-to'),
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Mobile number'),
                ),
              ),
              const SizedBox(width: Brand.spaceSm),
              FilledButton.tonal(
                key: const ValueKey<String>('announcement-test-send'),
                onPressed: enabled && controller.text.trim().isNotEmpty
                    ? onSend
                    : null,
                child: const Text('Send test'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
