import SwiftUI
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var isEditingProfile = false
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var username = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var profileImage: Image?
    
    var body: some View {
        ScrollView {
            VStack {
                Text("PROFILE")
                    .appText(size: AppStyle.titleSize)
                    .padding(.top)
                
                Spacer()
                    .frame(height: 160)
                
                // Profile Picture and Info Container
                VStack(spacing: 16) {
                    // Profile Picture
                    ZStack {
                        if let profileImage = profileImage {
                            profileImage
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 120, height: 120)
                                .foregroundColor(.white)
                        }
                        
                        // Camera Button
                        PhotosPicker(selection: $selectedItem,
                                   matching: .images) {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 35, height: 35)
                                .overlay(
                                    Image(systemName: "camera.fill")
                                        .foregroundColor(.white)
                                )
                        }
                        .position(x: 90, y: 90)
                    }
                    .padding(.bottom, 8)
                    
                    // User Info (Always Visible)
                    Group {
                        if let user = authManager.currentUser {
                            Text("\(user.firstName) \(user.lastName)")
                                .appText(size: 24)
                                .multilineTextAlignment(.center)
                            
                            Text("@\(user.username)")
                                .appText()
                                .opacity(0.8)
                        } else {
                            Text("No user data available")
                                .appText()
                                .foregroundColor(.red)
                        }
                    }
                    
                    // Edit Profile Button or Form
                    if isEditingProfile {
                        VStack(spacing: 16) {
                            TextField("First Name", text: $firstName)
                                .appText()
                                .appTextField()
                            
                            TextField("Last Name", text: $lastName)
                                .appText()
                                .appTextField()
                            
                            TextField("Username", text: $username)
                                .appText()
                                .appTextField()
                            
                            HStack(spacing: 20) {
                                Button("Cancel") {
                                    isEditingProfile = false
                                }
                                .appButton()
                                
                                Button("Save") {
                                    authManager.updateUserDetails(firstName: firstName, lastName: lastName, username: username)
                                    isEditingProfile = false
                                }
                                .appButton()
                            }
                        }
                    } else {
                        Button("Edit Profile") {
                            firstName = authManager.currentUser?.firstName ?? ""
                            lastName = authManager.currentUser?.lastName ?? ""
                            username = authManager.currentUser?.username ?? ""
                            isEditingProfile = true
                        }
                        .appButton()
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(15)
                .padding(.horizontal)
                
                Spacer()
                    .frame(height: 30)
                
                Button("Sync with Apple Watch") {
                    authManager.syncWatch()
                }
                .appButton()
                
                Spacer()
                
                Button("Log Out") {
                    authManager.logout()
                }
                .appButton()
                .padding(.bottom)
            }
            .frame(maxHeight: UIScreen.main.bounds.height - 100)
        }
        .onChange(of: selectedItem) { _ in
            Task {
                if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: data) {
                        profileImage = Image(uiImage: uiImage)
                    }
                }
            }
        }
        .appBackground(imageName: "home")
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

#Preview {
    ProfileView()
        .environmentObject(AuthManager())
}
