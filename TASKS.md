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

Untouched. `lib/features/member/member_shell.dart` is a `TODO(phase-3)` and
nothing in `lib/` calls `mint_qr_token`, `book_class_session` or reads
`class_sessions`; `firebase_messaging` is in `pubspec.yaml` with zero
references behind it. The whole of the parity programme went first, so this
is the largest remaining block of work in the app — and the half that has a
backend waiting for it (Phase 0 is complete).

- [ ] Home: plan status, expiry date, days remaining, dues outstanding (reads `members.status`, never computes it)
- [ ] Payment history — invoices with status, payments with method and kind; refunds render as negative rows
- [ ] QR check-in screen — mint a token from the Edge Function, render it, auto-refresh on expiry
- [ ] Class browsing — upcoming `class_sessions` at the home branch, capacity shown
- [ ] Self-booking and cancellation via the Phase 0 booking RPC; optimistic UI with rollback on failure
- [ ] My bookings list
- [ ] Profile — name, phone, home branch; read-only in v1
- [ ] Push registration — write device token on login, delete on sign-out; foreground and background receipt. **Deferred on purpose on 2026-09-12**, when the rest of the notification surface shipped (see "Notifications parity" below): push needs a Firebase project, `google-services.json`/`GoogleService-Info.plist`, an iOS push entitlement, a `POST_NOTIFICATIONS` permission and `FCM_SERVICE_ACCOUNT_JSON` set in the Supabase dashboard — none of which the SMS half needed, and the last of which nobody on this machine can set.
- [ ] Member Messages history — a member may already read their own `notification_messages` (the policy shipped with `20260905150200_member_scope_rls.sql`, whose comment says "the Flutter app gets the history for free"). Not built with the staff notification work, because `member_shell.dart` is still a stub: the first member screen should be plan status, not a message log, and building this one first would set the member shell's navigation as a side effect of a staff feature.

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
- [x] **B. Visitors + register.** Visitor log (list, filter by status/branch/
      date, phone lookup), log a walk-in, edit, mark contacted/lost, and convert
      via `convert_visitor` into a prefilled `register_member` including the
      optional sale block. Shipped 2026-09-09. Not walked in a browser or on a
      device -- see the unchecked item below, which is the same gap Phase 3 and
      Phase 5 carry on the console side.
- [x] **C. Members read.** List with search, filters and pagination (archived
      excluded by default); detail with membership, invoice, payment and
      attendance history; photo display via signed URLs. Two of those did not
      land: **attendance** has no repository in `lib/data/`, so that tab says
      so rather than inventing a query (see Discovered), and **photos** stay
      deferred with the rest of the photo work in sub-project F -- the list and
      the profile render without one.
- [x] **D. Sales.** `renew_membership`, `record_payment`, today's collection
      sheet via `daily_collection`.
- [x] **E. Lifecycle.** `freeze_membership`, `unfreeze_membership`,
      `cancel_membership`, `set_member_left`, `reactivate_member`,
      `adjust_membership_dates`, `refund_payment`, `reverse_payment`. Role-gated
      per PLANNING.md §4: front desk sees neither refund nor cancel -- and the
      hidden button is UX only, the refusal still comes from the database.
- [x] **F. Admin.** Member edit (including `notifications_opt_out`, which
      nothing on this side read before), archive/restore, invite-to-app.
      **Photo capture and upload did not land** and was ticked here in error
      on 2026-09-10 — there is no `lib/data/photos/`, no signed-URL minting,
      and no capture anywhere; corrected 2026-09-11. That leaves the app with
      no member faces at all, on a check-in surface where a face is the point
      (see Discovered, 2026-09-10).

## Announcements (decided 2026-09-18)

The console's broadcast composer comes to this app: one message to every member
and every open walk-in, filtered by branch, by member status and by how recently
a visitor came in. Scoped as full parity with `/announcements` — compose, live
audience count, credit estimate, test send, the list with its delivery
breakdown, cancel, and scheduling.

Two decisions taken while scoping it:

- **A tab inside Messages, not a sixth destination.** The delivery log and the
  announcements list answer adjacent questions about the same table, and the bar
  holds five. The destination gates on `requiresAny`, so the front desk reaches
  it through `sendAnnouncement` while owner and manager reach it through either.
- **The front desk may announce.** This overturns the rule the upstream feature
  shipped with two days earlier, and the pgTAP comment that argued for it. The
  person standing at the door on the morning the gym is shut is the one who
  knows; the reach did not widen with the role, because
  `announcement_branch_scope` bounds a desk to its own branches and
  `jwt_can_announce()` refuses a desk that has none. Migration
  `20260918100000_announcement_front_desk.sql`, with the console's three role
  gates relaxed to match.

