import SwiftUI

struct MainTabView: View {
    init() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithTransparentBackground()
        
        // Add blur effect
        let blurEffect = UIBlurEffect(style: .regular)
        let blurView = UIVisualEffectView(effect: blurEffect)
        tabBarAppearance.backgroundEffect = UIBlurEffect(style: .regular)
        
        // Make background semi-transparent
        tabBarAppearance.backgroundColor = UIColor(white: 1, alpha: 0.2)
        
        // Customize colors for unselected items (white)
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = .white
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        // Create a dark purple color (RGB values adjusted for darker purple)
        let darkPurple = UIColor(red: 0.25, green: 0.0, blue: 0.35, alpha: 1.0)
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = darkPurple
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: darkPurple]
        
        // Apply the appearance
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
    
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
        .appBackground(imageName: "home")
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthManager())
}
