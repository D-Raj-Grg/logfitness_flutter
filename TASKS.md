# TASKS — Lord of Gyms Mobile

Check this before starting work. Mark tasks `[x]` the moment they are done.
Add newly discovered tasks under the phase they belong to, or under **Discovered**.
Context: `PLANNING.md` (architecture) · `../logfitness_saas/docs/PRD.md` (product) · `../logfitness_saas/TASKS.md` (backend backlog).

Phase 0 items live in the `logfitness_saas` repo. They are listed here because this app blocks on them; mark them `[x]` here when they land there.

---

## Phase 0 — Backend prerequisites

- [ ] Apply the Phase 1 member-spine migrations to the remote project and confirm `members`, `memberships`, `invoices`, `payments` exist with RLS enabled → logfitness_saas
- [ ] Backend: member invitation flow — staff invites a member by email, accept sets password and links `auth.users.id` to `members.auth_user_id` (mirror of the staff invite flow) → logfitness_saas
- [ ] Backend: link flow that populates `members.auth_user_id` from the accepted invitation (RPC or Edge Function; unique per org, never overwrites an existing link) → logfitness_saas
- [ ] Backend: `current_member()` RPC mirroring `current_staff()` — readable before claims exist → logfitness_saas
- [ ] Backend: access-token hook emits `{org_id, role: 'member', branch_ids[]}` for a member principal → logfitness_saas
- [ ] Backend: member-scope RLS policies — a member reads only their own `members`, `memberships`, `invoices`, `payments`, `attendance`, `class_bookings` rows — with a cross-tenant and cross-member negative test → logfitness_saas
- [ ] Backend: QR token mint/verify Edge Function (short-lived, member-bound, single-use) → logfitness_saas Phase 2
- [ ] Backend: class self-booking RPC with capacity check and cancellation window → logfitness_saas Phase 4
- [ ] Backend: `device_tokens` table + push fanout Edge Function → logfitness_saas Phase 5
- [ ] Backend: define the "authenticated but not yet linked" contract — what a member session sees between sign-in and `auth_user_id` link (analogue of the console's `/auth/link` + refresh marker) → logfitness_saas

## Phase 1 — App foundation

- [x] `flutter create` with org `com.lordofgyms`, project `logfitness_flutter`, platforms `ios,android` only
- [x] `git init`, first commit, push to `https://github.com/D-Raj-Grg/logfitness_flutter.git`
- [x] `.gitignore` covers `.env*`, `*.jks`, `GoogleService-Info.plist`, `google-services.json`
- [ ] Pin Flutter/Dart SDK constraint in `pubspec.yaml` (Flutter 3.38, Dart 3.10)
- [ ] `analysis_options.yaml` with `flutter_lints` + `custom_lint` + `riverpod_lint`; `flutter analyze` clean
- [ ] Add stack deps from `PLANNING.md` §2 — nothing outside the table
- [ ] `supabase_flutter` init reading URL and publishable key from `--dart-define` (never committed); document the run command in `README.md`
- [ ] Riverpod `ProviderScope` root + `sessionProvider` + `claimsProvider`
- [ ] `go_router` skeleton with a single redirect guard (unauthenticated → login)
- [ ] Layer folders per `PLANNING.md` §6 with a placeholder repository proving the widget → controller → repository → supabase chain
- [ ] freezed models + Dart enums for the member spine, values matched one-to-one to the Postgres enums; unknown value throws
- [ ] `Money` formatter ported from `../logfitness_saas/lib/format.ts` — paisa `int` in, `NPR` string out at the render boundary only; unit tests for rounding and negatives
- [ ] Date formatter using `orgs.timezone` (default `Asia/Kathmandu`), not the device zone
- [ ] Theme: light + dark, Material 3, brand tokens
- [ ] CI: `flutter analyze` + `flutter test` on every push

## Phase 2 — Auth and role shell

- [ ] Staff login — email + password, same accounts as the web console
- [ ] Member login — email + password; accept-invite deep link sets the password on first open
- [ ] Post-login link step calling the Phase 0 link flow, then refreshing the session so claims arrive (no redirect loop)
- [ ] "Not yet linked" screen — signed in but no `members` row is linked to this auth user
- [ ] Role router — `member` claim → member shell, any `staff_role` → staff shell, no claims → link step
- [ ] Session persisted in `flutter_secure_storage`; cold start restores without re-login
- [ ] Sign-out clears session, claims, and cached data
- [ ] Widget tests for every redirect branch of the guard

## Phase 3 — Member app

- [ ] Home: plan status, expiry date, days remaining, dues outstanding (reads `members.status`, never computes it)
- [ ] Payment history — invoices with status, payments with method and kind; refunds render as negative rows
- [ ] QR check-in screen — mint a token from the Edge Function, render it, auto-refresh on expiry
- [ ] Class browsing — upcoming `class_sessions` at the home branch, capacity shown
- [ ] Self-booking and cancellation via the Phase 0 booking RPC; optimistic UI with rollback on failure
- [ ] My bookings list
- [ ] Profile — name, phone, home branch; read-only in v1
- [ ] Push registration — write device token on login, delete on sign-out; foreground and background receipt

## Phase 4 — Staff front desk

- [ ] Scan check-in via `mobile_scanner` verifying against the token Edge Function (≤3s from scan to confirmation; optimistic success state)
- [ ] Manual check-in fallback by phone search
- [ ] Check-in result surfaces plan status and dues so the desk can act on an expired or owing member
- [ ] Collect payment via `record_payment` — method from the `payment_method` enum, amount entered in rupees and converted with `toPaisa` once
- [ ] Walk-in member signup — name, phone, gender, home branch; phone-unique-per-org error handled
- [ ] Invite member to the app by email from member detail and from walk-in signup
- [ ] Renew via `renew_membership` — plan picker from `membership_plans` available at the branch
- [ ] Today's collection sheet via `daily_collection`, grouped by method
- [ ] Every mutation shows the audit-visible actor (the signed-in staff member) before confirming

## Phase 5 — Staff member management

- [ ] Member search and list (phone, name); status chips from `member_status`
- [ ] Member detail — membership history, invoices, payments, attendance
- [ ] Freeze / unfreeze via `freeze_membership` / `unfreeze_membership`
- [ ] Cancel via `cancel_membership`; mark left via `set_member_left`; reactivate via `reactivate_member`
- [ ] Refund via `refund_payment` — reason required, renders as a negative payment
- [ ] Arrears list via `arrears_report`, filterable by branch
- [ ] Branch switcher in the staff shell, options limited to `branch_ids[]` from claims
- [ ] Role gating in the UI matches `PLANNING.md` §4 (front desk cannot see refund or cancel)

## Phase 6 — Staff reports and admin

- [ ] Branch and chain collection reports, read-only, date-ranged
- [ ] Expiring-soon and arrears dashboards for managers and owners
- [ ] Plan catalog view (read-only; editing stays on the web console)
- [ ] Class and trainer schedule view (read-only; editing stays on the web console)
- [ ] Trainer shell — own upcoming sessions and attendance marking, if answered yes in Open questions

## Phase 7 — Release

- [ ] App icon and splash for iOS and Android
- [ ] Bundle ids, signing configs, keystore handling outside the repo
- [ ] Permission strings — camera (QR scan), notifications
- [ ] iOS privacy manifest and App Store review prerequisites
- [ ] Crash reporting and basic analytics
- [ ] Semantic versioning + build number bump in CI
- [ ] TestFlight and Play internal-track pipelines
- [ ] Store listing copy and screenshots

## Discovered

<!-- Format: - [ ] **YYYY-MM-DD** What was found and what to do about it -->

## Open questions

- [ ] Nepali-language UI at launch, or English-only? (bites harder on the member shell)
- [ ] Is the home branch binding for billing, or can any branch collect a renewal?
- [ ] How much staff parity belongs on mobile — is Phase 6 worth building, or does the console stay sole surface?
- [ ] Push provider — FCM directly, or OneSignal? Affects the upstream fanout contract
- [ ] Do trainers get PT-session tooling in v1, or a read-only shell?
- [ ] Phone OTP member login — deferred until an SMS gateway is chosen; invite/email is v1
