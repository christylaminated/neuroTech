//
//  ContentView.swift
//  NeuroFade
//
//  Created by Talia Kusmirek on 4/5/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authManager = AuthManager()
    
    var body: some View {
        if authManager.isAuthenticated {
            MainTabView()
                .environmentObject(authManager)
        } else {
            LoginView()
                .environmentObject(authManager)
        }
    }
}

#Preview {
    ContentView()
}
