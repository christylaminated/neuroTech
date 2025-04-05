import SwiftUI

struct HolographicBackground: ViewModifier {
    let backgroundName: String
    
    init(background: String) {
        self.backgroundName = background
    }
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                Image(backgroundName)
                    .resizable()
                    .ignoresSafeArea()
            )
    }
}

struct HolographicTitle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 34, weight: .bold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.top, 20)
    }
}

struct HolographicText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 16))
            .foregroundColor(.white.opacity(0.8))
    }
}

extension View {
    func holographicStyle(background: String) -> some View {
        self.modifier(HolographicBackground(background: background))
    }
    
    func holographicTitle() -> some View {
        self.modifier(HolographicTitle())
    }
    
    func holographicText() -> some View {
        self.modifier(HolographicText())
    }
}
