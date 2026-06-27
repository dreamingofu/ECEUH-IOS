import SwiftUI

/// A labeled horizontal meter used for faculty ratings (overall / difficulty /
/// would-take-again).
struct RatingBar: View {
    let label: String
    /// Fill fraction, 0…1.
    let fraction: Double
    let valueText: String
    var tint: Color = .accentColor

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.caption.weight(.semibold))
                    .textCase(.uppercase)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(valueText)
                    .font(.caption.weight(.semibold))
                    .monospacedDigit()
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color(.systemFill))
                    Capsule()
                        .fill(tint)
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
