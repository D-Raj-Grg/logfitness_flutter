// Check-in, and the two things about it that are easy to get wrong: an
// override needs a reason, and a duplicate is not an error.
//
// `Override` is not exported by flutter_riverpod 3.1.0, so override lists stay
// untyped literals (TASKS.md, Discovered, 2026-09-05).
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/data/attendance/attendance_repository.dart';
import 'package:logfitness_flutter/data/attendance/attendance_rpc_results.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/features/attendance/check_in_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _FakeAttendanceRepository implements AttendanceRepository {
  int callCount = 0;
  bool? lastOverride;
  String? lastOverrideReason;
  Object? error;

  /// What the RPC pretends to return.
  CheckInResult result = const CheckInResult(
    ok: true,
    banner: CheckInBanner.active,
    member: CheckInMemberSummary(id: 'm-1', fullName: 'Anjali Shrestha'),
  );

  @override
  Future<CheckInResult> checkInMember({
    required String memberId,
    required String branchId,
    AttendanceMethod method = AttendanceMethod.manual,
    bool override = false,
    String? overrideReason,
    String? notes,
  }) async {
    callCount++;
    lastOverride = override;
    lastOverrideReason = overrideReason;
    await Future<void>.delayed(const Duration(milliseconds: 10));
    if (error != null) {
      throw error!;
    }
    return result;
  }

  @override
  Never noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} is not faked');
}

void main() {
  late _FakeAttendanceRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = _FakeAttendanceRepository();
    container = ProviderContainer(
      overrides: [
        attendanceRepositoryProvider.overrideWithValue(repository),
      ],
    );
    // The screen holds this with `ref.watch`; without an equivalent
    // subscription the notifier auto-disposes across the first await.
    container.listen<bool>(checkInControllerProvider, (_, _) {});
  });

  tearDown(() => container.dispose());

  CheckInController notifier() =>
      container.read(checkInControllerProvider.notifier);

  test('a plain check-in records and carries the banner', () async {
    final outcome = await notifier().checkIn(
      memberId: 'm-1',
      branchId: 'branch-1',
    );

    expect(outcome, isA<CheckInRecorded>());
    expect((outcome as CheckInRecorded).result.banner, CheckInBanner.active);
    expect(repository.lastOverride, isFalse);
  });

  test('an expired member is still checked in, and flagged', () async {
    // Check-in does not refuse. A gym's door is staffed by a person, and the
    // software's job is to say what is true, not to bar someone mid-queue.
    repository.result = const CheckInResult(
      ok: true,
      banner: CheckInBanner.expired,
      duePaisa: 250000,
      member: CheckInMemberSummary(id: 'm-1', fullName: 'Anjali Shrestha'),
    );

    final outcome = await notifier().checkIn(
      memberId: 'm-1',
      branchId: 'branch-1',
    );

    expect(outcome, isA<CheckInRecorded>());
    final recorded = outcome as CheckInRecorded;
    expect(recorded.result.needsAttention, isTrue);
    expect(recorded.result.duePaisa, 250000);
  });

  test('a duplicate is reported as a duplicate, not as a failure', () async {
    repository.result = const CheckInResult(
      ok: false,
      reason: CheckInRefusal.alreadyCheckedIn,
      member: CheckInMemberSummary(id: 'm-1', fullName: 'Anjali Shrestha'),
    );

    final outcome = await notifier().checkIn(
      memberId: 'm-1',
      branchId: 'branch-1',
    );

    // The desk decides whether this is a mistake or a real second visit.
    expect(outcome, isA<CheckInDuplicate>());
  });

  test('an override sends the reason the database requires', () async {
    await notifier().checkIn(
      memberId: 'm-1',
      branchId: 'branch-1',
      overrideReason: 'Left kit behind, came back',
    );

    expect(repository.lastOverride, isTrue);
    expect(repository.lastOverrideReason, 'Left kit behind, came back');
  });

  test('a double tap records one visit', () async {
    final first = notifier().checkIn(memberId: 'm-1', branchId: 'branch-1');
    final second = notifier().checkIn(memberId: 'm-1', branchId: 'branch-1');
    await Future.wait<CheckInOutcome>(<Future<CheckInOutcome>>[first, second]);

    // The failure mode here is a duplicate visit row, which nobody notices
    // until the month's attendance numbers are wrong.
    expect(repository.callCount, 1);
  });

  test('a refusal reaches the caller as a refusal', () async {
    repository.error = const PostgrestException(
      message: 'permission denied',
      code: '42501',
    );

    final outcome = await notifier().checkIn(
      memberId: 'm-1',
      branchId: 'branch-1',
    );

    expect(outcome, isA<CheckInFailed>());
    expect((outcome as CheckInFailed).isRefusal, isTrue);
    expect(outcome.failure.kind, FailureKind.refused);
  });

  test('every banner value has a label', () {
    for (final CheckInBanner banner in CheckInBanner.values) {
      expect(banner.wire, isNotEmpty);
    }
    // Frozen must not read as expired: a frozen member has not lapsed.
    expect(CheckInBanner.frozen.needsAttention, isTrue);
    expect(CheckInBanner.active.needsAttention, isFalse);
  });
}
