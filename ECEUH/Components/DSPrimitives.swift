import SwiftUI

/// Brand-gradient avatar with initials (`ee-avatar`). One hue only — red — per
/// the design's "never another hue" rule.
struct Avatar: View {
    let initials: String
    var size: CGFloat = 48

    var body: some View {
        Text(initials)
            .font(.system(size: size * 0.38, weight: .bold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(EE.brandGrad)
            .clipShape(Circle())
            .accessibilityHidden(true)
    }
}

/// File-type / status badge capsule (`ee-badge`).
struct Badge: View {
    let type: FileType
    let label: String

    var body: some View {
        Text(label)
            .font(.caption2.weight(.bold))
            .textCase(.uppercase)
            .kerning(0.5)
            .foregroundStyle(EE.color(for: type))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(EE.color(for: type).opacity(0.16), in: Capsule())
    }
}

/// Five-star rating row, red fill (`ee-stars`).
struct Stars: View {
    let value: Double // 0…5

    var body: some View {
        let filled = Int(value.rounded())
        HStack(spacing: 3) {
            ForEach(0..<5, id: \.self) { i in
                Image(systemName: "star.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(i < filled ? EE.accent : EE.bgRaised)
            }
        }
        .accessibilityHidden(true)
    }
}

/// Thin red-gradient progress track (`ee-progress`).
struct EEProgressBar: View {
    let value: Double // 0…1

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(EE.bgRaised)
                Capsule().fill(EE.accentGrad)
                    .frame(width: max(0, min(1, value)) * geo.size.width)
            }
        }
        .frame(height: 6)
    }
}

/// Big number + uppercase label tile (`ee-stat`).
struct StatTile: View {
    let value: Int
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(value)")
                .font(.title.weight(.bold))
                .foregroundStyle(EE.text)
                .monospacedDigit()
            Text(label)
                .font(.caption.weight(.semibold))
                .textCase(.uppercase)
                .kerning(0.5)
                .foregroundStyle(EE.textDim)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 16)
        .padding(.horizontal, 18)
        .background(EE.bgElevated, in: RoundedRectangle(cornerRadius: Radii.md, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: Radii.md, style: .continuous).strokeBorder(EE.border))
    }
}

/// Colored rounded icon tile used as a list-row leading accessory (`ee-row-lead`).
struct IconTile: View {
    let systemName: String
    var color: Color = EE.accent
    var size: CGFloat = 30

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: size * 0.56, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(color, in: RoundedRectangle(cornerRadius: size * 0.27, style: .continuous))
    }
}

/// Glass toast banner (`ee-banner`).
struct Banner: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .background(EE.accentGrad, in: RoundedRectangle(cornerRadius: 9, style: .continuous))
            VStack(alignment: .leading, spacing: 1) {
                Text(title).font(.subheadline.weight(.semibold)).foregroundStyle(EE.text)
                Text(subtitle).font(.footnote).foregroundStyle(EE.textMuted)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 13)
        .padding(.horizontal, 16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Radii.md, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: Radii.md, style: .continuous).strokeBorder(EE.borderStrong))
    }
}

/// Section title used above home/archive grids (`ios-sectitle`).
struct SectionTitle: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.title2.weight(.bold))
            .foregroundStyle(EE.text)
    }
}
