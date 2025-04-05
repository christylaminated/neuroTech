import SwiftUI

class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var neurocoins: Int = 0
    
    func login(username: String, password: String) {
        // In a real app, you'd validate credentials against a backend
        self.isAuthenticated = true
        self.currentUser = User(username: username, firstName: "", lastName: "", watchSynced: false)
    }
    
    func signUp(username: String, password: String, firstName: String, lastName: String) {
        // In a real app, you'd create user on backend
        self.isAuthenticated = true
        self.currentUser = User(username: username, firstName: firstName, lastName: lastName, watchSynced: false)
    }
    
    func logout() {
        self.isAuthenticated = false
        self.currentUser = nil
    }
    
    func syncWatch() {
        self.currentUser?.watchSynced = true
    }
    
    func updateUserDetails(firstName: String? = nil, lastName: String? = nil, username: String? = nil) {
        // In a real app, you'd make an API call to update the user details
        if let firstName = firstName {
            currentUser?.firstName = firstName
        }
        if let lastName = lastName {
            currentUser?.lastName = lastName
        }
        if let username = username {
            currentUser?.username = username
        }
        objectWillChange.send()
    }
    
    func incrementNeurocoins() {
        neurocoins += 1
        objectWillChange.send()
    }
    
    func getLeaderboard() -> [LeaderboardEntry] {
        // In a real app, this would fetch from a backend
        // Mock data for now
        let mockUsers = [
            LeaderboardEntry(username: currentUser?.username ?? "You", neurocoins: neurocoins, rank: 1, isCurrentUser: true),
            LeaderboardEntry(username: "FocusMaster", neurocoins: 2800, rank: 2, isCurrentUser: false),
            LeaderboardEntry(username: "ZenMind", neurocoins: 2500, rank: 3, isCurrentUser: false),
            LeaderboardEntry(username: "BrainWave", neurocoins: 2200, rank: 4, isCurrentUser: false),
            LeaderboardEntry(username: "NeuroHacker", neurocoins: 2000, rank: 5, isCurrentUser: false),
            LeaderboardEntry(username: "MindfulPro", neurocoins: 1800, rank: 6, isCurrentUser: false),
            LeaderboardEntry(username: "FocusNinja", neurocoins: 1600, rank: 7, isCurrentUser: false),
            LeaderboardEntry(username: "BrainBooster", neurocoins: 1400, rank: 8, isCurrentUser: false),
            LeaderboardEntry(username: "CalmMaster", neurocoins: 1200, rank: 9, isCurrentUser: false),
            LeaderboardEntry(username: "ZenWarrior", neurocoins: 1000, rank: 10, isCurrentUser: false)
        ]
        return mockUsers
    }
}
