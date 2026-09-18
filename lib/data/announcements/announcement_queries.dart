// What the announcements list is paged by, what one page of it looks like, and
// the audience a composer is currently describing.
//
// Mirrors `AnnouncementListResult` and the `countAnnouncementAudience`
// arguments in `logfitness_saas/lib/db/announcements.ts`.
//
// No branch filter, unlike `notification_queries.dart`. The console's list has
// none either: read is org-wide on purpose, because a manager who cannot see
// that the owner announced a national closure will announce it again. RLS
// bounds it to the org and nothing narrows it further.
import 'package:logfitness_flutter/data/announcements/announcement_overview.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';

class AnnouncementListFilter {
  const AnnouncementListFilter({this.page = 1, this.pageSize = 20});

  final int page;
  final int pageSize;
}

/// One page of the list. [total] counts the whole set, not the page.
class AnnouncementPage {
  const AnnouncementPage({
    required this.rows,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  final List<AnnouncementOverview> rows;
  final int total;
  final int page;
  final int pageSize;

  bool get hasMore => page * pageSize < total;
}

/// The audience the composer is currently describing, as one value.
///
/// Value equality over every field is load-bearing rather than tidy: this is
/// the key of the count provider's family, so an edit that lands on the same
/// audience -- picking the status that was already picked, reopening a menu --
/// must not fire another round trip. `Object.hash` over the same fields, with
/// the status list hashed by content, is what makes that true.
class AnnouncementAudienceQuery {
  const AnnouncementAudienceQuery({
    this.audience = AnnouncementAudience.both,
    this.branchId,
    this.memberStatuses = const <MemberStatus>[],
    this.visitorDays,
    this.channel = NotificationChannel.sms,
  });

  final AnnouncementAudience audience;

  /// Null is "every branch I cover", which is what `announcement_branch_scope`
  /// resolves from the caller's own claim. It is not "no branch".
  final String? branchId;

  /// Empty is the database's default -- every status except `left` -- and the
  /// repository sends it as null for exactly that reason. It is never sent as
  /// an empty array, which would mean nobody.
  final List<MemberStatus> memberStatuses;

  /// Null is every open walk-in, however long ago they came in.
  final int? visitorDays;

  final NotificationChannel channel;

  /// The two cross-clearing rules, transcribed from the `.refine`s in
  /// `logfitness_saas/lib/validation/announcements.ts` and enforced by the
  /// `announcements_filter_shape` check constraint: a members-only send has no
  /// visitor window, and a visitors-only send has no member statuses.
  ///
  /// Applied here rather than in the composer so that the count and the send
  /// cannot describe different audiences -- and so that it is testable without
  /// pumping a widget.
  AnnouncementAudienceQuery normalised() {
    return AnnouncementAudienceQuery(
      audience: audience,
      branchId: branchId,
      memberStatuses: audience == AnnouncementAudience.visitors
          ? const <MemberStatus>[]
          : memberStatuses,
      visitorDays: audience == AnnouncementAudience.members
          ? null
          : visitorDays,
      channel: channel,
    );
  }

  AnnouncementAudienceQuery copyWith({
    AnnouncementAudience? audience,
    String? branchId,
    bool clearBranchId = false,
    List<MemberStatus>? memberStatuses,
    int? visitorDays,
    bool clearVisitorDays = false,
    NotificationChannel? channel,
  }) {
    return AnnouncementAudienceQuery(
      audience: audience ?? this.audience,
      branchId: clearBranchId ? null : (branchId ?? this.branchId),
      memberStatuses: memberStatuses ?? this.memberStatuses,
      visitorDays: clearVisitorDays ? null : (visitorDays ?? this.visitorDays),
      channel: channel ?? this.channel,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AnnouncementAudienceQuery &&
      other.audience == audience &&
      other.branchId == branchId &&
      other.visitorDays == visitorDays &&
      other.channel == channel &&
      _sameStatuses(other.memberStatuses, memberStatuses);

  @override
  int get hashCode => Object.hash(
    audience,
    branchId,
    visitorDays,
    channel,
    Object.hashAll(memberStatuses),
  );

  static bool _sameStatuses(List<MemberStatus> a, List<MemberStatus> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// The `member_status[]` argument, or null to mean "use the database's own
/// default".
///
/// Kept out of the repository and pure so it is testable without a client, the
/// same reason `notificationBranchFilter` lives beside its filter rather than
/// inside the query that uses it.
///
/// The distinction it protects is the whole audience. The console reaches it
/// with `args.memberStatuses?.length ? ... : undefined`: null means every
/// status except `left`, where `'{}'` means **nobody** -- and a broadcast to
/// nobody is refused with "Nobody matches that audience" only after the desk
/// has typed the whole thing out. `rpcParams` drops nulls and knows nothing
/// about emptiness, so the emptiness has to become null here.
List<String>? announcementStatusFilter(List<MemberStatus>? statuses) {
  if (statuses == null || statuses.isEmpty) return null;
  return statuses
      .map((MemberStatus status) => status.toDb())
      .toList(growable: false);
}
