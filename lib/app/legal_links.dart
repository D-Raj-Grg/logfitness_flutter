// The hosted pages the app has to be able to point at, in one place.
//
// App Store review and Play Data safety both ask for these as URLs, and the
// same URLs have to be reachable from inside the app: a store listing that
// promises an account can be deleted, with no way to start that from the
// phone, is the rejection this file exists to avoid.
//
// They live here rather than inline in Settings so the store metadata, the
// release checklist (README, "Publishing") and the screen all quote the same
// strings.
library;

/// Where the pages are published. A GitHub Pages site rather than the gym's
/// own domain: it is static, it has no login, and review has to be able to
/// open it without an account.
const String legalBaseUrl = 'https://d-raj-grg.github.io/legal/gymtross';

/// What is collected and why. Required by both stores.
const String privacyPolicyUrl = '$legalBaseUrl/privacy.html';

/// The terms the gym agrees to. Apple's standard EULA applies unless an app
/// supplies its own; this is that one.
const String termsUrl = '$legalBaseUrl/terms.html';

/// How to reach a human. Apple requires a support URL on every listing.
const String supportUrl = '$legalBaseUrl/support.html';

/// How to have an account and its data deleted.
///
/// Apple has required a way to initiate deletion *from inside the app* since
/// 2022 for anything that creates an account, and Play asks for this URL in
/// the Data safety form. Staff and member accounts here are created by the
/// gym, not self-signup, so the path is a request rather than a button that
/// destroys rows -- the page says who to ask and what happens.
const String deleteAccountUrl = '$legalBaseUrl/delete-account.html';
