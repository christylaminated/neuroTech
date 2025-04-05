//
//  BlockAppsView.swift
//  NeuroFade
//
//  Created by Talia Kusmirek on 4/5/25.
//

// The ability to select apps on your device to block them from being used
// Display the current list of blocked apps, with the ability to add, remove, and edit them

import SwiftUI

struct App: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    var isBlocked: Bool
}

struct BlockAppsView: View {
    @State private var apps: [App] = [
        App(name: "Instagram", icon: "camera.fill", isBlocked: true),
        App(name: "Twitter", icon: "bird.fill", isBlocked: false),
        App(name: "TikTok", icon: "play.circle.fill", isBlocked: true),
        App(name: "Facebook", icon: "person.2.fill", isBlocked: false),
        App(name: "YouTube", icon: "play.rectangle.fill", isBlocked: true)
    ]
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                Text("BLOCKED APPS")
                    .font(.largeTitle)
                    .bold()
                
                Text("Toggle apps you want to block during focus time")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                List {
                    ForEach($apps) { $app in
                        HStack {
                            Image(systemName: app.icon)
                                .foregroundColor(app.isBlocked ? .red : .gray)
                                .font(.title2)
                            
                            Text(app.name)
                                .font(.headline)
                            
                            Spacer()
                            
                            Toggle("", isOn: $app.isBlocked)
                                .tint(.red)
                        }
                        .padding(.vertical, 8)
                    }
                }
                .listStyle(PlainListStyle())
                
                VStack(spacing: 16) {
                    Button(action: {
                        // Debug: Print blocked apps
                        let blockedApps = apps.filter { $0.isBlocked }.map { $0.name }
                        print("Blocked Apps:", blockedApps)
                    }) {
                        Text("Save Changes")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    
                    Text("Debug: \(apps.filter { $0.isBlocked }.count) apps blocked")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    BlockAppsView()
}
