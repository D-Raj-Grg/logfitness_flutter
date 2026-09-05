# Lord of Gyms Mobile

Flutter app for gym members and staff. Same Supabase project as the staff web console
(`../logfitness_saas`). No separate backend.

Start here: `CLAUDE.md` → `PLANNING.md` → `TASKS.md`.

## Run

```sh
flutter run \
  --dart-define=SUPABASE_URL=https://<ref>.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=<key>
```

Keys are never committed. Copy them from the console's `.env.local`.
