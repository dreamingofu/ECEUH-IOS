import SwiftUI
import Supabase
import Observation
import AuthenticationServices
import CryptoKit

/// Real Supabase-backed auth/session store. Subsumes the earlier mock
/// `SessionStore`: tracks the session, the "explore as guest" choice, and the
/// profile; provides email/password, Sign in with Apple, Google, sign-out, and
/// in-app account deletion.
///
/// Notes for this project:
/// - Apple sign-in is wired but the Apple provider is currently disabled in the
///   Supabase dashboard (must be enabled + a Team ID/entitlement added before it
///   works; App Store requires it once Google is offered).
/// - Google requires the app's redirect URL (`eceuh://login-callback`) in the
///   Supabase Auth redirect allow-list.
/// - Email sign-up requires email confirmation (project setting).
@Observable
@MainActor
final class AuthService {
    var session: Session?
    var isLoading = false
    var errorMessage: String?
    /// True once the initial session restore has finished (gate avoids a flash).
    var didResolve = false

    /// "Explore without signing in" — persisted so it isn't asked every launch.
    var isGuest: Bool {
        didSet { UserDefaults.standard.set(isGuest, forKey: Self.guestKey) }
    }

    /// Editable profile (hydrated from the session; mirrors web `profiles`).
    var displayName = ""
    var email = ""
    var major = "Electrical & Computer Engineering"
    var gradYear = "2027"

    private static let guestKey = "auth.isGuest"
    private let client = SupabaseManager.client
    @ObservationIgnored private var webAuth: WebAuthenticator?
    @ObservationIgnored private var appleNonce: String?

    init() {
        isGuest = UserDefaults.standard.bool(forKey: Self.guestKey)
    }

    var isSignedIn: Bool { session != nil }
    var userId: UUID? { session?.user.id }

    /// True when the sign-in gate should be shown (not signed in, not a guest).
    var needsSignIn: Bool { !isSignedIn && !isGuest }

    // MARK: - Lifecycle

    /// Restore any persisted session and start observing auth changes.
    func start() async {
        guard SupabaseManager.isConfigured else { didResolve = true; return }
        session = try? await client.auth.session
        hydrateProfile()
        didResolve = true
        for await change in client.auth.authStateChanges {
            // With `emitLocalSessionAsInitialSession`, the initial event can carry
            // an expired stored session — don't treat that as signed-in. A valid
            // session still arrives via signIn / tokenRefreshed (auto-refresh),
            // and sign-out carries a nil session (which falls through to clear it).
            if let incoming = change.session, incoming.isExpired { continue }
            session = change.session
            hydrateProfile()
        }
    }

    private func hydrateProfile() {
        guard let user = session?.user else { return }
        email = user.email ?? ""
        if displayName.isEmpty {
            displayName = (user.userMetadata["full_name"]?.stringValue)
                ?? user.email?.components(separatedBy: "@").first
                ?? "ECE Student"
        }
    }

    // MARK: - Email / password

    /// Returns nil on a completed sign-in, or a user-facing message (e.g. the
    /// "check your email" confirmation notice) when sign-in isn't immediate.
    func signUp(email: String, password: String) async -> String? {
        await run {
            let response = try await self.client.auth.signUp(email: email, password: password)
            if response.session == nil {
                return "Check your email to confirm your account, then sign in."
            }
            return nil
        }
    }

    func signIn(email: String, password: String) async -> String? {
        await run {
            _ = try await self.client.auth.signIn(email: email, password: password)
            return nil
        }
    }

    // MARK: - Apple

    func prepareAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = Self.randomNonce()
        appleNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = Self.sha256(nonce)
    }

    func completeAppleSignIn(_ result: Result<ASAuthorization, Error>) async {
        switch result {
        case .failure(let error):
            errorMessage = error.localizedDescription
        case .success(let auth):
            guard
                let credential = auth.credential as? ASAuthorizationAppleIDCredential,
                let tokenData = credential.identityToken,
                let idToken = String(data: tokenData, encoding: .utf8),
                let nonce = appleNonce
            else {
                errorMessage = "Apple sign-in failed."
                return
            }
            _ = await run {
                try await self.client.auth.signInWithIdToken(
                    credentials: .init(provider: .apple, idToken: idToken, nonce: nonce))
                return nil
            }
        }
    }

    // MARK: - Google (OAuth via ASWebAuthenticationSession)

    func signInWithGoogle() async {
        let authenticator = WebAuthenticator()
        webAuth = authenticator
        _ = await run {
            try await self.client.auth.signInWithOAuth(
                provider: .google,
                redirectTo: URL(string: "eceuh://login-callback")
            ) { url in
                try await authenticator.start(url: url, callbackScheme: "eceuh")
            }
            return nil
        }
        webAuth = nil
    }

    // MARK: - Session management

    func continueAsGuest() { isGuest = true }

    func signOut() async {
        try? await client.auth.signOut()
        session = nil
        isGuest = false
        displayName = ""
    }

    /// In-app account deletion: delete the user's own progress rows, invoke the
    /// `delete-account` Edge Function (service-role deleteUser), then sign out.
    func deleteAccount() async throws {
        guard let userId else { throw AuthError.notSignedIn }
        try await client.from("progress").delete().eq("user_id", value: userId.uuidString).execute()
        try await client.functions.invoke("delete-account")
        try? await client.auth.signOut()
        session = nil
        isGuest = false
    }

    enum AuthError: LocalizedError {
        case notSignedIn
        var errorDescription: String? { "You're not signed in." }
    }

    // MARK: - Helpers

    /// Runs an async auth op with shared loading/error handling. The op returns
    /// an optional user-facing message (nil = silent success).
    private func run(_ op: @Sendable () async throws -> String?) async -> String? {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            return try await op()
        } catch {
            errorMessage = error.localizedDescription
            return error.localizedDescription
        }
    }

    private static func randomNonce(length: Int = 32) -> String {
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remaining = length
        while remaining > 0 {
            var random: UInt8 = 0
            _ = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            if random < charset.count {
                result.append(charset[Int(random)])
                remaining -= 1
            }
        }
        return result
    }

    private static func sha256(_ input: String) -> String {
        SHA256.hash(data: Data(input.utf8)).map { String(format: "%02x", $0) }.joined()
    }
}
