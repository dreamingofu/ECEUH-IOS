import SwiftUI
import Observation

/// Lightweight session/auth state. Phase 4 uses a mock; Phase 6 backs this with
/// the real Supabase `AuthService` (email/Apple/Google + delete). The shell can
/// be explored without signing in (mirrors the Flutter "Explore without signing
/// in" path); the Sign-In screen is presented as a full-screen cover.
@Observable
final class SessionStore {
    var isSignedIn: Bool = false
    var presentingSignIn: Bool = false

    // Mock profile (replaced by Supabase user metadata in Phase 6).
    var displayName: String = "Alex Cougar"
    var email: String = "acougar@cougarnet.uh.edu"
    var major: String = "Electrical & Computer Engineering"
    var gradYear: String = "2027"

    func presentSignIn() { presentingSignIn = true }

    /// Phase 4 mock sign-in. Replaced by real Supabase auth in Phase 6.
    func mockSignIn() {
        isSignedIn = true
        presentingSignIn = false
    }

    func continueAsGuest() {
        presentingSignIn = false
    }

    func signOut() {
        isSignedIn = false
        presentingSignIn = true
    }
}
