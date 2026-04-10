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

            CirclesListView()
                .tabItem {
                    Label("Circles", systemImage: "person.3.fill")
                }
                .tag(1)

            StatementView()
                .tabItem {
                    Label("Insights", systemImage: "chart.bar.fill")
                }
                .tag(2)

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle.fill")
                }
                .tag(3)
        }
        .tint(CCTheme.primaryBlue)
    }
}

#Preview {
    ContentView()
        .environment(AppState())
}
