import SwiftUI

/// Course hub landing page: a hero with quick stats, then two navigation cards —
/// File Library (with file-type filters) and External Resources — each opening
/// its own dedicated page.
struct CourseDetailScreen: View {
    let slug: String

    private var course: Course? { courseBySlug(slug) }
    private var files: [FileEntry] { kCourseFiles[slug] ?? [] }
    private var links: [LinkEntry] { kCourseLinks[slug] ?? [] }
    private var quizCount: Int { files.filter { $0.type == .quiz }.reduce(0) { $0 + $1.versionCount } }

    /// Distinct file-type labels present, in the design's badge order (capped).
    private var fileTags: [String] {
        let order: [FileType] = [.quiz, .exam, .homework, .classwork, .lab, .reference]
        return order.filter { t in files.contains { $0.type == t } }.prefix(4).map(\.label)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                hero

                NavigationLink(value: Route.fileLibrary(slug: slug)) {
                    HubCard(icon: "folder.fill",
                            title: course?.sections?.files?.title ?? "File Library",
                            subtitle: course?.sections?.files?.desc
                                ?? "Browse quizzes, exams, homework, and reference docs.",
                            tags: fileTags,
                            count: countLabel(files.count, "file"),
                            gradient: EE.redCardGrad, glowColor: EE.accent)
                }
                .buttonStyle(PressScaleStyle())

                NavigationLink(value: Route.externalLinks(slug: slug)) {
                    HubCard(icon: "link",
                            title: course?.sections?.links?.title ?? "External Resources",
                            subtitle: course?.sections?.links?.desc
                                ?? "Curated simulators, explainers, and references.",
                            tags: ["Simulators", "Docs", "References"],
                            count: countLabel(links.count, "link"),
                            gradient: EE.blueCardGrad, glowColor: EE.blue)
                }
                .buttonStyle(PressScaleStyle())
            }
            .padding(.horizontal, Spacing.gutter)
            .padding(.vertical, 4)
            .padding(.bottom, 24)
        }
        .background(EE.bg.ignoresSafeArea())
        .navigationTitle(course?.displayArchiveTitle ?? "Course")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func countLabel(_ n: Int, _ noun: String) -> String {
        "\(n) \(noun)\(n == 1 ? "" : "s")"
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
}

#Preview {
    NavigationStack { CourseDetailScreen(slug: "dld") }.preferredColorScheme(.dark)
}
