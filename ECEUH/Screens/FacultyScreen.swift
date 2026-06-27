import SwiftUI

struct FacultyScreen: View {
    @State private var query = ""

    private var filtered: [ProfessorCourse] {
        let q = query.lowercased()
        guard !q.isEmpty else { return kProfessorCourses }
        return kProfessorCourses.compactMap { course in
            let profs = course.profs.filter { p in
                p.name.lowercased().contains(q)
                    || course.title.lowercased().contains(q)
                    || course.code.lowercased().contains(q)
            }
            guard !profs.isEmpty else { return nil }
            return ProfessorCourse(id: course.id, code: course.code, title: course.title, profs: profs)
        }
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                ForEach(filtered) { course in
                    CourseFacultySection(course: course)
                }
                if filtered.isEmpty {
                    ContentUnavailableView.search(text: query).padding(.top, 48)
                }
            }
            .padding()
        }
        .navigationTitle("Faculty")
        .searchable(text: $query, prompt: "Search courses or professors…")
    }
}

private struct CourseFacultySection: View {
    let course: ProfessorCourse

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(course.title).font(.headline)
                Spacer()
                TagChip(text: course.code.replacingOccurrences(of: " ", with: "_"))
            }
            ForEach(course.profs, id: \.name) { prof in
                ProfCard(prof: prof)
            }
        }
    }
}

private struct ProfCard: View {
    let prof: Professor

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Text(prof.initials)
                    .font(.subheadline.weight(.heavy))
                    .foregroundStyle(Color.accentColor)
                    .frame(width: 48, height: 48)
                    .background(Color.accentColor.opacity(0.12), in: Circle())
                    .overlay(Circle().strokeBorder(Color.accentColor.opacity(0.32), lineWidth: 1.5))
                VStack(alignment: .leading, spacing: 2) {
                    Text(prof.name).font(.headline)
                    Text(prof.dept).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
            }

            if prof.hasRating {
                RatingBar(label: "Overall Rating",
                          fraction: (prof.overall ?? 0) / 5,
                          valueText: "\(String(format: "%.1f", prof.overall ?? 0)) / 5.0")
                RatingBar(label: "Difficulty",
                          fraction: (prof.difficulty ?? 0) / 5,
                          valueText: prof.difficulty.map { "\(String(format: "%.1f", $0)) / 5.0" } ?? "—")
                RatingBar(label: "Would Take Again",
                          fraction: Double(prof.wouldTake ?? 0) / 100,
                          valueText: prof.wouldTake.map { "\($0)%" } ?? "—")
            } else {
                Text("No ratings yet.")
                    .font(.caption).italic()
                    .foregroundStyle(.secondary)
            }

            if let rmp = prof.rmpUrl {
                Button {
                    ShareService.openExternal(rmp)
                } label: {
                    Label("View on RMP", systemImage: "arrow.up.forward.app")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: Radii.lg, style: .continuous))
    }
}

#Preview {
    NavigationStack { FacultyScreen() }
}