- [x] **M. Announcements.** Two enums (`announcement_audience`,
      `announcement_status`) plus `AnnouncementState` on the view model;
      `AnnouncementOverview`, `AnnouncementAudienceCount`, the query value
      objects and `AnnouncementsRepository` with one method per console export;
      the list, audience-count and send controllers; a second live-refresh
      poller; the composer screen, the list tab, the tile, the badge and the
      stop dialog; `MessagesScreen` with the keep-alive wrapper; and
      `StaffCapability.sendAnnouncement`.
- [x] **N. The `announcement` enum value.** Not part of the feature and more
      urgent than it: upstream added it to `notification_event` on 2026-09-17
      and the Dart mirror was not updated, so the first broadcast sent from the
      console would have stopped every row of the delivery log from parsing —
      in a build that was already in App Store review. Build 7 was pulled from
      review because of it.
- [x] **O. The three acknowledgements (2026-09-20).** `member_welcome`,
      `payment_received` and `dues_cleared`, added upstream in
      `20260920100000`. Mirrored *before* anything can emit one rather than
      after an incident: their rules seed disabled, so the console's checkbox
      is what starts them, and this build has to be on phones before a gym
      ticks it. Enum, both label forms, `kEditableTemplateEvents`, the rule
      titles, `kTemplateVariables` and its sample values. `NotificationRule.isDues`
      is gone — the floor and the cadence stopped being the same question when
      the receipt gained a floor and no cadence, so it is `hasMinAmount` and
      `hasRepeat` now, mirroring the console's own split.

### Discovered

- `find.byType(FilledButton)` does not match `FilledButton.icon`, which builds a
  private subclass; `find.byWidgetPredicate` does. Cost an afternoon of a test
  that looked like a missing button.
- A `@riverpod` notifier read with `container.read(p.notifier)` and no listener
  is disposed at the next `await`, and the following read silently builds a
  fresh one. A test that mutates a notifier then awaits has to `container.listen`
  first, or it is asserting against a brand-new default.

## Notifications parity (decided 2026-09-12)

The console's whole notification surface comes to this app. That is a scope
decision taken on 2026-09-12 and it overrides two earlier lines: `CLAUDE.md`'s
"Scope discipline" and `PLANNING.md` §4 both said notification gateway
configuration stayed on the web console. It does not.

Cheap for the same reason the staff parity programme was cheap: **nothing
server-side changes.** Phase 5 upstream put the entire pipeline in Postgres
(pg_cron + pg_net, no Edge Function, no Next.js runtime) precisely so a second
client could reuse it, and `logfitness_saas/lib/db/notifications.ts` is 519
lines of thin wrappers over tables and RPCs that are already gate-tested. So
this is a port, not a design.

Decisions taken while scoping it, so they are not re-litigated:

- **Push is out of scope this round.** Deliberate, not forgotten — see Phase 3.
- **Polling, not realtime.** The console polls every 8s while anything is in
  flight and gives up after 15 minutes. Nothing in this app uses Supabase
  Realtime, and `notification_messages` is not in the realtime publication, so
  a subscription here would be the app's first with no supporting pattern. Two
  mobile-only additions: the poller pauses while the app is backgrounded (a
  phone in a pocket must not burn a query every 8s for a quarter of an hour)
  and refreshes once on resume, which is the web's `window.focus` listener.
- **The member-facing half is deferred to Phase 3**, where it belongs.
- **Repository mirrors `lib/db/notifications.ts` one-for-one**, same method
  names in the same order, for the same reason sub-projects A–F did: parity is
  only auditable if the correspondence is mechanical.

```
G. Foundation --+--> H. Delivery log
  (blocking)    +--> I. Manual send
                +--> J. Settings
                +--> L. Docs (last)
```

- [x] **G. Foundation.** Four enums (`notification_channel`, `notification_event`,
      `notification_provider` as `NotificationProviderKind`, `notification_status`);
      `NotificationMessage`, `NotificationProvider`, `NotificationRule`,
      `NotificationTemplate` and the preview/balance rows; `NotificationsRepository`
      with one method per console export; `smsSegments` in `lib/domain/format/`;
      the label maps; the status badge and the row tile; and three capabilities —
      `sendMemberMessage` (front desk and up, transcribed from
      `member_message_target`, which refuses a trainer), `viewNotificationLog`
      (manager and owner) and `configureNotifications` (owner only).
- [x] **H. Delivery log.** The Messages destination: summary chips, filters,
      keyset scroll, resend and cancel, and the 8s live refresh. The poller
      pauses while the app is backgrounded and refreshes once on resume, which
      the console has no equivalent of and a phone needs.
- [x] **I. Manual send.** Send SMS from the member profile, the member list row,
      the visitor log and the visitor profile; and the profile's Messages tab.
      Bottom sheets rather than dialogs -- a keyboard, a five-line body and a
      reason picker do not fit a phone dialog.
