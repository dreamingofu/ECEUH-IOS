import Foundation
import Supabase

/// Single configured Supabase client, built from `AppConfig` (injected via
/// Secrets.xcconfig → Info.plist). If credentials are absent (e.g. CI), the
/// client still constructs against a placeholder host and `isConfigured` is false.
enum SupabaseManager {
    static let client: SupabaseClient = {
        let url = URL(string: AppConfig.supabaseURL) ?? URL(string: "https://placeholder.supabase.co")!
        let key = AppConfig.supabaseAnonKey.isEmpty ? "placeholder" : AppConfig.supabaseAnonKey
        return SupabaseClient(supabaseURL: url, supabaseKey: key)
    }()

    static var isConfigured: Bool {
        !AppConfig.supabaseURL.isEmpty && !AppConfig.supabaseAnonKey.isEmpty
    }
}
