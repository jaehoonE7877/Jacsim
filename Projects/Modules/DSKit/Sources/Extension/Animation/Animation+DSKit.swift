import SwiftUI

public enum JSAnimation {
    public static let durationFast: Double = 0.18
    public static let durationNormal: Double = 0.24
    public static let durationSlow: Double = 0.32

    public static let navigation = Animation.easeInOut(duration: durationNormal)
    public static let toast = Animation.easeOut(duration: durationFast)
    public static let reward = Animation.easeInOut(duration: durationSlow)
    public static let navigationSpring = Animation.spring(response: 0.34, dampingFraction: 0.84)
    public static let emphasisSpring = Animation.spring(response: 0.28, dampingFraction: 0.86)

    // Compatibility shims for existing call sites.
    public static let spring = navigationSpring
    public static let easeOut = toast
    public static let easeInOut = navigation
}

public enum JSInteraction {
    public static let pressedOpacity: Double = 0.7
    public static let disabledOpacity: Double = 0.5
    public static let hoverScale: CGFloat = 1.02
    public static let pressedScale: CGFloat = 0.98
}
