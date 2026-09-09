# TASKS — Lord of Gyms Mobile

Check this before starting work. Mark tasks `[x]` the moment they are done.
Add newly discovered tasks under the phase they belong to, or under **Discovered**.
Context: `PLANNING.md` (architecture) · `../logfitness_saas/docs/PRD.md` (product) · `../logfitness_saas/TASKS.md` (backend backlog).

Phase 0 items live in the `logfitness_saas` repo. They are listed here because this app blocks on them; mark them `[x]` here when they land there.

---

## Phase 0 — Backend prerequisites

- [x] Apply the Phase 1 member-spine migrations to the remote project and confirm `members`, `memberships`, `invoices`, `payments` exist with RLS enabled → logfitness_saas
- [x] Backend: member invitation flow — staff invites a member by email, accept sets password and links `auth.users.id` to `members.auth_user_id` (mirror of the staff invite flow) → logfitness_saas
- [x] Backend: link flow that populates `members.auth_user_id` from the accepted invitation (RPC or Edge Function; unique per org, never overwrites an existing link) → logfitness_saas
- [x] Backend: `current_member()` RPC mirroring `current_staff()` — readable before claims exist → logfitness_saas
- [x] Backend: access-token hook emits member claims → logfitness_saas. Shipped as `{org_id, member_id, branch_ids: [home_branch_id]}`: there is no `role` claim, because PostgREST reads that one to pick the Postgres role for the request. Principal type is read off `member_id` vs `staff_role`.
- [x] Backend: member-scope RLS policies — a member reads only their own `members`, `memberships`, `invoices`, `payments`, `attendance`, `class_bookings` rows — with a cross-tenant and cross-member negative test → logfitness_saas
- [x] Backend: QR token mint/verify — built as Postgres RPCs (`mint_qr_token`, `verify_qr_token`), not an Edge Function: the project secret an Edge Function needs cannot be set from this tooling. Short-lived and member-bound; **not single-use** — replay inside the 90s window is stopped by the duplicate same-day check-in guard instead → logfitness_saas
- [x] Backend: class self-booking RPC with capacity check and cancellation window → logfitness_saas Phase 4
- [x] Backend: `device_tokens` table + push fanout Edge Function → logfitness_saas Phase 5 — table, RLS and RPCs tested; the FCM send path is unverified until `FCM_SERVICE_ACCOUNT_JSON` is set in the dashboard
- [x] Backend: define the "authenticated but not yet linked" contract — what a member session sees between sign-in and `auth_user_id` link (analogue of the console's `/auth/link` + refresh marker) → logfitness_saas

## Phase 1 — App foundation

- [x] `flutter create` with org `com.lordofgyms`, project `logfitness_flutter`, platforms `ios,android` only
- [x] `git init`, first commit, push to `https://github.com/D-Raj-Grg/logfitness_flutter.git`
- [x] `.gitignore` covers `.env*`, `*.jks`, `GoogleService-Info.plist`, `google-services.json`
- [x] Pin Flutter/Dart SDK constraint in `pubspec.yaml` (Flutter 3.38, Dart 3.10)
- [x] `analysis_options.yaml` with `flutter_lints` + `custom_lint` + `riverpod_lint`; `flutter analyze` clean
- [x] Add stack deps from `PLANNING.md` §2 — nothing outside the table
- [x] `supabase_flutter` init reading URL and publishable key from `--dart-define` (never committed); document the run command in `README.md`
- [x] Riverpod `ProviderScope` root + `sessionProvider` + `claimsProvider`
- [x] `go_router` skeleton with a single redirect guard (unauthenticated → login)
- [x] Layer folders per `PLANNING.md` §6 with a placeholder repository proving the widget → controller → repository → supabase chain
- [x] freezed models + Dart enums for the member spine, values matched one-to-one to the Postgres enums; unknown value throws
- [x] `Money` formatter ported from `../logfitness_saas/lib/format.ts` — paisa `int` in, `NPR` string out at the render boundary only; unit tests for rounding and negatives
- [x] Date formatter using `orgs.timezone` (default `Asia/Kathmandu`), not the device zone
- [x] Theme: light + dark, Material 3, brand tokens
- [x] CI: `flutter analyze` + `flutter test` on every push

## Phase 2 — Auth and role shell

- [x] Staff login — email + password, same accounts as the web console
- [x] Member login — email + password; accept-invite deep link sets the password on first open
- [x] Post-login link step calling the Phase 0 link flow, then refreshing the session so claims arrive (no redirect loop)
- [x] "Not yet linked" screen — signed in but no `members` row is linked to this auth user
- [x] Role router — routes on `principalProvider`: `member_id` claim → member shell, `staff_role` → staff shell, neither → link step, still resolving → splash, and a linked-but-stale token renders its shell while the refresh lands rather than parking on `/link`
- [x] Session persisted in `flutter_secure_storage`; cold start restores without re-login
- [x] Sign-out clears session, claims, and cached data
- [x] Widget tests for every redirect branch of the guard

## Phase 3 — Member app

- [ ] Home: plan status, expiry date, days remaining, dues outstanding (reads `members.status`, never computes it)
- [ ] Payment history — invoices with status, payments with method and kind; refunds render as negative rows
- [ ] QR check-in screen — mint a token from the Edge Function, render it, auto-refresh on expiry
- [ ] Class browsing — upcoming `class_sessions` at the home branch, capacity shown
- [ ] Self-booking and cancellation via the Phase 0 booking RPC; optimistic UI with rollback on failure
- [ ] My bookings list
- [ ] Profile — name, phone, home branch; read-only in v1
- [ ] Push registration — write device token on login, delete on sign-out; foreground and background receipt

## Staff parity programme (decided 2026-09-09)

The staff half of this app is being built to **full parity with the web
console** -- all ~19 console routes and the 33 Server Actions behind them.
That is a scope decision taken on 2026-09-09, and it changes two rules written
here earlier: plan editing is no longer "web console only" (PLANNING.md §4's
"chain administration stays on the web console" now covers branch and staff
administration only), and `visitors` becomes a module of this app.

Parity is cheap in one specific way and expensive in another. Cheap: **every
RPC it needs already exists and is gate-tested upstream.** The console's
`lib/db/*.ts` is 1908 lines of thin wrappers around 37 Postgres functions, so
there is no business logic to re-derive -- CLAUDE.md's "keep logic the Flutter
app will need in the database" was actually honoured. Expensive: it is still
~19 screens. So it is decomposed into six sub-projects, each with its own
spec and plan:

```
A. Staff foundation  --+--> B. Visitors (+ register)
   (prerequisite)      |
                       +--> C. Members read --+--> D. Sales
                                              +--> E. Lifecycle
                                              +--> F. Admin
```

Decisions taken while scoping it, so they are not re-litigated:

- **Repositories mirror the console's `lib/db/*.ts` one-for-one** -- same
  function names, same RPCs. Parity across 37 RPCs is only auditable if the
  correspondence is mechanical. The one deliberate deviation is pagination:
  the console pages by `searchParams`, mobile wants keyset infinite scroll, and
  porting the offset pagination first to fix it later is worse than doing it
  once.
- **Register is pulled forward into B**, out of D. Converting a visitor *is*
  registering a member -- the console's own member form already takes a
  `visitorId` and prefills from it -- so a visitor log that cannot convert is
  the feature with its point removed.
- **The no-local-write-queue rule holds.** B takes cash, which is exactly when
  it would be tempting to break. It stays broken-loudly instead: a write with
  no connection says so and saves nothing. `register_member` and
  `record_payment` are not idempotent, so a replay queue would need
  idempotency keys added upstream first -- a separate scope decision, not a
  detail.
- **Member photo defers to F**, and is a separate action from registration when
  it lands, so a failed upload can never cost the member or the payment that
  was taken with them.

- [x] **A. Staff foundation.** Models regenerated against the live schema (the
      `Member` model was seven columns behind -- `archived_at`/`archived_reason`/
      `archived_by`, `invited_by`/`invited_at`/`accepted_at`,
      `notifications_opt_out` -- and the archive columns are the dangerous half,
      because a staff search that cannot see `archived_at` shows the desk people
      it has deliberately put away). Date-only converter shipped, closing the
      2026-09-05 Discovered item before the write that needed it. `AppFailure`
      maps Postgres error codes to sentences, and exists because the console
      shipped a swallowed `42501` on 2026-09-07 that made a refusal look like
      success. `visitor_kind`/`visitor_status` enums and the `Visitor` model.
- [ ] **B. Visitors + register.** Visitor log (list, filter by status/branch/
      date, phone lookup), log a walk-in, edit, mark contacted/lost, and convert
      via `convert_visitor` into a prefilled `register_member` including the
      optional sale block.
- [ ] **C. Members read.** List with search, filters and pagination (archived
      excluded by default); detail with membership, invoice, payment and
      attendance history; photo display via signed URLs.
- [ ] **D. Sales.** `renew_membership`, `record_payment`, today's collection
      sheet via `daily_collection`.
- [ ] **E. Lifecycle.** `freeze_membership`, `unfreeze_membership`,
      `cancel_membership`, `set_member_left`, `reactivate_member`,
      `adjust_membership_dates`, `refund_payment`, `reverse_payment`. Role-gated
      per PLANNING.md §4: front desk sees neither refund nor cancel -- and the
      hidden button is UX only, the refusal still comes from the database.
- [ ] **F. Admin.** Member edit, photo capture and upload, archive/restore,
      invite-to-app.

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
- [x] Branch switcher in the staff shell, options limited to `branch_ids[]` from claims — selection exposed as `branchScopeProvider`; an owner's empty claim reads as org-wide, matching the RLS policies. Branch *names* still need a `branches` repository; the switcher shows shortened ids until one lands (see Discovered).
- [x] Role gating in the UI matches `PLANNING.md` §4 (front desk cannot see refund or cancel) — `StaffCapability` is the single declarative table; nav destinations and, once they exist, actions are derived from it. UX only: the database refuses independently and `FailureView` renders that refusal.

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

- [x] **2026-09-05** `path_provider_foundation` >= 2.5.0 pulls `objective_c`, whose native build hooks make `dart compile aot-snapshot` fail — which is how both `build_runner` and `custom_lint` compile their entrypoints, so codegen and linting broke outright. Pinned to 2.4.1 in `dependency_overrides` with the reason in a comment. Revisit once the Flutter/Dart toolchain supports build hooks in `dart compile`.
- [x] **2026-09-05** Android `compileSdk`/`targetSdk` pinned to 36 in `android/app/build.gradle.kts`. Flutter 3.38 defaults to 37, which only ships as the preview platform `android-37.0`; AGP looks up the exact hash string `android-37` and the build fails. Unpin once a stable 37 platform is installable.
- [ ] **2026-09-05** No IANA timezone database is in the stack, so `lib/domain/format/dates.dart` models org timezones as fixed UTC offsets (`Asia/Kathmandu` = +05:45, exact — Nepal has no DST). Adding a DST-observing org later means adding the `timezone` package to `PLANNING.md` §2 first.
- [x] **2026-09-05** Date-only Postgres columns (`joined_on`, `left_on`, `date_of_birth`, `start_date`, `end_date`, `issued_on`) are modelled as `DateTime`; `toJson` writes a full ISO timestamp. Harmless while these are read-only, but needs a date-only converter before the app ever writes one. — Closed 2026-09-09: `PlainDateConverter` now covers `memberships.start_date`/`end_date`/`frozen_on` and `invoices.issued_on` as well as the member columns, and every date-only RPC argument goes over the wire through `plainDateToWire`.
- [ ] **2026-09-05** `Override` is not exported by flutter_riverpod 3.1.0, so test override lists must stay untyped literals. Remove the workaround if a later riverpod re-exports it.
- [ ] **2026-09-05** Auth deep link redirect `com.lordofgyms.logfitness_flutter://login-callback` (see README.md "Deep links", `lib/supabase/auth_deep_links.dart`) needs to be added to the Supabase dashboard's Auth → URL Configuration → Redirect URLs allow-list for project `hefptanjhwxcuhikuhwd`. Cannot be done from this machine — the Supabase CLI is not logged in. Until someone with dashboard access adds it, invite/recovery emails will not open this app; treat the platform-side wiring as unverified end-to-end until confirmed.
- [x] **2026-09-09** `PaymentKind` in `lib/domain/enums/postgres_enums.dart` is missing `reversal`. The live `public.payment_kind` enum is `{payment, refund, reversal}` — `reverse_payment` has inserted rows with that kind since `20260907120500_reverse_payment.sql`. Any `payments` row or `daily_collection` row carrying it throws out of `fromJson`, so `PaymentsRepository.listPaymentsForMember` and `dailyCollection` fail outright for an org that has ever reversed an entry. Add the value (`@JsonValue('reversal') reversal('reversal')`) and a case for it wherever the kind is rendered. Not fixed here because `lib/domain/**` was out of scope for the data-layer task. — Fixed 2026-09-09. The more useful half is why it survived: the enum's round-trip test asserted the list `['payment', 'refund']`, which is the values the enum happened to have rather than the values `public.payment_kind` declares, so the test passed for two days while the app could not read its own data. It now checks the set both ways.
- [ ] **2026-09-09** The console's `setMemberLeft` (`logfitness_saas/lib/db/memberships.ts`) passes two arguments, but the live `set_member_left` takes three: `p_member_id, p_reason, p_left_on date`. The console can therefore only ever record a departure as the org's today. Mobile passes the third argument optionally; the console should too, or the argument should be dropped upstream.
- [ ] **2026-09-09** `daily_collection` and `arrears_report` return `TABLE(...)`, but the console's `dailyCollection`/`arrearsReport` return the generated `Json` type with no row model. Mobile models them (`DailyCollectionRow`, `ArrearsRow` in `lib/data/payments/payment_rpc_results.dart`); `arrears_report.bucket` is plain `text` from the function, not a Postgres enum, so it is carried as a `String` on both sides.
- [ ] **2026-09-09** `register_member`'s `hint` (`'member'` or `'sale'`, which half of the transaction refused) is not surfaced by PostgREST on a `PostgrestException`, so the Flutter caller cannot land the error on the right form field the way the console's Server Action does. Either move the discriminator into the message text upstream, or accept that mobile shows one combined error.

- [ ] **2026-09-09** The branch switcher can only show ids. Claims carry `branch_ids[]` and nothing else, and there is no `branches` repository in this app, so `branchNamesProvider` (`lib/features/staff/branch_scope.dart`) resolves to an empty map and the switcher degrades to `Branch 3f2504e0`. Back it with a `lib/data/branches/` repository mirroring the console's `lib/db/branches.ts` and the switcher needs no other change. An owner's claim is empty by design (empty `branch_ids` means the whole org to the RLS policies), so that repository is also the only way an owner ever gets a *per-branch* option rather than "All branches".
- [x] **2026-09-09** `lib/features/members/member_lookup_panel.dart` renders its error state as `Text('Lookup failed: $error')` — the exact shape `AppFailure` and `FailureView` exist to prevent, since a `42501` refusal there is indistinguishable from any other error and carries no distinct treatment. Fixed 2026-09-09 rather than deferred to sub-project C: the panel is mounted as the Members destination today, so it was the one live screen in the app that could show a refusal as an unreadable `toString()`. It now renders through `AsyncValueView`. Still open there: the row renders `member.status.wire`, the raw enum value, where the console shows a label — that wants a `MemberStatusBadge` alongside the visitor one, in sub-project C.

## Discovered — audit fixes (2026-09-05)

- [x] **2026-09-05** Adversarial audit of Phases 0–2 found six real defects; all fixed and covered by tests. In this repo: `/set-password` was exempt from the redirect guard unconditionally (a linked member was stranded there forever, and nothing ever navigated *to* it, so an invited member could be linked without ever setting a password); an error out of `principalProvider` — an unrecognised `staff_role` throws by design — rendered a blank splash with no way out; `PendingRefresh` routed into a shell whose stale token would have made every RLS-scoped read come back empty, with no refresh actually triggered; and `AppClaims` read a malformed claim set as "not linked yet", hiding a backend regression behind a friendly screen.
- [x] **2026-09-05** Backend fixes (in `logfitness_saas`): the member-photos storage policy still tested `is_org_member()` alone, so any member could download every other member's photo; `link_member_account()` did not check `email_confirmed_at`, so signing up with a member's address was enough to claim their record; `push-fanout` only branch-scoped the `branch_id` target, letting a single-branch front desk push arbitrary content to the whole chain; and `book_class_session` skipped `has_branch_access()` and accepted members whose derived status was `left` or whose session pack was spent.

## Open questions

- [ ] Nepali-language UI at launch, or English-only? (bites harder on the member shell)
- [ ] Is the home branch binding for billing, or can any branch collect a renewal?
- [x] How much staff parity belongs on mobile — is Phase 6 worth building, or does the console stay sole surface?
      Answered 2026-09-09: **full parity**, both surfaces. See "Staff parity
      programme" above. The console is not retired; the two ship the same
      capabilities and the database stays the single boundary for both.
- [ ] Push provider — FCM directly, or OneSignal? Affects the upstream fanout contract
- [ ] Do trainers get PT-session tooling in v1, or a read-only shell?
- [ ] Phone OTP member login — deferred until an SMS gateway is chosen; invite/email is v1