- [x] **J. Settings.** Owner-only: gateway per channel with its write-only Vault
      token, the reminder rules, and the template editor with its segment counter.
      Four channel states, not the console's three: *active row, no token* reads
      as **No token yet**, because calling it Connected would be a lie and
      calling it Not set up would discard the row.
- [x] **L. Docs.** `PLANNING.md`, `CLAUDE.md`, this file and
      `../logfitness_saas/TASKS.md`.

Shipped 2026-09-12. Gates: `dart run build_runner build` with a clean
`git diff` on the generated sources, `flutter analyze`, `dart run custom_lint`
and `flutter test` -- 696 tests, all green. **Not walked on a device**, which is
the same gap Phases 3 and 5 carry. What it has *not* been run against is a
phone; the backend half is live and proven -- the project carries an active
SMSPasal gateway with a Vault-held token, carrier-split sender IDs
(`sender_ntc` / `sender_ncell`), and ten messages already delivered with
`provider_status` 200. So these screens will open on real rows rather than an
empty state, and `../logfitness_saas/docs/notifications.md` §4's "not proven"
list is out of date for SMSPasal (see the Discovered note upstream).

## Phase 4 — Staff front desk

Ticked 2026-09-11 against the code, not from memory: the staff parity
sub-projects B–F built most of this phase on their way past it, and the boxes
were never came back to. Scan-to-confirmation timing is still unmeasured —
nothing here has run on a device (see Discovered, 2026-09-09).

- [x] Scan check-in via `mobile_scanner` verifying against the token RPC (`lib/features/attendance/scan_check_in_screen.dart`; `verify_qr_token` then `check_in_member`, because verifying is not checking in). Built as RPCs, not an Edge Function — see Phase 0. **≤3s not yet measured.**
- [x] Manual check-in fallback by phone search — `lib/features/attendance/check_in_screen.dart`, and it is the default surface with the scanner behind a button
- [x] Check-in result surfaces plan status and dues so the desk can act on an expired or owing member — dues render on the row *before* the check-in, not only in the result banner
- [x] Collect payment via `record_payment` — `lib/features/payments/record_payment_screen.dart`
- [x] Walk-in member signup — `lib/features/members/register_member_screen.dart`; phone-unique-per-org handled through `AppFailure`
- [x] Invite member to the app by email from member detail — `lib/features/members/member_admin_panel.dart`. **Not offered from walk-in signup**; that half is unbuilt
- [x] Renew via `renew_membership` — `lib/features/payments/renew_membership_screen.dart`
- [x] Today's collection sheet via `daily_collection`, grouped by method — `lib/features/payments/collection_sheet_screen.dart`, mounted as the Collection destination
- [ ] Every mutation shows the audit-visible actor (the signed-in staff member) before confirming — nothing reads `currentStaff` in a confirm dialog; the shell names the role in its chrome and that is all

## Phase 5 — Staff member management

Shipped by sub-projects C, D and E; ticked 2026-09-11 against the code.

- [x] Member search and list (phone, name); status chips from `member_status` — `lib/features/members/member_list_screen.dart`, labels pinned to the console's wording by `member_labels.dart`
- [x] Member detail — membership history, invoices, payments, attendance. All four tabs are live; attendance reads `lib/data/attendance/`
- [x] Freeze / unfreeze via `freeze_membership` / `unfreeze_membership` — `lib/features/memberships/membership_action_panel.dart`
- [x] Cancel via `cancel_membership`; mark left via `set_member_left`; reactivate via `reactivate_member`
- [x] Refund via `refund_payment` — reason required, renders as a negative payment — `lib/features/memberships/refund_payment_screen.dart`
- [x] Arrears list via `arrears_report`, filterable by branch — `lib/features/payments/arrears_screen.dart`, ageing buckets read off the row. It was built and then reachable from nothing for a day; mounted on the Reports destination 2026-09-11
- [x] Branch switcher in the staff shell, options limited to `branch_ids[]` from claims — selection exposed as `branchScopeProvider`; an owner's empty claim reads as org-wide, matching the RLS policies. Branch *names* still need a `branches` repository; the switcher shows shortened ids until one lands (see Discovered).
- [x] Role gating in the UI matches `PLANNING.md` §4 (front desk cannot see refund or cancel) — `StaffCapability` is the single declarative table; nav destinations and, once they exist, actions are derived from it. UX only: the database refuses independently and `FailureView` renders that refusal.

## Phase 6 — Staff reports and admin

