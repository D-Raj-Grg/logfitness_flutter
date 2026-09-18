// The pure parts of the announcements data layer: what gets sent for an
// audience, and what counts as the same audience.
//
// No client here. What is tested is the logic that decides what travels, which
// is the part that is wrong in a way the screen cannot show you -- the
// repository itself is not unit-tested against a client, for the reason
// `notification_queries_test.dart` gives.
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/announcements/announcement_queries.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';

void main() {
  group('announcementStatusFilter', () {
    test('an empty selection is null -- the default, not nobody', () {
      // The single most expensive thing on this surface to get wrong. Null
      // means every status except `left`; `'{}'` means nobody, and the desk
      // only finds out after typing the whole announcement.
      expect(announcementStatusFilter(const <MemberStatus>[]), isNull);
    });

    test('null stays null', () {
      expect(announcementStatusFilter(null), isNull);
    });

    test('a real selection travels as the wire strings', () {
      expect(
        announcementStatusFilter(const <MemberStatus>[
          MemberStatus.active,
          MemberStatus.frozen,
        ]),
        <String>['active', 'frozen'],
      );
    });
  });

  group('AnnouncementAudienceQuery.normalised', () {
    test('a visitors-only audience carries no member statuses', () {
      const query = AnnouncementAudienceQuery(
        audience: AnnouncementAudience.visitors,
        memberStatuses: <MemberStatus>[MemberStatus.active],
        visitorDays: 30,
      );

      final normalised = query.normalised();
      expect(normalised.memberStatuses, isEmpty);
      // ...and keeps the window, which is the half that applies.
      expect(normalised.visitorDays, 30);
    });

    test('a members-only audience carries no visitor window', () {
      const query = AnnouncementAudienceQuery(
        audience: AnnouncementAudience.members,
        memberStatuses: <MemberStatus>[MemberStatus.active],
        visitorDays: 30,
      );

      final normalised = query.normalised();
      expect(normalised.visitorDays, isNull);
      expect(normalised.memberStatuses, <MemberStatus>[MemberStatus.active]);
    });

    test('both keeps both halves', () {
      const query = AnnouncementAudienceQuery(
        memberStatuses: <MemberStatus>[MemberStatus.expired],
        visitorDays: 90,
      );

      final normalised = query.normalised();
      expect(normalised.memberStatuses, <MemberStatus>[MemberStatus.expired]);
      expect(normalised.visitorDays, 90);
    });

    test('the two rules are the check constraint, transcribed', () {
      // `announcements_filter_shape` refuses the other shapes outright, so a
      // query that reaches the RPC unnormalised is a `23514` rather than a
      // wrong audience -- which is safer and still a worse experience than not
      // sending it.
      expect(
        const AnnouncementAudienceQuery(
          audience: AnnouncementAudience.visitors,
          memberStatuses: <MemberStatus>[MemberStatus.left],
        ).normalised().memberStatuses,
        isEmpty,
      );
    });
  });

  group('AnnouncementAudienceQuery equality', () {
    test('the same audience is the same key, so no second round trip', () {
      // Value equality is what makes the count provider's family free to
      // re-read when nothing actually changed.
      const a = AnnouncementAudienceQuery(
        audience: AnnouncementAudience.members,
        branchId: 'branch-1',
        memberStatuses: <MemberStatus>[MemberStatus.active],
      );
      const b = AnnouncementAudienceQuery(
        audience: AnnouncementAudience.members,
        branchId: 'branch-1',
        memberStatuses: <MemberStatus>[MemberStatus.active],
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('a different status list is a different audience', () {
      const a = AnnouncementAudienceQuery(
        memberStatuses: <MemberStatus>[MemberStatus.active],
      );
      const b = AnnouncementAudienceQuery(
        memberStatuses: <MemberStatus>[MemberStatus.active, MemberStatus.frozen],
      );

      expect(a, isNot(b));
    });

    test('no branch and a branch are different audiences', () {
      expect(
        const AnnouncementAudienceQuery(),
        isNot(const AnnouncementAudienceQuery(branchId: 'branch-1')),
      );
    });

    test('clearing the branch really clears it', () {
      const query = AnnouncementAudienceQuery(branchId: 'branch-1');
      expect(query.copyWith(clearBranchId: true).branchId, isNull);
      // Without the flag, null is indistinguishable from "leave it alone" --
      // which is how a branch filter that is tapped off never turns off.
      expect(query.copyWith().branchId, 'branch-1');
    });

    test('clearing the visitor window really clears it', () {
      const query = AnnouncementAudienceQuery(visitorDays: 30);
      expect(query.copyWith(clearVisitorDays: true).visitorDays, isNull);
      expect(query.copyWith().visitorDays, 30);
    });
  });

  group('AnnouncementPage', () {
    test('hasMore is the count against what has been read', () {
      const page = AnnouncementPage(
        rows: <Never>[],
        total: 41,
        page: 2,
        pageSize: 20,
      );
      expect(page.hasMore, isTrue);

      const last = AnnouncementPage(
        rows: <Never>[],
        total: 40,
        page: 2,
        pageSize: 20,
      );
      expect(last.hasMore, isFalse);
    });
  });
}
