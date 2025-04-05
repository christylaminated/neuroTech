import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var editingField: String?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("PROFILE")
                .font(.largeTitle)
                .bold()
            
            VStack(spacing: 25) {
                EditableInfoRow(
                    title: "Username",
                    value: authManager.currentUser?.username ?? "",
                    isEditing: editingField == "username",
                    onEdit: { editingField = "username" },
                    onSave: { newValue in
                        authManager.updateUserDetails(username: newValue)
                        editingField = nil
                    }
                )
                
                EditableInfoRow(
                    title: "First Name",
                    value: authManager.currentUser?.firstName ?? "",
                    isEditing: editingField == "firstName",
                    onEdit: { editingField = "firstName" },
                    onSave: { newValue in
                        authManager.updateUserDetails(firstName: newValue)
                        editingField = nil
                    }
                )
                
                EditableInfoRow(
                    title: "Last Name",
                    value: authManager.currentUser?.lastName ?? "",
                    isEditing: editingField == "lastName",
                    onEdit: { editingField = "lastName" },
                    onSave: { newValue in
                        authManager.updateUserDetails(lastName: newValue)
                        editingField = nil
                    }
                )
                
                Button(action: {
                    authManager.syncWatch()
                }) {
                    Text(authManager.currentUser?.watchSynced ?? false ? "Watch Synced" : "Sync Watch")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(authManager.currentUser?.watchSynced ?? false)
                
                Button(action: {
                    authManager.logout()
                }) {
                    Text("Logout")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 40)
            
            Spacer()
        }
        .padding()
    }
}

struct EditableInfoRow: View {
    let title: String
    let value: String
    let isEditing: Bool
    let onEdit: () -> Void
    let onSave: (String) -> Void
    
    @State private var editedValue: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            
            HStack {
                if isEditing {
                    TextField("", text: $editedValue)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .onAppear {
                            editedValue = value
                        }
                    
                    Button(action: {
                        onSave(editedValue)
                    }) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                } else {
                    Text(value)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    
                    Button(action: onEdit) {
                        Image(systemName: "pencil.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }
}