- [ ] Branch and chain collection reports, read-only, date-ranged. `daily_collection` is today-only today; a ranged report is the new part
- [ ] Expiring-soon and arrears dashboards for managers and owners. **Arrears half is done** (Phase 5) and is what the Reports destination opens on; expiring-soon is not built, and when it lands Reports becomes an index with both behind it
- [ ] Plan catalog view (read-only; editing stays on the web console)
- [ ] Class and trainer schedule view (read-only; editing stays on the web console)
- [ ] Trainer shell — own upcoming sessions and attendance marking, if answered yes in Open questions

## Phase 7 — Release

- [ ] App icon and splash for iOS and Android
- [ ] Bundle ids, signing configs, keystore handling outside the repo. `applicationId` is set; release still builds with `signingConfig = debug`
- [ ] Permission strings — camera (QR scan) is in `ios/Runner/Info.plist` already, notifications is not (and nothing requests them yet — see Phase 3 push)
- [ ] iOS privacy manifest and App Store review prerequisites
- [ ] Crash reporting and basic analytics
- [ ] Semantic versioning + build number bump in CI
- [ ] TestFlight and Play internal-track pipelines
- [ ] Store listing copy and screenshots

## Discovered

<!-- Format: - [ ] **YYYY-MM-DD** What was found and what to do about it -->

- [ ] **2026-09-12** Two deliberate deviations from the console in the
      notification settings, both recorded so a reviewer does not read them as
      drift. (1) The dues rule's minimum amount is capped at 10,000,000
      **paisa** (Rs 100,000) where the console caps its *rupee* input at
      10,000,000 -- the console's ceiling is a hundred times larger than any
      gym's dues and is almost certainly a units slip upstream. (2) The Send
      test body is generic where the console interpolates the gym's name: the
      claims on this app's token carry `org_id` and no org name, and fetching
      one to write a test message is not worth a round trip. Both want a
      decision rather than a fix.

- [x] **2026-09-12** Review of the notification port found six real defects,
      all fixed with a regression test each. Worth keeping because four of them
      are shapes that will recur: (1) **postgrest-dart's `.order()` defaults to
      *descending***, where supabase-js and PostgREST default to ascending --
      the rules list rendered upside-down, and the same bare `.order()` was
      already reversing the member list (Z-A), the plan catalog and the branch
      list. Every `.order()` in `lib/data/` is now explicit. (2) **A write
      notifier nobody watches is auto-disposed after one frame**, so an RPC
      that outlives a frame resumed on a dead `Ref`: Send again, Cancel and the
      one-tap visitor welcome all performed the write and then told the desk
      nothing -- or told them "nothing was saved" about a write that happened.
      Both notifiers are now `keepAlive`. (3) **`invalidateSelf` blanks the
      list**, because `AsyncValueView` renders a spinner for an `AsyncLoading`
      that carries a value; the eight-second poll was throwing a scrolled
      reader back to the top. `refresh()` now re-reads every loaded page in one
      widened request and writes the state directly. (4) **`loadMore` had no
      generation guard**, so a page in flight when a filter changed was
      appended to the new list. (5) The log's first query was fetched before
      the branch scope reached the filter. (6) The search field's clear button
      was rebuilt off the wrong thing.

- [ ] **2026-09-12** Two deliberate divergences from the console, recorded so
      they read as decisions rather than drift. (1) Switching a gateway away
      from "Another gateway" **clears** the stored `endpoint_url`; the console
      preserves it behind a hidden input. An address belonging to a gateway the
      gym no longer uses is not worth carrying, but the two clients do leave
      different rows behind. (2) The template editor writes `is_active: true`
      and `updated_by` on every save, matching the console -- that one was a
      divergence and is now fixed; noted here because the upsert's
      "only the keys you send" behaviour is the trap underneath it.

- [ ] **2026-09-12** The delivery log cannot name who pressed Send.
      `notification_messages.created_by` is a staff id and there is no staff
      repository in `lib/data/` -- `current_staff()` answers only for the
      signed-in person, so there is nothing that turns another staff id into a
      name. `NotificationTile` takes a `senderName` and is passed null, with a
      `TODO(notifications)` at the call site. The console shows the name, so
      this is a real parity gap rather than a deliberate simplification. It
      wants a `lib/data/staff/` repository over a staff-name read that RLS
      already allows (`is_org_member(org_id) and jwt_is_staff()`), which is the
      same thing a future staff-administration screen would need.

- [ ] **2026-09-12** `package:fake_async` is in `pubspec.lock` only as a
      transitive dependency of `flutter_test`, so importing it trips
      `depend_on_referenced_packages` and `flutter analyze` is a merge gate. The
      live-refresh tests inject the clock instead
      (`notificationPollIntervalProvider` / `notificationPollGiveUpProvider`,
      overridden to milliseconds). That is arguably the better test anyway, but
      if a later timer test wants real fake-async, the fix is one line in
      `dev_dependencies`.

