import SwiftUI

struct ArchivesScreen: View {
    var selectTab: (AppTab) -> Void = { _ in }

    @State private var filter = "All"
    private let options = ["All", "2000s", "3000s"]

    private var shown: [Course] {
        // Only classes that have content (files); empties stay in code, hidden.
        let base = coursesWithContent
        switch filter {
        case "2000s": return base.filter { $0.level == 2000 }
        case "3000s": return base.filter { $0.level == 3000 }
        default:      return base
        }
    }

    private var archiveStats: [StatSlideStat] {
        let courses = coursesWithContent.count
        let files = coursesWithContent.reduce(0) { $0 + (kCourseFiles[$1.slug]?.count ?? 0) }
        let pdfs = coursesWithContent.reduce(0) { acc, c in
            acc + (kCourseFiles[c.slug]?.reduce(0) { $0 + $1.versionCount } ?? 0)
        }
        return [
            StatSlideStat(number: "\(courses)", bold: "courses", rest: "live now"),
            StatSlideStat(number: "\(files)", bold: "files", rest: "to study"),
            StatSlideStat(number: "\(pdfs)", bold: "PDFs", rest: "to grab"),
        ]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                StatSlide(kicker: "The library", heading: "Past papers, solved & sorted",
                          stats: archiveStats)
                SectionDivider(label: "Browse courses")
                EESegmentedControl(options: options, selection: $filter)

                if shown.isEmpty {
                    ContentUnavailableView("No classes here yet", systemImage: "books.vertical",
                        description: Text("Classes appear as content is added."))
                        .frame(height: 360)
                } else {
                    // Swipeable deck — one course card per page, with page dots.
                    TabView {
                        ForEach(shown) { course in
                            VStack(spacing: 0) {
                                NavigationLink(value: Route.courseDetail(slug: course.slug)) {
                                    CourseDeckCard(course: course)
                                }
                                .buttonStyle(.plain)
                                Spacer(minLength: 0)
                            }
                            .padding(.horizontal, 4)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .frame(height: 430)
                    .id(filter)
                }

                Text("Quiz walkthroughs, exams, homework & formula sheets.")
                    .font(.caption).foregroundStyle(EE.textDim)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, Spacing.gutter)
            .padding(.vertical, 4)
            .padding(.bottom, 24)
        }
        .background(EE.bg.ignoresSafeArea())
        .navigationTitle("Archives")
    }
}

/// A large, prominent course card for the Archives swipe deck.
private struct CourseDeckCard: View {
    let course: Course

    private var hasArt: Bool { UIImage(named: artAsset(for: course.slug)) != nil }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            cover
                .frame(height: 190)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: Radii.lg, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text(course.code)
                    .font(.eeMono(.caption2)).textCase(.uppercase).kerning(0.8)
                    .foregroundStyle(EE.accent)
                Text(course.displayArchiveTitle)
                    .font(.title2.weight(.bold)).foregroundStyle(EE.text)
                    .lineLimit(2).fixedSize(horizontal: false, vertical: true)
            }

            HStack(spacing: 6) {
                Text("\(course.units) Units").font(.subheadline).foregroundStyle(EE.textDim)
                if let badge = courseBadge(for: course.slug) {
                    Text("·").foregroundStyle(EE.textDim)
                    Text(badge).font(.subheadline.weight(.semibold)).foregroundStyle(EE.accent)
                }
                Spacer()
                Label("Open", systemImage: "arrow.right")
                    .font(.subheadline.weight(.semibold)).foregroundStyle(EE.accent)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(EE.bgCard, in: RoundedRectangle(cornerRadius: Radii.card, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: Radii.card, style: .continuous).strokeBorder(EE.border))
        .eeCardShadow()
        .contentShape(Rectangle())
    }

    @ViewBuilder private var cover: some View {
        ZStack {
            if hasArt {
                Image(artAsset(for: course.slug)).resizable().scaledToFill()
            } else {
                LinearGradient(colors: [Color(hex: 0x7A0A16), .black],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
            }
            EE.sheen
        }
    }
}

#Preview {
    NavigationStack { ArchivesScreen() }.preferredColorScheme(.dark)
}
