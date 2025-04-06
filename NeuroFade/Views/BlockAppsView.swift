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
    @State private var selectedApps: Set<String> = []
    @State private var showingSaveAlert = false
    @State private var saveSuccess = false
    
    let availableApps = [
        "Instagram",
        "TikTok",
        "X",
        "YouTube",
        "Snapchat",
        "Messages",
        "Mail"
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("BLOCK APPS")
                    .appText(size: AppStyle.titleSize)
                    .padding(.top)
                
                // Description Card
                VStack(alignment: .leading, spacing: 16) {
                    Text("Select apps to block during focus time:")
                        .appText()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(15)
                .padding(.horizontal)
                
                // Apps List
                VStack(spacing: 12) {
                    ForEach(availableApps, id: \.self) { app in
                        Button(action: {
                            if selectedApps.contains(app) {
                                selectedApps.remove(app)
                            } else {
                                selectedApps.insert(app)
                            }
                        }) {
                            HStack {
                                Image(systemName: "app.fill")
                                    .foregroundColor(.white)
                                    .frame(width: 24, height: 24)
                                
                                Text(app)
                                    .appText()
                                
                                Spacer()
                                
                                Image(systemName: selectedApps.contains(app) ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(.white)
                                    .font(.system(size: 20))
                            }
                            .padding()
                            .background(selectedApps.contains(app) ? .regularMaterial : .ultraThinMaterial)
                            .if(selectedApps.contains(app)) { view in
                                view.overlay(Color.purple.opacity(0.3))
                            }
                            .cornerRadius(10)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Save Button
                Button("Save Changes") {
                    saveBlockedApps()
                }
                .appButton()
                .padding(.horizontal)
                .padding(.top, 12)
            }
            .padding(.bottom, 20)
        }
        .appBackground(imageName: "home")
        .alert("Success", isPresented: $showingSaveAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(saveSuccess ? "Apps saved successfully!" : "Failed to save apps. Please try again.")
        }
    }
    
    private func saveBlockedApps() {
        // Save the selected apps to UserDefaults
        UserDefaults.standard.set(Array(selectedApps), forKey: "blockedApps")
        saveSuccess = true
        showingSaveAlert = true
    }
}

#Preview {
    BlockAppsView()
}
