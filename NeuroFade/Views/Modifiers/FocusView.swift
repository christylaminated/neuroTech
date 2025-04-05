//
//  FocusView.swift
//  NeuroFade
//
//  Created by Talia Kusmirek on 4/5/25.
//

import SwiftUI

struct FocusView: View {
    @State private var showMainTab = false
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        VStack(spacing: 30) {
            Text("It's time to focus.")
                .font(.largeTitle)
                .foregroundColor(.blue)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 5)
            
            Text("Your EEG and ECG metrics are not within optimal ranges for access to this content.")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                showMainTab = true
            }) {
                Text("Check Your Levels")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.95))
        .edgesIgnoringSafeArea(.all)
        .fullScreenCover(isPresented: $showMainTab, content: {
            MainTabView()
                .environmentObject(authManager)
        })
    }
}

struct FocusView_Previews: PreviewProvider {
    static var previews: some View {
        FocusView()
            .environmentObject(AuthManager())
    }
}
