import SwiftUI
import Observation

/// Theme preference. The Flutter/web app only persisted `light`/`dark`; `system`
/// is an additional native-iOS option (absence of the key = follow system).
enum AppTheme: String, CaseIterable, Identifiable {
    case system, light, dark
    var id: String { rawValue }

    var label: String {
        switch self {
        case .system: "System"
        case .light:  "Light"
        case .dark:   "Dark"
        }
    }
}

/// Light/dark mode store. Persists under the UserDefaults key `ee-theme` with the
/// exact string values (`"dark"` / `"light"`) the web and Android apps use, so a
/// user's preference roams across platforms. The key being absent means "follow
/// the system", which the other platforms treat as their default.
@Observable
final class ThemeService {
    static let key = "ee-theme"

    var theme: AppTheme {
        didSet { persist() }
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        switch defaults.string(forKey: ThemeService.key) {
        case "dark":  theme = .dark
        case "light": theme = .light
        case "system": theme = .system
        default:      theme = .dark // signature OLED-black look is the default
        }
    }

    /// The `preferredColorScheme` value to apply at the app root.
    /// `nil` means follow the system.
    var colorScheme: ColorScheme? {
        switch theme {
        case .system: nil
        case .light:  .light
        case .dark:   .dark
        }
    }

    func setTheme(_ newValue: AppTheme) {
        theme = newValue
    }

    /// Flip between light and dark (treats `system` as currently-light).
    func toggle() {
        theme = (theme == .dark) ? .light : .dark
    }

    private func persist() {
        switch theme {
        case .system: defaults.removeObject(forKey: ThemeService.key)
        case .light:  defaults.set("light", forKey: ThemeService.key)
        case .dark:   defaults.set("dark", forKey: ThemeService.key)
        }
    }
}
