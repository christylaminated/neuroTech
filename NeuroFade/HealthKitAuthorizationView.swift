import SwiftUI

struct HealthKitAuthorizationView: View {
    @StateObject private var healthKitManager = HealthKitManager.shared
    @State private var isRequestingAuthorization = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.fill")
                .font(.system(size: 60))
                .foregroundColor(.red)
            
            Text("Health Data Access")
                .font(.title)
                .bold()
            
            Text("NeuroFade needs access to your heart rate and HRV data from your Apple Watch to provide personalized insights.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if let errorMessage = healthKitManager.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            
            Button(action: {
                isRequestingAuthorization = true
                Task {
                    await healthKitManager.requestAuthorization()
                    isRequestingAuthorization = false
                }
            }) {
                if isRequestingAuthorization {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    Text("Grant Access")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .disabled(isRequestingAuthorization)
            .padding(.horizontal)
        }
        .padding()
        .task {
            await healthKitManager.checkAuthorizationStatus()
        }
    }
} 