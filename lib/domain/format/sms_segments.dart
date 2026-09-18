// How many SMS one body costs.
//
// Dart mirror of `logfitness_saas/lib/notifications/messages.ts`. A Devanagari
// message is UCS-2, so a segment is 70 characters rather than 160 and bills two
// to three times an English one. Segments, not characters, are what turn into
// money, so that is what every screen showing a message counts.
//
// Lives in `domain/format/` beside `money.dart` rather than in a feature
// because three surfaces need the same arithmetic -- the template editor, the
// member sheet and the visitor sheet -- which is the same reason the console
// lifted it out of its template editor.

/// What one body costs to send.
class SmsSegments {
  const SmsSegments({
    required this.unicode,
    required this.count,
    required this.perSegment,
  });

  /// True when the body leaves the GSM range and has to go out as UCS-2.
  final bool unicode;

  /// Segments, never zero: an empty body still costs one if it is sent.
  final int count;

  /// 70 for a unicode body, 160 otherwise.
  final int perSegment;
}

/// The cost of [body], counted exactly as the console counts it.
///
/// Two deliberate choices, both for parity rather than for correctness:
///
///  - the unicode test reads UTF-16 code units (`codeUnitAt`), matching
///    JavaScript's `charCodeAt`;
///  - `count` divides `body.length`, which is code units and not runes, so an
///    emoji (a surrogate pair) counts as two.
///
/// Being "more correct" on one side of the wire than the other would make the
/// app and the console quote different prices for the same message, which is
/// worse than both being slightly wrong in the same direction.
SmsSegments smsSegments(String body) {
  bool unicode = false;
  for (int i = 0; i < body.length; i++) {
    if (body.codeUnitAt(i) > 127) {
      unicode = true;
      break;
    }
  }
  final int perSegment = unicode ? 70 : 160;
  final int count = (body.length / perSegment).ceil();
  return SmsSegments(
    unicode: unicode,
    count: count < 1 ? 1 : count,
    perSegment: perSegment,
  );
}

/// The longest body the database will store.
///
/// `enqueue_notification` writes `left(btrim(body), 1000)`, so anything past
/// this is silently shortened server-side. Every editor caps here instead, so
/// the person typing sees the limit rather than discovering it in the log.
const int kNotificationBodyMaxLength = 1000;
