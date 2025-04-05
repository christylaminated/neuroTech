//
//  ContentView.swift
//  NeuroFade
//
//  Created by Talia Kusmirek on 4/5/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authManager = AuthManager()
    @StateObject private var healthKitManager = HealthKitManager.shared
    
    var body: some View {
        if authManager.isAuthenticated {
            if healthKitManager.isAuthorized {
                MainTabView()
                    .environmentObject(authManager)
            } else {
                HealthKitAuthorizationView()
                    .environmentObject(authManager)
            }
        } else {
            LoginView()
                .environmentObject(authManager)
        }
    }
}

#Preview {
    ContentView()
}
