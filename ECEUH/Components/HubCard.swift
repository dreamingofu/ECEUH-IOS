import SwiftUI

/// A tappable navigation card for the course hub (→ File Library / External
/// Resources). An accent icon tile, title, subtitle, optional content tags, a
/// count, and an "Open →" affordance — a port of the design's `HubCard`.
///
/// Pass a `gradient` to render a saturated, full-color card (foreground colors
/// flip to white-on-color); leave it `nil` for the plain near-black surface.
struct HubCard: View {
    var icon: String = "folder.fill"
    let title: String
    var subtitle: String? = nil
    var tags: [String] = []
    var count: String? = nil
    var open: String = "Open"
    var gradient: LinearGradient? = nil
    var glowColor: Color = EE.accent

    private var tinted: Bool { gradient != nil }
    private var titleColor: Color { tinted ? .white : EE.text }
    private var subColor: Color { tinted ? .white.opacity(0.85) : EE.textMuted }
    private var dimColor: Color { tinted ? .white.opacity(0.7) : EE.textDim }
    private var openColor: Color { tinted ? .white : EE.accent }
    private var lineColor: Color { tinted ? .white.opacity(0.2) : EE.separator }
    private var borderColor: Color { tinted ? .white.opacity(0.18) : EE.border }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                tile
                Spacer(minLength: 8)
                if let count {
                    Text(count)
                        .font(.eeMono(.caption)).foregroundStyle(dimColor)
                        .padding(.top, 4)
                }
            }

            Text(title).font(.title3.weight(.bold)).foregroundStyle(titleColor)

            if let subtitle {
                Text(subtitle)
                    .font(.subheadline).foregroundStyle(subColor)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if !tags.isEmpty {
                HStack(spacing: 6) {
                    ForEach(tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption2.weight(.semibold)).textCase(.uppercase).kerning(0.5)
                            .foregroundStyle(tinted ? .white.opacity(0.9) : EE.textMuted)
                            .padding(.horizontal, 9).padding(.vertical, 4)
                            .background(tinted ? AnyShapeStyle(.white.opacity(0.16))
                                               : AnyShapeStyle(EE.bgRaised), in: Capsule())
                    }
                }
            }

            Divider().overlay(lineColor).padding(.top, 2)

            HStack(spacing: 6) {
                Text(open).font(.subheadline.weight(.semibold))
                Image(systemName: "arrow.right").font(.caption.weight(.bold))
            }
            .foregroundStyle(openColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background {
            ZStack {
                if let gradient { gradient; EE.sheen } else { EE.bgCard }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: Radii.card, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: Radii.card, style: .continuous).strokeBorder(borderColor))
        .modifier(HubShadow(tinted: tinted, glow: glowColor))
        .contentShape(Rectangle())
    }

    private var tile: some View {
        Image(systemName: icon)
            .font(.system(size: 20, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 46, height: 46)
            .background {
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .fill(tinted ? AnyShapeStyle(.white.opacity(0.16)) : AnyShapeStyle(EE.accentGrad))
            }
            .modifier(TileGlow(enabled: !tinted))
    }
}

/// Soft red glow under the plain icon tile (skipped on tinted cards).
private struct TileGlow: ViewModifier {
    let enabled: Bool
    func body(content: Content) -> some View {
        enabled ? AnyView(content.eeGlowSoft()) : AnyView(content)
    }
}

/// Card shadow: a tinted color glow for full-color cards, the standard long
/// card shadow otherwise.
private struct HubShadow: ViewModifier {
    let tinted: Bool
    let glow: Color
    func body(content: Content) -> some View {
        if tinted {
            content.shadow(color: glow.opacity(0.4), radius: 20, x: 0, y: 12)
        } else {
            content.eeCardShadow()
        }
    }
}
