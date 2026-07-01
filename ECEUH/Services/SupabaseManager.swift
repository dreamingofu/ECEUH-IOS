import Foundation
import Supabase

/// Single configured Supabase client, built from `AppConfig` (injected via
/// Secrets.xcconfig → Info.plist). If credentials are absent (e.g. CI), the
/// client still constructs against a placeholder host and `isConfigured` is false.
enum SupabaseManager {
    /// The configured Supabase URL, but only if it's actually a valid http(s) URL
    /// with a host. A malformed value (e.g. a bad `Secrets.xcconfig`) parses into a
    /// non-nil-but-invalid `URL` that traps `SupabaseClient.init` at launch, so we
    /// validate here and fall back to the placeholder instead of crashing.
    private static var validatedURL: URL? {
        guard let url = URL(string: AppConfig.supabaseURL),
              let scheme = url.scheme?.lowercased(), scheme == "https" || scheme == "http",
              let host = url.host, !host.isEmpty else { return nil }
        return url
    }

    static let client: SupabaseClient = {
        let url = validatedURL ?? URL(string: "https://placeholder.supabase.co")!
        let key = AppConfig.supabaseAnonKey.isEmpty ? "placeholder" : AppConfig.supabaseAnonKey
        return SupabaseClient(supabaseURL: url, supabaseKey: key)
    }()

    static var isConfigured: Bool {
        validatedURL != nil && !AppConfig.supabaseAnonKey.isEmpty
    }
}
