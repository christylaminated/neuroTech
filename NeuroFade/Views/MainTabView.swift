import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "timer")
                }
            
            LeaderboardView()
                .tabItem {
                    Label("Leaderboard", systemImage: "circles.hexagonpath.fill")
                }
            
            
            BlockAppsView()
                .tabItem {
                    Label("Block Apps", systemImage: "app.badge")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthManager())
}
