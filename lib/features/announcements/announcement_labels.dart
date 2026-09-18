// The words the announcements surface uses.
//
// Transcribed from `logfitness_saas/components/announcements/announcements-table.tsx`
// and `announcement-composer.tsx` rather than paraphrased, so the two clients
// describe the same broadcast the same way. Where the console uses two
// different wordings for the same value -- the table says "Members", the
// composer says "Members only" -- both are kept, because the difference is
// deliberate: a table cell is a description and a picker row is a choice.
//
// Every switch is exhaustive with no `default`, so a new enum value is a
// compile error here rather than a blank label on a screen.
import 'package:logfitness_flutter/data/announcements/announcement_overview.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';

/// The composer's wording: what you are choosing.
String announcementAudienceLabel(AnnouncementAudience audience) =>
    switch (audience) {
      AnnouncementAudience.both => 'Members and visitors',
      AnnouncementAudience.members => 'Members only',
      AnnouncementAudience.visitors => 'Visitors only',
    };

/// The list's wording: what was chosen.
String announcementAudienceShort(AnnouncementAudience audience) =>
    switch (audience) {
      AnnouncementAudience.both => 'Members and visitors',
      AnnouncementAudience.members => 'Members',
      AnnouncementAudience.visitors => 'Visitors',
    };

/// What stage the broadcast as a whole is at. Reads `state`, which is derived
/// from the outbox, never the stored `status`, which is only what was asked
/// for.
String announcementStateLabel(AnnouncementState state) => switch (state) {
  AnnouncementState.cancelled => 'Stopped',
  AnnouncementState.scheduled => 'Scheduled',
  AnnouncementState.sending => 'Sending',
  AnnouncementState.sent => 'Sent',
};

/// Delivery is a sentence, not a status.
///
/// A broadcast is rarely in one state: most of it has arrived, a few numbers
/// were unusable, one failed. So the line reads as counts, in the order the
/// desk asks about them, and the badge says only what stage the whole thing is
/// at. Transcribed from `deliveryLine()` in the console's table.
String announcementDeliveryLine(AnnouncementOverview row) {
  final List<String> parts = <String>[
    if (row.sent > 0) '${row.sent} delivered',
    if (row.queued > 0) '${row.queued} waiting',
    if (row.failed > 0) '${row.failed} failed',
    if (row.skipped > 0) '${row.skipped} not sent',
    if (row.cancelled > 0) '${row.cancelled} stopped',
  ];
  return parts.isEmpty ? 'Nothing queued' : parts.join(' · ');
}

/// The branch picker's "no branch chosen" row, which means every branch the
/// sender covers -- resolved from their own claim by
/// `announcement_branch_scope`, so for an owner it is the chain and for anybody
/// else it is theirs.
const String kEveryBranchLabel = 'Every branch I cover';

/// The windows the composer offers for "how recently did they come in".
///
/// Null is every open walk-in, which is the database's own default, and it
/// leads because it is the common case.
const List<(int?, String)> kVisitorWindows = <(int?, String)>[
  (null, 'Every open visitor'),
  (30, 'Visited in the last 30 days'),
  (90, 'Visited in the last 90 days'),
  (180, 'Visited in the last 6 months'),
];

/// The member statuses a broadcast may be narrowed to.
///
/// No `left`, deliberately, and the omission is the console's: somebody who has
/// left the gym is not in the audience for "we are shut on Sunday". The
/// database will accept the filter if it is asked for by name -- "we reopen on
/// Monday" is a win-back -- but nothing in either client offers it, because a
/// tick box is too easy a way to text four hundred former members.
const List<MemberStatus> kAnnouncementMemberStatuses = <MemberStatus>[
  MemberStatus.active,
  MemberStatus.expired,
  MemberStatus.frozen,
];

/// The label under a status chip.
String announcementMemberStatusLabel(MemberStatus status) => switch (status) {
  MemberStatus.active => 'Active',
  MemberStatus.expired => 'Expired',
  MemberStatus.frozen => 'Frozen',
  MemberStatus.left => 'Left',
};
