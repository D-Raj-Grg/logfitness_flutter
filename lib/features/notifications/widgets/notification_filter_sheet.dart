// The two filters that do not fit on a phone's chip row.
//
// Status stays on the log itself, because it is the one a desk actually
// reaches for ("what failed last night"). Reason and channel are narrower
// questions asked less often, and a second and third scrolling chip row buys
// nothing but two lines of screen: they go in a sheet, behind one button that
// says how many of them are on.
//
// `PickerField` rather than a `DropdownButtonFormField` for the reason that
// file states at length -- a dropdown's overlay covers most of a phone.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/data/notifications/notification_queries.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/features/common/picker_field.dart';
import 'package:logfitness_flutter/features/notifications/notification_labels.dart';
import 'package:logfitness_flutter/features/notifications/notification_log_controller.dart';

const Key notificationFilterSheetKey = Key('notification-filter-sheet');

/// Opens the reason/channel sheet over [context].
///
/// Writes straight through to [notificationFilterProvider] as each field is
/// picked rather than collecting a draft and applying it on dismiss: the list
/// behind the sheet is only half covered, so a change that shows up there
/// immediately is its own confirmation.
Future<void> showNotificationFilterSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (BuildContext sheetContext) => const _NotificationFilterSheet(),
  );
}

class _NotificationFilterSheet extends ConsumerWidget {
  const _NotificationFilterSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final NotificationListFilter filter = ref.watch(notificationFilterProvider);
    final NotificationFilter notifier = ref.read(
      notificationFilterProvider.notifier,
    );

    return SafeArea(
      key: notificationFilterSheetKey,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Brand.spaceLg,
          0,
          Brand.spaceLg,
          Brand.spaceLg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: Brand.spaceMd),
              child: Text('Narrow the log', style: theme.textTheme.titleMedium),
            ),
            PickerField<NotificationEvent?>(
              key: const ValueKey<String>('notification-filter-event'),
              label: 'Reason',
              // The absent value is a real option rather than a cleared field:
              // "Any reason" is what the reader is choosing, and a picker with
              // no way back to it is a trap.
              hint: kEveryReasonLabel,
              value: filter.event,
              options: <PickerOption<NotificationEvent?>>[
                const PickerOption<NotificationEvent?>(
                  value: null,
                  label: kEveryReasonLabel,
                ),
                for (final NotificationEvent event in NotificationEvent.values)
                  PickerOption<NotificationEvent?>(
                    value: event,
                    label: notificationEventLabel(event),
                  ),
              ],
              onChanged: notifier.setEvent,
            ),
            const SizedBox(height: Brand.spaceMd),
            PickerField<NotificationChannel?>(
              key: const ValueKey<String>('notification-filter-channel'),
              label: 'Channel',
              hint: kEveryChannelLabel,
              value: filter.channel,
              options: <PickerOption<NotificationChannel?>>[
                const PickerOption<NotificationChannel?>(
                  value: null,
                  label: kEveryChannelLabel,
                ),
                for (final NotificationChannel channel
                    in NotificationChannel.values)
                  PickerOption<NotificationChannel?>(
                    value: channel,
                    label: notificationChannelLabel(channel),
                  ),
              ],
              onChanged: notifier.setChannel,
            ),
            const SizedBox(height: Brand.spaceLg),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  key: const ValueKey<String>('notification-filter-clear'),
                  // Clears the search and the status chip too, not only what
                  // this sheet holds. Someone reaching for "show me everything"
                  // does not mean "everything except the three words I typed
                  // upstairs".
                  onPressed: () {
                    notifier.clear();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Clear filters'),
                ),
                const SizedBox(width: Brand.spaceSm),
                FilledButton.tonal(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
