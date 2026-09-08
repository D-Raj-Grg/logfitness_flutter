// The shape of a member list request, and what comes back. The Dart
// counterpart of the console's `memberListQuerySchema`
// (`logfitness_saas/lib/validation/members.ts`) and `MemberListResult`
// (`logfitness_saas/lib/db/members.ts`).
//
// It is a value object rather than a pile of named arguments because the
// filter, the page and the term travel together through a controller and into
// a URL, and splitting them means every layer restates the defaults.
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:logfitness_flutter/data/members/member_overview.dart';

part 'member_list_query.freezed.dart';

/// The status chip the desk has selected.
///
/// Deliberately **not** `MemberStatus`: four of these are the Postgres enum,
/// but `expiring`, `dues` and `archived` are predicates over other columns
/// (`days_to_expiry`, `due_paisa`, `archived_at`). Mirrors the console's
/// `status` union exactly so the two surfaces agree on what a chip means.
enum MemberListFilter {
  active('active'),
  expired('expired'),
  frozen('frozen'),
  left('left'),

  /// Active, and expiring within seven days. The number is the console's, and
  /// changing it here alone would make the two dashboards disagree.
  expiring('expiring'),

  /// Anything with money outstanding.
  dues('dues'),

  /// The only filter that shows archived members. Every other query hides
  /// them.
  archived('archived');

  const MemberListFilter(this.wire);

  /// The token the console puts in the query string. Kept identical so a
  /// deep link written by one surface is readable by the other.
  final String wire;
}

/// What a list offers. Mirrors `PAGE_SIZES` in `logfitness_saas/lib/pagination.ts`.
const List<int> memberPageSizes = <int>[10, 25, 50, 100];

/// Mirrors `DEFAULT_PAGE_SIZE`.
const int defaultMemberPageSize = 25;

@freezed
abstract class MemberListQuery with _$MemberListQuery {
  const factory MemberListQuery({
    /// Matches a phone prefix, a member-code prefix, or any part of the name
    /// -- the three things a front desk is ever told. Trimmed by the
    /// repository, not here.
    @Default('') String q,
    MemberListFilter? status,

    /// One-based, like the console's. Page zero is not a thing the URL can
    /// express.
    @Default(1) int page,
    @Default(defaultMemberPageSize) int pageSize,
  }) = _MemberListQuery;
}

@freezed
abstract class MemberListResult with _$MemberListResult {
  const factory MemberListResult({
    required List<MemberOverview> rows,

    /// The count of rows matching the filters, ignoring the page window --
    /// what the pager needs to know how many pages there are.
    required int total,
    required int page,
    required int pageSize,
  }) = _MemberListResult;
}
