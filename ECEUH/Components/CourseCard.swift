import SwiftUI

/// Course archive cover card (`ee-course`): 16:10 cover art (or a red/ink
/// gradient fallback), a red mono code, a bold name, and a units / badge row.
struct CourseCard: View {
    let code: String
    let name: String
    var artAsset: String? = nil
    var units: String? = nil
    var badge: String? = nil

    private var hasArt: Bool { artAsset.flatMap { UIImage(named: $0) } != nil }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            thumb
            VStack(alignment: .leading, spacing: 4) {
                Text(code)
                    .font(.eeMono(.caption2))
                    .textCase(.uppercase)
                    .kerning(0.8)
                    .foregroundStyle(EE.accent)
                Text(name)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(EE.text)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 6)

            if units != nil || badge != nil {
                HStack {
                    if let units { Text(units).font(.caption).foregroundStyle(EE.textDim) }
                    Spacer(minLength: 4)
                    if let badge {
                        Text(badge).font(.caption.weight(.bold)).foregroundStyle(EE.accent)
                    }
                }
                .padding(.horizontal, 6)
                .padding(.bottom, 4)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(EE.bgCard, in: RoundedRectangle(cornerRadius: Radii.card, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: Radii.card, style: .continuous).strokeBorder(EE.border))
        .contentShape(Rectangle())
    }

    private var thumb: some View {
        RoundedRectangle(cornerRadius: Radii.md, style: .continuous)
            .fill(Color.black)
            .aspectRatio(16.0 / 10.0, contentMode: .fit)
            .overlay {
                Group {
                    if hasArt, let artAsset {
                        Image(artAsset).resizable().scaledToFill()
                    } else {
                        LinearGradient(
                            colors: [Color(hex: 0x7A0A16), Color.black],
                            startPoint: .topLeading, endPoint: .bottomTrailing)
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: Radii.md, style: .continuous))
    }
}
