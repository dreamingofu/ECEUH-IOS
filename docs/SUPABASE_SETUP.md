# Supabase setup (Phase 6)

The iOS app connects to the **existing web-app Supabase project**
(`bnbpuhixxsjhrxkxvddh`) so accounts and progress are shared across web,
Android, and iOS.

## Status — what's wired (and verified)

- `supabase-swift` package added; `SupabaseManager` builds the client from
  `AppConfig` (URL + anon key via `Secrets.xcconfig` → Info.plist).
- `AuthService`: email/password (sign in + sign up), Sign in with Apple, Google
  (OAuth via `ASWebAuthenticationSession`), sign-out, session restore, and
  in-app `deleteAccount()`.
- `SignInScreen` + an **auth gate** (sign-in is presented until you sign in or
  choose "Explore without signing in"). `ProgressService` syncs to the
  `progress(user_id, course, status)` table (pull on sign-in, write-through).
- **Verified on-device:** the app reaches the live project and the embedded anon
  key authenticates (a bogus sign-in returns GoTrue's "Invalid login
  credentials").

Discovered from the live project: providers **email ✓** and **google ✓** are
enabled, **apple ✗** is not; tables `progress(user_id, course, status,
updated_at)` and `profiles(id, username, display_name, avatar_url, created_at)`
exist; **email confirmation is required** for new sign-ups.

## Local credentials

Copy `Secrets.example.xcconfig` → `Secrets.xcconfig` (gitignored). It's already
set locally to this project's URL + anon key. Format note: the `$()` splits the
`//` so xcconfig doesn't treat it as a comment.

## Remaining manual steps (need your dashboard / Apple account)

1. **Enable Sign in with Apple** — it's currently OFF in the Supabase dashboard
   (Authentication → Providers → Apple). The App Store **requires** Apple once
   you offer Google. After enabling it server-side, the app also needs the
   *Sign in with Apple* capability wired (set `CODE_SIGN_ENTITLEMENTS =
   ECEUH/ECEUH.entitlements` and a Development Team in the project) — give me your
   **Apple Team ID** and I'll wire it.
2. **Google redirect URL** — add `eceuh://login-callback` to the Auth redirect
   allow-list (Authentication → URL Configuration → Redirect URLs) so the Google
   flow can return to the app.
3. **Deploy the account-deletion Edge Function** (in-app delete calls it so the
   service-role key never ships in the app):
   ```bash
   supabase login
   supabase link --project-ref bnbpuhixxsjhrxkxvddh
   supabase functions deploy delete-account
   ```
   Source: `supabase/functions/delete-account/`.
4. **(Optional, for testing email auth on the simulator)** email confirmation is
   on, so a fresh sign-up won't get a session until the emailed link is clicked.
   You can turn on "auto-confirm" temporarily, or test with a confirmed account.
