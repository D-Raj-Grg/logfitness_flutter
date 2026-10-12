// Hand-written reads behind the member home, payments, messages and profile
// screens. No annotation here needs build_runner. RLS bounds every query to
// the signed-in member's own rows (20260905150200_member_scope_rls.sql), so
// nothing filters by org or branch.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_flutter/data/auth/auth_repository.dart';
import 'package:logfitness_flutter/data/auth/current_member.dart';
import 'package:logfitness_flutter/data/memberships/membership.dart';
import 'package:logfitness_flutter/data/memberships/memberships_repository.dart';
import 'package:logfitness_flutter/data/notifications/notification_message.dart';
import 'package:logfitness_flutter/data/notifications/notifications_repository.dart';
import 'package:logfitness_flutter/data/payments/invoice.dart';
import 'package:logfitness_flutter/data/payments/payment.dart';
import 'package:logfitness_flutter/data/payments/payment_with_collector.dart';
import 'package:logfitness_flutter/data/payments/payments_repository.dart';
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';

/// The signed-in member's own row via `current_member()`. `status` is the
/// trigger-derived `members.status`; it is displayed, never computed.
final memberSelfProvider = FutureProvider.autoDispose<CurrentMember>((
  ref,
) async {
  final CurrentMember? me = await ref
      .watch(authRepositoryProvider)
      .currentMember();
  if (me == null) {
    throw StateError('No member profile is linked to this account.');
  }
  return me;
});

/// Everything the Home screen shows.
class MemberHomeData {
  const MemberHomeData({
    required this.member,
    required this.membership,
    required this.duePaisa,
    required this.openInvoices,
  });

  final CurrentMember member;

  /// The membership that best describes "my plan right now", or null if the
  /// member has never held one.
  final Membership? membership;

  /// Sum of `due_paisa` over invoices that are not void. Integer paisa.
  final int duePaisa;
  final int openInvoices;
}

Membership? _pickCurrent(List<Membership> all) {
  if (all.isEmpty) {
    return null;
  }
  final List<Membership> sorted = List<Membership>.of(all)
    ..sort((a, b) => b.startDate.compareTo(a.startDate));
  for (final MembershipStatus s in <MembershipStatus>[
    MembershipStatus.active,
    MembershipStatus.frozen,
    MembershipStatus.upcoming,
  ]) {
    for (final Membership m in sorted) {
      if (m.status == s) {
        return m;
      }
    }
  }
  return sorted.first;
}

final memberHomeProvider = FutureProvider.autoDispose<MemberHomeData>((
  ref,
) async {
  final CurrentMember me = await ref.watch(memberSelfProvider.future);
  final List<Object> results = await Future.wait<Object>(<Future<Object>>[
    ref.watch(membershipsRepositoryProvider).listMembershipsForMember(
      me.memberId,
    ),
    ref.watch(paymentsRepositoryProvider).listInvoicesForMember(me.memberId),
  ]);
  final List<Membership> memberships = results[0] as List<Membership>;
  final List<Invoice> invoices = results[1] as List<Invoice>;
  int due = 0;
  int open = 0;
  for (final Invoice i in invoices) {
    if (i.status != InvoiceStatus.voided && i.duePaisa > 0) {
      due += i.duePaisa;
      open++;
    }
  }
  return MemberHomeData(
    member: me,
    membership: _pickCurrent(memberships),
    duePaisa: due,
    openInvoices: open,
  );
});

class MemberPaymentsData {
  const MemberPaymentsData({
    required this.currency,
    required this.invoices,
    required this.payments,
  });

  final String currency;
  final List<Invoice> invoices;
  final List<Payment> payments;
}

final memberPaymentsProvider = FutureProvider.autoDispose<MemberPaymentsData>((
  ref,
) async {
  final CurrentMember me = await ref.watch(memberSelfProvider.future);
  final PaymentsRepository repo = ref.watch(paymentsRepositoryProvider);
  final List<Object> results = await Future.wait<Object>(<Future<Object>>[
    repo.listInvoicesForMember(me.memberId),
    repo.listPaymentsForMember(me.memberId),
  ]);
  final List<Invoice> invoices = results[0] as List<Invoice>;
  final payments = results[1] as List<PaymentWithCollector>;
  return MemberPaymentsData(
    currency: me.currency,
    invoices: invoices,
    payments: payments.map<Payment>((p) => p.payment).toList(),
  );
});

final memberOwnMessagesProvider =
    FutureProvider.autoDispose<List<NotificationMessage>>((ref) async {
      final CurrentMember me = await ref.watch(memberSelfProvider.future);
      return ref
          .watch(notificationsRepositoryProvider)
          .listNotificationsForMember(me.memberId, limit: 100);
    });
