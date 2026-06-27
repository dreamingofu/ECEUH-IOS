import SwiftUI

/// Typography — native SF Pro (sans), SF Mono (codes/metadata), New York (serif
/// accent), mapped onto semantic text styles so Dynamic Type still scales. The
/// design's px ramp (34→11) corresponds to the iOS Large Title→Caption 2 ramp.
extension Font {
    static let eeLargeTitle = Font.largeTitle.weight(.bold)   // 34
    static let eeTitle1     = Font.title.weight(.bold)        // 28
    static let eeTitle2     = Font.title2.weight(.bold)       // 22
    static let eeTitle3     = Font.title3.weight(.bold)       // 20
    static let eeHeadline   = Font.headline                   // 17 semibold
    static let eeBody       = Font.body                       // 17
    static let eeCallout    = Font.callout                    // 16
    static let eeSubhead    = Font.subheadline                // 15
    static let eeFootnote   = Font.footnote                   // 13
    static let eeCaption    = Font.caption                    // 12
    static let eeCaption2   = Font.caption2                   // 11

    /// SF Mono — course codes, file versions, rating values, metadata.
    static func eeMono(_ style: Font.TextStyle = .footnote, weight: Font.Weight = .bold) -> Font {
        .system(style, design: .monospaced).weight(weight)
    }
    /// New York serif — reserved accent.
    static func eeSerif(_ style: Font.TextStyle, weight: Font.Weight = .bold) -> Font {
        .system(style, design: .serif).weight(weight)
    }
}

extension View {
    /// Accent kicker — uppercase, tracked, scarlet (`ee-kicker`).
    func eeKicker() -> some View {
        font(.caption.weight(.bold))
            .textCase(.uppercase)
            .kerning(0.7)
            .foregroundStyle(EE.accent)
    }
}
