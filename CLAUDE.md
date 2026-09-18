# Lord of Gyms Mobile — session rules

## Start of every conversation

1. **Read `PLANNING.md` first.** It holds the architecture, stack, role model, and conventions. Do not propose or write code before reading it.
2. **Read `TASKS.md` before starting work.** Pick up the current phase. Do not skip ahead to a later phase without an explicit instruction.
3. **Mark tasks `[x]` in `TASKS.md` the moment they are complete** — not at the end of the session.
4. **Add newly discovered tasks to `TASKS.md`** as you find them, under the phase they belong to or under **Discovered**.

Product context lives in `../logfitness_saas/docs/PRD.md`. The backend contract lives in
`../logfitness_saas/PLANNING.md`. Read them when scope, schema, or priority is in question.

## Hard rules

- **The database is not ours.** Schema changes belong in `logfitness_saas`, applied through Supabase MCP `apply_migration`. This repo never writes a migration. If the app needs a column, a policy, or an RPC, add the task to `../logfitness_saas/TASKS.md` first and build against it once it lands.
- **RLS is the tenant boundary.** Never hand-filter by `org_id` in Dart as a security measure. A query that returns the right rows only because of a client-side filter is a bug — fix the policy, not the query.
- **Money is integer paisa in `int`.** Convert to a decimal exactly once, in the formatter at the render boundary — never in queries, totals, or business logic. Dart mirror of `../logfitness_saas/lib/format.ts`.
- **Multi-table writes go through the existing Postgres RPCs**, never a sequence of `supabase.from(...)` calls: `renew_membership`, `record_payment`, `refund_payment`, `freeze_membership`, `unfreeze_membership`, `cancel_membership`, `set_member_left`, `reactivate_member`, plus the report functions `daily_collection` and `arrears_report`, and the notification surface: `enqueue_notification`, `send_member_notification`, `send_visitor_notification`, `retry_notification`, `cancel_notification`, `set_notification_credential` and `clear_notification_credential`. `notification_messages` has **no client write policy at all** — every write to it is one of those RPCs.
- **Never set `members.status`.** It is trigger-derived in the database. Writing it from the client is always wrong.
- **Financial history is append-only.** Renewals insert a new `memberships` row; refunds are negative `payments` rows with a reason. The app never deletes or edits a payment.
- **Models are generated, not hand-written.** `freezed` + `json_serializable` off the Supabase schema, regenerated after any migration lands in the SaaS repo. Dart enum values must match the Postgres enums exactly.
- **Run `build_runner` after touching any annotated file.** Riverpod, freezed, and go_router codegen share it; a stale `.g.dart` fails in confusing ways.
- **Flutter 3.38 / Dart 3.10 differ from training data.** Verify the current API before writing. Do not assume pre-3.x idioms, and heed deprecation notices from `flutter analyze`.
- **Role gates the shell, RLS gates the data.** Client-side role checks are UX only. Never treat a hidden button as an access control.

## Scope discipline

v1 excludes: card-on-file/Stripe recurring billing, member web self-service, POS and
inventory, payroll/HR, biometric hardware, workout program builder, exercise library,
body-composition tracking, marketing/CRM, accounting integrations. Mobile adds one of its
own: **offline-first is deferred, not solved** — aggressive caching and optimistic check-in
UI only, no local write queue. That rule survived contact with the cash drawer on
2026-09-09 and is not a placeholder: `register_member` and `record_payment` are not
idempotent, so a replay queue needs idempotency keys added upstream before it is even
discussable. Do not build these without an explicit scope decision.

**Chain administration** was a third exclusion until 2026-09-09, when the staff half of
this app was scoped to full parity with the web console (see `TASKS.md`, "Staff parity
programme"). Member, membership, payment, plan and visitor management all belong here now.
What is still console-only is **branch and staff administration** — creating branches,
inviting staff, setting roles and branch assignments.

**Notifications came here on 2026-09-12**, and that is a second scope decision, taken
explicitly: the delivery log, the gateway configuration, the reminder rules, the gym's own
message wording, and sending one member or one walk-in a message by hand all live in this
app now. Earlier copies of this file said gateway configuration stayed on the console; they
are out of date. What did **not** come with it is push — `firebase_messaging` is still in
`pubspec.yaml` with nothing behind it, and `TASKS.md` Phase 3's push item is unchecked on
purpose, not by omission.
