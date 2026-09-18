// Dart mirrors of the Postgres enums defined upstream in
// `logfitness_saas/supabase/migrations/`. Values must match the database
// exactly — an unrecognised wire value must fail loudly, never fall back to
// a silent default. See PLANNING.md §5.
//
// Each enum:
//   - carries a `wire` field holding the exact Postgres string;
//   - exposes `static X fromDb(String value)` that throws
//     [UnknownEnumValue] on anything the database didn't send;
//   - exposes `toDb()` returning `wire`;
//   - is annotated per-value with `@JsonValue` so json_serializable can
//     (de)serialize it directly inside generated `fromJson`/`toJson`.
import 'package:json_annotation/json_annotation.dart';

/// Thrown when a string read from Postgres does not match any known value
/// of the target enum. Never silently defaulted — see PLANNING.md §5 and
/// CLAUDE.md ("Dart enum values must match the Postgres enums exactly").
class UnknownEnumValue implements Exception {
  const UnknownEnumValue(this.enumName, this.value);

  final String enumName;
  final String value;

  @override
  String toString() =>
      'UnknownEnumValue: "$value" is not a known value of $enumName';
}

/// Mirrors `public.member_status`.
enum MemberStatus {
  @JsonValue('active')
  active('active'),
  @JsonValue('expired')
  expired('expired'),
  @JsonValue('frozen')
  frozen('frozen'),
  @JsonValue('left')
  left('left');

  const MemberStatus(this.wire);

  final String wire;

  static MemberStatus fromDb(String value) => MemberStatus.values.firstWhere(
        (e) => e.wire == value,
        orElse: () => throw UnknownEnumValue('MemberStatus', value),
      );

  String toDb() => wire;
}

/// Mirrors `public.member_gender`.
enum MemberGender {
  @JsonValue('male')
  male('male'),
  @JsonValue('female')
  female('female'),
  @JsonValue('other')
  other('other');

  const MemberGender(this.wire);

  final String wire;

  static MemberGender fromDb(String value) => MemberGender.values.firstWhere(
        (e) => e.wire == value,
        orElse: () => throw UnknownEnumValue('MemberGender', value),
      );

  String toDb() => wire;
}

/// Mirrors `public.plan_type`.
enum PlanType {
  @JsonValue('time')
  time('time'),
  @JsonValue('session_pack')
  sessionPack('session_pack');

  const PlanType(this.wire);

  final String wire;

  static PlanType fromDb(String value) => PlanType.values.firstWhere(
        (e) => e.wire == value,
        orElse: () => throw UnknownEnumValue('PlanType', value),
      );

  String toDb() => wire;
}

/// Mirrors `public.membership_status`.
enum MembershipStatus {
  @JsonValue('upcoming')
  upcoming('upcoming'),
  @JsonValue('active')
  active('active'),
  @JsonValue('frozen')
  frozen('frozen'),
  @JsonValue('expired')
  expired('expired'),
  @JsonValue('cancelled')
  cancelled('cancelled');

  const MembershipStatus(this.wire);

  final String wire;

  static MembershipStatus fromDb(String value) =>
      MembershipStatus.values.firstWhere(
        (e) => e.wire == value,
        orElse: () => throw UnknownEnumValue('MembershipStatus', value),
      );

  String toDb() => wire;
}

/// Mirrors `public.payment_method`.
enum PaymentMethod {
  @JsonValue('cash')
  cash('cash'),
  @JsonValue('esewa')
  esewa('esewa'),
  @JsonValue('khalti')
  khalti('khalti'),
  @JsonValue('fonepay')
  fonepay('fonepay'),
  @JsonValue('bank')
  bank('bank'),
  @JsonValue('card')
  card('card');

  const PaymentMethod(this.wire);

  final String wire;

  static PaymentMethod fromDb(String value) =>
      PaymentMethod.values.firstWhere(
        (e) => e.wire == value,
        orElse: () => throw UnknownEnumValue('PaymentMethod', value),
      );

  String toDb() => wire;
}

