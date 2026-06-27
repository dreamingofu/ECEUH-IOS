import SwiftUI

/// A file entry card (`ee-filerow`): a file-type badge, the version, title and
/// description, and Preview / Save / Share actions that open the action sheet.
struct FileRow: View {
    let file: FileEntry
    var onOpen: () -> Void

    private var versionText: String {
        "\(file.primary.label) · .\(file.primary.ext.lowercased())"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Badge(type: file.type, label: file.label)
                Spacer()
                Text(versionText)
                    .font(.eeMono(.caption))
                    .foregroundStyle(EE.textDim)
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
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(EE.bgCard, in: RoundedRectangle(cornerRadius: Radii.lg, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: Radii.lg, style: .continuous).strokeBorder(EE.border))
    }
}
