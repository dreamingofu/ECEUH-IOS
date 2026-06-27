import SwiftUI

/// A screen/section header: an accent kicker, a title, and an optional subtitle.
struct SectionHeader: View {
    var kicker: String? = nil
    let title: String
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let kicker { Text(kicker).eeKicker() }
            Text(title)
                .font(.title.weight(.bold))
                .foregroundStyle(EE.text)
            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(EE.textMuted)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
