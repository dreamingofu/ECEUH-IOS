import SwiftUI

struct FacultyScreen: View {
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                ForEach(kProfessorCourses) { course in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(course.code)
                            .font(.eeMono(.caption2)).textCase(.uppercase).kerning(1)
                            .foregroundStyle(EE.accent)
                        Text(course.title)
                            .font(.title3.weight(.bold)).foregroundStyle(EE.text)
                        VStack(spacing: 12) {
                            ForEach(course.profs, id: \.name) { ProfCard(prof: $0) }
                        }
                        .padding(.top, 4)
                    }
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

private struct ProfCard: View {
    let prof: Professor

    var body: some View {
        EECard(padding: 16) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    Avatar(initials: prof.initials, size: 48)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(prof.name).font(.headline).foregroundStyle(EE.text)
                        Text(prof.dept).font(.footnote).foregroundStyle(EE.textDim)
                    }
                    Spacer(minLength: 4)
                    if let overall = prof.overall {
                        VStack(alignment: .trailing, spacing: 0) {
                            Text(String(format: "%.1f", overall))
                                .font(.title2.weight(.bold)).foregroundStyle(EE.accent).monospacedDigit()
                            Text("/ 5.0").font(.caption2).textCase(.uppercase).kerning(0.8)
                                .foregroundStyle(EE.textDim)
                        }
                    }
                }
                if prof.hasRating {
                    VStack(spacing: 11) {
                        RatingBar(label: "Overall", fraction: (prof.overall ?? 0) / 5,
                                  valueText: String(format: "%.1f", prof.overall ?? 0))
                        RatingBar(label: "Difficulty", fraction: (prof.difficulty ?? 0) / 5,
                                  valueText: prof.difficulty.map { String(format: "%.1f", $0) } ?? "—")
                        RatingBar(label: "Would take again", fraction: Double(prof.wouldTake ?? 0) / 100,
                                  valueText: prof.wouldTake.map { "\($0)%" } ?? "—")
                    }
                } else {
                    Text("Unrated — no RateMyProfessors data yet.")
                        .font(.footnote).italic().foregroundStyle(EE.textDim)
                }
            }
        }
    }
}

#Preview {
    NavigationStack { FacultyScreen() }.preferredColorScheme(.dark)
}
