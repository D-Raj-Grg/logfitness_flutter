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
collection. Broader staff surface follows in later phases. **The web console remains the
primary surface for chain administration** — timetable editing, staff CRUD, and plan catalog
management are not mobile work in v1.

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
| Push | `firebase_messaging` | Consumes the Edge Function fanout. FCM vs. OneSignal is still open — see §10. |
| Session | `flutter_secure_storage` | Refresh token at rest. |
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
| `owner` | Staff shell | Manager capability across every branch in the org. Chain administration stays on the web console. |

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
payment_kind       payment | refund
invoice_status     unpaid | partial | paid | void
staff_role         owner | manager | front_desk | trainer
member_gender      male | female | other
```

**RPC surface — call these, do not reimplement:**

```
renew_membership      record_payment       refund_payment
freeze_membership     unfreeze_membership  cancel_membership
set_member_left       reactivate_member    current_staff
daily_collection(...) arrears_report(p_branch_id default null)
```

`current_staff()` is read instead of the `staff` table, because a fresh session may carry no
claims yet. A member-side `current_member()` equivalent does not exist and is Phase 0 work.

**Claims contract.** The Supabase access-token hook injects `{org_id, role, branch_ids[]}`.
The client reads them off the session, not off a table. A session created before the principal
row is linked carries no claims; the web console solves this with a link route plus a
refresh marker, and the app must handle the analogous state rather than looping.

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
                           classes, attendance)
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

- This repo is **empty**. No `pubspec.yaml`, no `lib/`, no platform folders, no git history. Nothing has been scaffolded.
- Toolchain installed globally: Flutter 3.38.7 stable (Dart 3.10.7). No fvm, no melos. No platform toggles set in `flutter config`.
- Git remote is decided but not yet wired: `https://github.com/D-Raj-Grg/logfitness_flutter.git`.
- Upstream backend is **mid-Phase-1**. The member spine (members, plans, memberships, invoices and payments, status derivation, RLS, RPCs, reports) is written as migrations in `logfitness_saas`, but the Phase 6 prerequisites this app depends on — member-scope RLS, `current_member()`, the member invite/link flow, the QR token Edge Function, push fanout — are **unbuilt**.
- Supabase project ref: `hefptanjhwxcuhikuhwd`, shared with the web console.

**Next task: Phase 0.** Phase 1 scaffolding can begin in parallel, but nothing in Phases 2+ is
buildable until the Phase 0 items land upstream.

---

## 10. Open questions

- Nepali-language UI at launch, or English-only? Sharper here than on the staff console — members are not trained users.
- Is the home branch binding for billing, or can any branch collect a renewal? Determines whether the staff shell needs a branch picker at payment time.
- How much staff parity actually belongs on mobile? Phases 5 and 6 are scoped on an assumption that can be revisited.
- Push provider: FCM directly, or OneSignal? Affects the Edge Function fanout contract upstream.
- Do trainers get PT-session tooling in v1, or is the trainer shell read-only?
- Phone OTP login for members — deferred; revisit once an SMS gateway is chosen. Invite/email is the v1 path.
