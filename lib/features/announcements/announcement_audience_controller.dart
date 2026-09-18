// The live audience count behind the composer.
//
// Mirrors the `useEffect` in
// `logfitness_saas/components/announcements/announcement-composer.tsx` that
// re-runs `previewAnnouncementAudience` whenever a filter moves, with one
// addition the web does not need: a debounce. A browser fires that effect on a
// state change; a phone fires it on a chip tap, and a desk trying three status
// combinations in two seconds would otherwise make three round trips over a
// connection that may be a phone's.
//
// The audience is one value with value equality ([AnnouncementAudienceQuery]),
// so landing on a draft that is already current costs nothing at all.
//
// The two cross-clearing rules live on the query's `normalised()` rather than
// here or in the widget, so the number on screen and the rows the send writes
// describe the same audience by construction.
import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:logfitness_flutter/data/announcements/announcement_audience_count.dart';
import 'package:logfitness_flutter/data/announcements/announcement_queries.dart';
import 'package:logfitness_flutter/data/announcements/announcements_repository.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';

part 'announcement_audience_controller.g.dart';

/// How long the composer waits after the last edit before asking the database
/// what the audience now is.
///
/// A provider rather than a constant so a test can shrink it, the pattern
/// `notificationPollInterval` set.
@riverpod
Duration announcementCountDebounce(Ref ref) =>
    const Duration(milliseconds: 400);

/// The audience the composer is currently describing.
///
/// Every setter writes to a pending value and restarts the timer; the state
/// itself only moves once the edits stop, which is what the count provider
/// watches. A second composer opened later starts from the default because the
/// screen invalidates this on the way in.
@riverpod
class AnnouncementDraft extends _$AnnouncementDraft {
  Timer? _debounce;
  AnnouncementAudienceQuery? _pending;

  @override
  AnnouncementAudienceQuery build() {
    ref.onDispose(() => _debounce?.cancel());
    return const AnnouncementAudienceQuery();
  }

  void setAudience(AnnouncementAudience audience) =>
      _schedule(_current.copyWith(audience: audience).normalised());

  void setBranchId(String? branchId) => _schedule(
    _current
        .copyWith(branchId: branchId, clearBranchId: branchId == null)
        .normalised(),
  );

  void setVisitorDays(int? days) => _schedule(
    _current
        .copyWith(visitorDays: days, clearVisitorDays: days == null)
        .normalised(),
  );

  /// Ticking a status on or off. The order is kept stable rather than following
  /// the taps, so two people who picked the same three statuses in a different
  /// order produce the same query -- and therefore the same provider key, and
  /// no extra round trip.
  void toggleStatus(MemberStatus status) {
    final List<MemberStatus> next = <MemberStatus>[
      for (final MemberStatus s in MemberStatus.values)
        if (s == status
            ? !_current.memberStatuses.contains(status)
            : _current.memberStatuses.contains(s))
          s,
    ];
    _schedule(_current.copyWith(memberStatuses: next).normalised());
  }

  AnnouncementAudienceQuery get _current => _pending ?? state;

  void _schedule(AnnouncementAudienceQuery next) {
    _pending = next;
    // Nothing actually changed -- a chip tapped to the value it already had, a
    // picker reopened and dismissed on the same row. Leaving the timer alone
    // means the count is not delayed by an edit that was not one.
    if (next == state) {
      _debounce?.cancel();
      _debounce = null;
      _pending = null;
      return;
    }
    _debounce?.cancel();
    _debounce = Timer(ref.read(announcementCountDebounceProvider), () {
      _debounce = null;
      final AnnouncementAudienceQuery? settled = _pending;
      _pending = null;
      if (settled != null) state = settled;
    });
  }
}

/// Who would get it, and therefore what it would cost.
///
/// The same function the send uses to build its audience, so the number above
/// the button is the number of messages that get written -- not a second query
/// that agrees with the first most of the time.
@riverpod
Future<AnnouncementAudienceCount> announcementAudienceCount(Ref ref) {
  final AnnouncementAudienceQuery query = ref.watch(announcementDraftProvider);
  return ref
      .read(announcementsRepositoryProvider)
      .countAnnouncementAudience(query);
}
