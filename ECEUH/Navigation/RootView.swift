import SwiftUI

/// The app shell: a native `TabView` with one `NavigationStack` per tab. Nested
/// pushes are driven by the typed `Route` enum; the Sign-In screen is presented
/// as a full-screen cover.
struct RootView: View {
    @Environment(SessionStore.self) private var session
    @State private var selectedTab: AppTab = .academy

    var body: some View {
        @Bindable var session = session

        TabView(selection: $selectedTab) {
            tab(.academy) {
                HomeScreen(selectTab: { selectedTab = $0 })
            }
            tab(.research) {
                ArchivesScreen()
            }
            tab(.clubs) {
                ClubsScreen()
            }
            tab(.ratings) {
                FacultyScreen()
            }
            tab(.account) {
                SettingsScreen()
            }
        }
        .fullScreenCover(isPresented: $session.presentingSignIn) {
            SignInScreen()
        }
    }

    /// A tab whose root is wrapped in a `NavigationStack` with the shared
    /// route destinations attached.
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
        case .courseHub(let slug):     CourseHubScreen(slug: slug)
        case .fileLibrary(let slug):   FileLibraryScreen(slug: slug)
        case .externalLinks(let slug): ExternalLinksScreen(slug: slug)
        case .clubDetail(let slug):    ClubDetailScreen(slug: slug)
        case .privacy:                 PrivacyScreen()
        case .deleteAccount:           DeleteAccountScreen()
        }
    }
}

#Preview {
    RootView()
        .environment(ThemeService())
        .environment(NotificationService())
        .environment(SessionStore())
}
