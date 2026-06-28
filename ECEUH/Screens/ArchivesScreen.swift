import SwiftUI

struct ArchivesScreen: View {
    var selectTab: (AppTab) -> Void = { _ in }

    @State private var filter = "All"
    private let options = ["All", "2000s", "3000s"]
    private let cols = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    private var shown: [Course] {
        // Only classes that have content (files); empties stay in code, hidden.
        let base = coursesWithContent
        switch filter {
        case "2000s": return base.filter { $0.level == 2000 }
        case "3000s": return base.filter { $0.level == 3000 }
        default:      return base
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                EESegmentedControl(options: options, selection: $filter)
                LazyVGrid(columns: cols, spacing: 12) {
                    ForEach(shown) { course in
                        NavigationLink(value: Route.courseDetail(slug: course.slug)) {
                            CourseCard(code: course.code, name: course.displayArchiveTitle,
                                       artAsset: artAsset(for: course.slug),
                                       units: "\(course.units) Units", badge: courseBadge(for: course.slug))
                        }
                        .buttonStyle(.plain)
                    }
                    Button { selectTab(.faculty) } label: {
                        CourseCard(code: "RMP", name: "Professor Ratings", artAsset: "art-rmp",
                                   units: "Faculty", badge: "Reference")
                    }
                    .buttonStyle(.plain)
                }
                Text("Quiz walkthroughs, exams, homework & formula sheets.")
                    .font(.caption).foregroundStyle(EE.textDim)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 4)
            }
            .padding(.horizontal, Spacing.gutter)
            .padding(.vertical, 4)
            .padding(.bottom, 24)
        }
        .background(EE.bg.ignoresSafeArea())
        .navigationTitle("Archives")
    }
}

#Preview {
    NavigationStack { ArchivesScreen() }.preferredColorScheme(.dark)
}
