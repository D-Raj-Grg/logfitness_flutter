// The two announcement models against rows shaped exactly as PostgREST hands
// them over: snake_case keys, nulls where the view returns null, and enum
// values as the wire strings the database actually stores.
//
// No client here at all. What is tested is the mapping and the derived
// wording -- the parts that are wrong in a way nobody notices until a broadcast
// is on screen saying the wrong thing about four hundred messages.
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/announcements/announcement_audience_count.dart';
import 'package:logfitness_flutter/data/announcements/announcement_overview.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/features/announcements/announcement_labels.dart';

Map<String, dynamic> overviewRow({Map<String, dynamic> overrides = const {}}) =>
    <String, dynamic>{
      'id': 'a-1',
      'org_id': 'org-1',
      'branch_id': 'branch-1',
      'branch_name': 'Hetauda',
      'title': 'Closed Sunday',
      'body': 'We are shut on Sunday.',
      'channel': 'sms',
      'audience': 'both',
      'member_statuses': <String>['active', 'frozen'],
      'visitor_days': 30,
      'status': 'sending',
      'state': 'sending',
      'scheduled_for': '2026-09-18T02:00:00Z',
      'created_at': '2026-09-18T02:00:00Z',
      'created_by': 'staff-1',
      'created_by_name': 'Ashish',
      'total': 10,
      'queued': 3,
      'sent': 5,
      'failed': 1,
      'skipped': 1,
      'cancelled': 0,
      'last_sent_at': '2026-09-18T02:05:00Z',
      ...overrides,
    };

void main() {
  group('AnnouncementOverview', () {
    test('maps the view row field for field', () {
      final row = AnnouncementOverview.fromJson(overviewRow());

      expect(row.id, 'a-1');
      expect(row.branchName, 'Hetauda');
      expect(row.channel, NotificationChannel.sms);
      expect(row.audience, AnnouncementAudience.both);
      expect(row.memberStatuses, <MemberStatus>[
        MemberStatus.active,
        MemberStatus.frozen,
      ]);
      expect(row.visitorDays, 30);
      expect(row.status, AnnouncementStatus.sending);
      expect(row.state, AnnouncementState.sending);
      expect(row.createdByName, 'Ashish');
      expect(row.total, 10);
      expect(row.queued, 3);
      expect(row.lastSentAt, DateTime.utc(2026, 9, 18, 2, 5));
    });

    test('every nullable column survives being null', () {
      final row = AnnouncementOverview.fromJson(
        overviewRow(
          overrides: <String, dynamic>{
            'branch_id': null,
            'branch_name': null,
            'member_statuses': null,
            'visitor_days': null,
            'created_by': null,
            'created_by_name': null,
            'last_sent_at': null,
          },
        ),
      );

      expect(row.branchId, isNull);
      // Null is "the database's own default", not "nobody" -- the distinction
      // the repository protects when it sends an empty list as null.
      expect(row.memberStatuses, isNull);
      expect(row.visitorDays, isNull);
      expect(row.lastSentAt, isNull);
    });

    test('a state this app does not know about throws, never defaults', () {
      // The view could grow a state; rendering an unknown one as "sent" would
      // be the log disagreeing with what members actually received.
      expect(
        () => AnnouncementOverview.fromJson(
          overviewRow(overrides: <String, dynamic>{'state': 'halfway'}),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('an unknown audience throws too', () {
      expect(
        () => AnnouncementOverview.fromJson(
          overviewRow(overrides: <String, dynamic>{'audience': 'everyone'}),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    group('isCancellable', () {
      test('something is still waiting, so there is something to stop', () {
        expect(AnnouncementOverview.fromJson(overviewRow()).isCancellable, isTrue);
      });

      test('nothing queued means it has gone, and an SMS cannot be recalled', () {
        final row = AnnouncementOverview.fromJson(
          overviewRow(
            overrides: <String, dynamic>{'queued': 0, 'state': 'sent'},
          ),
        );
        expect(row.isCancellable, isFalse);
      });

      test('already stopped, even with rows still queued', () {
        final row = AnnouncementOverview.fromJson(
          overviewRow(
            overrides: <String, dynamic>{'state': 'cancelled', 'queued': 4},
          ),
        );
        expect(row.isCancellable, isFalse);
      });
    });
  });

  group('announcementDeliveryLine', () {
    test('reads as counts, in the order the desk asks about them', () {
      final row = AnnouncementOverview.fromJson(
        overviewRow(
          overrides: <String, dynamic>{
            'sent': 3,
            'queued': 2,
            'failed': 1,
            'skipped': 0,
            'cancelled': 0,
          },
        ),
      );
      expect(announcementDeliveryLine(row), '3 delivered · 2 waiting · 1 failed');
    });

    test('a broadcast with nothing behind it says so', () {
      final row = AnnouncementOverview.fromJson(
        overviewRow(
          overrides: <String, dynamic>{
            'total': 0,
            'sent': 0,
            'queued': 0,
            'failed': 0,
            'skipped': 0,
            'cancelled': 0,
          },
        ),
      );
      expect(announcementDeliveryLine(row), 'Nothing queued');
    });

    test('stopped and not-sent are named rather than folded into failed', () {
      final row = AnnouncementOverview.fromJson(
        overviewRow(
          overrides: <String, dynamic>{
            'sent': 0,
            'queued': 0,
            'failed': 0,
            'skipped': 4,
            'cancelled': 7,
          },
        ),
      );
      expect(announcementDeliveryLine(row), '4 not sent · 7 stopped');
    });
  });

  group('AnnouncementAudienceCount', () {
    test('an empty row is zeros, not an absence', () {
      final count = AnnouncementAudienceCount.fromJson(<String, dynamic>{});
      expect(count.total, 0);
      expect(count.reachable, 0);
      expect(count.nothingToSend, isTrue);
    });

    test('forty in the audience and none of them reachable is nothing to send', () {
      // The case that matters: the filters found people, every one of them has
      // an unusable number, and pressing Send would write forty skipped rows
      // and light up no handsets at all.
      final count = AnnouncementAudienceCount.fromJson(<String, dynamic>{
        'total': 40,
        'reachable': 0,
        'unusable': 40,
        'members': 40,
        'visitors': 0,
      });
      expect(count.nothingToSend, isTrue);
    });

    test('one reachable is something to send', () {
      final count = AnnouncementAudienceCount.fromJson(<String, dynamic>{
        'total': 40,
        'reachable': 1,
        'unusable': 39,
        'members': 40,
        'visitors': 0,
      });
      expect(count.nothingToSend, isFalse);
    });
  });
}
