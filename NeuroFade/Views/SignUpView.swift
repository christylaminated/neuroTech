import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var username = ""
    @State private var password = ""
    
    var body: some View {
        VStack(spacing: 32) {
            Text("CREATE ACCOUNT")
                .appText(size: AppStyle.titleSize)
                .padding(.top, 50)
            
            VStack(spacing: 20) {
                TextField("First Name", text: $firstName)
                    .appText()
                    .appTextField()
                
                TextField("Last Name", text: $lastName)
                    .appText()
                    .appTextField()
                
                TextField("Username", text: $username)
                    .appText()
                    .appTextField()
                
                SecureField("Password", text: $password)
                    .appText()
                    .appTextField()
                
                Button("Sign Up") {
                    authManager.signUp(username: username, password: password, firstName: firstName, lastName: lastName)
                    dismiss()
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
    }
}

struct InputField: View {
    let title: String
    @Binding var text: String
    var isSecure: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            
            if isSecure {
                SecureField("", text: $text)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            } else {
                TextField("", text: $text)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
        }
    }
}

#Preview {
    SignUpView()
        .environmentObject(AuthManager())
}
