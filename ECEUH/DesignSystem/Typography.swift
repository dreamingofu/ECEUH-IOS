import SwiftUI

/// Semantic typography helpers. These map the Flutter `TextTheme` slots onto
/// system text styles so everything scales with Dynamic Type automatically.
///
/// Rule for the whole codebase: never use `Font.system(size:)` with a hardcoded
/// number. Use these helpers or the standard semantic styles (`.title2`,
/// `.headline`, `.body`, `.caption`, …).
extension View {
    /// Large page heading (Flutter `displayMedium`/`displayLarge`).
    func eceuhDisplay() -> some View {
        font(.largeTitle.weight(.bold))
    }

    /// Section heading (Flutter `displaySmall`/`headlineMedium`).
    func eceuhSectionTitle() -> some View {
        font(.title2.weight(.semibold))
    }

    /// Card / list-row title (Flutter `titleLarge`/`titleMedium`).
    func eceuhCardTitle() -> some View {
        font(.headline)
    }

    /// Body copy (Flutter `bodyMedium`/`bodyLarge`).
    func eceuhBody() -> some View {
        font(.body)
    }

    /// Uppercase accent label / kicker (Flutter `labelSmall`).
    func eceuhKicker() -> some View {
        font(.caption.weight(.semibold))
            .textCase(.uppercase)
            .kerning(0.7)
            .foregroundStyle(Color.accentColor)
    }
}
