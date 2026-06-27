import SwiftUI

/// A labeled red meter (`ee-rb`) — faculty Overall / Difficulty / Would-take-again.
struct RatingBar: View {
    let label: String
    let fraction: Double // 0…1
    let valueText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text(label)
                    .font(.caption.weight(.semibold))
                    .textCase(.uppercase)
                    .kerning(0.5)
                    .foregroundStyle(EE.textMuted)
                Spacer()
                Text(valueText)
                    .font(.eeMono(.footnote))
                    .foregroundStyle(EE.text)
                    .monospacedDigit()
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(EE.bgRaised)
                    Capsule().fill(EE.accent)
                        .frame(width: max(0, min(1, fraction)) * geo.size.width)
                }
            }
            .frame(height: 6)
            .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(label)
        .accessibilityValue(valueText)
    }
}
