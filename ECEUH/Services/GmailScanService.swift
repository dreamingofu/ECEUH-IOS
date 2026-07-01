import Foundation
import Observation
import AuthenticationServices
import CryptoKit
import Security

/// Scans the user's Gmail for quiz / exam / deadline emails and proposes planner
/// dates. Uses Google OAuth 2.0 with PKCE via `ASWebAuthenticationSession` and the
/// Gmail REST API directly — no third-party SDK.
///
/// Requires a Google OAuth **iOS** client ID in `AppConfig.googleClientID`
/// (see `docs/GOOGLE_SETUP.md`). Until that's set, `isConfigured` is false and the
/// UI shows a setup hint instead of attempting the flow. Read-only scope only
/// (`gmail.readonly`); nothing is ever sent or modified.
@Observable
@MainActor
final class GmailScanService {
    enum Phase: Equatable { case idle, connecting, scanning, done, failed(String) }
    private(set) var phase: Phase = .idle

    @ObservationIgnored private var webAuth: WebAuthenticator?

    /// True once a *real* Google OAuth client ID has been supplied (rejects an
    /// empty value and the `your-…` placeholder from Secrets.example.xcconfig).
    var isConfigured: Bool {
        let id = AppConfig.googleClientID
        return id.hasSuffix(".apps.googleusercontent.com") && !id.hasPrefix("your-")
    }

    /// The reversed-client-ID URL scheme Google redirects back to (iOS client type):
    /// `NNN-xyz.apps.googleusercontent.com` → `com.googleusercontent.apps.NNN-xyz`.
    private var redirectScheme: String {
        let id = AppConfig.googleClientID
        let suffix = ".apps.googleusercontent.com"
        let base = id.hasSuffix(suffix) ? String(id.dropLast(suffix.count)) : id
        return "com.googleusercontent.apps.\(base)"
    }
    private var redirectURI: String { "\(redirectScheme):/oauth2redirect" }

    /// Run the full flow: OAuth → search Gmail → parse candidate dates. Returns the
    /// suggested events (possibly empty). Never throws — failures land in `phase`.
    func scan() async -> [PersonalEvent] {
        guard isConfigured else {
            phase = .failed("Gmail scanning isn't set up yet.")
            return []
        }
        do {
            phase = .connecting
            let token = try await authorize()
            phase = .scanning
            let events = try await fetchCandidates(token: token)
            phase = .done
            return events
        } catch is CancellationError {
            phase = .idle          // user declined consent on Google's page
            return []
        } catch {
            if let asError = error as? ASWebAuthenticationSessionError, asError.code == .canceledLogin {
                phase = .idle      // user dismissed the sign-in sheet
            } else {
                phase = .failed(error.localizedDescription)
            }
            return []
        }
    }

    func reset() { phase = .idle }

    // MARK: OAuth (PKCE)

    private func authorize() async throws -> String {
        let verifier = Self.randomURLSafe(64)
        let challenge = Self.codeChallenge(for: verifier)

        var comps = URLComponents(string: "https://accounts.google.com/o/oauth2/v2/auth")!
        comps.queryItems = [
            .init(name: "client_id", value: AppConfig.googleClientID),
            .init(name: "redirect_uri", value: redirectURI),
            .init(name: "response_type", value: "code"),
            .init(name: "scope", value: "https://www.googleapis.com/auth/gmail.readonly"),
            .init(name: "code_challenge", value: challenge),
            .init(name: "code_challenge_method", value: "S256"),
            .init(name: "prompt", value: "consent"),
        ]

        let auth = WebAuthenticator()
        webAuth = auth
        let callback = try await auth.start(url: comps.url!, callbackScheme: redirectScheme)

        let items = URLComponents(url: callback, resolvingAgainstBaseURL: false)?.queryItems
        // Google redirects with ?error=access_denied when the user declines consent.
        if let error = items?.first(where: { $0.name == "error" })?.value {
            if error == "access_denied" || error == "user_denied" { throw CancellationError() }
            throw GmailError.oauth(error)
        }
        guard let code = items?.first(where: { $0.name == "code" })?.value else {
            throw GmailError.noCode
        }
        return try await exchange(code: code, verifier: verifier)
    }