- [x] **2026-09-05** `path_provider_foundation` >= 2.5.0 pulls `objective_c`, whose native build hooks make `dart compile aot-snapshot` fail — which is how both `build_runner` and `custom_lint` compile their entrypoints, so codegen and linting broke outright. Pinned to 2.4.1 in `dependency_overrides` with the reason in a comment. Revisit once the Flutter/Dart toolchain supports build hooks in `dart compile`.
- [x] **2026-09-05** Android `compileSdk`/`targetSdk` pinned to 36 in `android/app/build.gradle.kts`. Flutter 3.38 defaults to 37, which only ships as the preview platform `android-37.0`; AGP looks up the exact hash string `android-37` and the build fails. Unpin once a stable 37 platform is installable.
- [ ] **2026-09-05** No IANA timezone database is in the stack, so `lib/domain/format/dates.dart` models org timezones as fixed UTC offsets (`Asia/Kathmandu` = +05:45, exact — Nepal has no DST). Adding a DST-observing org later means adding the `timezone` package to `PLANNING.md` §2 first.
- [x] **2026-09-05** Date-only Postgres columns (`joined_on`, `left_on`, `date_of_birth`, `start_date`, `end_date`, `issued_on`) are modelled as `DateTime`; `toJson` writes a full ISO timestamp. Harmless while these are read-only, but needs a date-only converter before the app ever writes one. — Closed 2026-09-09: `PlainDateConverter` now covers `memberships.start_date`/`end_date`/`frozen_on` and `invoices.issued_on` as well as the member columns, and every date-only RPC argument goes over the wire through `plainDateToWire`.
- [ ] **2026-09-05** `Override` is not exported by flutter_riverpod 3.1.0, so test override lists must stay untyped literals. Remove the workaround if a later riverpod re-exports it.
- [ ] **2026-09-05** Auth deep link redirect `com.gymtross.app://login-callback` (see README.md "Deep links", `lib/supabase/auth_deep_links.dart`) needs to be added to the Supabase dashboard's Auth → URL Configuration → Redirect URLs allow-list for project `hefptanjhwxcuhikuhwd`. Cannot be done from this machine — the Supabase CLI is not logged in. Until someone with dashboard access adds it, invite/recovery emails will not open this app; treat the platform-side wiring as unverified end-to-end until confirmed.
- [x] **2026-09-09** `PaymentKind` in `lib/domain/enums/postgres_enums.dart` is missing `reversal`. The live `public.payment_kind` enum is `{payment, refund, reversal}` — `reverse_payment` has inserted rows with that kind since `20260907120500_reverse_payment.sql`. Any `payments` row or `daily_collection` row carrying it throws out of `fromJson`, so `PaymentsRepository.listPaymentsForMember` and `dailyCollection` fail outright for an org that has ever reversed an entry. Add the value (`@JsonValue('reversal') reversal('reversal')`) and a case for it wherever the kind is rendered. Not fixed here because `lib/domain/**` was out of scope for the data-layer task. — Fixed 2026-09-09. The more useful half is why it survived: the enum's round-trip test asserted the list `['payment', 'refund']`, which is the values the enum happened to have rather than the values `public.payment_kind` declares, so the test passed for two days while the app could not read its own data. It now checks the set both ways.
- [ ] **2026-09-09** The console's `setMemberLeft` (`logfitness_saas/lib/db/memberships.ts`) passes two arguments, but the live `set_member_left` takes three: `p_member_id, p_reason, p_left_on date`. The console can therefore only ever record a departure as the org's today. Mobile passes the third argument optionally; the console should too, or the argument should be dropped upstream.
- [ ] **2026-09-09** `daily_collection` and `arrears_report` return `TABLE(...)`, but the console's `dailyCollection`/`arrearsReport` return the generated `Json` type with no row model. Mobile models them (`DailyCollectionRow`, `ArrearsRow` in `lib/data/payments/payment_rpc_results.dart`); `arrears_report.bucket` is plain `text` from the function, not a Postgres enum, so it is carried as a `String` on both sides.
- [ ] **2026-09-09** `register_member`'s `hint` (`'member'` or `'sale'`, which half of the transaction refused) is not surfaced by PostgREST on a `PostgrestException`, so the Flutter caller cannot land the error on the right form field the way the console's Server Action does. Either move the discriminator into the message text upstream, or accept that mobile shows one combined error.

