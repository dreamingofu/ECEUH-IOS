import SwiftUI

struct ClubsScreen: View {
    @State private var query = ""

    private var q: String { query.trimmingCharacters(in: .whitespaces).lowercased() }
    private var active: [Club] { kClubs.filter(\.isActive) }

    private func matches(_ c: Club) -> Bool {
        guard !q.isEmpty else { return true }
        return c.name.lowercased().contains(q)
            || (c.acronym?.lowercased().contains(q) ?? false)
            || c.category.rawValue.lowercased().contains(q)
            || c.tags.contains { $0.lowercased().contains(q) }
    }

    private var results: [Club] { active.filter(matches) }

    private func clubs(in category: ClubCategory) -> [Club] {
        active.filter { $0.category == category }
            .sorted { ($0.featured ? 0 : 1, $0.name) < ($1.featured ? 0 : 1, $1.name) }
    }

    var body: some View {
        List {
            if q.isEmpty {
                ForEach(ClubCategory.allCases, id: \.self) { category in
                    let list = clubs(in: category)
                    Section {
                        ForEach(list) { row($0) }
                    } header: {
                        header(category, count: list.count)
                    }
                }
            } else if results.isEmpty {
                ContentUnavailableView.search(text: query)
                    .listRowBackground(Color.clear)
            } else {
                Section {
                    ForEach(results) { row($0) }
                } header: {
                    Text("\(results.count) result\(results.count == 1 ? "" : "s")")
                        .foregroundStyle(EE.textDim)
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(EE.bg.ignoresSafeArea())
        .navigationTitle("Clubs")
        .searchable(text: $query, prompt: "Search clubs, tags, categories…")
        .tint(EE.accent)
    }

    private func row(_ club: Club) -> some View {
        NavigationLink(value: Route.clubDetail(slug: club.slug)) {
            ClubRow(club: club)
        }
        .listRowBackground(EE.bgCard)
    }

    private func header(_ category: ClubCategory, count: Int) -> some View {
        HStack(spacing: 8) {
            Circle().fill(category.color).frame(width: 7, height: 7)
            Text(category.rawValue).font(.footnote.weight(.bold)).foregroundStyle(EE.text)
            Spacer()
            Text("\(count)").font(.caption).foregroundStyle(EE.textDim).monospacedDigit()
        }
    }
}

struct ClubRow: View {
    let club: Club

    var body: some View {
        HStack(spacing: 14) {
            Text(club.badge)
                .font(.system(size: 14, weight: .bold))
                .minimumScaleFactor(0.5).lineLimit(1)
                .foregroundStyle(.white)
                .frame(width: 48, height: 48)
                .background(club.category.color.gradient,
                            in: RoundedRectangle(cornerRadius: 13, style: .continuous))
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 6) {
                    Text(club.name)
                        .font(.subheadline.weight(.semibold)).foregroundStyle(EE.text)
                        .lineLimit(2).fixedSize(horizontal: false, vertical: true)
                    if club.featured {
                        Image(systemName: "star.fill").font(.caption2).foregroundStyle(EE.accent)
                    }
                }
                HStack(spacing: 6) {
                    ForEach(club.tags.prefix(2), id: \.self) { TagChip(text: $0) }
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 5)
    }
}

#Preview {
    NavigationStack { ClubsScreen() }.preferredColorScheme(.dark)
}
