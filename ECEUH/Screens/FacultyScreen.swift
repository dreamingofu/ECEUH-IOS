import SwiftUI

struct FacultyScreen: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                FacultyStatSlide()
                ForEach(kProfessorCourses) { course in
                    CourseFacultySection(course: course)
                }
                Text("Sourced from RateMyProfessors — never invented.")
                    .font(.caption).foregroundStyle(EE.textDim)
                    .frame(maxWidth: .infinity).padding(.top, 4)
            }
            .padding(.horizontal, Spacing.gutter)
            .padding(.vertical, 4)
            .padding(.bottom, 24)
        }
        .background(EE.bg.ignoresSafeArea())
        .navigationTitle("Faculty")
    }
}

/// A "stat slide" header (design `slides/04-stat.html`): a glowing dark panel
/// with a red kicker, a heading, and three big red-gradient stat numbers.
private struct FacultyStatSlide: View {
    private var courseCount: Int { kProfessorCourses.count }
    private var profCount: Int { Set(kProfessorCourses.flatMap { $0.profs.map(\.name) }).count }
    private var topRating: Double { kProfessorCourses.flatMap(\.profs).compactMap(\.overall).max() ?? 0 }

    var body: some View {
        StatSlide(kicker: "By the numbers", heading: "Faculty, rated by students", stats: [
            StatSlideStat(number: "\(courseCount)", bold: "courses", rest: "with faculty"),
            StatSlideStat(number: "\(profCount)", bold: "professors", rest: "listed"),
            StatSlideStat(number: String(format: "%.1f", topRating), bold: "top rating", rest: "from RMP"),
        ])
    }
}

/// One class section: header + a row of selectable professor tabs; tapping a
/// professor reveals their (tier-colored) rating below.
private struct CourseFacultySection: View {
    let course: ProfessorCourse
    @State private var selected = 0

    private var safeIndex: Int { min(max(0, selected), course.profs.count - 1) }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(course.code)
                    .font(.eeMono(.caption2)).textCase(.uppercase).kerning(1)
                    .foregroundStyle(EE.accent)
                Text(course.title)
                    .font(.title3.weight(.bold)).foregroundStyle(EE.text)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(course.profs.enumerated()), id: \.offset) { index, prof in
                        ProfTab(prof: prof, selected: index == safeIndex) {
                            withAnimation(.easeOut(duration: 0.2)) { selected = index }
                        }
                    }
                }
                .padding(.vertical, 2)
                .padding(.horizontal, 1)
            }

            if let prof = course.profs[safe: safeIndex] {
                ProfDetailCard(prof: prof)
                    .id(safeIndex)
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
            }
        }
    }
}

/// A professor "tab": a tier dot + name; the selected tab gets a tier-colored ring.
private struct ProfTab: View {
    let prof: Professor
    let selected: Bool
    let action: () -> Void

    private var tier: RatingTier { RatingTier(overall: prof.overall) }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Circle().fill(tier.color).frame(width: 7, height: 7)
                Text(prof.shortName)
                    .font(.subheadline.weight(selected ? .semibold : .medium))
            }
            .foregroundStyle(selected ? EE.text : EE.textMuted)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Capsule().fill(selected ? EE.bgRaised : EE.bgCard))
            .overlay(Capsule().strokeBorder(selected ? tier.color.opacity(0.7) : EE.border,
                                            lineWidth: selected ? 1.5 : 1))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(prof.shortName), \(tier.label)")
        .accessibilityAddTraits(selected ? [.isSelected] : [])
    }
}

/// The selected professor's rating, color-coded by tier (avatar, score, bars).
private struct ProfDetailCard: View {
    let prof: Professor
    private var tier: RatingTier { RatingTier(overall: prof.overall) }

    var body: some View {
        EECard(padding: 16) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    Avatar(initials: prof.initials, size: 52,
                           gradient: AvatarPalette.gradient(for: prof.name))
                    VStack(alignment: .leading, spacing: 1) {
                        Text(prof.name).font(.headline).foregroundStyle(EE.text)
                        Text(prof.dept).font(.footnote).foregroundStyle(EE.textDim)
                    }
                    Spacer(minLength: 4)
                    if let overall = prof.overall {
                        VStack(alignment: .trailing, spacing: 0) {
                            Text(String(format: "%.1f", overall))
                                .font(.title.weight(.bold)).foregroundStyle(tier.color).monospacedDigit()
                            Text("/ 5.0").font(.caption2).textCase(.uppercase).kerning(0.8)
                                .foregroundStyle(EE.textDim)
                        }
                    }
                }

                if prof.hasRating {
                    VStack(spacing: 11) {
                        RatingBar(label: "Overall", fraction: (prof.overall ?? 0) / 5,
                                  valueText: String(format: "%.1f", prof.overall ?? 0),
                                  tint: RatingTier(overall: prof.overall).color)
                        RatingBar(label: "Difficulty", fraction: (prof.difficulty ?? 0) / 5,
                                  valueText: prof.difficulty.map { String(format: "%.1f", $0) } ?? "—",
                                  tint: RatingTier.difficulty(prof.difficulty).color)
                        RatingBar(label: "Would take again", fraction: Double(prof.wouldTake ?? 0) / 100,
                                  valueText: prof.wouldTake.map { "\($0)%" } ?? "—",
                                  tint: RatingTier.wouldTake(prof.wouldTake).color)
                    }
                    if let rmp = prof.rmpUrl {
                        EEButton(title: "View on RateMyProfessors", icon: "arrow.up.right",
                                 variant: .tinted, size: .small, block: true) {
                            ShareService.openExternal(rmp)
                        }
                    }
                } else {
                    Text("New to this course — no ratings yet.")
                        .font(.footnote).italic().foregroundStyle(EE.textDim)
                }
            }
        }
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    NavigationStack { FacultyScreen() }.preferredColorScheme(.dark)
}
