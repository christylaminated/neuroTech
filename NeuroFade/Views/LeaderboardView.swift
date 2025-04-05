import SwiftUI

struct LeaderboardView: View {
    @EnvironmentObject var authManager: AuthManager
    
    private func getCurrentUserRank() -> Int {
        return authManager.getLeaderboard().first { entry in
            entry.username == authManager.currentUser?.username
        }?.rank ?? 0
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("LEADERBOARD")
                    .appText(size: AppStyle.titleSize)
                    .padding(.top)
                
                // User Stats Card
                VStack(spacing: 16) {
                    // Coin Icon
                    Image("coin")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                    
                    // Coin Count
                    Text("\(authManager.neurocoins)")
                        .appText(size: 32)
                        .bold()
                    
                    // Rank
                    VStack(spacing: 4) {
                        Text("YOUR RANK")
                            .appText(size: 16)
                            .opacity(0.8)
                        Text("#\(getCurrentUserRank())")
                            .appText(size: 28)
                            .bold()
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(15)
                .padding(.horizontal)
                
                // Leaderboard List
                VStack(spacing: 12) {
                    ForEach(authManager.getLeaderboard(), id: \.rank) { entry in
                        LeaderboardRowView(entry: entry, isCurrentUser: entry.username == authManager.currentUser?.username)
                    }
                }
                .padding()
            }
            .padding(.bottom, 20)
        }
        .appBackground(imageName: "home")
    }
}

struct LeaderboardRowView: View {
    let entry: LeaderboardEntry
    let isCurrentUser: Bool
    
    var body: some View {
        HStack {
            Text("#\(entry.rank)")
                .appText(size: 20)
                .frame(width: 50)
            
            Text(entry.username)
                .appText()
            
            Spacer()
            
            HStack(spacing: 4) {
                Image("coin")
                    .resizable()
                    .frame(width: 20, height: 20)
                Text("\(entry.neurocoins)")
                    .appText()
            }
        }
        .padding()
        .background(isCurrentUser ? .regularMaterial : .ultraThinMaterial)
        .if(isCurrentUser) { view in
            view.overlay(Color.purple.opacity(0.3))
        }
        .cornerRadius(10)
    }
}

extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

#Preview {
    LeaderboardView()
        .environmentObject(AuthManager())
}
