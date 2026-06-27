import SwiftUI

/// A file entry row: type badge, version picker, title/description, and
/// Preview / Share / Save actions. The action closures are wired to real
/// services in Phase 5; the version `Menu` selects which `FileVersion` the
/// actions operate on.
struct FileRow: View {
    let file: FileEntry
    var onPreview: (FileVersion) -> Void = { _ in }
    var onShare: (FileVersion) -> Void = { _ in }
    var onSave: (FileVersion) -> Void = { _ in }

    @State private var selected: FileVersion?

    private var version: FileVersion { selected ?? file.primary }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                FileTypeBadge(type: file.type)
                Spacer()
                versionControl
            }

            Text(file.title).font(.headline)
            if !file.desc.isEmpty {
                Text(file.desc).font(.subheadline).foregroundStyle(.secondary)
            }

            HStack(spacing: 8) {
                Button { onPreview(version) } label: { Label("Preview", systemImage: "eye") }
                    .buttonStyle(.bordered)
                Button { onShare(version) } label: { Label("Share", systemImage: "square.and.arrow.up") }
                    .buttonStyle(.bordered)
                Button { onSave(version) } label: { Label("Save", systemImage: "arrow.down.to.line") }
                    .buttonStyle(.borderedProminent)
            }
            .font(.caption)
            .controlSize(.small)
            .buttonBorderShape(.capsule)
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var versionControl: some View {
        let detail = "\(version.label) · .\(version.ext.lowercased())"
        if file.versionCount > 1 {
            Menu {
                ForEach(file.versions, id: \.url) { v in
                    Button(v.label) { selected = v }
                }
            } label: {
                Label(detail, systemImage: "chevron.down")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } else {
            Text(detail)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
