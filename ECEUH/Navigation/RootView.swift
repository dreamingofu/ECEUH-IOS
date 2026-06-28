import SwiftUI

/// App shell — four native tabs themed to the scarlet-on-black design. Sign-in
/// is optional (offered from Settings), so there's no forced launch gate.
struct RootView: View {
    @State private var selectedTab: AppTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            tab(.home) {
                HomeScreen(selectTab: { selectedTab = $0 })
            }
            tab(.archives) {
                ArchivesScreen()
            }
            tab(.faculty) {
                FacultyScreen()
            }
            tab(.settings) {
                SettingsScreen()
            }
        }
        .tint(EE.accent)
    }

    private func tab<Root: View>(_ tab: AppTab, @ViewBuilder root: () -> Root) -> some View {
        NavigationStack {
            root()
                .navigationDestination(for: Route.self, destination: routeDestination)
        }
        .tabItem { Label(tab.title, systemImage: tab.symbol) }
        .tag(tab)
    }

    @ViewBuilder
    private func routeDestination(_ route: Route) -> some View {
        switch route {
        case .courseDetail(let slug): CourseDetailScreen(slug: slug)
        case .fileLibrary(let slug):  FileLibraryScreen(slug: slug)
        case .externalLinks(let slug): ExternalLinksScreen(slug: slug)
        case .clubs:                  ClubsScreen()
        case .clubDetail(let slug):   ClubDetailScreen(slug: slug)
        case .privacy:                PrivacyScreen()
        case .deleteAccount:          DeleteAccountScreen()
        }
    }
}

#Preview {
    RootView()
        .environment(ThemeService())
        .environment(NotificationService())
        .environment(AuthService())
        .environment(ProgressService())
}
