import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Hub", systemImage: "house")
                }
                .tag(0)

            NavigationStack {
                StatementView()
            }
            .tabItem {
                Label("Insights", systemImage: "chart.bar")
            }
            .tag(1)

            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("Profile", systemImage: "person")
            }
            .tag(2)
        }
        .tint(CCTheme.navy)
    }
}

#Preview {
    ContentView()
        .environment(AppState())
        .environment(AppStateManager.shared)
}
