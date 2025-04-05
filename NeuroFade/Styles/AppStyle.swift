import SwiftUI

struct AppStyle {
    // Colors
    static let textColor = Color.white
    static let buttonBorderColor = Color.white
    
    // Font sizes
    static let titleSize: CGFloat = 24
    static let bodySize: CGFloat = 16
    static let buttonSize: CGFloat = 18
    
    // Button style
    static let buttonCornerRadius: CGFloat = 8
    static let buttonBorderWidth: CGFloat = 1
}

// Text modifier
struct AppTextModifier: ViewModifier {
    let size: CGFloat
    
    func body(content: Content) -> some View {
        content
            .font(.ralewayRegular(size: size))
            .foregroundColor(AppStyle.textColor)
    }
}

// Button modifier
struct AppButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.ralewayRegular(size: AppStyle.buttonSize))
            .foregroundColor(AppStyle.textColor)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(.clear)
            .overlay(
                RoundedRectangle(cornerRadius: AppStyle.buttonCornerRadius)
                    .stroke(AppStyle.buttonBorderColor, lineWidth: AppStyle.buttonBorderWidth)
            )
    }
}

// Background modifier
struct AppBackgroundModifier: ViewModifier {
    let imageName: String
    
    func body(content: Content) -> some View {
        content
            .background(
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
            )
    }
}

// Text field style
struct AppTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(AppStyle.buttonCornerRadius)
            .foregroundColor(.white)
    }
}

// View extensions for easy use
extension View {
    func appText(size: CGFloat = AppStyle.bodySize) -> some View {
        modifier(AppTextModifier(size: size))
    }
    
    func appButton() -> some View {
        modifier(AppButtonModifier())
    }
    
    func appBackground(imageName: String) -> some View {
        modifier(AppBackgroundModifier(imageName: imageName))
    }
    
    func appTextField() -> some View {
        self.textFieldStyle(AppTextFieldStyle())
    }
}
