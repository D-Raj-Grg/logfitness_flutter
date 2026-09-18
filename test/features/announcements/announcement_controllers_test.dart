// The announcements controllers, against a fake AnnouncementsRepository -- no
// network, no real Supabase client. The fake `implements` the repository, the
// house pattern, so the controllers are exercised through the same surface a
// screen calls.
//
// The invariants here are the expensive ones: an empty status selection must
// not reach the database as "nobody", a double tap must not send a broadcast
// twice, a cancel that stopped nothing must not claim it stopped something,
// and a failed second page must not blank a list somebody is reading.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/announcements/announcement_audience_count.dart';
import 'package:logfitness_flutter/data/announcements/announcement_overview.dart';
import 'package:logfitness_flutter/data/announcements/announcement_queries.dart';
import 'package:logfitness_flutter/data/announcements/announcements_repository.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/features/announcements/announcement_audience_controller.dart';
import 'package:logfitness_flutter/features/announcements/announcement_list_controller.dart';
import 'package:logfitness_flutter/features/announcements/send_announcement_controller.dart';

AnnouncementOverview announcementRow(
  String id, {
  int queued = 0,
  AnnouncementState state = AnnouncementState.sent,
}) => AnnouncementOverview(
  id: id,
  orgId: 'org-1',
  title: 'Closed Sunday',
  body: 'We are shut on Sunday.',
  channel: NotificationChannel.sms,
  audience: AnnouncementAudience.both,
  status: AnnouncementStatus.sending,
  state: state,
  scheduledFor: DateTime.utc(2026, 9, 18, 2),
  createdAt: DateTime.utc(2026, 9, 18, 2),
  total: 10,
  queued: queued,
  sent: 10 - queued,
  failed: 0,
  skipped: 0,
  cancelled: 0,
);

class FakeAnnouncementsRepository implements AnnouncementsRepository {
  final List<AnnouncementListFilter> listCalls = <AnnouncementListFilter>[];
  final List<AnnouncementAudienceQuery> countCalls =
      <AnnouncementAudienceQuery>[];

  /// What the send was actually asked to do. The statuses here are the point
  /// of the "empty means the default" test.
  final List<Map<String, Object?>> sendCalls = <Map<String, Object?>>[];
  final List<String> testCalls = <String>[];
  final List<String> cancelCalls = <String>[];

  int total = 2;
  int pageSize = 1;
  int queuedPerRow = 0;

  Object? nextListError;
  Object? sendError;
  Object? testError;
  int cancelStops = 3;

  @override
  Future<AnnouncementPage> listAnnouncements(
    AnnouncementListFilter filter,
  ) async {
    listCalls.add(filter);
    if (nextListError != null) {
      final Object error = nextListError!;
      nextListError = null;
      throw error;
    }
    return AnnouncementPage(
      rows: <AnnouncementOverview>[
        announcementRow('a-${filter.page}', queued: queuedPerRow),
      ],
      total: total,
      page: filter.page,
      pageSize: pageSize,
    );
  }

  @override
  Future<AnnouncementAudienceCount> countAnnouncementAudience(
    AnnouncementAudienceQuery query,
  ) async {
    countCalls.add(query);
    return const AnnouncementAudienceCount(
      total: 10,
      reachable: 9,
      unusable: 1,
      members: 8,
      visitors: 2,
    );
  }

  @override
  Future<String> sendAnnouncement({
    required String title,
    required String body,
    required AnnouncementAudience audience,
    NotificationChannel channel = NotificationChannel.sms,
    String? branchId,
    List<MemberStatus>? memberStatuses,
    int? visitorDays,
    DateTime? scheduledFor,
  }) async {
    sendCalls.add(<String, Object?>{
      'title': title,
      'body': body,
      'audience': audience,
      'branchId': branchId,
      'memberStatuses': memberStatuses,
      'visitorDays': visitorDays,
      'scheduledFor': scheduledFor,
    });
    if (sendError != null) throw sendError!;
    return 'a-new';
  }

  @override
  Future<String> sendAnnouncementTest({
    required String body,
    required String to,
    String? title,
    NotificationChannel channel = NotificationChannel.sms,
  }) async {
    testCalls.add(to);
    if (testError != null) throw testError!;
    return 'm-1';
  }

  @override
  Future<int> cancelAnnouncement(String id) async {
    cancelCalls.add(id);
    return cancelStops;
  }

  @override
  Never noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not faked');
}

