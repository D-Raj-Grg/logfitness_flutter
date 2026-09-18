// Segment arithmetic, pinned against the console's.
//
// This is the file that decides what a message costs, so the parity target is
// `logfitness_saas/lib/notifications/messages.ts` character for character. A
// test here that "corrected" the counting would make the app and the console
// quote two different prices for the same body, which is worse than both being
// wrong in the same direction.
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/domain/format/sms_segments.dart';

/// `count` characters of plain ASCII.
String _ascii(int count) => 'a' * count;

/// `count` Devanagari characters -- each one a single UTF-16 code unit, so the
/// only thing that changes against [_ascii] is the segment size.
String _devanagari(int count) => 'क' * count;

void main() {
  group('smsSegments -- GSM bodies', () {
    test('160 characters is one segment and 161 is two', () {
      final one = smsSegments(_ascii(160));
      expect(one.unicode, isFalse);
      expect(one.perSegment, 160);
      expect(one.count, 1);

      final two = smsSegments(_ascii(161));
      expect(two.count, 2, reason: 'the 161st character buys a second segment');
      expect(two.perSegment, 160);
    });

    test('a short body is one segment', () {
      expect(smsSegments('Your membership ends on Sunday.').count, 1);
    });

    test('an empty body is one segment, never zero', () {
      // Nothing is ever sent for free: the floor is `max(1, ...)` upstream and
      // has to be here too, or an empty editor reads as "this costs nothing".
      final empty = smsSegments('');
      expect(empty.count, 1);
      expect(empty.unicode, isFalse);
      expect(empty.perSegment, 160);
    });

    test('the last GSM character is 127, not 255', () {
      // The console tests `charCodeAt(i) > 127`, so anything past plain ASCII
      // -- including Latin-1 accents, which real GSM-7 does carry -- is UCS-2.
      // Matching that is the point; being more generous here would quote a
      // cheaper price than the gateway charges.
      expect(smsSegments('').unicode, isFalse);
      expect(smsSegments('é').unicode, isTrue);
    });
  });

  group('smsSegments -- unicode bodies', () {
    test('a Devanagari body is UCS-2 and gets 70 characters a segment', () {
      final result = smsSegments('तपाईंको सदस्यता सकिँदै छ।');
      expect(result.unicode, isTrue);
      expect(result.perSegment, 70);
    });

    test('70 Devanagari characters is one segment and 71 is two', () {
      expect(smsSegments(_devanagari(70)).count, 1);
      expect(smsSegments(_devanagari(71)).count, 2);
    });

    test('one Devanagari character makes the whole body unicode', () {
      // Mixed bodies are the common case -- an English template with the gym's
      // name in Nepali -- and they bill at 70, not at 160 for the English part.
      final result = smsSegments('${_ascii(100)}क');
      expect(result.unicode, isTrue);
      expect(result.perSegment, 70);
      expect(result.count, 2);
    });
  });

  group('smsSegments -- code units, deliberately', () {
    test('an emoji counts as two characters, because it is two code units', () {
      // PINNED ON PURPOSE. `count` divides `body.length`, which is UTF-16 code
      // units and not runes, exactly as JavaScript's `.length` does. An emoji
      // is a surrogate pair, so it counts twice.
      //
      // 35 emoji are 70 code units -- one segment. 36 are 72 -- two. Counting
      // runes would call the second body 36 characters and quote one segment,
      // and the console would quote two for the same text.
      expect(smsSegments('😀' * 35).count, 1);
      expect(smsSegments('😀' * 36).count, 2);

      // The premise of the two assertions above, stated so a future reader
      // does not have to take it on trust.
      expect(('😀' * 36).length, 72);
      expect(('😀' * 36).runes.length, 36);
    });

    test('a single emoji is unicode and still only one segment', () {
      final result = smsSegments('😀');
      expect(result.unicode, isTrue);
      expect(result.perSegment, 70);
      expect(result.count, 1);
    });
  });

  test('the body cap matches what the database stores', () {
    // `enqueue_notification` writes `left(btrim(body), 1000)`, so an editor
    // that allowed more would silently ship a truncated message.
    expect(kNotificationBodyMaxLength, 1000);
  });
}
