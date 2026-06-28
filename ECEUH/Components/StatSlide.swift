import SwiftUI

/// One headline number on a `StatSlide` (a big red-gradient figure + label).
struct StatSlideStat {
    let number: String
    let bold: String
    let rest: String
}

/// A "stat slide" header (design `slides/04-stat.html`): a glowing dark panel
/// with a red kicker, a heading, and a row of big red-gradient stat numbers.
/// Shared by the Faculty and Archives landing pages.
struct StatSlide: View {
    let kicker: String
    let heading: String
    let stats: [StatSlideStat]
    var glowCorner: UnitPoint = UnitPoint(x: 0.9, y: 0.08)

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text(kicker)
                    .font(.caption.weight(.bold)).textCase(.uppercase).kerning(1.5)
                    .foregroundStyle(EE.accent)
                Text(heading)
                    .font(.title2.weight(.heavy)).foregroundStyle(EE.text)
                    .fixedSize(horizontal: false, vertical: true)
            }
            HStack(alignment: .top, spacing: 14) {
                ForEach(Array(stats.enumerated()), id: \.offset) { _, s in stat(s) }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(22)
        .background {
            ZStack {
                EE.bgCard
                RadialGradient(colors: [Color(hex: 0xEC1B34, alpha: 0.18), .clear],
                               center: glowCorner, startRadius: 0, endRadius: 340)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: Radii.xl, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: Radii.xl, style: .continuous).strokeBorder(EE.border))
        .eeCardShadow()
    }

    private func stat(_ s: StatSlideStat) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(s.number)
                .font(.largeTitle.weight(.heavy))
                .foregroundStyle(EE.accentGrad)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            (Text(s.bold).font(.caption2.weight(.semibold)).foregroundStyle(EE.text)
                + Text(" \(s.rest)").font(.caption2).foregroundStyle(EE.textMuted))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
