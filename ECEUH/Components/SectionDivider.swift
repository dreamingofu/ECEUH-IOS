import SwiftUI

/// A labeled section divider: a centered uppercase kicker with a scarlet dot,
/// flanked by hairlines. Separates the stat slide from the content below.
struct SectionDivider: View {
    let label: String

    var body: some View {
        HStack(spacing: 12) {
            line
            HStack(spacing: 6) {
                Circle().fill(EE.accent).frame(width: 5, height: 5)
                Text(label)
                    .font(.caption.weight(.bold)).textCase(.uppercase).kerning(1.5)
                    .foregroundStyle(EE.textMuted)
            }
            line
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .combine)
    }

    private var line: some View {
        Rectangle().fill(EE.border).frame(height: 1).frame(maxWidth: .infinity)
    }
}
