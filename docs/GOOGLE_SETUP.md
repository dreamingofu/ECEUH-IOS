# Google sync — setup

The planner has two Google-facing features:

1. **Calendar sync (works out of the box).** Toggling **Add to Calendar** on a
   planner event writes it to the device calendar via EventKit. If the user has
   added their Google account under **iOS Settings → Calendar → Accounts**, iOS
   syncs those events to Google Calendar automatically (CalDAV). No app-side
   Google configuration is required — only the calendar permission prompt, whose
   copy lives in `Info.plist` (`NSCalendarsFullAccessUsageDescription`).

2. **Gmail scan (needs a Google OAuth client ID).** *Planner → Scan Gmail for
   dates* signs the user in with Google (read-only `gmail.readonly` scope), reads
   recent quiz/exam/deadline emails, and proposes planner dates to add. This uses
   OAuth 2.0 with PKCE via `ASWebAuthenticationSession` and the Gmail REST API
   directly — **no third-party SDK**. It stays disabled until a client ID is set.

## Enabling the Gmail scan

1. In the [Google Cloud Console](https://console.cloud.google.com/), create (or
   reuse) a project and **enable the Gmail API** (APIs & Services → Library →
   Gmail API → Enable).
2. Configure the **OAuth consent screen** (External is fine for testing; add your
   own account as a test user). Add the scope
   `https://www.googleapis.com/auth/gmail.readonly`.
3. Create an **OAuth client ID** of type **iOS**. Bundle ID: `edu.uh.eceuh`.
   Google issues a client ID like `NNN-xyz.apps.googleusercontent.com`; no client
   secret is used (public client + PKCE).
4. Copy `Secrets.example.xcconfig` → `Secrets.xcconfig` (gitignored) and set:

   ```
   GOOGLE_OAUTH_CLIENT_ID = NNN-xyz.apps.googleusercontent.com
   ```

5. Rebuild. `AppConfig.googleClientID` now resolves via `Info.plist`, so
   `GmailScanService.isConfigured` becomes true and the scan runs.

### Redirect URI

The app derives Google's expected iOS redirect from the client ID (the "reversed
client ID"):

```
com.googleusercontent.apps.NNN-xyz:/oauth2redirect
```

`ASWebAuthenticationSession` intercepts that scheme itself, so it does **not** need
to be registered in `Info.plist`'s `CFBundleURLTypes`. Nothing about the token is
persisted — the access token lives only for the duration of a single scan.

## Scope & privacy

- Read-only Gmail access; the app never sends, deletes, or modifies mail.
- Dates are parsed on-device (`NSDataDetector` + keyword classification) from
  message subjects/snippets; suggestions are shown for the user to confirm before
  anything is added to the planner.
