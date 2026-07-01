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

/// Home is reserved for unique, app-only features: a search box over the whole
/// app, the quote header, a per-session Clubs spotlight, and the personal planner.
struct HomeScreen: View {
    var selectTab: (AppTab) -> Void = { _ in }

    @Environment(CalendarStore.self) private var calendar
    @Environment(SemesterStore.self) private var semester
    @State private var query = ""
    @State private var showingSemesterSetup = false
    @FocusState private var searchFocused: Bool

    private var trimmedQuery: String { query.trimmingCharacters(in: .whitespaces) }
    private var searching: Bool { !trimmedQuery.isEmpty }
    private var results: [SearchResult] { AppSearch.results(for: query) }

    private var activeClubCount: Int { kClubs.filter(\.isActive).count }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                searchField

                if searching {
                    searchResults
                } else {
                    HomeQuoteSlide()
                    activeCoursesCard
                    plannerCard
                    clubsCard
                }
            }
            .padding(.horizontal, Spacing.gutter)
            .padding(.vertical, 4)
            .padding(.bottom, 24)
            .animation(.easeInOut(duration: 0.18), value: searching)
        }
        .background(EE.bg.ignoresSafeArea())
        .navigationTitle("ECEUH")
        .scrollDismissesKeyboard(.interactively)
        .sheet(isPresented: $showingSemesterSetup) {
            SemesterSetupSheet(store: semester)
        }
    }

    // MARK: Search

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass").foregroundStyle(EE.textDim)
            TextField("Search courses, files, clubs, faculty…", text: $query)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .focused($searchFocused)
                .foregroundStyle(EE.text)
            if !query.isEmpty {
                Button {
                    query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(EE.textDim)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 11)
        .background(EE.bgCard, in: RoundedRectangle(cornerRadius: Radii.md, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: Radii.md, style: .continuous)
            .strokeBorder(searchFocused ? EE.accentLine : EE.border,
                          lineWidth: searchFocused ? 1.5 : 1))
    }

    @ViewBuilder private var searchResults: some View {
        if results.isEmpty {
            ContentUnavailableView.search(text: trimmedQuery)
                .frame(maxWidth: .infinity).padding(.vertical, 44)
        } else {
            VStack(alignment: .leading, spacing: 10) {
                Text("\(results.count) result\(results.count == 1 ? "" : "s")")
                    .font(.caption.weight(.semibold)).foregroundStyle(EE.textDim)
                    .padding(.leading, 2)
                VStack(spacing: 8) {
                    ForEach(results) { result in
                        SearchResultRow(result: result) { tab in
                            query = ""
                            searchFocused = false
                            selectTab(tab)
                        }
                    }
                }
            }
        }
    }

    // MARK: Cards

    private var activeCoursesCard: some View {
        ActiveCoursesCard(store: semester) { showingSemesterSetup = true }
    }

    private var clubsCard: some View {
        NavigationLink(value: Route.clubs) {
            HubCard(icon: "person.3.fill",
                    title: "Clubs & Orgs",
                    subtitle: "Explore \(activeClubCount) UH Cullen student organizations — engineering societies, technical teams, and honor societies.",
                    tags: ["Engineering", "Technology", "Honor"],
                    count: "\(activeClubCount)",
                    open: "Browse clubs",
                    gradient: SessionAccent.clubGradient.gradient,
                    glowColor: SessionAccent.clubGradient.glowColor)
        }
        .buttonStyle(PressScaleStyle())
    }

    private var plannerCard: some View {
        NavigationLink(value: Route.calendar) {
            PlannerHomeCard(next: calendar.upcoming.first, count: calendar.upcoming.count)
        }
        .buttonStyle(PressScaleStyle())
    }
}

/// One global-search hit. Routes push within the Home stack; a tab destination
/// (faculty) switches tabs via the `onTab` callback.
private struct SearchResultRow: View {
    let result: SearchResult
    var onTab: (AppTab) -> Void

    var body: some View {
        switch result.destination {
        case .route(let route):
            NavigationLink(value: route) { content }
                .buttonStyle(PressScaleStyle())
        case .tab(let tab):
            Button { onTab(tab) } label: { content }
                .buttonStyle(PressScaleStyle())
        }
    }

    private var content: some View {
        HStack(spacing: 12) {
            IconTile(systemName: result.kind.icon, color: result.kind.tint, size: 36)
            VStack(alignment: .leading, spacing: 2) {
                Text(result.title)
                    .font(.subheadline.weight(.semibold)).foregroundStyle(EE.text).lineLimit(1)
                Text(result.subtitle)
                    .font(.footnote).foregroundStyle(EE.textDim).lineLimit(1)
            }
            Spacer(minLength: 8)
            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold)).foregroundStyle(EE.textFaint)
        }
        .padding(.horizontal, 12).padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(EE.bgCard, in: RoundedRectangle(cornerRadius: Radii.md, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: Radii.md, style: .continuous).strokeBorder(EE.border))
        .contentShape(Rectangle())
    }
}

/// A "quote slide" header (design `slides/05-quote.html`): a big serif quote
/// mark, an italic serif pull-quote, and a logo attribution, over a red glow.
private struct HomeQuoteSlide: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\u{201C}")
                .font(.system(size: 64, weight: .bold, design: .serif))
                .foregroundStyle(EE.accent)
                .frame(height: 30, alignment: .top)
                .accessibilityHidden(true)
            Text("For students, by a student — built in real time, every semester.")
                .font(.system(.title2, design: .serif).weight(.medium))
                .italic()
                .foregroundStyle(EE.text)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 12) {
                Image("AppLogo")
                    .resizable().scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                VStack(alignment: .leading, spacing: 1) {
                    Text("The ECEUH project").font(.subheadline.weight(.bold)).foregroundStyle(EE.text)
                    Text("UH Electrical & Computer Engineering").font(.footnote).foregroundStyle(EE.textDim)
                }
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(22)
        .background {
            ZStack {
                EE.bgCard
                RadialGradient(colors: [Color(hex: 0xEC1B34, alpha: 0.20), .clear],
                               center: UnitPoint(x: 0.5, y: 1.15), startRadius: 0, endRadius: 380)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: Radii.xl, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: Radii.xl, style: .continuous).strokeBorder(EE.border))
        .eeCardShadow()
    }
}

#Preview {
    NavigationStack { HomeScreen() }
        .environment(CalendarStore(notifications: NotificationService(), calendarSync: CalendarSyncService()))
        .environment(SemesterStore())
        .preferredColorScheme(.dark)
}