- [x] **2026-09-09** The branch switcher can only show ids. Claims carry `branch_ids[]` and nothing else, and there is no `branches` repository in this app, so `branchNamesProvider` (`lib/features/staff/branch_scope.dart`) resolves to an empty map and the switcher degrades to `Branch 3f2504e0`. Back it with a `lib/data/branches/` repository mirroring the console's `lib/db/branches.ts` and the switcher needs no other change. An owner's claim is empty by design (empty `branch_ids` means the whole org to the RLS policies), so that repository is also the only way an owner ever gets a *per-branch* option rather than "All branches". — Closed: `lib/data/branches/` landed with sub-project C and `branchNamesProvider` resolves through it.
- [x] **2026-09-09** `lib/features/members/member_lookup_panel.dart` renders its error state as `Text('Lookup failed: $error')` — the exact shape `AppFailure` and `FailureView` exist to prevent, since a `42501` refusal there is indistinguishable from any other error and carries no distinct treatment. Fixed 2026-09-09 rather than deferred to sub-project C: the panel is mounted as the Members destination today, so it was the one live screen in the app that could show a refusal as an unreadable `toString()`. It now renders through `AsyncValueView`. Still open there: the row renders `member.status.wire`, the raw enum value, where the console shows a label — that wants a `MemberStatusBadge` alongside the visitor one, in sub-project C.

- [x] **2026-09-10** There is no attendance data layer. `lib/data/` has
      members, memberships, payments, plans, branches and visitors, and nothing
      that reads `attendance`; the console's `listAttendanceForMember` and
      `AttendanceDetailRow` have no Dart counterpart. The member profile's
      fourth tab therefore says attendance is not available yet rather than
      rendering an empty list, because an empty tab reads as "never checked in"
      -- a different claim entirely. Wants `lib/data/attendance/` before the
      check-in work in Phase 4. — Closed by `ebe9cc7`: `lib/data/attendance/`
      ships the repository, `AttendanceDetail` and the check-in RPC results,
      and the fourth tab renders real visits. The stub's doc comment outlived
      the stub by a day and was corrected 2026-09-11.

- [x] **2026-09-11** An owner could not sell anything from the app. `branchOptionsProvider`
      (`lib/features/staff/branch_scope.dart`) returned the `branch_ids[]` claim verbatim, and
      an owner's is *empty* because empty means "the whole org" to the RLS policies. With no
      options, the register form never resolved a home branch, so it queried no plans and the
      Plan dropdown was empty with no error — and submitting refused with "this session has no
      branch". Fixed by mirroring the console's `resolveBranchScope` (`lib/scope.ts`): an
      org-wide session is offered every branch it can read, from `branchesProvider`; everyone
      else keeps the claim, and never touches that read.
- [x] **2026-09-11** Every discounted sale from the app was rejected by the database.
      `register_member` and `renew_membership` have required a discount reason since
      `20260910130100_discount_reason_rpcs.sql` (`check_violation` without one), and neither
      Flutter repository sent `p_discount_reason`/`p_discount_note`. Both now do, and both
      screens ask for the reason — and the free-text note when it is `other` — exactly when a
      discount is present, the way `member-sale-fields.tsx` does.
- [x] **2026-09-11** The sale forms had no paid/part/unpaid choice, so the quickest path
      through them (type the price, tap Register) recorded a payment that may never have
      happened — the defect the console fixed with `PaymentStatusChoice`. Ported as
      `lib/features/common/payment_status_choice.dart`, with the console's amount behaviour:
      full refills and locks the amount, unpaid clears it and raises the invoice in full, part
      leaves it to the cashier. The transaction reference is now required only when the rail
      is not cash *and* money actually moved.
- [x] **2026-09-11** `DropdownButtonFormField` replaced by `PickerField`
      (`lib/features/common/picker_field.dart`) on the register and renew forms. The Material
      dropdown's overlay covered most of the form with an unlabelled, edge-to-edge list with
      no mark on the current value; the sheet says what it is asking, marks the selection, and
      has room for the plan's term and price beside its name.
- [x] **2026-09-11** The joining-fee waiver the console prints on a sale had no counterpart
      here, because it needs the org's list fee and this app had no query for it. Added
      `lib/data/orgs/` (mirroring `lib/db/orgs.ts`) and `signupFeeSplit` in
      `lib/domain/format/plan_pricing.dart`; both sale summaries show the charged fee and the
      waived memo. The read degrades to zero, so a sale never waits on it.
- [x] **2026-09-11** `Form.validate()` only reaches *mounted* fields, and both sale forms are
      `ListView`s, which do not build what is off screen — so scrolling down to the submit
      button can unmount the field being validated. A discount with no reason passed
      validation that way and was refused by Postgres instead, reaching the desk as a failed
      registration rather than a missing answer. Both screens now check the sale's invariants
      in `_submit` (`_saleGap`), independently of what happens to be on screen. Anything else
      that relies on a validator in a long scrolling form has the same hole.

## Discovered — audit fixes (2026-09-05)

