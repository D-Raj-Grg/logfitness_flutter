# PLANNING — Lord of Gyms Mobile

Read this at the start of every session. It is the architectural contract.
Product context: `../logfitness_saas/docs/PRD.md`. Backend contract: `../logfitness_saas/PLANNING.md`. Work queue: `TASKS.md`.

---

## 1. What this is

One Flutter binary, two role-shells, one Supabase project — the same Postgres that backs the
staff web console at `logfitness_saas`. There is no separate backend and no bespoke API: the
app speaks `supabase_flutter` to the same tables under the same RLS policies.

**Members** authenticate with email + password after accepting a staff-sent invitation —
the same invite mechanism the console uses for staff. Accepting links the Supabase auth user
to the existing `members.auth_user_id`. Phone OTP is deferred. Until this app ships, members are records in the system, not users.
They get plan status and dues, payment history, QR check-in, class booking, and push.

**Staff** authenticate with email and password using the same accounts as the web console.
Mobile owns the counter: scan check-in, collect payment, walk-in signup, renewals, today's
collection — and, since the parity decision of 2026-09-09, the rest of the member surface too:
the visitor log, the member list and detail, the membership lifecycle, refunds and reversals,
archiving, and member-app invitations. **What stays on the web console is branch and staff
administration** — creating branches, inviting staff, setting roles and branch assignments —
along with timetable editing and plan catalog management. **Notification gateway
configuration moved here on 2026-09-12** — see `TASKS.md`, "Notifications parity" — so the
whole messaging surface now lives on both clients: the delivery log, the gateway, the
reminder schedule, the gym's own wording, and sending one member or one walk-in a message
by hand. See `TASKS.md`, "Staff parity programme".

---

## 2. Stack

| Layer | Choice | Notes |
| --- | --- | --- |
| SDK | Flutter 3.38 / Dart 3.10 | Pin the constraint in `pubspec.yaml`. Installed globally; no fvm, no melos. |
| Backend | `supabase_flutter` | Auth, PostgREST, Realtime. Same project as the web console. No separate backend. |
| State + DI | `flutter_riverpod` + `riverpod_annotation` | Codegen providers. No global singletons, no service locator. |
| Routing | `go_router` | Typed routes with a single auth + role redirect guard. |
| Models | `freezed` + `json_serializable` | Generated off the Supabase schema. Never hand-written. |
| Codegen | `build_runner` | Shared by riverpod, freezed, and go_router. |
| QR | `mobile_scanner` | Staff scans; member screen renders the minted token. |
| Photos | `image_picker` | Camera or gallery, for the member photo. Added 2026-09-11. Downscaled and re-encoded on pick, because the `member-photos` bucket caps an object at 5&nbsp;MB and a phone camera clears that on its own. Not `camera`: this needs one still image with the system UI, not a viewfinder. |
| Push | `firebase_messaging` | Declared, and still with zero references behind it. FCM vs. OneSignal is still open — see §10 — and push was **explicitly deferred** when the rest of the notification surface landed on 2026-09-12. |
| Session | `flutter_secure_storage` | Refresh token at rest. |
| Preferences | `shared_preferences` | Non-secret settings that survive a restart — the theme choice today. Deliberately not `flutter_secure_storage`: a display preference is not a credential, and putting it in the keychain would blur where secrets live. |
| Formatting | `intl` | Money and dates. Locale and timezone come from `orgs`, not from the device. |
| Lints | `flutter_lints` + `custom_lint` + `riverpod_lint` | `flutter analyze` clean is a merge gate. |

Anything not in this table is undecided. Add it here before adding it to `pubspec.yaml`.

---

## 3. Architecture rules — non-negotiable

**Backend ownership.** The schema belongs to `logfitness_saas`. This repo contains no
`supabase/migrations/`, no SQL, and no seed data. A missing column is a task in the other
repo's backlog, not a workaround here.

**RLS is the boundary.** Every read is scoped by policy against the JWT claims
`{org_id, role, branch_ids[]}` set by the Supabase access-token hook. Client-side filtering is
for presentation only. A query that would leak across tenants if the filter were removed is a
policy bug and must be reported upstream, not patched in Dart.

**Money.** Integer paisa in `int`, end to end. Convert to a decimal exactly once, in the
formatter at the render boundary. Never in a query, a sum, a comparison, or a controller.
Currency comes from `orgs.currency` (default `NPR`), never hardcoded at a call site.

**Derived status.** `members.status` is recomputed by a database trigger. The app reads it and
never writes it. The same holds for anything else the database derives.

