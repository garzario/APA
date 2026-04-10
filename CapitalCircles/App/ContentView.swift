import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            NavigationStack {
                GoalsListView()
            }
            .tabItem {
                Label("Goals", systemImage: "target")
            }
            .tag(1)

            CirclesListView()
                .tabItem {
                    Label("Circles", systemImage: "person.3.fill")
                }
                .tag(2)

            NavigationStack {
                StatementView()
            }
            .tabItem {
                Label("Insights", systemImage: "chart.bar.fill")
            }
            .tag(3)

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle.fill")
                }
                .tag(4)
        }
        .tint(CCTheme.primaryBlue)
    }
}

#Preview {
    ContentView()
        .environment(AppState())
        .environment(AppStateManager.shared)
}
