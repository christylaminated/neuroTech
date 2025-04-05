import SwiftUI

struct LeaderboardView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 20) {
                Text("Who's on top?")
                    .font(.largeTitle)
                    .foregroundColor(.primary)
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                    .padding(.bottom, -10)
                
                Text("Gain coins by staying in focus mode!")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 20)
                    .padding(.bottom, -120)
                
                // User's stats card
                VStack(spacing: 4) {
                    Image("coin")
                        .resizable()
                        .renderingMode(.original)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                    
                    Text("\(authManager.neurocoins)")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Rank #\(getCurrentRank())")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white)
                        .shadow(radius: 5)
                )
                .padding(.horizontal)
                .padding(.top)
                
                // Leaderboard list
                VStack(spacing: 0) {
                    ForEach(authManager.getLeaderboard()) { entry in
                        LeaderboardRow(entry: entry)
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                        
                        if entry.rank < authManager.getLeaderboard().count {
                            Divider()
                                .padding(.horizontal)
                        }
                    }
                }
                .background(Color.white)
                .cornerRadius(15)
                .shadow(radius: 5)
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .background(Color.gray.opacity(0.1))
        .edgesIgnoringSafeArea(.bottom)
    }
    
    private func getCurrentRank() -> Int {
        return authManager.getLeaderboard().first(where: { $0.isCurrentUser })?.rank ?? 0
    }
}

struct LeaderboardRow: View {
    let entry: LeaderboardEntry
    
    var body: some View {
        HStack(spacing: 15) {
            Text("#\(entry.rank)")
                .font(.headline)
                .foregroundColor(.gray)
                .frame(width: 40, alignment: .leading)
            
            Text(entry.username)
                .font(.body)
                .foregroundColor(entry.isCurrentUser ? .blue : .primary)
                .fontWeight(entry.isCurrentUser ? .bold : .regular)
            
            Spacer()
            
            HStack(spacing: 5) {
                Image("coin")
                    .resizable()
                    .renderingMode(.original)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                Text("\(entry.neurocoins)")
                    .font(.headline)
            }
        }
        .contentShape(Rectangle()) // Makes the entire row tappable
    }
}

#Preview {
    LeaderboardView()
        .environmentObject(AuthManager())
}