    private func exchange(code: String, verifier: String) async throws -> String {
        var req = URLRequest(url: URL(string: "https://oauth2.googleapis.com/token")!)
        req.httpMethod = "POST"
        req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let form = [
            "client_id": AppConfig.googleClientID,
            "code": code,
            "code_verifier": verifier,
            "grant_type": "authorization_code",
            "redirect_uri": redirectURI,
        ]
        req.httpBody = form
            .map { "\($0.key)=\(Self.formEncode($0.value))" }
            .joined(separator: "&")
            .data(using: .utf8)

        let (data, resp) = try await URLSession.shared.data(for: req)
        try Self.checkOK(resp)
        struct TokenResponse: Decodable { let access_token: String }
        return try JSONDecoder().decode(TokenResponse.self, from: data).access_token
    }

    // MARK: Gmail

    private func fetchCandidates(token: String) async throws -> [PersonalEvent] {
        let query = "newer_than:120d (quiz OR exam OR midterm OR final OR test OR homework OR assignment OR \"due date\" OR deadline)"
        var listComps = URLComponents(string: "https://gmail.googleapis.com/gmail/v1/users/me/messages")!
        listComps.queryItems = [
            .init(name: "q", value: query),
            .init(name: "maxResults", value: "25"),
        ]
        let listData = try await authedGet(listComps.url!, token: token)
        struct MessageList: Decodable {
            struct Ref: Decodable { let id: String }
            let messages: [Ref]?
        }
        let ids = (try JSONDecoder().decode(MessageList.self, from: listData).messages ?? []).map(\.id)

        var candidates: [PersonalEvent] = []
        for id in ids.prefix(25) {
            var msgComps = URLComponents(string: "https://gmail.googleapis.com/gmail/v1/users/me/messages/\(id)")!
            msgComps.queryItems = [
                .init(name: "format", value: "metadata"),
                .init(name: "metadataHeaders", value: "Subject"),
            ]
            guard let data = try? await authedGet(msgComps.url!, token: token) else { continue }
            struct Message: Decodable {
                struct Payload: Decodable {
                    struct Header: Decodable { let name: String; let value: String }
                    let headers: [Header]?
                }
                let snippet: String?
                let payload: Payload?
            }
            guard let msg = try? JSONDecoder().decode(Message.self, from: data) else { continue }
            let subject = msg.payload?.headers?.first { $0.name.lowercased() == "subject" }?.value ?? ""
            // Gmail returns `snippet` HTML-entity-escaped; decode it before use.
            let text = subject + ". " + Self.decodeEntities(msg.snippet ?? "")
            if let event = Self.parseEvent(subject: subject, text: text) { candidates.append(event) }
        }
        return Self.dedupe(candidates)
    }

    private func authedGet(_ url: URL, token: String) async throws -> Data {
        var req = URLRequest(url: url)
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (data, resp) = try await URLSession.shared.data(for: req)
        try Self.checkOK(resp)
        return data
    }

    // MARK: Parsing

    /// Extract a candidate planner event from an email's subject + snippet: the
    /// first future-leaning date it mentions, classified by keyword.
    private static func parseEvent(subject: String, text: String) -> PersonalEvent? {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue)
        let range = NSRange(text.startIndex..., in: text)
        // First *future* date wins — a quiz/exam email refers to an upcoming date,
        // and NSDataDetector otherwise happily returns past/sent dates we'd wrongly
        // add as "Overdue".
        let matches = detector?.matches(in: text, options: [], range: range) ?? []
        guard let date = matches.compactMap(\.date).first(where: { $0.timeIntervalSinceNow > -3600 })
        else { return nil }

