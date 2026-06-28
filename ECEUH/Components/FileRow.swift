import SwiftUI

/// A file entry card (`ee-filerow`): a file-type badge, the version, title and
/// description, and Preview / Save / Share actions that open the action sheet.
///
/// Files that bundle multiple versions (e.g. a quiz with A/B variants and their
/// solutions) get a tappable "N versions" disclosure that expands the card in
/// place to list each version; tapping a version previews it directly.
struct FileRow: View {
    let file: FileEntry
    var onOpen: () -> Void
    var onPreviewVersion: (FileVersion) -> Void = { _ in }

    @State private var expanded = false

    private var isMulti: Bool { file.versionCount > 1 }
    private var typeColor: Color { EE.color(for: file.type) }
    private var versionText: String {
        "\(file.primary.label) · .\(file.primary.ext.lowercased())"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Badge(type: file.type, label: file.label)
                Spacer()
                if isMulti {
                    disclosure
                } else {
                    Text(versionText)
                        .font(.eeMono(.caption))
                        .foregroundStyle(EE.textDim)
                }
            }
            Text(file.title).font(.headline).foregroundStyle(EE.text)
            if !file.desc.isEmpty {
                Text(file.desc).font(.subheadline).foregroundStyle(EE.textMuted)
            }
            HStack(spacing: 8) {
                EEButton(title: "Preview", icon: "eye", variant: .tinted, size: .small, action: onOpen)
                EEButton(title: "Save", icon: "arrow.down.to.line", variant: .gray, size: .small, action: onOpen)
                EEButton(title: "Share", icon: "square.and.arrow.up", variant: .gray, size: .small, action: onOpen)
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

    // MARK: Disclosure + versions

    private var disclosure: some View {
        Button {
            withAnimation(.easeOut(duration: 0.2)) { expanded.toggle() }
        } label: {
            HStack(spacing: 5) {
                Text("\(file.versionCount) versions")
                    .font(.eeMono(.caption2)).textCase(.uppercase).kerning(0.5)
                Image(systemName: expanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 9, weight: .bold))
            }
            .foregroundStyle(typeColor)
            .padding(.horizontal, 10).padding(.vertical, 5)
            .background(typeColor.opacity(0.14), in: Capsule())
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(expanded ? "Hide \(file.versionCount) versions"
                                     : "Show \(file.versionCount) versions")
    }

    private var versionList: some View {
        VStack(spacing: 0) {
            ForEach(Array(file.versions.enumerated()), id: \.offset) { index, version in
                Button { onPreviewVersion(version) } label: {
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
                .accessibilityLabel("Preview \(file.title) — \(version.label)")
                if index < file.versions.count - 1 {
                    Divider().overlay(EE.separator).padding(.leading, 54)
                }
            }
        }
        .background(EE.bgRaised, in: RoundedRectangle(cornerRadius: Radii.md, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: Radii.md, style: .continuous).strokeBorder(EE.border))
    }
}
