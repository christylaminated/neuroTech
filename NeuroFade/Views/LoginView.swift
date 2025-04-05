import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var username = ""
    @State private var password = ""
    @State private var showingSignUp = false
    
    var body: some View {
        VStack(spacing: 32) {
            Text("NEUROFADE")
                .appText(size: AppStyle.titleSize)
                .padding(.top, 50)
            
            VStack(spacing: 20) {
                TextField("Username", text: $username)
                    .appText()
                    .appTextField()
                
                SecureField("Password", text: $password)
                    .appText()
                    .appTextField()
                
                Button("Login") {
                    authManager.login(username: username, password: password)
                }
                .appButton()
                
                Button("Create Account") {
                    showingSignUp = true
                }
                .appButton()
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(15)
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .appBackground(imageName: "login")
        .sheet(isPresented: $showingSignUp) {
            SignUpView()
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthManager())
}
