import Foundation

/// Centralized endpoints / config. Keeps the R2 bucket host and Supabase keys in
/// one place so a bucket or project change is a single edit (rather than hunting
/// through the data files). Supabase values are injected via `Secrets.xcconfig`
/// → Info.plist at build time (wired in Phase 6).
enum AppConfig {
    /// Cloudflare R2 bucket base URL for course files.
    static let r2Base = "https://pub-8a57ce7900574340969d1b3eb5bcdc1e.r2.dev"

    static let supabaseURL = Bundle.main.infoDictionary?["SUPABASE_URL"] as? String ?? ""
    static let supabaseAnonKey = Bundle.main.infoDictionary?["SUPABASE_ANON_KEY"] as? String ?? ""
}
