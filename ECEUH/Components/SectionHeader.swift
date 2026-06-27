import SwiftUI

/// A reusable screen/section header: an accent kicker, a title, and an optional
/// subtitle. Used at the top of content screens (the native analog of the
/// Flutter `HeroCard`).
struct SectionHeader: View {
    var kicker: String? = nil
    let title: String
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let kicker {
                Text(kicker)
                    .font(.caption.weight(.semibold))
                    .textCase(.uppercase)
                    .kerning(0.7)
                    .foregroundStyle(Color.accentColor)
            }
            Text(title)
                .font(.title.weight(.bold))
            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
