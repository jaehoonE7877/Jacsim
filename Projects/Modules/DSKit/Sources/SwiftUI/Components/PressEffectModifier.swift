import SwiftUI

public struct PressEffectModifier: ViewModifier {
    @State private var isPressed = false
    private let pressedScale: CGFloat = 0.95
    private let pressedOpacity: CGFloat = 0.9
    
    public init() {}
    
    public func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? pressedScale : 1.0)
            .opacity(isPressed ? pressedOpacity : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
            .onLongPressGesture(
                minimumDuration: 0,
                maximumDistance: 12,
                pressing: { isPressing in
                    isPressed = isPressing
                },
                perform: {}
            )
    }
}

extension View {
    public func pressEffect() -> some View {
        modifier(PressEffectModifier())
    }
}

public struct PressEffectButtonStyle: ButtonStyle {
    private let pressedScale: CGFloat = 0.95
    private let pressedOpacity: CGFloat = 0.9

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? pressedScale : 1.0)
            .opacity(configuration.isPressed ? pressedOpacity : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

extension Button {
    public func pressEffect() -> some View {
        buttonStyle(PressEffectButtonStyle())
    }
}
