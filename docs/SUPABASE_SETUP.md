# Supabase setup (Phase 6)

The iOS app connects to the **existing web-app Supabase project** so accounts and
progress are shared across web, Android, and iOS. To wire it up I need the items
below; the app builds and runs fully without them today (auth is a mock until
Phase 6).

## What I need from you

1. **Project URL + anon key** — from the existing project
   (Supabase dashboard → Project Settings → API). These go into a **gitignored**
   `Secrets.xcconfig` (copy `Secrets.example.xcconfig`):
   ```
   SUPABASE_URL = https:/$()/<your-ref>.supabase.co
   SUPABASE_ANON_KEY = <anon-key>
   ```
2. **Progress table shape** — the table + columns the web app uses for per-unit
   progress (so iOS reads/writes the same rows). If you're unsure, share the
   table name and I'll match it; the app currently mirrors the web `eceuh:progress`
   shape (`unit_key`, `status`, `user_id`).
3. **Apple Developer Team ID + bundle id** — for the Sign in with Apple
   capability (default bundle id `edu.uh.eceuh`). Sign in with Apple can only be
   validated on a real device signed into iCloud.
4. **Google provider** — confirm Google is enabled in the Supabase dashboard
   (Authentication → Providers → Google) with an iOS redirect URL; I'll register
   the matching custom URL scheme in `Info.plist`.

## Deploy the account-deletion Edge Function

In-app account deletion (App Store requirement) calls a server-side function so
the **service-role key never ships in the app**. Source is in
`supabase/functions/delete-account/`.

```bash
supabase login
supabase link --project-ref <your-ref>
supabase functions deploy delete-account
```

The function reads `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` from the Edge
runtime automatically. The client sends the user's session JWT so a caller can
only delete their own account.

## What Phase 6 will add in the app

- `supabase-swift` Swift Package dependency.
- `SupabaseManager` (configured client from `AppConfig`).
- `AuthService`: email/password, Sign in with Apple (`ASAuthorizationController`
  → `signInWithIdToken`), Google (`signInWithOAuth` via `ASWebAuthenticationSession`),
  sign-out, and `deleteAccount()` (progress rows → Edge Function → sign out).
- Real `SignInScreen` + an auth gate.
- `ProgressService` cloud sync (pull on sign-in, write-through on change).
