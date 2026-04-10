import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Family", systemImage: "house")
                }
                .tag(0)

            NavigationStack {
                GoalsListView()
            }
            .tabItem {
                Label("Goals", systemImage: "target")
            }
            .tag(1)

            NavigationStack {
                CirclesListView()
            }
            .tabItem {
                Label("Circles", systemImage: "person.2")
            }
            .tag(2)

            NavigationStack {
                StatementView()
            }
            .tabItem {
                Label("Insights", systemImage: "chart.bar")
            }
            .tag(3)

            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("Profile", systemImage: "person")
            }
            .tag(4)
        }
        .tint(CCTheme.navy)
    }
}

#Preview {
    ContentView()
        .environment(AppState())
        .environment(AppStateManager.shared)
}
