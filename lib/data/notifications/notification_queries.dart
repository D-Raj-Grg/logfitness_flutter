// What the delivery log is narrowed to, what one page of it looks like, and the
// two pure filter-string builders behind both.
//
// Mirrors `NotificationListFilter` / `NotificationListResult` in
// `logfitness_saas/lib/db/notifications.ts`.
//
// None of this is a security boundary. RLS already bounds the rows to the org
// and, for anyone who is not an owner or a manager, to their own branches,
// before any of it is applied.
import 'package:logfitness_flutter/data/notifications/notification_message.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';

class NotificationListFilter {
  const NotificationListFilter({
    this.branchIds,
    this.status,
    this.event,
    this.channel,
    this.query,
    this.page = 1,
    this.pageSize = 20,
  });

  /// `null` = every branch RLS allows, which is what an owner sees by default.
  /// An empty list is a real filter matching nothing, so the two must never be
  /// conflated -- the branch switcher may not silently widen.
  final List<String>? branchIds;

  final NotificationStatus? status;
  final NotificationEvent? event;
  final NotificationChannel? channel;

  /// Free text over the recipient address and the message itself.
  final String? query;

  final int page;
  final int pageSize;

  bool get isFiltered =>
      status != null || event != null || channel != null || query != null;
}

/// One page of the log. [total] counts the whole filtered set, not the page.
class NotificationPage {
  const NotificationPage({
    required this.rows,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  final List<NotificationMessage> rows;
  final int total;
  final int page;
  final int pageSize;

  bool get hasMore => page * pageSize < total;
}

/// The `or` expression that scopes the log to a set of branches, or `null` when
/// there is nothing to scope to.
///
/// Not `inFilter`, which is what every other repository here uses: a message
/// raised for the whole org carries **no branch**, and it belongs to everyone
/// who can see the org rather than to nobody. `branch_id.is.null` is that
/// clause, and dropping it hides staff invitations and test messages from every
/// screen that has a branch selected.
///
/// An empty list returns `'branch_id.is.null'` rather than an `in.()`, which is
/// not valid PostgREST -- and which is also the honest reading of "the branches
/// I am scoped to, of which there are none".
String? notificationBranchFilter(List<String>? branchIds) {
  if (branchIds == null) return null;
  if (branchIds.isEmpty) return 'branch_id.is.null';
  return 'branch_id.is.null,branch_id.in.(${branchIds.join(',')})';
}

/// The `or` expression for the free-text search, or `null` when there is
/// nothing to search for.
///
/// Kept pure so it can be tested without a client, and written
/// character-for-character like the console's. `%`, `_`, `,` and the
/// parentheses are stripped rather than escaped: they are the syntax of the
/// `or` expression itself, and none of them is meaningful in a phone number or
/// in the body of a reminder.
String? notificationSearchFilter(String? term) {
  final String? trimmed = term?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  final String escaped = trimmed.replaceAll(RegExp(r'[%_,()]'), ' ').trim();
  if (escaped.isEmpty) return null;
  return 'to_address.ilike.%$escaped%,body.ilike.%$escaped%';
}

/// The four states the log's summary strip counts, in the order it shows them.
const List<NotificationStatus> kSummaryStatuses = <NotificationStatus>[
  NotificationStatus.sent,
  NotificationStatus.queued,
  NotificationStatus.failed,
  NotificationStatus.skipped,
];

/// How many messages are sitting in each state.
class NotificationStatusCounts {
  const NotificationStatusCounts(this.byStatus);

  final Map<NotificationStatus, int> byStatus;

  int operator [](NotificationStatus status) => byStatus[status] ?? 0;

  int get total => byStatus.values.fold(0, (int sum, int n) => sum + n);
}
