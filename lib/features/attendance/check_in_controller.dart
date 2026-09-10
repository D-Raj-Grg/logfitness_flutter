// The front desk's check-in.
//
// Declared with manual `Notifier`/`Provider` rather than `@riverpod` to keep
// this file out of the codegen graph — the same choice `branch_scope.dart`
// makes.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/data/attendance/attendance_repository.dart';
import 'package:logfitness_flutter/data/attendance/attendance_rpc_results.dart';
import 'package:logfitness_flutter/data/members/member_overview.dart';
import 'package:logfitness_flutter/data/members/members_repository.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';

/// What came back from trying to check someone in.
sealed class CheckInOutcome {
  const CheckInOutcome();
}

/// Recorded. [result] still carries the banner and the dues — a successful
/// check-in is very often the moment a renewal conversation should happen.
class CheckInRecorded extends CheckInOutcome {
  const CheckInRecorded(this.result);

  final CheckInResult result;
}

/// Already checked in today. Not an error: the desk decides whether this is a
/// mistake or a genuine second visit, and an override with a reason forces it.
class CheckInDuplicate extends CheckInOutcome {
  const CheckInDuplicate(this.result);

  final CheckInResult result;
}

class CheckInFailed extends CheckInOutcome {
  const CheckInFailed(this.failure);

  final AppFailure failure;

  bool get isRefusal => failure.isRefusal;
}

/// The desk's member search box.
///
/// Deliberately not the member list: the desk types a phone number and wants a
/// handful of hits in one round trip, which is what
/// `searchMembersForCheckIn` is for.
class CheckInSearch extends Notifier<AsyncValue<List<MemberOverview>>> {
  @override
  AsyncValue<List<MemberOverview>> build() =>
      const AsyncValue<List<MemberOverview>>.data(<MemberOverview>[]);

  Future<void> search(String term) async {
    final trimmed = term.trim();
    if (trimmed.isEmpty) {
      state = const AsyncValue<List<MemberOverview>>.data(<MemberOverview>[]);
      return;
    }

    state = const AsyncValue<List<MemberOverview>>.loading();
    state = await AsyncValue.guard(
      () => ref.read(membersRepositoryProvider).searchMembersForCheckIn(trimmed),
    );
  }

  void clear() =>
      state = const AsyncValue<List<MemberOverview>>.data(<MemberOverview>[]);
}

final checkInSearchProvider =
    NotifierProvider<CheckInSearch, AsyncValue<List<MemberOverview>>>(
  CheckInSearch.new,
);

/// Records check-ins. `true` while one is in flight.
class CheckInController extends Notifier<bool> {
  @override
  bool build() => false;

  /// Checks a member in.
  ///
  /// Pass [overrideReason] to force a second check-in on the same day. The
  /// database requires a reason for that and refuses without one, which is
  /// what makes an override auditable rather than invisible.
  Future<CheckInOutcome> checkIn({
    required String memberId,
    required String branchId,
    AttendanceMethod method = AttendanceMethod.manual,
    String? overrideReason,
  }) async {
    if (state) {
      // Not idempotent, and the failure mode is a duplicate visit row rather
      // than an error anyone would notice.
      return const CheckInFailed(
        AppFailure(FailureKind.invalid, 'That check-in is already saving.'),
      );
    }

    state = true;
    try {
      final result = await ref.read(attendanceRepositoryProvider).checkInMember(
            memberId: memberId,
            branchId: branchId,
            method: method,
            override: overrideReason != null,
            overrideReason: overrideReason,
          );

      if (result.isDuplicate) {
        return CheckInDuplicate(result);
      }
      return CheckInRecorded(result);
    } catch (error, stackTrace) {
      return CheckInFailed(mapError(error, stackTrace));
    } finally {
      state = false;
    }
  }
}

final checkInControllerProvider =
    NotifierProvider<CheckInController, bool>(CheckInController.new);
