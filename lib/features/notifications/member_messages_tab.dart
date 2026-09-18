// The member profile's Messages tab: what this gym has actually told this
// person.
//
// The question it answers is the one a desk gets asked across the counter --
// "nobody told me my membership was ending" -- and the answer is a row with a
// date, the words that went out, and whether the gateway took it. That is why
// the whole body is on the row rather than a subject line: "we sent you a
// reminder" and "we sent you *this*" are not the same claim.
//
// **A history, not a queue.** No Resend, no Cancel, no row menu. Those belong
// on the delivery log, where someone auditing the outbox is looking at every
// row the sweeps wrote; here the desk is looking at one person while that
// person waits. `NotificationTile` takes a null `trailing` for exactly this.
//
// Reads through `send_message_controller.dart`; a widget that builds a
// PostgREST query is a review failure (PLANNING.md §6).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/data/notifications/notification_message.dart';
import 'package:logfitness_flutter/features/common/async_value_view.dart';
import 'package:logfitness_flutter/features/notifications/member_message_sheet.dart';
import 'package:logfitness_flutter/features/notifications/send_message_controller.dart';
import 'package:logfitness_flutter/features/notifications/widgets/notification_tile.dart';
import 'package:logfitness_flutter/features/staff/staff_capabilities.dart';

/// The last 25 messages sent to one member, newest first.
class MemberMessagesTab extends ConsumerWidget {
  const MemberMessagesTab({
    required this.memberId,
    required this.memberName,
    super.key,
  });

  final String memberId;

  /// Only ever used as the sheet's "To ___, now." line.
  final String memberName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<NotificationMessage>> messages = ref.watch(
      memberMessagesProvider(memberId),
    );
    // UX only. `member_message_target` gates on {owner, manager, front_desk}
    // itself and refuses a trainer; hiding the button is a courtesy, and the
    // refusal still reaches the screen if it is reached anyway (CLAUDE.md).
    final bool canSend = ref
        .watch(staffCapabilitiesProvider)
        .contains(StaffCapability.sendMemberMessage);

    return Column(
      children: <Widget>[
        if (canSend)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Brand.spaceMd,
              Brand.spaceMd,
              Brand.spaceMd,
              Brand.spaceSm,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.tonalIcon(
                key: const ValueKey<String>('member-messages-send'),
                onPressed: () => showMemberMessageSheet(
                  context,
                  memberId: memberId,
                  fullName: memberName,
                ),
                icon: const Icon(Icons.sms_outlined),
                label: const Text('Send an SMS'),
              ),
            ),
          ),
        Expanded(
          child: AsyncValueView<List<NotificationMessage>>(
            value: messages,
            onRetry: () => ref.invalidate(memberMessagesProvider(memberId)),
            isEmpty: (List<NotificationMessage> rows) => rows.isEmpty,
            // Said plainly, because an empty tab and a tab that failed to load
            // look identical from the outside and only one of them is a claim
            // about what the gym did.
            emptyMessage: 'Nothing has been sent to this member yet.',
            data: (List<NotificationMessage> rows) => RefreshIndicator(
              onRefresh: () async =>
                  ref.invalidate(memberMessagesProvider(memberId)),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: rows.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (BuildContext context, int index) =>
                    NotificationTile(message: rows[index]),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