**Transactions via RPC.** A user action that touches more than one table calls the existing
Postgres RPC. Renewal is `renew_membership`, not an insert into `memberships` followed by an
insert into `invoices`. If an action has no RPC, the RPC is the first task, upstream.

**Append-only history.** Renewals insert. Refunds are negative `payments` rows carrying a
reason. The app exposes no path that deletes or edits a financial row.

**Generated types.** Model classes are produced from the schema and regenerated whenever a
migration lands upstream. Dart enums mirror the Postgres enums value-for-value; an unknown
value must fail loudly rather than silently fall through to a default.

**Role shell.** `go_router`'s redirect reads the `role` claim and routes to the member shell or
the staff shell. This is navigation, not authorization — the database decides what the session
can actually see.

**Offline stance.** Deferred, not solved. Cache reads aggressively and keep the check-in
interaction optimistic so the counter never blocks on the network. Do not build a local write
queue, a sync engine, or a local database in v1.

---

## 4. Roles

| Role | Surface | Capabilities |
| --- | --- | --- |
| `member` | Member shell | Own plan status, expiry, and dues. Own payment history. QR check-in. Browse and book classes. Introduced by this app — does not exist in the web console's role model. |
| `front_desk` | Staff shell | Check-in (scan and manual), collect payment, walk-in signup, renewals, today's collection. Scoped to assigned branches. |
| `trainer` | Staff shell | Own classes and sessions, attendance for them. Scoped to assigned branches. |
| `manager` | Staff shell | Everything front desk can do, plus member management, freezes, cancellations, refunds, and branch reports. Scoped to assigned branches. |
| `owner` | Staff shell | Manager capability across every branch in the org. Branch and staff administration — creating branches, inviting staff, setting roles and branch assignments — stay on the web console. Notification configuration — the gateway, the reminder rules and the templates — is owner-only here too, and the RLS policies on `notification_providers`, `notification_rules` and `notification_templates` say so independently of any gate in `staff_capabilities.dart`. Everything else reached parity on 2026-09-09; see `TASKS.md`, "Staff parity programme". |

Staff roles match the `staff_role` Postgres enum exactly. `member` is a distinct principal type
that reaches the database through its own RLS policies.

---

## 5. Data model

The schema is defined and owned upstream. **Source of truth: `../logfitness_saas/PLANNING.md` §5
and `../logfitness_saas/supabase/migrations/`.** Do not restate or fork it here. What the client
must know:

**Identity.** `members.phone` is unique per org — phone is the identity anchor in this market,
and stays the search key. Login is by invited email; phone OTP is deferred. `members.auth_user_id` is nullable and is the link this
app populates. `members.home_branch_id` sets the member's home branch.

**Postgres enums the client mirrors:**

```
member_status      active | expired | frozen | left
membership_status  upcoming | active | frozen | expired | cancelled
plan_type          time | session_pack
payment_method     cash | esewa | khalti | fonepay | bank | card
payment_kind       payment | refund | reversal
invoice_status     unpaid | partial | paid | void
staff_role         owner | manager | front_desk | trainer
member_gender      male | female | other

notification_channel   sms | viber | email
notification_event     renewal_reminder | dues_reminder | birthday_greeting |
                       staff_invite | test_message | custom_message |
                       visitor_welcome | visitor_follow_up | announcement |
                       member_welcome | payment_received | dues_cleared
notification_provider  sparrow_sms | aakash_sms | smspasal_sms |
                       viber_business | resend_email | custom_http | log_only
notification_status    queued | sending | sent | failed | cancelled | skipped
announcement_audience  members | visitors | both
announcement_status    scheduled | sending | cancelled
```

`announcement_overview.state` (`cancelled | scheduled | sending | sent`) looks
like one of these and is not: it is a `case` expression in the view, derived
from the outbox. It is mirrored as `AnnouncementState` in
`lib/data/announcements/announcement_overview.dart` rather than in
`postgres_enums.dart`, with the same throwing `fromDb`.

`notification_provider` is mirrored in Dart as `NotificationProviderKind`: the
Postgres enum and the `notification_providers` table share a name and Dart
cannot. `fromDb` throws on an unknown value **by design**, so adding a value to
any of these four upstream needs a client release before anything can emit it.

**RPC surface — call these, do not reimplement:**

