// What `announcement_audience_count` answers: who would get this, how many of
// them can actually be reached, and therefore what the send is about to cost.
//
// A plain class rather than a freezed model, like `notification_previews.dart`:
// an RPC result row, read once and never written back, so there is nothing for
// `toJson` or `copyWith` to do.
//
// It matters that this is the *same* function the send uses to build its
// audience. The number above the button is the number of rows the send writes,
// rather than a second query that agrees with the first until a member is
// archived between the two.
//
// Mirrors `AnnouncementAudienceCount` in
// `logfitness_saas/lib/db/announcements.ts`.

class AnnouncementAudienceCount {
  const AnnouncementAudienceCount({
    required this.total,
    required this.reachable,
    required this.unusable,
    required this.members,
    required this.visitors,
  });

  /// Zeros rather than nulls, matching the console's `row?.total ?? 0`: an
  /// empty result means an empty gym, which is a number and not an absence.
  factory AnnouncementAudienceCount.fromJson(Map<String, dynamic> json) {
    return AnnouncementAudienceCount(
      total: (json['total'] as num?)?.toInt() ?? 0,
      reachable: (json['reachable'] as num?)?.toInt() ?? 0,
      unusable: (json['unusable'] as num?)?.toInt() ?? 0,
      members: (json['members'] as num?)?.toInt() ?? 0,
      visitors: (json['visitors'] as num?)?.toInt() ?? 0,
    );
  }

  static const AnnouncementAudienceCount empty = AnnouncementAudienceCount(
    total: 0,
    reachable: 0,
    unusable: 0,
    members: 0,
    visitors: 0,
  );

  /// Everybody the filters match, reachable or not.
  final int total;

  /// The ones with a usable address. This is what gets queued, and what the
  /// credit estimate multiplies.
  final int reachable;

  /// The rest. They are still written to the log, as `skipped` with a reason,
  /// so "was this member told" always has an answer -- but they cost nothing
  /// and nobody's handset lights up.
  final int unusable;

  final int members;
  final int visitors;

  /// Nothing to send. Not an error: a filter that matches nobody is a mistake
  /// being caught before the button rather than after, which is why the
  /// composer disables Send on it and `send_announcement` refuses it outright.
  bool get nothingToSend => reachable == 0;
}
