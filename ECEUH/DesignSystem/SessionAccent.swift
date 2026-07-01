import SwiftUI

/// A saturated, deliberately *non-scarlet* card gradient. The app's core UI is
/// red-on-OLED-black, so the Home "Clubs" spotlight pulls from this cooler, more
/// varied palette to read as a distinct surface that stands apart from the brand.
struct ClubGradientStyle: Hashable {
    let name: String
    let colors: [UInt32]  // top-left → bottom-right, saturated → near-black
    let glow: UInt32

    var gradient: LinearGradient {
        LinearGradient(colors: colors.map { Color(hex: $0) },
                       startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    var glowColor: Color { Color(hex: glow) }
}

/// Per-session visual accents. Values computed here are `static let`s, so they're
/// evaluated once per process launch and stay stable for the whole session.
enum SessionAccent {
    /// The non-red palette the Clubs card rotates through, one pick per session.
    static let clubPalette: [ClubGradientStyle] = [
        ClubGradientStyle(name: "Indigo",  colors: [0x6366F1, 0x4338CA, 0x1E1B4B], glow: 0x6366F1),
        ClubGradientStyle(name: "Teal",    colors: [0x2DD4BF, 0x0D9488, 0x042F2E], glow: 0x14B8A6),
        ClubGradientStyle(name: "Violet",  colors: [0xA855F7, 0x7C3AED, 0x2E1065], glow: 0xA855F7),
        ClubGradientStyle(name: "Ocean",   colors: [0x38BDF8, 0x1D4ED8, 0x0B1B3F], glow: 0x3B82F6),
        ClubGradientStyle(name: "Emerald", colors: [0x34D399, 0x059669, 0x022C22], glow: 0x10B981),
        ClubGradientStyle(name: "Amber",   colors: [0xFBBF24, 0xEA580C, 0x431407], glow: 0xF59E0B),
        ClubGradientStyle(name: "Fuchsia", colors: [0xF472B6, 0xBE185D, 0x4A0A29], glow: 0xEC4899),
        ClubGradientStyle(name: "Cyan",    colors: [0x22D3EE, 0x0891B2, 0x083344], glow: 0x06B6D4),
    ]

    private static let lastIndexKey = "session.clubGradientIndex"

    /// The Clubs-card gradient for *this* session. Computed once per launch and
    /// deliberately different from the previous session's pick, so the card
    /// visibly changes every time the user opens the app.
    static let clubGradient: ClubGradientStyle = pickClubGradient()

    private static func pickClubGradient(defaults: UserDefaults = .standard) -> ClubGradientStyle {
        let count = clubPalette.count
        let last = defaults.object(forKey: lastIndexKey) as? Int
        var index = Int.random(in: 0..<count)
        if count > 1, index == last { index = (index + 1) % count }  // never repeat back-to-back
        defaults.set(index, forKey: lastIndexKey)
        return clubPalette[index]
    }
}