void main() {
  late FakeAnnouncementsRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = FakeAnnouncementsRepository();
    container = ProviderContainer(
      // Untyped literal on purpose: `Override` is not exported by
      // flutter_riverpod 3.1.0 (TASKS.md, Discovered, 2026-09-05).
      overrides: [
        announcementsRepositoryProvider.overrideWithValue(repository),
        // The debounce is a provider precisely so a test can collapse it.
        announcementCountDebounceProvider.overrideWithValue(Duration.zero),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('the list', () {
    test('reads page one and reports the database total', () async {
      final state = await container.read(announcementListProvider.future);

      expect(state.rows.single.id, 'a-1');
      expect(state.total, 2);
      expect(state.hasMore, isTrue);
    });

    test('a failed page two keeps page one on screen and says what happened',
        () async {
      await container.read(announcementListProvider.future);

      repository.nextListError = const AppFailure(
        FailureKind.offline,
        'No connection.',
      );
      await container.read(announcementListProvider.notifier).loadMore();

      final state = container.read(announcementListProvider).value!;
      // The rows someone is reading stay put...
      expect(state.rows.single.id, 'a-1');
      // ...and the failure is carried where the screen can say it out loud.
      expect(state.appendFailure?.message, 'No connection.');
    });

    test('loadMore appends rather than replacing', () async {
      await container.read(announcementListProvider.future);
      await container.read(announcementListProvider.notifier).loadMore();

      final state = container.read(announcementListProvider).value!;
      expect(state.rows.map((r) => r.id), <String>['a-1', 'a-2']);
      expect(state.hasMore, isFalse);
    });

    test('refresh re-reads the whole loaded window, not just page one',
        () async {
      await container.read(announcementListProvider.future);
      await container.read(announcementListProvider.notifier).loadMore();

      repository.listCalls.clear();
      await container.read(announcementListProvider.notifier).refresh();

      // Two pages loaded, so one request for both of them -- shortening the
      // list under a scrolled reader is as bad as blanking it.
      expect(repository.listCalls.single.pageSize, 40);
      expect(container.read(announcementListProvider).value!.page, 2);
    });

    test('the pending count sums what is still queued across the rows',
        () async {
      repository.queuedPerRow = 4;
      await container.read(announcementListProvider.future);
      await container.read(announcementListProvider.notifier).loadMore();

      expect(container.read(announcementPendingCountProvider), 8);
    });
  });

  group('the audience draft', () {
    // The draft is autoDispose, and a bare `container.read` of a notifier is
    // not a listener: without this the notifier is disposed the moment the test
    // awaits, and the next read builds a fresh one with the default audience --
    // which looks exactly like the cross-clearing under test. The composer
    // watches it for real, so this subscription is what the screen does.
    void keepDraftAlive() =>
        container.listen(announcementDraftProvider, (_, _) {});

    test('an empty status selection is never sent as "nobody"', () async {
      // The most expensive thing on this screen to get wrong. Null means the
      // database's own default -- every status except `left`; an empty array
      // means nobody, and the desk finds out by being refused after typing the
      // whole thing.
      await container.read(announcementAudienceCountProvider.future);

      expect(repository.countCalls.single.memberStatuses, isEmpty);

      await container
          .read(sendAnnouncementProvider.notifier)
          .send(
            title: 'Closed Sunday',
            body: 'We are shut.',
            audience: AnnouncementAudience.members,
            memberStatuses: const <MemberStatus>[],
          );
      // The repository is what turns emptiness into null on the wire; what the
      // controller must not do is invent a status nobody picked.
      expect(repository.sendCalls.single['memberStatuses'], isEmpty);
    });

    test('choosing visitors drops the member statuses', () async {
      keepDraftAlive();
      final notifier = container.read(announcementDraftProvider.notifier)
        ..toggleStatus(MemberStatus.active);
      await Future<void>.delayed(Duration.zero);
      expect(
        container.read(announcementDraftProvider).memberStatuses,
        <MemberStatus>[MemberStatus.active],
      );

      notifier.setAudience(AnnouncementAudience.visitors);
      await Future<void>.delayed(Duration.zero);

      expect(container.read(announcementDraftProvider).memberStatuses, isEmpty);
    });

    test('choosing members drops the visitor window', () async {
      keepDraftAlive();
      final notifier = container.read(announcementDraftProvider.notifier)
        ..setVisitorDays(30);
      await Future<void>.delayed(Duration.zero);
      expect(container.read(announcementDraftProvider).visitorDays, 30);

      notifier.setAudience(AnnouncementAudience.members);
      await Future<void>.delayed(Duration.zero);

      expect(container.read(announcementDraftProvider).visitorDays, isNull);
    });

    test('setting a field to the value it already holds does not re-fire',
        () async {
      keepDraftAlive();
      await container.read(announcementAudienceCountProvider.future);
      expect(repository.countCalls, hasLength(1));

      // `both` is already the audience. Value equality on the query is what
      // makes this free rather than another round trip.
      container
          .read(announcementDraftProvider.notifier)
          .setAudience(AnnouncementAudience.both);
      await Future<void>.delayed(Duration.zero);

      expect(repository.countCalls, hasLength(1));
    });
  });

  group('sending', () {
    test('a second press while the first is in flight never leaves the phone',
        () async {
      final notifier = container.read(sendAnnouncementProvider.notifier);

      final first = notifier.send(
        title: 'Closed Sunday',
        body: 'We are shut.',
        audience: AnnouncementAudience.both,
      );
      final second = await notifier.send(
        title: 'Closed Sunday',
        body: 'We are shut.',
        audience: AnnouncementAudience.both,
      );

      expect(second, isA<AnnouncementFailed>());
      expect(await first, isA<AnnouncementSent>());
      expect(repository.sendCalls, hasLength(1));
    });

    test('a refusal arrives with the database\'s own sentence intact',
        () async {
      repository.sendError = const AppFailure(
        FailureKind.refused,
        'Only an owner, manager or front desk can send an announcement',
        code: '42501',
      );

      final result = await container
          .read(sendAnnouncementProvider.notifier)
          .send(
            title: 'Closed Sunday',
            body: 'We are shut.',
            audience: AnnouncementAudience.both,
          );

      expect(result, isA<AnnouncementFailed>());
      final failed = result as AnnouncementFailed;
      expect(failed.isRefusal, isTrue);
      expect(
        failed.failure.message,
        'Only an owner, manager or front desk can send an announcement',
      );
    });

    test('an empty audience is reported as the database worded it', () async {
      repository.sendError = const AppFailure(
        FailureKind.notFound,
        'Nobody matches that audience',
        code: 'P0002',
      );

      final result = await container
          .read(sendAnnouncementProvider.notifier)
          .send(
            title: 'Closed Sunday',
            body: 'We are shut.',
            audience: AnnouncementAudience.members,
          );

      expect(
        (result as AnnouncementFailed).failure.message,
        'Nobody matches that audience',
      );
    });

    test('the in-flight flag clears after a throw', () async {
      repository.sendError = const AppFailure(FailureKind.unknown, 'Boom.');

      await container.read(sendAnnouncementProvider.notifier).send(
        title: 'Closed Sunday',
        body: 'We are shut.',
        audience: AnnouncementAudience.both,
      );

      expect(container.read(sendAnnouncementProvider), isFalse);
    });

    test('a send says whether it went or is going to', () async {
      final now = await container.read(sendAnnouncementProvider.notifier).send(
        title: 'Closed Sunday',
        body: 'We are shut.',
        audience: AnnouncementAudience.both,
      );
      expect((now as AnnouncementSent).scheduled, isFalse);
      expect(now.message, contains('within a minute'));

      final later = await container
          .read(sendAnnouncementProvider.notifier)
          .send(
            title: 'Closed Sunday',
            body: 'We are shut.',
            audience: AnnouncementAudience.both,
            scheduledFor: DateTime.utc(2026, 9, 20),
          );
      expect((later as AnnouncementSent).scheduled, isTrue);
      expect(later.message, contains('Nothing goes out until then'));
    });
  });

  group('the test send', () {
    test('the rate limit is a failure, not a quiet success', () async {
      repository.testError = const AppFailure(
        FailureKind.duplicate,
        'That test has just been sent. Give it a minute.',
        code: '23505',
      );

      final result = await container
          .read(sendAnnouncementProvider.notifier)
          .test(body: 'We are shut.', to: '9800000201');

      expect(
        (result as AnnouncementFailed).failure.message,
        'That test has just been sent. Give it a minute.',
      );
    });
  });

  group('stopping', () {
    test('says how many it stopped', () async {
      final result = await container
          .read(sendAnnouncementProvider.notifier)
          .cancel('a-1');

      expect((result as AnnouncementCancelled).stopped, 3);
      expect(result.message, 'Stopped 3 messages that had not gone yet.');
    });

    test('stopping nothing does not claim to have stopped something', () async {
      // An SMS cannot be recalled, so zero is a real answer and the screen has
      // to say so rather than read as a successful cancellation.
      repository.cancelStops = 0;

      final result = await container
          .read(sendAnnouncementProvider.notifier)
          .cancel('a-1');

      expect((result as AnnouncementCancelled).stopped, 0);
      expect(result.message, contains('already gone out'));
    });
  });
}
