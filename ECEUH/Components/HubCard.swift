import SwiftUI

/// A tappable navigation card for the course hub (→ File Library / External
/// Resources). An accent icon tile, title, subtitle, optional content tags, a
/// count, and an "Open →" affordance — a port of the design's `HubCard`.
struct HubCard: View {
    var icon: String = "folder.fill"
    let title: String
    var subtitle: String? = nil
    var tags: [String] = []
    var count: String? = nil
    var open: String = "Open"

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 46, height: 46)
                    .background(EE.accentGrad, in: RoundedRectangle(cornerRadius: 13, style: .continuous))
                    .eeGlowSoft()
                Spacer(minLength: 8)
                if let count {
                    Text(count)
                        .font(.eeMono(.caption)).foregroundStyle(EE.textDim)
                        .padding(.top, 4)
                }
            }

            Text(title).font(.title3.weight(.bold)).foregroundStyle(EE.text)

            if let subtitle {
                Text(subtitle)
                    .font(.subheadline).foregroundStyle(EE.textMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if !tags.isEmpty {
                HStack(spacing: 6) {
                    ForEach(tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption2.weight(.semibold)).textCase(.uppercase).kerning(0.5)
                            .foregroundStyle(EE.textMuted)
                            .padding(.horizontal, 9).padding(.vertical, 4)
                            .background(EE.bgRaised, in: Capsule())
                    }
                }
            }

            Divider().overlay(EE.separator).padding(.top, 2)

            HStack(spacing: 6) {
                Text(open).font(.subheadline.weight(.semibold))
                Image(systemName: "arrow.right").font(.caption.weight(.bold))
            }
            .foregroundStyle(EE.accent)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(EE.bgCard, in: RoundedRectangle(cornerRadius: Radii.card, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: Radii.card, style: .continuous).strokeBorder(EE.border))
        .eeCardShadow()
        .contentShape(Rectangle())
    }
}
