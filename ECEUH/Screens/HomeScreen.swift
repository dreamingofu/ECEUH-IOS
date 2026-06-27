import SwiftUI

/// Module-readiness for a live course (hub / files / links / topics), mirroring
/// the Flutter `_moduleProgress`.
private func moduleProgress(_ course: Course) -> (ready: Int, total: Int) {
    var ready = 0
    if course.hub != nil { ready += 1 }
    if course.sections?.files != nil { ready += 1 }
    if course.sections?.links != nil { ready += 1 }
    if course.sections?.topics != nil { ready += 1 }
    return (ready, 4)
}

struct HomeScreen: View {
    /// Switches the root tab (for "View all" / faculty CTA).
    var selectTab: (AppTab) -> Void = { _ in }

    @State private var appeared = false

    private var activeCourse: Course { liveCourses.first ?? kCourses[0] }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                searchEntry
                NavigationLink(value: Route.courseHub(slug: activeCourse.slug)) {
                    ActiveCourseCard(course: activeCourse)
                }
                .buttonStyle(.plain)

                FacultyCTACard { selectTab(.ratings) }

                librarySection
                FacultyLedger()
            }
            .padding()
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 12)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) { appeared = true }
        }
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("ECEUH").font(.headline.weight(.bold))
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("University of Houston · ECE")
                .font(.caption.weight(.semibold))
                .textCase(.uppercase)
                .kerning(0.7)
                .foregroundStyle(Color.accentColor)
            (Text("Master your ")
                + Text("ECE").foregroundColor(.accentColor).italic()
                + Text(" coursework."))
                .font(.largeTitle.weight(.bold))
            Text("A living record of homework walkthroughs, lab notes, and faculty ratings — built in real time each semester at the University of Houston.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var searchEntry: some View {
        Button { selectTab(.research) } label: {
            HStack {
                Image(systemName: "magnifyingglass")
                Text("Search courses, archives, and faculty…")
                Spacer()
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .padding(12)
            .background(Color(.secondarySystemGroupedBackground), in: Capsule())
        }
        .buttonStyle(.plain)
    }

    private var librarySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Your Library").font(.title2.weight(.bold))
                Spacer()
                Button { selectTab(.research) } label: {
                    Label("View all", systemImage: "arrow.right")
                        .font(.caption.weight(.bold))
                        .textCase(.uppercase)
                }
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(liveCourses) { course in
                        NavigationLink(value: Route.courseHub(slug: course.slug)) {
                            CourseCoverCard(course: course)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

// MARK: - Active course card

private struct ActiveCourseCard: View {
    let course: Course

    var body: some View {
        let progress = moduleProgress(course)
        let fraction = Double(progress.ready) / Double(progress.total)
        let pct = Int((fraction * 100).rounded())

        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Active Course")
                        .font(.caption2.weight(.bold))
                        .textCase(.uppercase)
                        .kerning(1)
                        .foregroundStyle(Color.accentColor)
                        .padding(.horizontal, 10).padding(.vertical, 4)
                        .background(Color.accentColor.opacity(0.12), in: Capsule())
                    Text(course.hub?.title ?? course.title)
                        .font(.title3.weight(.semibold))
                    Text("\(course.code) · \(course.desc)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                Spacer(minLength: 12)
                Text("\(pct)%")
                    .font(.title.weight(.bold))
                    .foregroundStyle(Color.accentColor)
                    .monospacedDigit()
            }

            HStack {
                Text("Resources ready").font(.subheadline.weight(.semibold))
                Spacer()
                Text("\(progress.ready)/\(progress.total) modules")
                    .font(.caption).foregroundStyle(.secondary)
            }

            ProgressView(value: fraction)
                .tint(Color.accentColor)

            HStack(spacing: 12) {
                StatBox(label: "Modules", value: "\(progress.ready)/\(progress.total)")
                StatBox(label: "Units", value: "\(course.units)")
            }
        }
        .padding()
        .background(Color.accentColor.opacity(0.08), in: RoundedRectangle(cornerRadius: Radii.xl, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Radii.xl, style: .continuous)
                .strokeBorder(Color.accentColor.opacity(0.18))
        )
        .contentShape(Rectangle())
    }
}

private struct StatBox: View {
    let label: String
    let value: String
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption2.weight(.bold))
                .textCase(.uppercase)
                .kerning(1)
                .foregroundStyle(Color.accentColor)
            Text(value).font(.headline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: Radii.md, style: .continuous))
    }
}

// MARK: - Faculty CTA

private struct FacultyCTACard: View {
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: "person.3.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(.white.opacity(0.12), in: Circle())
                Text("Faculty Directory").font(.title3.weight(.semibold))
                Text("Browse ratings, difficulty, and reviews from real ECE students.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.75))
                Divider().overlay(.white.opacity(0.15))
                Label("View all professors", systemImage: "star.fill")
                    .font(.caption.weight(.bold))
                    .textCase(.uppercase)
                    .foregroundStyle(Brand.goldDark)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(.white)
            .padding()
            .background(Brand.navy, in: RoundedRectangle(cornerRadius: Radii.xl, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack { HomeScreen() }
        .environment(SessionStore())
}
