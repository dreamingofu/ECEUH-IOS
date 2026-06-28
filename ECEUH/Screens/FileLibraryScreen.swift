import SwiftUI

/// A course's File Library: color-coded file-type filter chips + the filtered
/// file rows, each with Preview / Save / Share actions.
struct FileLibraryScreen: View {
    let slug: String

    @State private var typeFilter: FileType?
    @State private var actionFile: FileEntry?
    @State private var preview: PreviewTarget?
    @State private var shareItem: ShareableURL?
    @State private var saving = false
    @State private var toast: String?

    private var course: Course? { courseBySlug(slug) }
    private var files: [FileEntry] { kCourseFiles[slug] ?? [] }

    /// File-type chips in the design's badge order, limited to types present.
    private let order: [FileType] = [.quiz, .exam, .homework, .classwork, .lab, .reference]
    private var presentTypes: [FileType] { order.filter { t in files.contains { $0.type == t } } }
    private var shown: [FileEntry] {
        guard let t = typeFilter else { return files }
        return files.filter { $0.type == t }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(kicker: course?.code ?? "Course",
                              title: course?.sections?.files?.title ?? "File Library",
                              subtitle: course?.sections?.files?.desc)

                if !presentTypes.isEmpty { filters }
                countLine

                if shown.isEmpty {
                    emptyState
                } else {
                    ForEach(shown) { file in
                        FileRow(file: file) { actionFile = file }
                    }
                }
            }
            .padding(.horizontal, Spacing.gutter)
            .padding(.vertical, 4)
            .padding(.bottom, 24)
        }
        .background(EE.bg.ignoresSafeArea())
        .navigationTitle("File Library")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $actionFile) { actionSheet(for: $0).presentationDetents([.height(360), .medium]) }
        .sheet(item: $preview) { PreviewScreen(target: $0) }
        .sheet(item: $shareItem) { ShareSheet(items: [$0.url]) }
        .overlay { if saving { savingOverlay } }
        .overlay(alignment: .bottom) { toastView }
    }

    // MARK: Filters

    private var filters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterPill(label: "All", color: EE.accent, selected: typeFilter == nil) {
                    withAnimation(.easeOut(duration: 0.18)) { typeFilter = nil }
                }
                ForEach(presentTypes, id: \.self) { t in
                    FilterPill(label: t.label, color: EE.color(for: t), selected: typeFilter == t) {
                        withAnimation(.easeOut(duration: 0.18)) { typeFilter = (typeFilter == t ? nil : t) }
                    }
                }
            }
            .padding(.vertical, 2).padding(.horizontal, 1)
        }
    }

    private var countLine: some View {
        Text(typeFilter == nil
             ? "\(files.count) \(files.count == 1 ? "file" : "files")"
             : "\(shown.count) of \(files.count) files")
            .font(.eeMono(.caption)).foregroundStyle(EE.textDim)
    }

    @ViewBuilder private var emptyState: some View {
        Text(files.isEmpty
             ? "No files in the bucket yet — check back during the semester."
             : "No \(typeFilter?.label.lowercased() ?? "") files in this library.")
            .font(.footnote).italic().foregroundStyle(EE.textDim)
            .padding(.vertical, 8)
    }

    // MARK: Action sheet

    private func actionSheet(for file: FileEntry) -> some View {
        let target = PreviewTarget(url: file.primary.url, title: file.title)
        return VStack(spacing: 14) {
            Capsule().fill(EE.bgRaised).frame(width: 36, height: 5).padding(.top, 8)
            HStack {
                Text(file.title).font(.title3.weight(.bold)).foregroundStyle(EE.text)
                Spacer()
            }
            HStack(spacing: 8) {
                Badge(type: file.type, label: file.label)
                Text("\(file.primary.label) · .\(file.primary.ext.lowercased())")
                    .font(.eeMono(.caption)).foregroundStyle(EE.textDim)
                Spacer()
            }
            VStack(spacing: 0) {
                actionRow("eye", EE.classwork, "Preview") { closeThen { preview = target } }
                Divider().overlay(EE.separator).padding(.leading, 58)
                actionRow("arrow.down.to.line", EE.homework, "Save to library") {
                    actionFile = nil; Task { await save(file.primary) }
                }
                Divider().overlay(EE.separator).padding(.leading, 58)
                actionRow("square.and.arrow.up", EE.lab, "Share…") {
                    closeThen { if let u = URL(string: file.primary.url) { shareItem = ShareableURL(url: u) } }
                }
            }
            .background(EE.bgCard, in: RoundedRectangle(cornerRadius: Radii.lg, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: Radii.lg, style: .continuous).strokeBorder(EE.border))
            EEButton(title: "Open PDF", icon: "arrow.down.to.line", block: true) {
                closeThen { preview = target }
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity)
        .background(EE.bgElevated.ignoresSafeArea())
    }

    private func actionRow(_ icon: String, _ color: Color, _ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                IconTile(systemName: icon, color: color)
                Text(title).font(.body).foregroundStyle(EE.text)
                Spacer()
                Image(systemName: "chevron.right").font(.footnote).foregroundStyle(EE.textFaint)
            }
            .padding(.vertical, 11).padding(.horizontal, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func closeThen(_ action: @escaping () -> Void) {
        actionFile = nil
        Task { try? await Task.sleep(for: .seconds(0.25)); action() }
    }

    private func save(_ version: FileVersion) async {
        saving = true
        defer { saving = false }
        let ok = await ShareService.download(version.url) != nil
        withAnimation { toast = ok ? "Saved to library" : "Couldn't save" }
        Task { try? await Task.sleep(for: .seconds(2)); withAnimation { toast = nil } }
    }

    private var savingOverlay: some View {
        ProgressView("Saving…").padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    @ViewBuilder private var toastView: some View {
        if let toast {
            Text(toast).font(.subheadline.weight(.medium)).foregroundStyle(EE.text)
                .padding(.horizontal, 16).padding(.vertical, 10)
                .background(.regularMaterial, in: Capsule())
                .padding(.bottom, 24)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
}

/// A selectable file-type filter chip: a type-colored dot + label; the selected
/// chip fills and outlines in its type color (mirrors the Faculty `ProfTab`).
private struct FilterPill: View {
    let label: String
    let color: Color
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Circle().fill(color).frame(width: 7, height: 7)
                Text(label).font(.subheadline.weight(selected ? .semibold : .medium))
            }
            .foregroundStyle(selected ? color : EE.textMuted)
            .padding(.horizontal, 14).padding(.vertical, 8)
            .background(Capsule().fill(selected ? color.opacity(0.16) : EE.bgCard))
            .overlay(Capsule().strokeBorder(selected ? color.opacity(0.65) : EE.border,
                                            lineWidth: selected ? 1.5 : 1))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(label) filter")
        .accessibilityAddTraits(selected ? [.isSelected] : [])
    }
}

#Preview {
    NavigationStack { FileLibraryScreen(slug: "dld") }.preferredColorScheme(.dark)
}
