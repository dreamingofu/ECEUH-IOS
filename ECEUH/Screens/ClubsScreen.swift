import SwiftUI

struct ClubsScreen: View {
    @State private var query = ""
    @State private var selectedTag: String?

    /// The five most-covered tags (by number of clubs carrying them) — the filters.
    /// Computed from the data so it stays correct as the directory grows.
    private static let topTags: [(tag: String, count: Int)] = {
        var counts: [String: Int] = [:]
        for club in kClubs where club.isActive {
            for tag in club.tags { counts[tag, default: 0] += 1 }
        }
        return counts
            .sorted { $0.value != $1.value ? $0.value > $1.value : $0.key < $1.key }
            .prefix(5)
            .map { (tag: $0.key, count: $0.value) }
    }()

    /// Distinct, non-brand colors assigned to the filters by position.
    private static let filterColors: [Color] = [
        Color(hex: 0x3B82F6),  // blue
        Color(hex: 0xA855F7),  // purple
        Color(hex: 0x34D399),  // emerald
        Color(hex: 0xF59E0B),  // amber
        Color(hex: 0xEC4899),  // pink
    ]

    private var q: String { query.trimmingCharacters(in: .whitespaces).lowercased() }
    private var active: [Club] { kClubs.filter(\.isActive) }

    private func matchesSearch(_ c: Club) -> Bool {
        guard !q.isEmpty else { return true }
        return c.name.lowercased().contains(q)
            || (c.acronym?.lowercased().contains(q) ?? false)
            || c.category.rawValue.lowercased().contains(q)
            || c.tags.contains { $0.lowercased().contains(q) }
    }

    private func matchesTag(_ c: Club) -> Bool {
        guard let selectedTag else { return true }
        return c.tags.contains(selectedTag)
    }

    private var results: [Club] {
        active.filter { matchesSearch($0) && matchesTag($0) }
            .sorted { ($0.featured ? 0 : 1, $0.name) < ($1.featured ? 0 : 1, $1.name) }
    }

    /// The default category-grouped layout shows only when nothing narrows it.
    private var showingGrouped: Bool { q.isEmpty && selectedTag == nil }

    private func clubs(in category: ClubCategory) -> [Club] {
        active.filter { $0.category == category }
            .sorted { ($0.featured ? 0 : 1, $0.name) < ($1.featured ? 0 : 1, $1.name) }
    }

    var body: some View {
        List {
            if showingGrouped {
                ForEach(ClubCategory.allCases, id: \.self) { category in
                    let list = clubs(in: category)
                    Section {
                        ForEach(list) { row($0) }
                    } header: {
                        header(category, count: list.count)
                    }
                }
            } else if results.isEmpty {
                emptyResults
                    .listRowBackground(Color.clear)
            } else {
                Section {
                    ForEach(results) { row($0) }
                } header: {
                    Text(resultsHeader).foregroundStyle(EE.textDim)
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(EE.bg.ignoresSafeArea())
        .safeAreaInset(edge: .top, spacing: 0) { filterBar }
        .navigationTitle("Clubs")
        .searchable(text: $query, prompt: "Search clubs, tags, categories…")
        .tint(EE.accent)
    }

    private var resultsHeader: String {
        if let selectedTag, q.isEmpty {
            return "\(results.count) in \(selectedTag)"
        }
        return "\(results.count) result\(results.count == 1 ? "" : "s")"
    }

    @ViewBuilder private var emptyResults: some View {
        if !q.isEmpty {
            ContentUnavailableView.search(text: query)
        } else {
            ContentUnavailableView("No clubs here", systemImage: "person.3",
                                   description: Text("Nothing tagged \(selectedTag ?? "")."))
        }
    }

    // MARK: Filter bar

    /// Horizontally-scrolling, color-coded tag filters pinned under the search bar.
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(Self.topTags.enumerated()), id: \.element.tag) { index, item in
                    FilterChip(title: item.tag, count: item.count,
                               color: Self.filterColors[index % Self.filterColors.count],
                               selected: selectedTag == item.tag) {
                        withAnimation(.easeOut(duration: 0.15)) {
                            selectedTag = (selectedTag == item.tag) ? nil : item.tag
                        }
                    }
                }
            }
            .padding(.horizontal, Spacing.gutter)
            .padding(.vertical, 10)
        }
        .background(EE.bg)
        .overlay(alignment: .bottom) { Rectangle().fill(EE.separator).frame(height: 0.5) }
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

/// A color-coded tag filter pill with a club-count badge.
private struct FilterChip: View {
    let title: String
    let count: Int
    let color: Color
    let selected: Bool
    let action: () -> Void

    var body: some View {
        // On the saturated selected fill, near-black text clears WCAG AA on all
        // five filter colors (white does not — emerald/amber only reach ~2:1).
        let onFill = Color.black
        return Button(action: action) {
            HStack(spacing: 6) {
                Circle().fill(selected ? onFill : color).frame(width: 7, height: 7)
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(selected ? onFill : EE.text)
                Text("\(count)")
                    .font(.caption2.weight(.bold)).monospacedDigit()
                    .foregroundStyle(selected ? onFill : color)
                    .padding(.horizontal, 6).padding(.vertical, 2)
                    .background(selected ? Color.black.opacity(0.14) : color.opacity(0.16), in: Capsule())
            }
            .padding(.horizontal, 12).padding(.vertical, 8)
            .background(selected ? AnyShapeStyle(color) : AnyShapeStyle(color.opacity(0.12)), in: Capsule())
            .overlay(Capsule().strokeBorder(selected ? Color.clear : color.opacity(0.35)))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(title), \(count) club\(count == 1 ? "" : "s")")
        .accessibilityAddTraits(selected ? [.isSelected] : [])
    }
}

#Preview {
    NavigationStack { ClubsScreen() }.preferredColorScheme(.dark)
}
