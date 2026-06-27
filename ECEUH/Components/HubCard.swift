import SwiftUI

/// A tappable navigation card (course hub → File Library / External Resources).
/// Native card surface with an accent icon tile, title, subtitle, tags, and an
/// "Open" affordance.
struct HubCard: View {
    let systemImage: String
    let title: String
    let subtitle: String
    var tags: [String] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundStyle(Color.accentColor)
                .frame(width: 46, height: 46)
                .background(
                    Color.accentColor.opacity(0.12),
                    in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                )

            Text(title).font(.title3.weight(.semibold))
            Text(subtitle).font(.subheadline).foregroundStyle(.secondary)

            if !tags.isEmpty {
                HStack(spacing: 6) {
                    ForEach(tags, id: \.self) { TagChip(text: $0) }
                }
            }

            HStack {
                Spacer()
                Label("Open", systemImage: "arrow.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.accentColor)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            Color(.secondarySystemGroupedBackground),
            in: RoundedRectangle(cornerRadius: Radii.lg, style: .continuous)
        )
        .contentShape(Rectangle())
    }
}
