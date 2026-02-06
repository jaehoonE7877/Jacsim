import SwiftUI

public enum JSAnimation {
    public static let durationFast: Double = 0.15
    public static let durationNormal: Double = 0.25
    public static let durationSlow: Double = 0.35
    
    public static let spring = Animation.spring(response: 0.35, dampingFraction: 0.8)
    public static let easeOut = Animation.easeOut(duration: durationNormal)
    public static let easeInOut = Animation.easeInOut(duration: durationNormal)
}

public enum JSInteraction {
    public static let pressedOpacity: Double = 0.7
    public static let disabledOpacity: Double = 0.5
    public static let hoverScale: CGFloat = 1.02
    public static let pressedScale: CGFloat = 0.98
}