- [x] **2026-09-05** Adversarial audit of Phases 0–2 found six real defects; all fixed and covered by tests. In this repo: `/set-password` was exempt from the redirect guard unconditionally (a linked member was stranded there forever, and nothing ever navigated *to* it, so an invited member could be linked without ever setting a password); an error out of `principalProvider` — an unrecognised `staff_role` throws by design — rendered a blank splash with no way out; `PendingRefresh` routed into a shell whose stale token would have made every RLS-scoped read come back empty, with no refresh actually triggered; and `AppClaims` read a malformed claim set as "not linked yet", hiding a backend regression behind a friendly screen.
- [x] **2026-09-05** Backend fixes (in `logfitness_saas`): the member-photos storage policy still tested `is_org_member()` alone, so any member could download every other member's photo; `link_member_account()` did not check `email_confirmed_at`, so signing up with a member's address was enough to claim their record; `push-fanout` only branch-scoped the `branch_id` target, letting a single-branch front desk push arbitrary content to the whole chain; and `book_class_session` skipped `has_branch_access()` and accepted members whose derived status was `left` or whose session pack was spent.

- [ ] **2026-09-09** Sub-project B had never been run on a device.
      **Partly closed 2026-09-11: it runs.** `flutter run` on an iPhone 17 Pro
      simulator (iOS 26.2), `--dart-define-from-file=env/local.json`, Xcode
      build 43.8s, no errors; Supabase init completed and a session restored
      from secure storage, so it came up signed in as the seeded owner without
      a password being needed after all.
      **Seen working against live data:** the staff shell and its bottom nav;
      the check-in screen with its search and Scan FAB; the visitor log — 6 real
      walk-ins, "Needs a call" selected by default, filter chips, the count
      line, and `visited_on` rendering as the right calendar day; the member
      list — 24 members, the status-count strip (19 active / 5 expired / 10 with
      dues), NPR with Indian grouping, "Starts later" for `upcoming` (the
      console's word, so the label parity holds), and avatars falling back to
      initials. Two destinations with FABs coexisted with no hero assert, which
      is the shell fix holding.
      **Still unverified, and it is a lot:** every write path (nothing was
      logged, registered, paid or checked in), member detail and its five tabs,
      a real photo rendering through a signed URL (only one member in the org
      has one), and every role other than owner — the manager, front desk and
      trainer seed rows are `invited` with no auth user, so their shells cannot
      be reached at all. The front-desk gate changed on 2026-09-11 is therefore
      still untested on a device.
      **Why it stopped there:** driving the simulator needed hand-rolled
      coordinate mapping (`cliclick` plus an AppleScript window-geometry read).
      Bottom-nav taps worked; row taps and text entry did not land reliably.
      Going further wants a real driver — `integration_test` + `flutter drive`
      — which is its own task and is not in the stack table yet.
- [ ] **2026-09-09** `build_runner` in this repo takes **450-900s from a cold
      cache** and 4s warm. Two things made it worse and are worth knowing
      before someone concludes the toolchain is broken: agent worktrees created
      under `.claude/worktrees/` sit *inside* the package root, so the builder
      globs a full copy of the project per worktree; and killing a run
      mid-AOT leaves the build script to recompile from scratch next time. The
      worktree directory is now gitignored and removed. If it is slow again,
      check for nested checkouts before deleting `.dart_tool/build`.
- [x] **2026-09-09** The register screen's payment-method dropdown renders
      `PaymentMethod.wire` -- `esewa`, `fonepay` -- rather than display names.
      The console has proper labels. Wants the same treatment the visitor
      labels got (`visitor_labels.dart`, pinned to the console's wording by a
      test), extended to payment methods, member status and membership status,
      in sub-project C. Done 2026-09-10: `lib/features/members/member_labels.dart`
      covers member status, membership status, payment method, payment kind,
      invoice status and plan type, each pinned across the *whole* enum by
      `test/features/members/member_labels_test.dart`. The lookup panel's
      `member.status.wire` went with it.
- [ ] **2026-09-09** A member registered on either surface always starts opted
      **in** to automated messages, and nothing at the point of registration can
      change that. Closed on the edit side (`member_edit_screen.dart` carries
      the switch, and `updateMember` requires the argument rather than
      defaulting it). Still open at registration, and **checked 2026-09-11: the
      web console is identical** -- `components/members/member-form.tsx` renders
      the consent checkbox inside a `{member ? ...}` branch, so it appears only
      when editing, and `register_member` has no `p_notifications_opt_out`
      argument to carry it anyway. So this is a product gap on both surfaces,
      not a mobile parity gap, and fixing it only here would make the two
      disagree. The real fix is upstream: add the argument to the RPC (logged in
      `../logfitness_saas/TASKS.md`), then offer it on both forms. Until then,
      consent is collected after the fact, on the first edit.

- [ ] **2026-09-10** Two role gates in the mobile lifecycle panel are stricter
      than the console's and want a deliberate decision rather than drift.
      `staff_capabilities.dart` has no capability for *adjust membership dates*,
      so it was gated on `manageMembers` (manager and up), matching the
      console's own owner/manager gate -- free days are money. But the console
      lets a **front desk** mark a member as left, where our capability doc
      binds `set_member_left` to manager and up, so mobile is the more
      restrictive of the two. Pick one and make both surfaces agree.
- [ ] **2026-09-10** The staff shell mounts sibling `Scaffold`s, so every
      screen with a floating action button needs an explicit `heroTag` or
      Flutter asserts "multiple heroes share the same tag" -- and it throws in
      the running app, not only under test. Three screens hit it independently
      (check-in, the visitor log, the member list) and each was fixed at the
      call site. The shell-level fix is the real one.
- [ ] **2026-09-10** `AsyncValueView` has no way to pass an `icon` through to
      its `EmptyView`, so every empty state it renders is
      `Icons.inbox_outlined` unless the caller builds `EmptyView` by hand.
      Cosmetic, and easy.
- [ ] **2026-09-10** The renewal screen restates `renew_membership`'s
      `starts_on` logic in Dart to project the new period before it is written.
      It can disagree with the database when the device's date differs from
      `org_today`. It is labelled a projection on screen rather than hidden, but
      a `preview_renewal` RPC upstream would remove the duplication -- worth a
      `../logfitness_saas/TASKS.md` entry if it should go.
- [ ] **2026-09-10** `PaymentsRepository.listInvoicesForMember` and
      `MembershipsRepository.listInvoicesForMember` are byte-identical. The
      duplication is deliberate upstream and the comments say so, but two
      providers reading two copies can diverge later.
- [x] **2026-09-10** Member photos are still not rendered or captured anywhere.
      The console mints signed URLs (`memberPhotoUrls`) and there is no Dart
      equivalent of its `lib/db/photos`. Sub-project F shipped edit, archive,
      restore and invite **without** the photo half; capture at registration was
      deferred by an explicit decision, but display was not -- a member list
      with no faces is a worse check-in surface than the console's.
      — Closed 2026-09-11, display first. `lib/data/photos/` mirrors the
      console's module; the member list signs one batch of URLs per page rather
      than one request per row; the detail header and the check-in rows carry a
      face. Every failure along the way -- no photo, an expired signature, a
      dead network, a missing object -- lands on initials, because a face is
      worth having and never worth a broken screen.
      Capture followed, on the **edit** screen only and uploading the moment a
      photo is picked. The member already exists there, so a failed upload costs
      the photo and nothing else -- the same reasoning that kept capture out of
      registration. Needed `image_picker`, recorded in PLANNING §2 before
      pubspec as that file requires, with the reason it is downscaled on pick
      (the bucket caps an object at 5 MB and a phone camera clears that
      unaided). The iOS camera usage string was widened: it claimed the camera
      was for QR scanning only, which stopped being true here, and a purpose
      string that does not match what the app does is what App Review rejects.
      **Registration still takes no photo, deliberately.**

- [x] **2026-09-11** `arrears_screen.dart` was complete, tested and reachable
      from nothing: the Reports destination in `staff_destinations.dart` still
      carried `builder: null`, so managers and owners got
      `StaffPlaceholderScreen` over a finished screen. Wired 2026-09-11. Worth
      a habit rather than a fix — the destination table is the one place a
      screen becomes reachable, and a sub-project that builds a screen without
      touching it produces exactly this.

- [ ] **2026-09-11** `TASKS.md` drifted badly enough to be misleading: Phases 4
      and 5 read as 0/9 and 2/8 when the code had 8/9 and 8/8, sub-project F
      claimed photo work that does not exist, and three Discovered items
      described problems already fixed. Everything above is now ticked against
      the code. The rule that failed is the one at the top of this file --
      "mark tasks `[x]` the moment they are done" -- and it failed because the
      parity sub-projects each had their own plan and ticked *that*. A
      sub-project that crosses a phase should tick the phase too.

- [ ] **2026-09-11** The extended FAB occludes the status-and-money column of
      whatever row it floats over. Bottom padding was added to both lists on
      2026-09-11 and that fixes only the **last** row at full scroll; mid-list,
      "Register" still covers a member's status badge, dues and end date, and
      "Log walk-in" covers a visitor's status. Confirmed on a simulator, not
      inferred. The right-hand column is what a desk reads, so this is a
      legibility problem rather than a cosmetic one.
      Three ways out, none free: shrink to a circular FAB (less occlusion, but
      loses the label, which the design context argues against for a
      not-tech-sophisticated audience); move the action into the app bar (zero
      occlusion, worse one-handed reach at a counter); or dock a full-width
      button above the navigation bar (occludes nothing because the list pads
      for it, stays thumb-reachable, costs ~64px of list height permanently).
      The docked bar is the one to try first. Needs a decision, not a default.

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
