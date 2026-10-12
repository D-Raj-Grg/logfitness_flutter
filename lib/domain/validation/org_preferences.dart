// What the Preferences screen will and will not accept, decided without a
// widget. Mirrors `orgPreferencesSchema` in
// `logfitness_saas/lib/validation/orgs.ts`; `set_org_setting` (migration
// `20261007100000_set_org_setting.sql`) is the second layer behind it.

/// Used by `class_cancellation_window_minutes()` in SQL when the key is unset.
const int kDefaultCancellationWindowMinutes = 120;

/// Seven days. The RPC's ceiling.
const int kMaxCancellationWindowMinutes = 10080;

const List<String> kNotificationLocales = <String>['en', 'ne'];

String notificationLocaleLabel(String locale) =>
    locale == 'ne' ? 'Nepali' : 'English';

enum PreferencesField { cancellationWindow, notificationLocale }

class OrgPreferences {
  const OrgPreferences({
    required this.cancellationWindowMinutes,
    required this.notificationLocale,
  });

  final int cancellationWindowMinutes;
  final String notificationLocale;

  /// Reads `orgs.settings`, falling back to the same defaults SQL uses when a
  /// key is missing or holds something unusable.
  factory OrgPreferences.fromSettings(Object? settings) {
    final Map<String, dynamic> bag = settings is Map<String, dynamic>
        ? settings
        : const <String, dynamic>{};
    final Object? window = bag['class_cancellation_window_minutes'];
    final Object? locale = bag['notification_locale'];
    return OrgPreferences(
      cancellationWindowMinutes: window is int && window >= 0
          ? window
          : kDefaultCancellationWindowMinutes,
      notificationLocale:
          locale is String && kNotificationLocales.contains(locale)
          ? locale
          : 'en',
    );
  }
}

class PreferencesValidation {
  const PreferencesValidation({required this.errors, this.values});

  final Map<PreferencesField, String> errors;
  final OrgPreferences? values;

  bool get isValid => errors.isEmpty && values != null;
}

PreferencesValidation validatePreferences({
  required String cancellationWindow,
  required String notificationLocale,
}) {
  final Map<PreferencesField, String> errors = <PreferencesField, String>{};

  final String text = cancellationWindow.trim();
  int minutes = 0;
  if (!RegExp(r'^\d+$').hasMatch(text)) {
    errors[PreferencesField.cancellationWindow] =
        'Enter a whole number of minutes.';
  } else {
    // Longer than 6 digits cannot be in range; avoids int overflow on paste.
    final int? parsed = text.length > 6 ? null : int.tryParse(text);
    if (parsed == null || parsed > kMaxCancellationWindowMinutes) {
      errors[PreferencesField.cancellationWindow] =
          'Use at most $kMaxCancellationWindowMinutes minutes (7 days).';
    } else {
      minutes = parsed;
    }
  }

  if (!kNotificationLocales.contains(notificationLocale)) {
    errors[PreferencesField.notificationLocale] = 'Choose a language.';
  }

  return PreferencesValidation(
    errors: errors,
    values: errors.isEmpty
        ? OrgPreferences(
            cancellationWindowMinutes: minutes,
            notificationLocale: notificationLocale,
          )
        : null,
  );
}
