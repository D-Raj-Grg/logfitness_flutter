// The small conversions and labels the three sales screens share.
//
// The rupees -> paisa conversion lives here so it happens in exactly one
// place per screen, at the input boundary, and so a test can prove a
// fractional amount survives it (CLAUDE.md: "Money is integer paisa in
// `int`. Convert to a decimal exactly once, in the formatter at the render
// boundary -- never in queries, totals, or business logic").
import 'package:logfitness_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_flutter/domain/format/money.dart';

/// Rupees typed at the desk, as integer paisa. Blank and unparseable both
/// read as zero.
///
/// Zero rather than a throw because this is called on every keystroke to keep
/// the running sale summary live; the field's validator is what actually
/// refuses a bad entry, so no half-parsed number ever reaches an RPC.
int paisaOrZero(String raw) {
  final String trimmed = raw.trim();
  if (trimmed.isEmpty) {
    return 0;
  }
  try {
    return toPaisa(trimmed);
  } on FormatException {
    return 0;
  }
}

/// The validator every rupee field on these screens uses. Blank is allowed --
/// a screen that requires an amount says so with its own check, so that
/// "leave blank to invoice it" stays expressible.
String? rupeeValidator(String? value) {
  final String trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) {
    return null;
  }
  try {
    return toPaisa(trimmed) < 0 ? 'That cannot be negative.' : null;
  } on FormatException {
    return 'Enter an amount in rupees.';
  }
}

/// Renders integer paisa back into rupees for a text field's initial value.
///
/// The inverse of [paisaOrZero], and the only other place the divide by 100
/// happens. Whole rupees lose the `.0` because that is what a cashier types.
String rupeesFromPaisa(int paisa) {
  final double rupees = paisa / 100;
  return rupees == rupees.roundToDouble()
      ? rupees.round().toString()
      : rupees.toStringAsFixed(2);
}

/// Mirrors the console's `PAYMENT_METHOD_LABELS`. The wire value is exact but
/// unreadable ("esewa"); this is what a person sees.
String paymentMethodLabel(PaymentMethod method) => switch (method) {
  PaymentMethod.cash => 'Cash',
  PaymentMethod.esewa => 'eSewa',
  PaymentMethod.khalti => 'Khalti',
  PaymentMethod.fonepay => 'Fonepay',
  PaymentMethod.bank => 'Bank transfer',
  PaymentMethod.card => 'Card',
};

/// Every rail but cash carries a transaction reference, and the console's
/// `requireReferenceForDigital` refuses a digital payment without one. Same
/// rule here, so the two front ends do not disagree about what a complete
/// payment looks like.
bool methodNeedsReference(PaymentMethod method) => method != PaymentMethod.cash;

/// What a [PaymentKind] means to someone reconciling a drawer.
///
/// A refund says cash left the drawer. A reversal says a note that was rung
/// up never arrived. They are different facts about a different problem, and
/// the collection sheet must never fold them into one another or into the
/// takings (`postgres_enums.dart`, `PaymentKind.reversal`).
String paymentKindLabel(PaymentKind kind) => switch (kind) {
  PaymentKind.payment => 'Collected',
  PaymentKind.refund => 'Refunded',
  PaymentKind.reversal => 'Never received',
};
