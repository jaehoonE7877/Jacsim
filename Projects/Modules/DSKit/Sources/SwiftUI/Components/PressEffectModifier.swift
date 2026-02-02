import SwiftUI

public struct PressEffectModifier: ViewModifier {
    @State private var isPressed = false
    
    public init() {}
    
    public func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.92 : 1.0)
            .opacity(isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        isPressed = true
                    }
                    .onEnded { _ in
                        isPressed = false
                    }
            )
    }
}

extension View {
    public func pressEffect() -> some View {
        modifier(PressEffectModifier())
    }
}
