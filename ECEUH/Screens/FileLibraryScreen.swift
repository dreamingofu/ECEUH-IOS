import SwiftUI

struct FileLibraryScreen: View {
    let slug: String
    @State private var filter: FileType?
    @State private var preview: PreviewTarget?
    @State private var shareItem: ShareableURL?
    @State private var saving = false
    @State private var toast: String?

    var body: some View {
        let course = courseBySlug(slug)
        let entries = kCourseFiles[slug] ?? []
        let shown = filter == nil ? entries : entries.filter { $0.type == filter }

        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(
                    kicker: course?.title ?? "Course",
                    title: "File Library",
                    subtitle: "Bucket-backed classwork and references for \(course?.code ?? "this course"). Preview opens the file inline; Save downloads it for offline use."
                )

                filterChips

                if shown.isEmpty {
                    ContentUnavailableView("No files yet", systemImage: "tray",
                                           description: Text("Nothing for this filter."))
                        .padding(.top, 24)
                } else {
                    ForEach(shown) { file in
                        FileRow(
                            file: file,
                            onPreview: { v in preview = PreviewTarget(url: v.url, title: file.title) },
                            onShare: { v in if let url = URL(string: v.url) { shareItem = ShareableURL(url: url) } },
                            onSave: { v in Task { await save(v) } }
                        )
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground),
                                    in: RoundedRectangle(cornerRadius: Radii.lg, style: .continuous))
                    }
                }
            }
            .padding()
        }
        .navigationTitle("File Library")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $preview) { PreviewScreen(target: $0) }
        .sheet(item: $shareItem) { ShareSheet(items: [$0.url]) }
        .overlay {
            if saving {
                ProgressView("Saving…")
                    .padding()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .overlay(alignment: .bottom) {
            if let toast {
                Text(toast)
                    .font(.subheadline.weight(.medium))
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .background(.regularMaterial, in: Capsule())
                    .padding(.bottom, 24)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    private func save(_ version: FileVersion) async {
        saving = true
        defer { saving = false }
        let saved = await ShareService.download(version.url)
        withAnimation { toast = saved != nil ? "Saved to Files" : "Couldn't save" }
        Task {
            try? await Task.sleep(for: .seconds(2))
            withAnimation { toast = nil }
        }
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(label: "All", selected: filter == nil) { filter = nil }
                ForEach(FileType.allCases, id: \.self) { type in
                    FilterChip(label: type.label, selected: filter == type) { filter = type }
                }
            }
        }
    }
}

struct FilterChip: View {
    let label: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 14).padding(.vertical, 8)
                .background(selected ? Color.accentColor.opacity(0.15) : Color(.secondarySystemFill), in: Capsule())
                .foregroundStyle(selected ? Color.accentColor : Color.secondary)
                .overlay(Capsule().strokeBorder(selected ? Color.accentColor.opacity(0.4) : .clear))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack { FileLibraryScreen(slug: "dld") }
}
