import SwiftUI

public enum JSCornerRadius {
    /// 8pt - Small radius (buttons, small cards)
    public static let small: CGFloat = 8
    
    /// 12pt - Medium radius (cards, inputs)
    public static let medium: CGFloat = 12
    
    /// 16pt - Large radius (modals, sheets)
    public static let large: CGFloat = 16
    
    /// 20pt - Extra large radius (bottom sheets)
    public static let extraLarge: CGFloat = 20
    
    /// 9999pt - Circular radius (pills, avatars)
    public static let circular: CGFloat = 9999
}

public enum JSShadow {
    /// Small shadow - subtle elevation
    public static let small = ShadowStyle(
        color: Color.black.opacity(0.08),
        radius: 4,
        x: 0,
        y: 2
    )
    
    /// Medium shadow - standard elevation
    public static let medium = ShadowStyle(
        color: Color.black.opacity(0.12),
        radius: 8,
        x: 0,
        y: 4
    )
    
    /// Large shadow - prominent elevation
    public static let large = ShadowStyle(
        color: Color.black.opacity(0.16),
        radius: 16,
        x: 0,
        y: 8
    )
}

public struct ShadowStyle {
    public let color: Color
    public let radius: CGFloat
    public let x: CGFloat
    public let y: CGFloat
    
    public static let clear = ShadowStyle(color: .clear, radius: 0, x: 0, y: 0)
    
    public init(color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
        self.color = color
        self.radius = radius
        self.x = x
        self.y = y
    }
}

public extension ShadowStyle {
    static var small: ShadowStyle { JSShadow.small }
    static var medium: ShadowStyle { JSShadow.medium }
    static var large: ShadowStyle { JSShadow.large }
}

public extension View {
    func jsShadow(_ style: ShadowStyle) -> some View {
        self.shadow(
            color: style.color,
            radius: style.radius,
            x: style.x,
            y: style.y
        )
    }
}

public extension CGFloat {
    static let jsCornerSmall: CGFloat = JSCornerRadius.small
    static let jsCornerMedium: CGFloat = JSCornerRadius.medium
    static let jsCornerLarge: CGFloat = JSCornerRadius.large
    static let jsCornerExtraLarge: CGFloat = JSCornerRadius.extraLarge
    static let jsCornerCircular: CGFloat = JSCornerRadius.circular
    
    // Legacy aliases for backward compatibility
    static let jsRadiusSM: CGFloat = JSCornerRadius.small
    static let jsRadiusMD: CGFloat = JSCornerRadius.medium
    static let jsRadiusLG: CGFloat = JSCornerRadius.large
    static let jsRadiusXL: CGFloat = JSCornerRadius.extraLarge
    static let jsRadiusFull: CGFloat = JSCornerRadius.circular
}
