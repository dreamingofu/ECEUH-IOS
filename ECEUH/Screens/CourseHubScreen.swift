import SwiftUI

struct CourseHubScreen: View {
    let slug: String

    var body: some View {
        let course = courseBySlug(slug)
        Group {
            if let course {
                content(course)
            } else {
                ContentUnavailableView("Course not found", systemImage: "questionmark.folder")
            }
        }
        .navigationTitle(course?.hub?.title ?? course?.title ?? "Course")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func content(_ course: Course) -> some View {
        let files = kCourseFiles[slug] ?? []
        let links = kCourseLinks[slug] ?? []
        let quizCount = files.filter { $0.type == .quiz }.reduce(0) { $0 + $1.versionCount }
        let testCount = files.filter { $0.type == .exam }.reduce(0) { $0 + $1.versionCount }

        return ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(
                    kicker: course.hub?.kicker ?? "Course Hub",
                    title: course.hub?.title ?? course.title,
                    subtitle: course.hub?.desc ?? course.desc
                )

                HStack(spacing: 8) {
                    HubStat(value: quizCount, label: "Quizzes")
                    HubStat(value: testCount, label: "Tests")
                    HubStat(value: links.count, label: "External")
                }

                NavigationLink(value: Route.fileLibrary(slug: slug)) {
                    HubCard(systemImage: "folder.fill", title: "File Library",
                            subtitle: course.sections?.files?.desc ?? "Bucket-backed classwork and references.",
                            tags: ["Classwork", "Quizzes", "Reference"])
                }
                .buttonStyle(.plain)

                NavigationLink(value: Route.externalLinks(slug: slug)) {
                    HubCard(systemImage: "link", title: "External Resources",
                            subtitle: course.sections?.links?.desc ?? "Tools and references for the course.",
                            tags: ["Simulators", "Docs", "Videos"])
                }
                .buttonStyle(.plain)
            }
            .padding()
        }
    }
}

private struct HubStat: View {
    let value: Int
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(value)").font(.title2.weight(.bold)).monospacedDigit()
            Text(label).font(.caption2).textCase(.uppercase).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

#Preview {
    NavigationStack { CourseHubScreen(slug: "dld") }
}
