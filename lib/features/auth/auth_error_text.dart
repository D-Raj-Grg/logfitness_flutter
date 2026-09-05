// Pure error -> copy mapping shared by the auth screens. Kept separate and
// dependency-free (no widgets) so it is trivial to unit-test and reuse
// between login_screen.dart and set_password_screen.dart.
//
// Supabase's own [AuthException.message] is written for a developer reading
// logs, not a gym member -- these screens never show it directly. Every
// branch below is a plain-English sentence a first-time, non-technical user
// can act on.
import 'package:supabase_flutter/supabase_flutter.dart';

/// Generic fallback shown for anything not specifically mapped below --
/// deliberately vague because the underlying cause (network blip, a
/// Supabase outage, an error code this app does not yet recognise) is not
/// something the member can do anything about beyond trying again.
const kGenericAuthErrorMessage = 'Something went wrong. Please try again.';

/// Maps an error thrown by `signInWithPassword` to the message shown on
/// [LoginScreen].
///
/// | Supabase `AuthException.code` | Shown message |
/// | --- | --- |
/// | `invalid_credentials` | "Wrong email or password." |
/// | `email_not_confirmed` | "Please confirm your email before signing in." |
/// | `user_banned` | "This account has been disabled. Ask the front desk for help." |
/// | `over_request_rate_limit` / `over_email_send_rate_limit` | "Too many attempts. Please wait a few minutes and try again." |
/// | anything else (including non-auth errors, e.g. network failures) | [kGenericAuthErrorMessage] |
String mapSignInErrorMessage(Object error) {
  if (error is AuthException) {
    switch (error.code) {
      case 'invalid_credentials':
        return 'Wrong email or password.';
      case 'email_not_confirmed':
        return 'Please confirm your email before signing in.';
      case 'user_banned':
        return 'This account has been disabled. Ask the front desk for help.';
      case 'over_request_rate_limit':
      case 'over_email_send_rate_limit':
        return 'Too many attempts. Please wait a few minutes and try again.';
    }
  }
  return kGenericAuthErrorMessage;
}

/// Maps an error thrown by `updateUser` (setting a new password) to the
/// message shown on [SetPasswordScreen].
///
/// | Condition | Shown message |
/// | --- | --- |
/// | `AuthWeakPasswordException` | "Choose a stronger password: " + reasons |
/// | `same_password` | "Your new password must be different from the old one." |
/// | `session_expired` / `session_not_found` | "Your session has expired. Please sign in again." |
/// | anything else | [kGenericAuthErrorMessage] |
String mapUpdatePasswordErrorMessage(Object error) {
  if (error is AuthWeakPasswordException) {
    return 'Choose a stronger password: ${error.reasons.join(', ')}.';
  }
  if (error is AuthException) {
    switch (error.code) {
      case 'same_password':
        return 'Your new password must be different from the old one.';
      case 'session_expired':
      case 'session_not_found':
        return 'Your session has expired. Please sign in again.';
    }
  }
  return kGenericAuthErrorMessage;
}
