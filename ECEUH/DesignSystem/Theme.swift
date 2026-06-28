import SwiftUI
import UIKit

extension Color {
    /// Build a Color from a packed 0xRRGGBB hex value (with optional alpha).
    init(hex: UInt32, alpha: Double = 1) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }

    /// A dynamic color that resolves per the active interface style. Lets a
    /// single `Color` adapt to light/dark without threading `colorScheme`.
    static func dynamic(dark: UInt32, light: UInt32, darkAlpha: Double = 1, lightAlpha: Double = 1) -> Color {
        Color(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(hex: dark, alpha: darkAlpha)
                : UIColor(hex: light, alpha: lightAlpha)
        })
    }
}

extension UIColor {
    convenience init(hex: UInt32, alpha: Double = 1) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: CGFloat(alpha))
    }
}

/// ECEUH-for-iOS design tokens — the OLED black / scarlet-red / white theme.
/// Colors are dynamic (dark is the signature default; light is a clean iOS
/// grouped light mode). Ported 1:1 from the design system's `tokens/colors.css`.
enum EE {
    // ── Surfaces ──────────────────────────────────────────────────────────
    static let bg          = Color.dynamic(dark: 0x000000, light: 0xF2F2F7)
    static let bgBase      = Color.dynamic(dark: 0x000000, light: 0xFFFFFF)
    static let bgElevated  = Color.dynamic(dark: 0x1C1C1E, light: 0xFFFFFF)
    static let bgCard      = Color.dynamic(dark: 0x1C1C1E, light: 0xFFFFFF)
    static let bgRaised    = Color.dynamic(dark: 0x2C2C2E, light: 0xE5E5EA)

    // ── Text ──────────────────────────────────────────────────────────────
    static let text        = Color.dynamic(dark: 0xFFFFFF, light: 0x000000)
    static let textSoft    = Color.dynamic(dark: 0xEBEBF5, light: 0x3C3C43)
    static let textMuted   = Color.dynamic(dark: 0xAEAEB2, light: 0x6C6C70)
    static let textDim     = Color.dynamic(dark: 0x8E8E93, light: 0x8E8E93)
    static let textFaint   = Color.dynamic(dark: 0x636366, light: 0xAEAEB2)

    // ── Accent (scarlet) ──────────────────────────────────────────────────
    static let accent       = Color.dynamic(dark: 0xEC1B34, light: 0xD81B2E)
    static let accentDeep    = Color(hex: 0x7A0A16)
    static let accentBright  = Color(hex: 0xFF4D5C)
    static let onAccent      = Color.white
    static let accentTint    = Color.dynamic(dark: 0xEC1B34, light: 0xD81B2E, darkAlpha: 0.16, lightAlpha: 0.10)
    static let accentLine    = Color.dynamic(dark: 0xEC1B34, light: 0xD81B2E, darkAlpha: 0.34, lightAlpha: 0.26)

    // ── Lines ─────────────────────────────────────────────────────────────
    static let border       = Color.dynamic(dark: 0xFFFFFF, light: 0x000000, darkAlpha: 0.10, lightAlpha: 0.10)
    static let borderStrong = Color.dynamic(dark: 0xFFFFFF, light: 0x000000, darkAlpha: 0.16, lightAlpha: 0.16)
    static let separator    = Color.dynamic(dark: 0xFFFFFF, light: 0x3C3C43, darkAlpha: 0.08, lightAlpha: 0.18)

    // ── File-type + status palette ────────────────────────────────────────
    static let quiz       = Color(hex: 0xFF5161)
    static let exam       = Color.dynamic(dark: 0xF59E0B, light: 0xB27A00)
    static let homework   = Color(hex: 0x34D399)
    static let classwork  = Color(hex: 0x3B82F6)
    static let lab        = Color(hex: 0xA855F7)
    static let reference  = Color(hex: 0xAEAEB2)
    static let good       = Color.dynamic(dark: 0x34D399, light: 0x15803D)
    static let warn       = Color.dynamic(dark: 0xFBBF24, light: 0xB45309)

    // ── Beautiful accents: gradients + glow ───────────────────────────────
    static let accentGrad = LinearGradient(
        colors: [Color(hex: 0xFF4D5C), Color(hex: 0xEC1B34), Color(hex: 0xB0122A)],
        startPoint: .topLeading, endPoint: .bottomTrailing)
    static let brandGrad = LinearGradient(
        colors: [Color(hex: 0xFF4D5C), Color(hex: 0xB0122A), Color(hex: 0x3A060D)],
        startPoint: .topLeading, endPoint: .bottomTrailing)
    /// Subtle top highlight ("sheen") for glass/cards.
    static let sheen = LinearGradient(
        colors: [Color.white.opacity(0.08), Color.white.opacity(0)],
        startPoint: .top, endPoint: .center)

    // ── Tinted hub-card fills (saturated at top-left → near-black) ─────────
    static let blue = Color(hex: 0x3B82F6)
    static let redCardGrad = LinearGradient(
        colors: [Color(hex: 0xA8182E), Color(hex: 0x520C18), Color(hex: 0x130307)],
        startPoint: .topLeading, endPoint: .bottomTrailing)
    static let blueCardGrad = LinearGradient(
        colors: [Color(hex: 0x2A5FCF), Color(hex: 0x143A86), Color(hex: 0x070F22)],
        startPoint: .topLeading, endPoint: .bottomTrailing)

    /// File-type accent color for a `FileType`.
    static func color(for type: FileType) -> Color {
        switch type {
        case .quiz:      quiz
        case .exam:      exam
        case .homework:  homework
        case .classwork: classwork
        case .lab:       lab
        case .reference: reference
        }
    }
}

extension View {
    /// Red action glow (soft) — for primary buttons and accent tiles.
    func eeGlowSoft() -> some View {
        shadow(color: Color(hex: 0xEC1B34, alpha: 0.40), radius: 12, x: 0, y: 8)
    }
    /// Deep ambient card shadow.
    func eeCardShadow() -> some View {
        shadow(color: Color.black.opacity(0.55), radius: 22, x: 0, y: 14)
    }
}
