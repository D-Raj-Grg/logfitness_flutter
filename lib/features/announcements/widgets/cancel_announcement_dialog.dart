// The confirmation in front of Stop.
//
// "Cancel" reads as "undo" and this is not one: the messages that have already
// left are on four hundred handsets and cannot be recalled. So the dialog says
// what will and will not happen, in the console's words
// (`components/announcements/announcement-row-actions.tsx`), and the
// destructive verb is on the button rather than in the title.
import 'package:flutter/material.dart';

/// Returns true when the desk confirmed.
Future<bool> confirmCancelAnnouncement(
  BuildContext context, {
  required String title,
  required int waiting,
}) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) => AlertDialog(
      title: Text('Stop "$title"?'),
      content: Text(
        'This stops the $waiting ${waiting == 1 ? 'message' : 'messages'} that '
        'have not gone out yet. Anything already delivered cannot be recalled, '
        'and the people who got it will not be told otherwise.',
      ),
      actions: <Widget>[
        TextButton(
          key: const ValueKey<String>('announcement-cancel-dismiss'),
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Leave it running'),
        ),
        FilledButton(
          key: const ValueKey<String>('announcement-cancel-confirm'),
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Stop the rest'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
