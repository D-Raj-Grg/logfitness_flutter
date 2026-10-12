import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/app/brand.dart';
import 'package:logfitness_flutter/data/notifications/notification_message.dart';
import 'package:logfitness_flutter/domain/format/dates.dart';
import 'package:logfitness_flutter/features/common/async_value_view.dart';
import 'package:logfitness_flutter/features/member/home/member_providers.dart';
import 'package:logfitness_flutter/features/notifications/notification_labels.dart';

/// Read-only history of messages the gym sent this member.
class MemberMessagesScreen extends ConsumerWidget {
  const MemberMessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(memberOwnMessagesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(memberOwnMessagesProvider);
          await ref.read(memberOwnMessagesProvider.future);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(Brand.spaceMd),
          children: <Widget>[
            AsyncValueView<List<NotificationMessage>>(
              value: async,
              onRetry: () => ref.invalidate(memberOwnMessagesProvider),
              isEmpty: (l) => l.isEmpty,
              emptyMessage: 'No messages yet.',
              data: (list) => Column(
                children: <Widget>[
                  for (final NotificationMessage m in list)
                    Card(
                      child: ListTile(
                        title: Text(
                          m.subject ?? notificationEventShort(m.event),
                        ),
                        subtitle: Text(
                          '${m.body}\n${formatDateTime(m.createdAt)}',
                        ),
                        isThreeLine: true,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
