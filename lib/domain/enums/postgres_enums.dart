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
