import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_flutter/domain/validation/org_preferences.dart';

void main() {
  PreferencesValidation v(String w, [String l = 'en']) =>
      validatePreferences(cancellationWindow: w, notificationLocale: l);

  test('accepts bounds 0 and 10080, trims', () {
    expect(v('0').values!.cancellationWindowMinutes, 0);
    expect(v(' 10080 ').values!.cancellationWindowMinutes, 10080);
    expect(v('90', 'ne').values!.notificationLocale, 'ne');
  });

  test('rejects out of range, blanks, fractions, negatives, huge', () {
    for (final String bad in <String>[
      '10081',
      '',
      '1.5',
      '-1',
      'abc',
      '99999999999999999999',
    ]) {
      final PreferencesValidation r = v(bad);
      expect(r.isValid, isFalse, reason: bad);
      expect(r.errors.containsKey(PreferencesField.cancellationWindow), isTrue);
    }
  });

  test('rejects unknown locale', () {
    expect(
      v('60', 'fr').errors.containsKey(PreferencesField.notificationLocale),
      isTrue,
    );
  });

  test('fromSettings applies defaults and ignores junk', () {
    final OrgPreferences d = OrgPreferences.fromSettings(<String, dynamic>{});
    expect(d.cancellationWindowMinutes, kDefaultCancellationWindowMinutes);
    expect(d.notificationLocale, 'en');
    final OrgPreferences j = OrgPreferences.fromSettings(<String, dynamic>{
      'class_cancellation_window_minutes': -5,
      'notification_locale': 'fr',
    });
    expect(j.cancellationWindowMinutes, kDefaultCancellationWindowMinutes);
    expect(j.notificationLocale, 'en');
    final OrgPreferences ok = OrgPreferences.fromSettings(<String, dynamic>{
      'class_cancellation_window_minutes': 30,
      'notification_locale': 'ne',
    });
    expect(ok.cancellationWindowMinutes, 30);
    expect(ok.notificationLocale, 'ne');
    expect(OrgPreferences.fromSettings(null).notificationLocale, 'en');
  });
}
