import SwiftUI

struct ClubsScreen: View {
    @State private var query = ""

    private var filtered: [Club] {
        let q = query.trimmingCharacters(in: .whitespaces).lowercased()
        guard !q.isEmpty else { return kClubs }
        return kClubs.filter { club in
            club.name.lowercased().contains(q)
                || club.description.lowercased().contains(q)
                || club.tags.contains { $0.contains(q) }
        }
    }

    var body: some View {
        List {
            Section {
                SectionHeader(
                    kicker: "Campus Clubs",
                    title: "Find Your People.",
                    subtitle: "Student organizations for every engineer at UH Cullen."
                )
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }

            if filtered.isEmpty {
                ContentUnavailableView.search(text: query)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            } else {
                ForEach(filtered) { club in
                    NavigationLink(value: Route.clubDetail(slug: club.slug)) {
                        ClubRow(club: club)
                    }
                }
            }
        }
        .navigationTitle("Clubs")
        .searchable(text: $query, prompt: "Search clubs or tags…")
    }
}

struct ClubRow: View {
    let club: Club

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: club.symbolName)
                .font(.title3)
                .foregroundStyle(Color.accentColor)
                .frame(width: 48, height: 48)
                .background(Color.accentColor.opacity(0.1), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            VStack(alignment: .leading, spacing: 6) {
                Text(club.name).font(.headline)
                Text(club.description)
                    .font(.subheadline).foregroundStyle(.secondary).lineLimit(2)
                HStack(spacing: 6) {
                    ForEach(club.tags, id: \.self) { TagChip(text: $0) }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack { ClubsScreen() }
}
