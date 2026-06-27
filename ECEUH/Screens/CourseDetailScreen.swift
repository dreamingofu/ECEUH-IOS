import SwiftUI

struct CourseDetailScreen: View {
    let slug: String

    @State private var tab = "Files"
    @State private var actionFile: FileEntry?
    @State private var preview: PreviewTarget?
    @State private var shareItem: ShareableURL?
    @State private var saving = false
    @State private var toast: String?

    private var course: Course? { courseBySlug(slug) }
    private var files: [FileEntry] { kCourseFiles[slug] ?? [] }
    private var links: [LinkEntry] { kCourseLinks[slug] ?? [] }
    private var quizCount: Int { files.filter { $0.type == .quiz }.reduce(0) { $0 + $1.versionCount } }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                hero
                EESegmentedControl(options: ["Files", "Links"], selection: $tab)
                if tab == "Files" { filesList } else { linksList }
            }
            .padding(.horizontal, Spacing.gutter)
            .padding(.vertical, 4)
            .padding(.bottom, 24)
        }
        .background(EE.bg.ignoresSafeArea())
        .navigationTitle(course?.displayArchiveTitle ?? "Course")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $actionFile) { actionSheet(for: $0).presentationDetents([.height(360), .medium]) }
        .sheet(item: $preview) { PreviewScreen(target: $0) }
        .sheet(item: $shareItem) { ShareSheet(items: [$0.url]) }
        .overlay { if saving { savingOverlay } }
        .overlay(alignment: .bottom) { toastView }
    }

    // MARK: Hero

    private var hero: some View {
        EECard(glow: true) {
            VStack(alignment: .leading, spacing: 0) {
                Text(course?.hub?.kicker ?? "Course Hub").eeKicker()
                Text(course?.displayArchiveTitle ?? "Course")
                    .font(.title.weight(.bold)).foregroundStyle(EE.text)
                    .padding(.top, 6)
                Text(course?.hub?.desc ?? course?.desc ?? "")
                    .font(.subheadline).foregroundStyle(EE.textMuted)
                    .padding(.top, 8)
                HStack(spacing: 10) {
                    StatTile(value: quizCount, label: "Quizzes")
                    StatTile(value: files.count, label: "Files")
                    StatTile(value: links.count, label: "Links")
                }
                .padding(.top, 16)
            }
        }
    }

    // MARK: Files / Links

    @ViewBuilder private var filesList: some View {
        if files.isEmpty {
            Text("No files in the bucket yet — check back during the semester.")
                .font(.footnote).italic().foregroundStyle(EE.textDim)
                .padding(.vertical, 8)
        } else {
            ForEach(files) { file in
                FileRow(file: file) { actionFile = file }
            }
        }
    }

    @ViewBuilder private var linksList: some View {
        if links.isEmpty {
            Text("No links yet for this course.")
                .font(.footnote).italic().foregroundStyle(EE.textDim).padding(.vertical, 8)
        } else {
            ForEach(links) { link in
                Button { ShareService.openExternal(link.url) } label: {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(link.title).font(.headline).foregroundStyle(EE.text)
                            Spacer()
                            Image(systemName: "arrow.up.right").font(.subheadline).foregroundStyle(EE.accent)
                        }
                        Text(link.desc).font(.footnote).foregroundStyle(EE.textMuted)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(EE.bgCard, in: RoundedRectangle(cornerRadius: Radii.lg, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: Radii.lg, style: .continuous).strokeBorder(EE.border))
                }
                .buttonStyle(.plain)
            }
        }
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

#Preview {
    NavigationStack { CourseDetailScreen(slug: "dld") }.preferredColorScheme(.dark)
}
