// The member profile's read side.
//
// One provider per tab rather than one that loads everything: a member with
// four years of payments should not keep the memberships strip waiting, and a
// refusal on one table has to be legible as a refusal on *that* tab rather
// than blanking the whole profile. Each is a `family` on the member id so the
// profile can be opened from anywhere without threading state through the
// navigator.
//
// Widgets call controllers; controllers call repositories (PLANNING.md §6).
// Declared by hand -- no codegen is needed for a family of futures.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/data/members/member.dart';
import 'package:logfitness_flutter/data/members/member_overview.dart';
import 'package:logfitness_flutter/data/members/members_repository.dart';
import 'package:logfitness_flutter/data/memberships/membership.dart';
import 'package:logfitness_flutter/data/memberships/memberships_repository.dart';
import 'package:logfitness_flutter/data/payments/invoice.dart';
import 'package:logfitness_flutter/data/payments/payment_with_collector.dart';
import 'package:logfitness_flutter/data/payments/payments_repository.dart';

/// The header of the profile: the view row for plan, expiry and dues, and the
/// table row for the fields the view does not carry (email, invite state, the
/// archive reason).
///
/// A plain Dart class, not freezed -- it never crosses the wire.
class MemberProfile {
  const MemberProfile({required this.member, required this.overview});

  final Member member;
  final MemberOverview overview;
}

/// Null when the member does not exist *or* when RLS hides it. The two are
/// indistinguishable by design -- that is what row-level security means -- so
/// the screen says "not found" for both rather than guessing which happened.
final memberProfileProvider = FutureProvider.family<MemberProfile?, String>((
  ref,
  String memberId,
) async {
  final MembersRepository repository = ref.read(membersRepositoryProvider);
  // Concurrently: two independent reads of the same row, and the profile
  // needs both before it can render a header.
  final List<Object?> both = await Future.wait(<Future<Object?>>[
    repository.fetchOverviewById(memberId),
    repository.fetchById(memberId),
  ]);

  final MemberOverview? overview = both[0] as MemberOverview?;
  final Member? member = both[1] as Member?;
  if (overview == null || member == null) {
    return null;
  }
  return MemberProfile(member: member, overview: overview);
});

/// Newest first. Financial history is append-only, so this is the record of
/// what was sold and when, not a mutable current state (CLAUDE.md).
final memberMembershipsProvider =
    FutureProvider.family<List<Membership>, String>((
      ref,
      String memberId,
    ) async {
      return ref
          .read(membershipsRepositoryProvider)
          .listMembershipsForMember(memberId);
    });

/// Read through the memberships repository, which is where the console keeps
/// it: invoices are raised by the membership RPCs.
final memberInvoicesProvider = FutureProvider.family<List<Invoice>, String>((
  ref,
  String memberId,
) async {
  return ref
      .read(membershipsRepositoryProvider)
      .listInvoicesForMember(memberId);
});

/// Payments, refunds and reversals, newest first, with the collector's name
/// already joined on -- the desk's audit question answered in the same round
/// trip.
final memberPaymentsProvider =
    FutureProvider.family<List<PaymentWithCollector>, String>((
      ref,
      String memberId,
    ) async {
      return ref
          .read(paymentsRepositoryProvider)
          .listPaymentsForMember(memberId);
    });
