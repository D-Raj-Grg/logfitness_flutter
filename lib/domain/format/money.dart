import 'package:intl/intl.dart';

/// Money is stored as integer paisa. It is converted to a decimal exactly
/// once, here, at the render boundary -- never in queries, totals, or
/// business logic. Mirrors `logfitness_saas/lib/format.ts`.
String formatMoney(
  int paisa, {
  String currency = 'NPR',
  bool withSymbol = true,
}) {
  final NumberFormat formatter = NumberFormat.decimalPattern('en_IN')
    ..minimumFractionDigits = 0
    ..maximumFractionDigits = 2;
  final String formatted = formatter.format(paisa / 100);

  return withSymbol ? '$currency $formatted' : formatted;
}

/// Parses user input in rupees into the integer paisa the database stores.
///
/// `Math.round` in JS rounds half towards positive infinity for every input,
/// including negatives (e.g. `Math.round(-0.5) == -0`, `Math.round(-1.5) ==
/// -1`). Dart's `num.round()` rounds half away from zero instead. Amounts in
/// this app are never negative user input (refunds are computed server-side
/// as negative paisa, not typed in), so the two only disagree on a half-cent
/// negative rupee value that should never reach this function; if one ever
/// does, this implementation rounds it away from zero rather than matching
/// JS bit-for-bit.
int toPaisa(Object rupees) {
  final num value;
  if (rupees is String) {
    final num? parsed = num.tryParse(rupees.replaceAll(',', ''));
    if (parsed == null) {
      throw FormatException('Not a valid amount: $rupees');
    }
    value = parsed;
  } else if (rupees is num) {
    value = rupees;
  } else {
    throw FormatException('Not a valid amount: $rupees');
  }

  if (!value.isFinite) {
    throw FormatException('Not a valid amount: $rupees');
  }

  return (value * 100).round();
}