```
register_member       renew_membership     record_payment
refund_payment        reverse_payment      adjust_membership_dates
freeze_membership     unfreeze_membership  cancel_membership
set_member_left       reactivate_member    archive_member
restore_member        invite_member        convert_visitor
check_in_member       check_out_member     in_gym_now
mint_qr_token         verify_qr_token      current_staff
daily_collection(...) arrears_report(p_branch_id default null)

enqueue_notification                 retry_notification
cancel_notification                  member_notification_preview
send_member_notification             visitor_notification_preview
send_visitor_notification            notification_template_preview
org_notification_locale              notification_has_credential
set_notification_credential          clear_notification_credential
request_notification_gateway_balance read_notification_gateway_balance

announcement_audience_count          send_announcement
send_announcement_test               cancel_announcement
```

The notification block landed on 2026-09-12 with `TASKS.md`'s "Notifications
parity"; the four announcement RPCs on 2026-09-18 with "Announcements". Three of
them are deliberately *not* callable from any client and are listed here only so
nobody goes looking: `notification_credential` (the Vault token itself),
`resolve_notification_template` (SECURITY DEFINER, for the cron sweeps, which
hold no claims) and `announcement_audience` (it takes an org id as an argument,
so a grant would hand any caller another gym's phone numbers).

All four announcement RPCs guard on `jwt_can_announce()` — owner, manager and a
front desk that has a branch of its own. That predicate is what
`StaffCapability.sendAnnouncement` transcribes; the Dart set is a copy of the
database's rule and never the source of it.

Seventeen of these, plus the fourteen notification RPCs above and the four
notification tables behind them, now have a **second consumer**. Changing an argument list or
a returned shape breaks a shipped app that updates on a store's schedule rather
than on deploy; the corresponding note lives in
`../logfitness_saas/TASKS.md`. Adding an argument with a default is safe;
reordering or renaming is not.

`current_staff()` is read instead of the `staff` table, because a fresh session may carry no
claims yet. A member-side `current_member()` equivalent does not exist and is Phase 0 work.

**Claims contract.** The Supabase access-token hook injects `{org_id, branch_ids[]}` plus a
principal marker: `staff_role` (and `staff_id`) for staff, `member_id` for members. It does **not**
set a `role` claim — that one belongs to PostgREST, which reads it to choose the Postgres role for
the request, and overwriting it breaks every authenticated call. Principal type is therefore read
off which marker is present, never off `role`.
The client reads them off the session, not off a table. A session created before the principal
row is linked carries no claims; the web console solves this with a link route plus a
refresh marker, and the app must handle the analogous state rather than looping.

**Not-yet-linked contract.** A session exists in three states and the app must render all three
without looping:

| State | How it is detected | Where it lands |
| --- | --- | --- |
| No session | `sessionProvider` is null | `/login` |
| Signed in, not linked | Session present, no `member_id` / `staff_role` claim, and `current_member()` / `current_staff()` both return nothing | `/link` — offers to claim a pending invitation via `link_member_account()`, then refreshes the session so claims arrive |
| Linked | Claims present, or the `current_*` RPC returns a row | Member shell or staff shell |

`current_member()` and `current_staff()` are security-definer RPCs precisely so they can be read
before claims exist. Linking only takes effect after `refreshSession()`, so the link step must
refresh once and then re-evaluate rather than redirect blindly — the web console solves the same
problem with `/auth/link` plus a short-lived refresh marker cookie, and the app carries a marker in
memory for the same reason. An account that refreshes and still has no claims stays on `/link` with
an explanation; it never bounces.

**Formatting inputs.** `orgs.currency` (default `NPR`) and `orgs.timezone` (default
`Asia/Kathmandu`) drive all money and date rendering. Mirror `../logfitness_saas/lib/format.ts`
as a Dart formatter; do not change formatting behaviour on the database side.

---

## 6. Conventions

**Files.** Layer-first, with a module axis inside each layer — the Dart analogue of the web
console's `lib/db/<module>.ts` / `lib/validation/<module>.ts` split, not folder-per-feature.

```
lib/main.dart
lib/app/                  router, theme, role shell, bootstrap
lib/supabase/             client, session, claims
lib/data/<module>/        repository + generated models
                          (members, memberships, payments, plans,
                           classes, attendance, visitors)
lib/domain/               formatters, enums, shared value types
lib/features/<module>/    screens, widgets, controllers
test/                     mirrors lib/ one-to-one
```

A repository is the only thing that touches `supabase`. Controllers call repositories; widgets
call controllers. A widget that builds a PostgREST query is a review failure.

**Naming.** Postgres stays `snake_case` plural. Dart is `lowerCamelCase` for members,
`UpperCamelCase` for types, `snake_case.dart` for filenames. Generated `*.g.dart` and
`*.freezed.dart` are committed. Riverpod providers are named for what they provide, not for
their mechanism — `currentMemberProvider`, not `memberFutureProvider`.

**Git.** Branch off `main` per phase task. Conventional Commits. No secrets in the tree —
Supabase URL and publishable key arrive via `--dart-define`, and any `.env` is gitignored.
Remote: `https://github.com/D-Raj-Grg/logfitness_flutter.git`.

---

## 7. Delivery phases

Ordered and sequential. Do not skip ahead without an explicit instruction.

0. **Backend prerequisites** — member RLS, `current_member()`, member invite + link flow, QR token and push Edge Functions. Lives in `logfitness_saas`; blocks everything here.
1. **App foundation** — scaffold, repo, lints, Supabase client, router skeleton, Riverpod root, generated models, money formatter, CI.
2. **Auth and role shell** — staff email/password, member invite accept + email/password, claims handling, the role router, session persistence.
3. **Member app** — plan and dues, payment history, QR check-in, class browsing and booking, push.
4. **Staff front desk** — scan check-in, manual fallback, collect payment, walk-in signup, renewals, today's collection.
5. **Staff member management** — search, detail, freeze/cancel/reactivate, arrears, refunds, branch switcher.
6. **Staff reports and admin** — read-only reports, plan catalog view, schedule view. Web console stays primary.
7. **Release** — icons, store pipelines, crash reporting, versioning, review prerequisites.

---

## 8. Out of scope for v1

Card-on-file and Stripe recurring billing · member web self-service · POS and inventory ·
payroll and HR · biometric hardware · workout program builder · exercise library ·
body-composition tracking · marketing and CRM · accounting integrations · offline-first write
sync · chain administration on mobile (timetable editing, staff CRUD, plan catalog CRUD).

---

## 9. Current state (2026-09-05)

- **Phases 0, 1 and 2 are complete.** 85 tests pass, `flutter analyze` and
  `dart run custom_lint` are clean, and the debug APK builds.
- Phase 0 landed upstream in `logfitness_saas`: `invite_member` / `link_member_account` /
  `current_member`, member claims from the access-token hook, member-scope RLS with negative
  tests, QR mint/verify as Postgres RPCs, the class schema with self-booking and waitlist
  promotion, and `device_tokens` plus a `push-fanout` function.
- Phase 1: pinned SDK, stack deps, strict lints, Supabase client with the session in the
  keychain, Riverpod root, generated models and enums, money and date formatters, theme, CI.
- Phase 2: one login for both principals, the invite deep link and set-password screen, the
  link step, the not-linked screen, and a role router driven by `principalProvider`.
- Two things are built but unverifiable from this machine, both needing the Supabase
  dashboard: the deep-link redirect URL (`com.gymtross.app://login-callback`)
  must be added to Auth → URL Configuration, and `FCM_SERVICE_ACCOUNT_JSON` must be set before
  push can send anything.
- `path_provider_foundation` is pinned to 2.4.1 and Android `compileSdk` to 36 — see TASKS.md
  **Discovered** for why.
- Supabase project ref: `hefptanjhwxcuhikuhwd`, shared with the web console.

**Next task: Phase 3, the member app** — plan status and dues, payment history, QR check-in,
class browsing and booking, push. Every backend piece it needs is now in place.

## 10. Open questions

- Nepali-language UI at launch, or English-only? Sharper here than on the staff console — members are not trained users. Partly answered by the notification work: **message** wording is already bilingual, because `notification_templates` is keyed by locale and the app renders whatever `org_notification_locale` resolves to. The app's own chrome is still English.
- Is the home branch binding for billing, or can any branch collect a renewal? Determines whether the staff shell needs a branch picker at payment time.
- How much staff parity actually belongs on mobile? Phases 5 and 6 are scoped on an assumption that can be revisited.
- Push provider: FCM directly, or OneSignal? Affects the Edge Function fanout contract upstream. Deferred again on 2026-09-12: the SMS/Viber/email half of notifications shipped without it, because that half needs no Firebase project, no native configuration and no `FCM_SERVICE_ACCOUNT_JSON` — all three of which push still waits on.
- Do trainers get PT-session tooling in v1, or is the trainer shell read-only?
- Phone OTP login for members — deferred; revisit once an SMS gateway is chosen. Invite/email is the v1 path.
