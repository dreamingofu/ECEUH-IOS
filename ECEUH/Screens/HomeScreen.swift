import SwiftUI

/// Cover-art asset name for a course slug (bundled for live courses; CourseCard
/// falls back to a red/ink gradient when absent).
func artAsset(for slug: String) -> String { "art-\(slug)" }

/// Curated archive badge for the live courses (design `data.js`).
func courseBadge(for slug: String) -> String? {
    switch slug {
    case "dld":       "Top Pick"
    case "circuits2": "Advanced"
    case "cprog":     "Fundamental"
    default:          nil
    }
}

/// Module readiness fraction for a live course (hub / files / links / topics).
private func readiness(_ course: Course) -> Double {
    var ready = 0
    if course.hub != nil { ready += 1 }
    if course.sections?.files != nil { ready += 1 }
    if course.sections?.links != nil { ready += 1 }
    if course.sections?.topics != nil { ready += 1 }
    return Double(ready) / 4
}

struct HomeScreen: View {
    var selectTab: (AppTab) -> Void = { _ in }

    private var cont: Course { liveCourses.first ?? kCourses[0] }
    private var spotlight: (prof: Professor, course: String)? {
        for c in kProfessorCourses {
            if let p = c.profs.first(where: { $0.hasRating }) { return (p, c.code) }
        }
        return nil
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                continueCard
                gridSection
                spotlightSection
                Text("For students, by a student.")
                    .font(.caption).foregroundStyle(EE.textDim)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 4)
            }
            .padding(.horizontal, Spacing.gutter)
            .padding(.vertical, 4)
            .padding(.bottom, 24)
        }
        .background(EE.bg.ignoresSafeArea())
        .navigationTitle("ECEUH")
    }

    // MARK: Continue

    private var continueCard: some View {
        EECard(glow: true) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    Image(systemName: "bolt.fill")
                        .font(.title3)
                        .foregroundStyle(.white)
                        .frame(width: 46, height: 46)
                        .background(EE.accentGrad, in: RoundedRectangle(cornerRadius: 13, style: .continuous))
                        .eeGlowSoft()
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Continue").eeKicker()
                        Text(cont.hub?.title ?? cont.displayArchiveTitle)
                            .font(.title3.weight(.bold)).foregroundStyle(EE.text)
                    }
                    Spacer(minLength: 0)
                }
                HStack(spacing: 10) {
                    EEProgressBar(value: readiness(cont))
                    Text("\(Int((readiness(cont) * 100).rounded()))%")
                        .font(.eeMono(.caption)).foregroundStyle(EE.textMuted)
                }
                NavigationLink(value: Route.courseDetail(slug: cont.slug)) {
                    HStack(spacing: 7) {
                        Text("Resume course")
                        Image(systemName: "arrow.right")
                    }
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .foregroundStyle(EE.onAccent)
                    .background(EE.accentGrad, in: RoundedRectangle(cornerRadius: Radii.md, style: .continuous))
                    .eeGlowSoft()
                }
                .buttonStyle(PressScaleStyle())
            }
        }
    }

    // MARK: Archives grid

    private var gridSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Course Archives") { selectTab(.archives) }
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(Array(liveCourses.prefix(3))) { course in
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
        }
    }

    // MARK: Faculty spotlight

    private var spotlightSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Faculty Ledger") { selectTab(.faculty) }
            if let spot = spotlight {
                let tier = RatingTier(overall: spot.prof.overall)
                EECard(glow: true) {
                    HStack(spacing: 14) {
                        Avatar(initials: spot.prof.initials, size: 64,
                               gradient: AvatarPalette.gradient(for: spot.prof.name))
                        VStack(alignment: .leading, spacing: 4) {
                            Text(spot.course)
                                .font(.eeMono(.caption2)).textCase(.uppercase).kerning(1.2)
                                .foregroundStyle(EE.accent)
                            Text(spot.prof.name).font(.title3.weight(.bold)).foregroundStyle(EE.text)
                            HStack(spacing: 10) {
                                Stars(value: spot.prof.overall ?? 0)
                                (Text(String(format: "%.1f", spot.prof.overall ?? 0))
                                    .font(.title3.weight(.bold)).foregroundStyle(tier.color)
                                 + Text(" / 5.0").font(.caption2).foregroundStyle(EE.textDim))
                            }
                        }
                        Spacer(minLength: 0)
                    }
                }
            }
        }
    }

    private func sectionHeader(_ title: String, all: @escaping () -> Void) -> some View {
        HStack {
            SectionTitle(text: title)
            Spacer()
            Button(action: all) {
                HStack(spacing: 2) { Text("All"); Image(systemName: "chevron.right") }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(EE.accent)
            }
        }
    }
}

#Preview {
    NavigationStack { HomeScreen() }.preferredColorScheme(.dark)
}
