// The visitor log's write side.
//
// Every action reports its outcome rather than returning void into a widget
// that assumes success. The console shipped a bug on 2026-09-07 where an
// authorization refusal was discarded and a manager could not tell a refused
// write from a completed one; `AppFailure` exists to carry that refusal, and
// this controller exists to make sure something is holding it when it arrives.
//
// Widgets call controllers; controllers call repositories (PLANNING.md §6).
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:logfitness_flutter/data/visitors/visitors_repository.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_flutter/features/visitors/visitor_list_controller.dart';

part 'visitor_actions_controller.g.dart';

/// The result of one write. A screen either shows what changed or shows why
/// it did not; there is no third case.
sealed class VisitorActionResult {
  const VisitorActionResult();
}

class VisitorActionSucceeded extends VisitorActionResult {
  const VisitorActionSucceeded([this.visitorId]);

  final String? visitorId;
}

class VisitorActionFailed extends VisitorActionResult {
  const VisitorActionFailed(this.failure);

  final AppFailure failure;

  /// The database refused this write. Worth distinguishing at the call site:
  /// role gating in this app is UX only (CLAUDE.md), so a refusal means the
  /// screen offered an action the caller was never allowed to take, and the
  /// message must say so rather than reading as a transient error.
  bool get isRefusal => failure.isRefusal;
}

@riverpod
class VisitorActions extends _$VisitorActions {
  @override
  bool build() => false; // true while a write is in flight

  /// Logs a walk-in. Returns the new visitor's id on success.
  ///
  /// `visitedOn` may be left null, in which case the `set_visitor_defaults`
  /// trigger fills the org's own today -- Kathmandu's day is not UTC's, and
  /// the database is the only thing that knows the org's timezone. Pass it
  /// only when the desk is deliberately backdating this morning's log of
  /// yesterday's walk-in.
  Future<VisitorActionResult> log({
    required String orgId,
    required String branchId,
    required String fullName,
    required String phone,
    VisitorKind kind = VisitorKind.enquiry,
    DateTime? visitedOn,
    String? note,
    String? interestedPlanId,
  }) {
    return _run(() async {
      final id = await ref.read(visitorsRepositoryProvider).insertVisitor(
            orgId: orgId,
            branchId: branchId,
            fullName: fullName,
            phone: phone,
            kind: kind,
            visitedOn: visitedOn,
            note: note,
            interestedPlanId: interestedPlanId,
          );
      return id;
    });
  }

  /// Edits a logged visitor. Only the fields passed are sent.
  ///
  /// `status` cannot be moved to `converted` here -- the repository throws
  /// rather than sending, because the database requires the member id and the
  /// timestamp to move with it. Use [convert].
  Future<VisitorActionResult> update(
    String visitorId, {
    Object? fullName = visitorFieldUnchanged,
    Object? phone = visitorFieldUnchanged,
    Object? kind = visitorFieldUnchanged,
    Object? visitedOn = visitorFieldUnchanged,
    Object? note = visitorFieldUnchanged,
    Object? interestedPlanId = visitorFieldUnchanged,
    Object? status = visitorFieldUnchanged,
  }) {
    return _run(() async {
      await ref.read(visitorsRepositoryProvider).updateVisitor(
            visitorId,
            fullName: fullName,
            phone: phone,
            kind: kind,
            visitedOn: visitedOn,
            note: note,
            interestedPlanId: interestedPlanId,
            status: status,
          );
      return visitorId;
    });
  }

  /// Marks a visitor as called back.
  Future<VisitorActionResult> markContacted(String visitorId) =>
      update(visitorId, status: VisitorStatus.contacted);

  /// Marks a visitor as not joining. Reversible -- a `lost` visitor who walks
  /// back in is still the same row, and can still be converted.
  Future<VisitorActionResult> markLost(String visitorId) =>
      update(visitorId, status: VisitorStatus.lost);

  /// Points a visitor at the member they became.
  ///
  /// Called *after* `register_member` has returned an id. The order matters:
  /// registering and then failing to link leaves a real member and a visitor
  /// still marked open, which is a correctable mistake, where refusing the
  /// registration because the link failed would lose the member entirely.
  /// That ordering decision is recorded upstream in
  /// `logfitness_saas/PLANNING.md` §4.
  Future<VisitorActionResult> convert({
    required String visitorId,
    required String memberId,
  }) {
    return _run(() async {
      await ref
          .read(visitorsRepositoryProvider)
          .convertVisitor(visitorId, memberId);
      return visitorId;
    });
  }

  /// Removes a visitor row. Owners only, enforced by RLS -- a non-owner gets
  /// a `42501` back, which surfaces as a refusal rather than silence.
  Future<VisitorActionResult> delete(String visitorId) {
    return _run(() async {
      await ref.read(visitorsRepositoryProvider).deleteVisitor(visitorId);
      return null;
    });
  }

  Future<VisitorActionResult> _run(Future<String?> Function() action) async {
    if (state) {
      // A double tap is not a second intent. Refusing here keeps a slow
      // network from logging the same walk-in twice.
      return const VisitorActionFailed(
        AppFailure(FailureKind.invalid, 'That is already being saved.'),
      );
    }

    state = true;
    try {
      final id = await action();
      // The log is the screen behind every one of these actions, so it is
      // always stale afterwards.
      await ref.read(visitorListProvider.notifier).refresh();
      return VisitorActionSucceeded(id);
    } catch (error, stackTrace) {
      return VisitorActionFailed(mapError(error, stackTrace));
    } finally {
      state = false;
    }
  }
}