/// Mirrors `public.discount_reason`. See
/// `logfitness_saas/supabase/migrations/20260910130000_discount_reason.sql`.
///
/// The sale RPCs refuse a discount without one of these
/// (`20260910130100_discount_reason_rpcs.sql`), so this is not decoration: a
/// discounted sale that does not carry a reason is rejected by the database.
enum DiscountReason {
  @JsonValue('festival')
  festival('festival'),
  @JsonValue('student')
  student('student'),
  @JsonValue('staff_referral')
  staffReferral('staff_referral'),
  @JsonValue('friend_referral')
  friendReferral('friend_referral'),
  @JsonValue('corporate')
  corporate('corporate'),
  @JsonValue('other')
  other('other');

  const DiscountReason(this.wire);

  final String wire;

  static DiscountReason fromDb(String value) =>
      DiscountReason.values.firstWhere(
        (e) => e.wire == value,
        orElse: () => throw UnknownEnumValue('DiscountReason', value),
      );

  String toDb() => wire;
}

/// Mirrors `public.payment_kind`.
enum PaymentKind {
  @JsonValue('payment')
  payment('payment'),
  @JsonValue('refund')
  refund('refund'),
  // Added 2026-09-09. `reverse_payment` has written this kind since
  // `20260907120500_payment_reversal.sql`, and this enum did not carry it, so
  // `fromDb` threw for any org that had ever reversed an entry -- taking out
  // payment history and the collection sheet, not just the reversed row. A
  // refund says cash left the drawer; a reversal says a note that was rung up
  // never arrived. They are different facts and the app has to read both.
  @JsonValue('reversal')
  reversal('reversal');

  const PaymentKind(this.wire);

  final String wire;

  static PaymentKind fromDb(String value) => PaymentKind.values.firstWhere(
        (e) => e.wire == value,
        orElse: () => throw UnknownEnumValue('PaymentKind', value),
      );

  String toDb() => wire;
}

/// Mirrors `public.invoice_status`.
enum InvoiceStatus {
  @JsonValue('unpaid')
  unpaid('unpaid'),
  @JsonValue('partial')
  partial('partial'),
  @JsonValue('paid')
  paid('paid'),
  @JsonValue('void')
  voided('void');

  const InvoiceStatus(this.wire);

  final String wire;

  static InvoiceStatus fromDb(String value) =>
      InvoiceStatus.values.firstWhere(
        (e) => e.wire == value,
        orElse: () => throw UnknownEnumValue('InvoiceStatus', value),
      );

  String toDb() => wire;
}

/// Mirrors `public.staff_role`.
enum StaffRole {
  @JsonValue('owner')
  owner('owner'),
  @JsonValue('manager')
  manager('manager'),
  @JsonValue('front_desk')
  frontDesk('front_desk'),
  @JsonValue('trainer')
  trainer('trainer');

  const StaffRole(this.wire);

  final String wire;

  static StaffRole fromDb(String value) => StaffRole.values.firstWhere(
        (e) => e.wire == value,
        orElse: () => throw UnknownEnumValue('StaffRole', value),
      );

  String toDb() => wire;
}

/// Mirrors `public.visitor_kind`.
///
/// Two kinds of person walk in: one asking what a month costs, one here to
/// train for a day as a guest. See
/// `logfitness_saas/supabase/migrations/20260908110100_visitors.sql`.
enum VisitorKind {
  @JsonValue('enquiry')
  enquiry('enquiry'),
  @JsonValue('guest')
  guest('guest');

  const VisitorKind(this.wire);

  final String wire;

  static VisitorKind fromDb(String value) => VisitorKind.values.firstWhere(
        (e) => e.wire == value,
        orElse: () => throw UnknownEnumValue('VisitorKind', value),
      );

  String toDb() => wire;
}

/// Mirrors `public.visitor_status`.
///
/// `converted` is not settable from the app: the database's
/// `visitors_converted_shape` constraint requires the member id and the
/// timestamp to move with it, which is what `convert_visitor` is for.
enum VisitorStatus {
  @JsonValue('new')
  isNew('new'),
  @JsonValue('contacted')
  contacted('contacted'),
  @JsonValue('converted')
  converted('converted'),
  @JsonValue('lost')
  lost('lost');

