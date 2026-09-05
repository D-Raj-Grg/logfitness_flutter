# Lord of Gyms — Mobile

One Flutter binary, two role shells (member and staff), speaking `supabase_flutter` to the same
Supabase project that backs the staff web console in `../logfitness_saas`. There is no separate
backend and no bespoke API — RLS is the tenant boundary.

- Architecture contract: [`PLANNING.md`](PLANNING.md)
- Work queue: [`TASKS.md`](TASKS.md)
- Session rules: [`CLAUDE.md`](CLAUDE.md)
- Product context: `../logfitness_saas/docs/PRD.md`

## Toolchain

Flutter 3.38.7 / Dart 3.10.7, installed globally. No fvm, no melos. iOS and Android only.

```bash
flutter pub get
dart run build_runner build
```

Run `build_runner` again after touching any annotated file — riverpod, freezed, and go_router
share it, and a stale `.g.dart` fails in confusing ways.

## Configuration

The Supabase URL and publishable key are never committed. They arrive as compile-time
constants via `--dart-define-from-file`:

```bash
cp env/local.example.json env/local.json   # then fill in the publishable key
flutter run --dart-define-from-file=env/local.json
```

`env/*.json` is gitignored apart from the example. The equivalent single-flag form works too:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://hefptanjhwxcuhikuhwd.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=...
```

Startup asserts both are present and fails loudly with the flag names if they are not.

## Checks

`flutter analyze` clean is a merge gate. CI runs the same four commands on every push:

```bash
dart run build_runner build
flutter analyze
dart run custom_lint
flutter test
```

## Layout

```
lib/app/            router, theme, role shell, bootstrap
lib/supabase/       client, session, claims
lib/data/<module>/  repository + generated models
lib/domain/         formatters, enums, shared value types
lib/features/<mod>/ screens, widgets, controllers
test/               mirrors lib/ one-to-one
```

A repository is the only thing that touches `supabase`. Controllers call repositories; widgets
call controllers.

## Rules that bite

- **Money is integer paisa in `int`.** Converted to a decimal exactly once, in the formatter at
  the render boundary.
- **The database is not ours.** Schema changes are migrations in `logfitness_saas`; this repo has
  no `supabase/` directory.
- **Never write `members.status`.** It is trigger-derived.
- **Multi-table writes go through the Postgres RPCs**, never a sequence of `from(...)` calls.
