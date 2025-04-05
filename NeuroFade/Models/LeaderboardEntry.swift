import Foundation

struct LeaderboardEntry: Identifiable {
    let id = UUID()
    let username: String
    let neurocoins: Int
    let rank: Int
    let isCurrentUser: Bool
}