  const VisitorStatus(this.wire);

  final String wire;

  static VisitorStatus fromDb(String value) => VisitorStatus.values.firstWhere(
        (e) => e.wire == value,
        orElse: () => throw UnknownEnumValue('VisitorStatus', value),
      );

  String toDb() => wire;
}

/// Mirrors `public.branch_status`.
///
/// A branch is deactivated, never deleted: it keeps every row it owns, and an
/// `owners delete branches` policy left over from the foundation migrations
/// was dropped upstream on 2026-09-08 so the rule is enforced by the database
/// rather than by the absence of a button.
enum BranchStatus {
  @JsonValue('active')
  active('active'),
  @JsonValue('inactive')
  inactive('inactive');

  const BranchStatus(this.wire);

  final String wire;

  static BranchStatus fromDb(String value) => BranchStatus.values.firstWhere(
        (e) => e.wire == value,
        orElse: () => throw UnknownEnumValue('BranchStatus', value),
      );

  String toDb() => wire;
}

/// Mirrors `public.attendance_method`.
///
/// `biometric` exists in the database and has since the attendance schema
/// shipped, even though biometric hardware is out of scope for v1 -- a device
/// integration would write this value. It is carried here so a row written by
/// anything other than this app still reads.
enum AttendanceMethod {
  @JsonValue('manual')
  manual('manual'),
  @JsonValue('qr')
  qr('qr'),
  @JsonValue('card')
  card('card'),
  @JsonValue('biometric')
  biometric('biometric');

  const AttendanceMethod(this.wire);

  final String wire;

  static AttendanceMethod fromDb(String value) =>
      AttendanceMethod.values.firstWhere(
        (e) => e.wire == value,
        orElse: () => throw UnknownEnumValue('AttendanceMethod', value),
      );

  String toDb() => wire;
}

/// Mirrors `public.notification_channel`.
enum NotificationChannel {
  @JsonValue('sms')
  sms('sms'),
  @JsonValue('viber')
  viber('viber'),
  @JsonValue('email')
  email('email');

  const NotificationChannel(this.wire);

  final String wire;

  static NotificationChannel fromDb(String value) =>
      NotificationChannel.values.firstWhere(
        (e) => e.wire == value,
        orElse: () => throw UnknownEnumValue('NotificationChannel', value),
      );

  String toDb() => wire;
}

/// Mirrors `public.notification_event`.
///
/// Nine values, grown in four migrations: the five the schema shipped with,
/// `custom_message` (the desk sending a member something by hand), the two
/// visitor events, and `announcement`. `staff_invite` and `test_message` are
/// here because the column can return them -- `send_member_notification`
/// refuses both, because neither is addressed to a member.
///
/// `announcement` is the same shape of thing and is here for a sharper reason:
/// it landed upstream in `20260917100000_announcement_event.sql` while this
/// mirror still had eight values, and `NotificationMessage.event` is not
/// nullable. One broadcast sent from the console and every row of the delivery
/// log stopped parsing -- the screen read "This app is out of date with the
/// server", which was true and useless. No manual surface offers it:
/// `send_member_notification` refuses it and a broadcast is fanned out by
/// `send_announcement`, never enqueued one at a time.
enum NotificationEvent {
  @JsonValue('renewal_reminder')
  renewalReminder('renewal_reminder'),
  @JsonValue('dues_reminder')
  duesReminder('dues_reminder'),
  @JsonValue('birthday_greeting')
  birthdayGreeting('birthday_greeting'),
  @JsonValue('staff_invite')
  staffInvite('staff_invite'),
  @JsonValue('test_message')
  testMessage('test_message'),
  @JsonValue('custom_message')
  customMessage('custom_message'),
  @JsonValue('visitor_welcome')
  visitorWelcome('visitor_welcome'),
  @JsonValue('visitor_follow_up')
  visitorFollowUp('visitor_follow_up'),
  @JsonValue('announcement')
  announcement('announcement');

  const NotificationEvent(this.wire);

  final String wire;

