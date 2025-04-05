import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    
    @State private var username = ""
    @State private var password = ""
    @State private var firstName = ""
    @State private var lastName = ""
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("CREATE ACCOUNT")
                    .font(.largeTitle)
                    .bold()
                
                VStack(spacing: 25) {
                    InputField(title: "Username", text: $username)
                    InputField(title: "Password", text: $password, isSecure: true)
                    InputField(title: "First Name", text: $firstName)
                    InputField(title: "Last Name", text: $lastName)
                    
                    Button(action: {
                        authManager.signUp(
                            username: username,
                            password: password,
                            firstName: firstName,
                            lastName: lastName
                        )
                        dismiss()
                    }) {
                        Text("Sign Up")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 40)
                
                Spacer()
            }
            .padding()
            .navigationBarItems(trailing: Button("Cancel") { 
                dismiss()
            })
        }
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
