// Attendance: who came in, when, and who is still inside.
//
// Mirrors `logfitness_saas/lib/db/attendance.ts` function for function. The
// reads go against the `attendance_detail` view rather than the `attendance`
// table, because every screen that lists a visit also wants the member's name
// and the branch's, and joining per row is how a check-in log becomes slow at
// exactly the moment a queue forms at the counter.
//
// RLS is the tenant boundary; no client-side `org_id` filter appears here.
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:logfitness_flutter/data/attendance/attendance_detail.dart';
import 'package:logfitness_flutter/data/attendance/attendance_rpc_results.dart';
import 'package:logfitness_flutter/data/repository_guard.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/format/plain_date.dart';
import 'package:logfitness_flutter/supabase/supabase_providers.dart';

part 'attendance_repository.g.dart';

/// One page of the branch-day log.
class AttendanceLogResult {
  const AttendanceLogResult({
    required this.rows,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  final List<AttendanceDetail> rows;
  final int total;
  final int page;
  final int pageSize;

  bool get hasMore => page * pageSize < total;
}

class AttendanceRepository {
  const AttendanceRepository(this._client);

  final SupabaseClient _client;

  static const _detail = 'attendance_detail';

  /// A member's own visits, newest first. Mirrors `listAttendanceForMember`.
  Future<List<AttendanceDetail>> listForMember(
    String memberId, {
    int limit = 60,
  }) {
    return guardFailures(() async {
      final rows = await _client
          .from(_detail)
          .select('*')
          .eq('member_id', memberId)
          .order('checked_in_at', ascending: false)
          .limit(limit);
      return _map(rows);
    });
  }

  /// The branch-day log behind the check-in screen. Mirrors `listAttendance`.
  Future<AttendanceLogResult> listAttendance({
    String? branchId,
    DateTime? on,
    int page = 1,
    int pageSize = 20,
  }) {
    return guardFailures(() async {
      PostgrestFilterBuilder<PostgrestList> request =
          _client.from(_detail).select('*');

      if (branchId != null) {
        request = request.eq('branch_id', branchId);
      }
      if (on != null) {
        // `attended_on` is a `date`: the gym's own calendar day. Sending an
        // instant would ask for the wrong day either side of midnight.
        request = request.eq('attended_on', plainDateToWire(on));
      }

      final from = (page - 1) * pageSize;
      final PostgrestResponse<PostgrestList> response = await request
          .order('checked_in_at', ascending: false)
          // Two people can be checked in at the same instant, and a paged list
          // needs a unique last sort key or the boundary between pages is
          // undefined. The console orders by id for the same reason.
          .order('id', ascending: false)
          .range(from, from + pageSize - 1)
          .count(CountOption.exact);

      return AttendanceLogResult(
        rows: _map(response.data),
        total: response.count,
        page: page,
        pageSize: pageSize,
      );
    });
  }

  /// Who is in the building right now, newest arrival first.
  Future<List<AttendanceDetail>> inGymNow({List<String>? branchIds}) {
    return guardFailures(() async {
      final rows = await _client.rpc<dynamic>(
        'in_gym_now',
        params: rpcParams(<String, dynamic>{'p_branch_ids': branchIds}),
      );
      return _map(rows);
    });
  }

  /// Records a visit.
  ///
  /// `check_in_member` snapshots the membership status, the dues and the days
  /// to expiry as they are at this moment. That snapshot is the point: a log
  /// that recomputed them later would show someone who was expired at the door
  /// as active once they renewed.
  ///
  /// [override] is how a desk lets in a member the rules would refuse, and
  /// [overrideReason] is what makes that decision auditable rather than
  /// invisible.
  Future<CheckInResult> checkInMember({
    required String memberId,
    required String branchId,
    AttendanceMethod method = AttendanceMethod.manual,
    bool override = false,
    String? overrideReason,
    String? notes,
  }) {
    return guardFailures(() async {
      final result = await _client.rpc<dynamic>(
        'check_in_member',
        params: rpcParams(<String, dynamic>{
          'p_member_id': memberId,
          'p_branch_id': branchId,
          'p_method': method.toDb(),
          'p_override': override,
          'p_override_reason': overrideReason,
          'p_notes': notes,
        }),
      );
      return CheckInResult.fromJson(
        Map<String, dynamic>.from(result as Map<dynamic, dynamic>),
      );
    });
  }

  /// Closes an open visit.
  Future<Map<String, dynamic>> checkOutMember(String attendanceId) {
    return guardFailures(() async {
      final result = await _client.rpc<dynamic>(
        'check_out_member',
        params: <String, dynamic>{'p_attendance_id': attendanceId},
      );
      return Map<String, dynamic>.from(result as Map<dynamic, dynamic>);
    });
  }

  static List<AttendanceDetail> _map(dynamic rows) {
    return (rows as List<dynamic>? ?? const <dynamic>[])
        .map((row) => AttendanceDetail.fromJson(row as Map<String, dynamic>))
        .toList(growable: false);
  }
}

@riverpod
AttendanceRepository attendanceRepository(Ref ref) {
  return AttendanceRepository(ref.watch(supabaseClientProvider));
}

/// A member's visit history, for the member detail screen's attendance tab.
@riverpod
Future<List<AttendanceDetail>> memberAttendance(Ref ref, String memberId) {
  return ref.watch(attendanceRepositoryProvider).listForMember(memberId);
}
