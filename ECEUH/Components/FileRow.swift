import SwiftUI

/// A file entry card (`ee-filerow`): a file-type badge, the version meta, title
/// and description. The whole card is the tap target — a single-version file
/// opens its preview; a multi-version file (e.g. a quiz with A/B variants and
/// their solutions) expands in place to list each version, and tapping a version
/// previews it. Long-press a card or a version row for quick Preview / Save /
/// Share without opening the file first.
struct FileRow: View {
    let file: FileEntry
    var onPreview: (FileVersion) -> Void
    var onSave: (FileVersion) -> Void
    var onShare: (FileVersion) -> Void

    @State private var expanded = false

    private var isMulti: Bool { file.versionCount > 1 }
    private var typeColor: Color { EE.color(for: file.type) }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if isMulti {
                header
            } else {
                header.contextMenu { menu(for: file.primary) }
            }

            if isMulti && expanded {
                VStack(spacing: 10) {
                    Divider().overlay(EE.separator)
                    versionList
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(EE.bgCard, in: RoundedRectangle(cornerRadius: Radii.lg, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: Radii.lg, style: .continuous).strokeBorder(EE.border))
    }

    // MARK: Header — tap previews (single) or expands (multi)

    private var header: some View {
        Button {
            if isMulti {
                withAnimation(.easeOut(duration: 0.2)) { expanded.toggle() }
            } else {
                onPreview(file.primary)
            }
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Badge(type: file.type, label: file.label)
                    Spacer(minLength: 8)
                    meta
                }
                Text(file.title).font(.headline).foregroundStyle(EE.text)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if !file.desc.isEmpty {
                    Text(file.desc).font(.subheadline).foregroundStyle(EE.textMuted)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityHint(isMulti ? (expanded ? "Hide versions" : "Show \(file.versionCount) versions")
                                   : "Opens preview")
    }

    /// Trailing meta: a "N versions" disclosure (multi) or "label ›" (single).
    /// Drops the file extension when the label already conveys it (e.g. "PDF").
    @ViewBuilder private var meta: some View {
        if isMulti {
            HStack(spacing: 5) {
                Text("\(file.versionCount) versions")
                    .font(.eeMono(.caption2)).textCase(.uppercase).kerning(0.5)
                Image(systemName: expanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 9, weight: .bold))
            }
            .foregroundStyle(typeColor)
            .padding(.horizontal, 10).padding(.vertical, 5)
            .background(typeColor.opacity(0.14), in: Capsule())
        } else {
            HStack(spacing: 6) {
                Text(singleMetaText)
                    .font(.eeMono(.caption)).foregroundStyle(EE.textDim)
                Image(systemName: "chevron.right")
                    .font(.caption2.weight(.bold)).foregroundStyle(EE.textFaint)
            }
        }
    }

    /// The single-version label, with the extension appended only when it adds
    /// information (i.e. the label isn't already the format, like "PDF · .pdf").
    private var singleMetaText: String {
        let label = file.primary.label
        let ext = file.primary.ext.lowercased()
        return label.lowercased() == ext ? label : "\(label) · .\(ext)"
    }

    // MARK: Version list (multi, expanded)

    private var versionList: some View {
        VStack(spacing: 0) {
            ForEach(Array(file.versions.enumerated()), id: \.offset) { index, version in
                Button { onPreview(version) } label: {
                    HStack(spacing: 12) {
                        IconTile(systemName: "doc.text", color: typeColor)
                        Text(version.label).font(.subheadline).foregroundStyle(EE.text)
                        Spacer(minLength: 8)
                        Text(".\(version.ext.lowercased())")
                            .font(.eeMono(.caption2)).foregroundStyle(EE.textDim)
                        Image(systemName: "chevron.right").font(.footnote).foregroundStyle(EE.textFaint)
                    }
                    .padding(.vertical, 10).padding(.horizontal, 12)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .contextMenu { menu(for: version) }
                .accessibilityLabel("Preview \(file.title) — \(version.label)")
                if index < file.versions.count - 1 {
                    Divider().overlay(EE.separator).padding(.leading, 54)
                }
            }
        }
        .background(EE.bgRaised, in: RoundedRectangle(cornerRadius: Radii.md, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: Radii.md, style: .continuous).strokeBorder(EE.border))
    }

    // MARK: Long-press menu

    @ViewBuilder private func menu(for version: FileVersion) -> some View {
        Button { onPreview(version) } label: { Label("Preview", systemImage: "eye") }
        Button { onSave(version) } label: { Label("Save to library", systemImage: "arrow.down.to.line") }
        Button { onShare(version) } label: { Label("Share…", systemImage: "square.and.arrow.up") }
    }
}
