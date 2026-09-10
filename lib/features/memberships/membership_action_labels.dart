// The words this feature uses for the Postgres enums, in one place.
//
// They match the web console deliberately: the desk staff reading the phone
// and the manager reading the console are discussing the same row, and the
// enum name is not what either of them calls it.
//
// The one that carries weight is [paymentKindLabel]. A refund and a reversal
// are both negative rows, and they are not the same fact -- one says cash
// left the drawer, the other says a note that was rung up never arrived.
// `PaymentKind.reversal` was missing from the Dart enum until 2026-09-09 and
// its absence took out payment history for any org that had reversed an
// entry. Labelling them identically would be the same mistake with a nicer
// stack trace.
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';

String paymentMethodLabel(PaymentMethod method) => switch (method) {
      PaymentMethod.cash => 'Cash',
      PaymentMethod.esewa => 'eSewa',
      PaymentMethod.khalti => 'Khalti',
      PaymentMethod.fonepay => 'Fonepay',
      PaymentMethod.bank => 'Bank transfer',
      PaymentMethod.card => 'Card',
    };

/// How a `payments` row reads on screen.
///
/// "Never received" rather than "Reversal" because that is the fact, and it
/// is the phrase the console uses on the drawer sheet.
String paymentKindLabel(PaymentKind kind) => switch (kind) {
      PaymentKind.payment => 'Payment',
      PaymentKind.refund => 'Refund',
      PaymentKind.reversal => 'Never received',
    };

String membershipStatusLabel(MembershipStatus status) => switch (status) {
      MembershipStatus.upcoming => 'Upcoming',
      MembershipStatus.active => 'Active',
      MembershipStatus.frozen => 'Frozen',
      MembershipStatus.expired => 'Expired',
      MembershipStatus.cancelled => 'Cancelled',
    };

String memberStatusLabel(MemberStatus status) => switch (status) {
      MemberStatus.active => 'Active',
      MemberStatus.expired => 'Expired',
      MemberStatus.frozen => 'Frozen',
      MemberStatus.left => 'Left',
    };

/// `2 days` / `1 day`, for the sentences that report what a freeze cost.
String dayCount(int days) {
  final int magnitude = days.abs();
  return '$magnitude ${magnitude == 1 ? 'day' : 'days'}';
}