        // Classify on whole words (so "example" doesn't match "exam", "overdue"
        // doesn't match "due", "finally" doesn't match "final"). Quiz is checked
        // before the broad exam keywords so "Quiz on the final chapter" stays a quiz.
        let words = Set(text.lowercased().split { !$0.isLetter }.map(String.init))
        func has(_ options: String...) -> Bool { options.contains { words.contains($0) } }
        let kind: EventKind
        if has("quiz") { kind = .quiz }
        else if has("exam", "midterm", "final", "test") { kind = .exam }
        else if has("lab") { kind = .lab }
        else if has("project") { kind = .project }
        else if has("homework", "assignment", "due", "deadline") { kind = .homework }
        else { kind = .other }

        let cleanSubject = Self.stripReplyPrefixes(subject)
        let title = String((cleanSubject.isEmpty ? text : cleanSubject).prefix(120))
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return nil }
        return PersonalEvent(title: title, kind: kind, date: date)
    }

    /// Drop leading "Re:" / "Fwd:" / "Fw:" prefixes from an email subject.
    private static func stripReplyPrefixes(_ subject: String) -> String {
        var s = subject.trimmingCharacters(in: .whitespacesAndNewlines)
        let prefixes = ["re:", "fwd:", "fw:"]
        var changed = true
        while changed {
            changed = false
            for p in prefixes where s.lowercased().hasPrefix(p) {
                s = String(s.dropFirst(p.count)).trimmingCharacters(in: .whitespaces)
                changed = true
            }
        }
        return s
    }

    /// Decode the handful of HTML entities Gmail snippets actually contain. `&amp;`
    /// is decoded last so `&amp;#39;`-style double escapes collapse correctly.
    private static func decodeEntities(_ s: String) -> String {
        var out = s
        for (entity, char) in [("&#39;", "'"), ("&#34;", "\""), ("&quot;", "\""),
                               ("&lt;", "<"), ("&gt;", ">"), ("&nbsp;", " "), ("&amp;", "&")] {
            out = out.replacingOccurrences(of: entity, with: char)
        }
        return out
    }

    private static func dedupe(_ events: [PersonalEvent]) -> [PersonalEvent] {
        var seen = Set<String>()
        var out: [PersonalEvent] = []
        let cal = Calendar.current
        for e in events {
            // Include kind so two distinct items that share a long subject prefix on
            // the same day aren't collapsed into one.
            let key = "\(e.kind.rawValue)|\(e.title.lowercased())|\(cal.startOfDay(for: e.date).timeIntervalSince1970)"
            if seen.insert(key).inserted { out.append(e) }
        }
        return out.sorted { $0.date < $1.date }
    }

    // MARK: Helpers

    private static func checkOK(_ resp: URLResponse) throws {
        if let http = resp as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
            throw GmailError.http(http.statusCode)
        }
    }

    private static func randomURLSafe(_ byteCount: Int) -> String {
        var bytes = [UInt8](repeating: 0, count: byteCount)
        _ = SecRandomCopyBytes(kSecRandomDefault, byteCount, &bytes)
        return Data(bytes).base64URLEncodedString()
    }

    private static func codeChallenge(for verifier: String) -> String {
        let hash = SHA256.hash(data: Data(verifier.utf8))
        return Data(hash).base64URLEncodedString()
    }

    private static func formEncode(_ value: String) -> String {
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: "-._~")
        return value.addingPercentEncoding(withAllowedCharacters: allowed) ?? value
    }

    enum GmailError: LocalizedError {
        case noCode, http(Int), oauth(String)
        var errorDescription: String? {
            switch self {
            case .noCode:         "Google didn't return an authorization code."
            case .http(let code): "Gmail request failed (HTTP \(code))."
            case .oauth(let e):   "Google sign-in failed (\(e))."
            }
        }
    }
}

private extension Data {
    /// Base64URL without padding (RFC 7636 PKCE encoding).
    func base64URLEncodedString() -> String {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
