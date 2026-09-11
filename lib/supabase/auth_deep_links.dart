/// The redirect URL Supabase Auth uses to bring the user back into this app
/// after an invite, recovery, or magic-link email is opened.
///
/// This is a custom URL scheme, not a universal/app link: `scheme` matches
/// the Android `applicationId` in `android/app/build.gradle.kts` and the
/// `CFBundleURLSchemes` entry in `ios/Runner/Info.plist`, and `host` matches
/// the Android intent filter's `android:host`. The three must be changed
/// together.
///
/// `supabase_flutter` 2.17 bundles its own `app_links`-based observer
/// (`SupabaseAuth` in the package internals) and picks up the incoming URL
/// automatically the moment the OS hands it to the app — there is no
/// `getInitialUri`/stream-listening code to write here. This constant only
/// needs to be *passed* to the auth call that generates the link, and the
/// platform manifests only need to know how to route it back to the app.
///
/// **Still required, and not something this repo's CLI access can do:** the
/// Supabase project's Auth → URL Configuration allow-list
/// (dashboard project `hefptanjhwxcuhikuhwd`) must include this exact URL.
/// A redirect URL Supabase does not recognise is silently ignored and the
/// email link falls back to the project's default site URL, so this is
/// unverified until someone with dashboard access adds it. See the
/// "Deep links" section of `README.md`.
const kAuthRedirectUrl =
    'com.gymtross.app://login-callback';

/// Passes [kAuthRedirectUrl] as the `emailRedirectTo` / `redirectTo`
/// argument of a Supabase Auth call that sends an email the user opens on
/// this device.
///
/// Use it at the call site rather than inlining the constant, e.g.:
///
/// ```dart
/// await Supabase.instance.client.auth.resetPasswordForEmail(
///   email,
///   redirectTo: kAuthRedirectUrl,
/// );
/// ```
///
/// Member invitations in this app are sent by staff from the web console's
/// `invite_member` RPC, not from this client — this helper exists for any
/// mobile-initiated email flow this app adds later (password reset,
/// re-sending a magic link, OTP-by-email), so the redirect stays in one
/// place instead of being retyped at each call site.
String authRedirectUrl() => kAuthRedirectUrl;
