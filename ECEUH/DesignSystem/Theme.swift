import SwiftUI

extension Color {
    /// Build a Color from a packed 0xRRGGBB hex value (with optional alpha).
    init(hex: UInt32, alpha: Double = 1) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}

/// Brand palette. The native look leans on system colors for backgrounds and
/// text (so Dynamic Type + automatic dark mode come for free); these are the few
/// brand-specific values carried over from the Flutter "Kinetic Luxe" theme.
///
/// The gold accent is also defined as an `AccentColor` asset (light/dark) so it
/// becomes the app-wide tint automatically.
enum Brand {
    static let goldLight = Color(hex: 0x735C00) // accent, light mode
    static let goldDark  = Color(hex: 0xE9C349) // accent, dark mode
    static let navy      = Color(hex: 0x0A192F) // deep background (dark brand surface)
    static let card      = Color(hex: 0x13243D) // navy card surface

    /// Gold that adapts to the current color scheme. Prefer `Color.accentColor`
    /// (driven by the asset) for tinting; use this where an explicit gold is needed.
    static func gold(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? goldDark : goldLight
    }
}
