# ECEUH — iOS

Native Swift/SwiftUI rewrite of the [ECEUH](https://eceuh.com) Flutter app — a UH
Electrical & Computer Engineering knowledge base (course archives, file library,
faculty ratings, clubs, curated links).

- **Look:** native iOS (SF Pro, SF Symbols, system materials, Dynamic Type) with
  the brand gold as the app accent. Light / dark / system.
- **Target:** iOS 17+ · Swift 6 toolchain · built with Xcode 26.
- **Backend:** Supabase (shared with the web app) — wired in Phase 6; see
  [docs/SUPABASE_SETUP.md](docs/SUPABASE_SETUP.md).

## Project structure

The Xcode project uses a **synchronized root group** (`ECEUH/`), so any `.swift`
file added under it is compiled automatically — no manual project edits.

```
ECEUH/
  App/           ECEUHApp.swift — @main, injects services
  Models/        Course, Professor, FileEntry, LinkEntry, Club (+ enums)
  Data/          static data (kCourses, kProfessorCourses, …) + AppConfig
  Services/      Theme, Progress, Notification, Share, Session (Auth in Phase 6)
  DesignSystem/  Tokens, Theme/palette, Typography, SFSymbols, Hashing
  Components/    CourseArt, CourseCoverCard, FileRow, RatingBar, HubCard, …
  Navigation/    AppTab, Route, RootView (TabView + per-tab NavigationStack)
  Screens/       13 screens, 1:1 with the Flutter app
  Resources/     Assets.xcassets (AppIcon, AccentColor)
  Info.plist · PrivacyInfo.xcprivacy · ECEUH.entitlements
```

## Build & run (simulator)

```bash
xcodebuild -project ECEUH.xcodeproj -scheme ECEUH \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -derivedDataPath build -configuration Debug build

xcrun simctl boot "iPhone 17"
xcrun simctl install booted build/Build/Products/Debug-iphonesimulator/ECEUH.app
xcrun simctl launch booted edu.uh.eceuh
xcrun simctl io booted screenshot shot.png   # optional
```

Simulator builds need no signing. Sign in with Apple / Google and APNs delivery
require a real device + provider/APNs configuration.

## Secrets

Copy `Secrets.example.xcconfig` → `Secrets.xcconfig` (gitignored) and fill in the
Supabase URL + anon key. Wired into the build in Phase 6.

## Status

All phases implemented: scaffold, data, components, all 13 screens + navigation,
device services + PDF preview, polish (app icon, animated faculty spotlight,
accessibility), and **Supabase** (email/Apple/Google auth, auth gate, progress
sync, in-app delete). Connectivity to the live project is verified.

A few **manual Supabase/Apple steps** remain before Apple/Google sign-in fully
work and account-deletion is live — see [docs/SUPABASE_SETUP.md](docs/SUPABASE_SETUP.md).
