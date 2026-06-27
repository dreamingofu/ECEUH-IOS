import SwiftUI

struct ArchivesScreen: View {
    var body: some View {
        List {
            Section {
                SectionHeader(
                    kicker: "Course Archives",
                    title: "Every course in the ECE base.",
                    subtitle: "Live courses have full walkthroughs, files, and resources. The rest are on deck and get added one at a time."
                )
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }

            Section("Live") {
                ForEach(liveCourses) { course in
                    NavigationLink(value: Route.courseHub(slug: course.slug)) {
                        LiveCourseRow(course: course)
                    }
                }
            }

            Section("On Deck · \(upcomingCourses.count) courses") {
                ForEach(upcomingCourses) { course in
                    HStack(spacing: 12) {
                        Text(course.code)
                            .font(.caption.monospaced())
                            .foregroundStyle(.secondary)
                            .frame(width: 72, alignment: .leading)
                        Text(course.displayArchiveTitle)
                            .font(.subheadline)
                        Spacer()
                        Text("Coming soon")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 8).padding(.vertical, 3)
                            .background(Color(.tertiarySystemFill), in: Capsule())
                    }
                }
            }
        }
        .navigationTitle("Archives")
    }
}

struct LiveCourseRow: View {
    let course: Course

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "book.fill")
                .foregroundStyle(Color.accentColor)
                .frame(width: 44, height: 44)
                .background(Color.accentColor.opacity(0.1), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            VStack(alignment: .leading, spacing: 3) {
                Text(course.code)
                    .font(.caption2.weight(.bold))
                    .textCase(.uppercase)
                    .foregroundStyle(Color.accentColor)
                Text(course.displayArchiveTitle).font(.headline)
                Text("\(course.units) units · Live")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack { ArchivesScreen() }
}