  static NotificationEvent fromDb(String value) =>
      NotificationEvent.values.firstWhere(
        (e) => e.wire == value,
        orElse: () => throw UnknownEnumValue('NotificationEvent', value),
      );

  String toDb() => wire;
}

/// Mirrors `public.notification_provider` -- the *gateway*, not the row.
///
/// Named `...Kind` because `NotificationProvider` is the table's row model and
/// Postgres lets an enum and a table share a name where Dart does not.
///
/// `logOnly` is carried because the column can return it, but it is
/// deliberately absent from the gateway picker, exactly as it is absent from
/// the console's `CHOICES`: it is a development sink, not something an owner
/// should be able to select and then wonder why nothing arrives.
enum NotificationProviderKind {
  @JsonValue('sparrow_sms')
  sparrowSms('sparrow_sms'),
  @JsonValue('aakash_sms')
  aakashSms('aakash_sms'),
  @JsonValue('smspasal_sms')
  smspasalSms('smspasal_sms'),
  @JsonValue('viber_business')
  viberBusiness('viber_business'),
  @JsonValue('resend_email')
  resendEmail('resend_email'),
  @JsonValue('custom_http')
  customHttp('custom_http'),
  @JsonValue('log_only')
  logOnly('log_only');

  const NotificationProviderKind(this.wire);

  final String wire;

  static NotificationProviderKind fromDb(String value) =>
      NotificationProviderKind.values.firstWhere(
        (e) => e.wire == value,
        orElse: () => throw UnknownEnumValue('NotificationProviderKind', value),
      );

  String toDb() => wire;
}

/// Mirrors `public.notification_status`.
///
/// `skipped` is not a failure. It means the gym deliberately did not send: no
/// gateway on that channel, no token, an opted-out member, or a number that
/// cannot be delivered to. Every surface that colours a status has to say so.
enum NotificationStatus {
  @JsonValue('queued')
  queued('queued'),
  @JsonValue('sending')
  sending('sending'),
  @JsonValue('sent')
  sent('sent'),
  @JsonValue('failed')
  failed('failed'),
  @JsonValue('cancelled')
  cancelled('cancelled'),
  @JsonValue('skipped')
  skipped('skipped');

  const NotificationStatus(this.wire);

  final String wire;

  static NotificationStatus fromDb(String value) =>
      NotificationStatus.values.firstWhere(
        (e) => e.wire == value,
        orElse: () => throw UnknownEnumValue('NotificationStatus', value),
      );

  String toDb() => wire;
}

/// Mirrors `public.announcement_audience`.
///
/// Who a broadcast is addressed to. `both` is both groups of people, not both
/// rows: a walk-in whose number is also a member's is texted once, as the
/// member, because that is the wording meant for somebody who already pays.
enum AnnouncementAudience {
  @JsonValue('members')
  members('members'),
  @JsonValue('visitors')
  visitors('visitors'),
  @JsonValue('both')
  both('both');

  const AnnouncementAudience(this.wire);

  final String wire;

  static AnnouncementAudience fromDb(String value) =>
      AnnouncementAudience.values.firstWhere(
        (e) => e.wire == value,
        orElse: () => throw UnknownEnumValue('AnnouncementAudience', value),
      );

  String toDb() => wire;
}

/// Mirrors `public.announcement_status`.
///
/// What was *asked for*, and it never moves again except to `cancelled`. It is
/// not what the announcements list renders: that reads `announcement_overview`
/// `state`, which is derived from the outbox and knows the difference between a
/// send that is still going and one that has finished. The two part company the
/// moment a scheduled hour passes -- see [AnnouncementState].
enum AnnouncementStatus {
  @JsonValue('scheduled')
  scheduled('scheduled'),
  @JsonValue('sending')
  sending('sending'),
  @JsonValue('cancelled')
  cancelled('cancelled');

  const AnnouncementStatus(this.wire);

  final String wire;

  static AnnouncementStatus fromDb(String value) =>
      AnnouncementStatus.values.firstWhere(
        (e) => e.wire == value,
        orElse: () => throw UnknownEnumValue('AnnouncementStatus', value),
      );

  String toDb() => wire;
}
