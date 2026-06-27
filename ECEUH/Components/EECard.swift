import SwiftUI

/// The ECEUH "bento" surface: near-black fill, hairline border, large radius,
/// long soft shadow, a top sheen, and an optional two-corner red `glow`
/// (`ee-card` / `ee-card--glow`).
struct EECard<Content: View>: View {
    var glow: Bool = false
    var padding: CGFloat = Spacing.inset
    var radius: CGFloat = Radii.card
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                ZStack {
                    EE.bgCard
                    if glow {
                        RadialGradient(
                            colors: [Color(hex: 0xEC1B34, alpha: 0.22), .clear],
                            center: UnitPoint(x: 0.85, y: -0.05), startRadius: 0, endRadius: 360)
                        RadialGradient(
                            colors: [Color(hex: 0xEC1B34, alpha: 0.10), .clear],
                            center: UnitPoint(x: 0.0, y: 1.05), startRadius: 0, endRadius: 280)
                    }
                    EE.sheen
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(EE.border, lineWidth: 1))
            .eeCardShadow()
    }
}
