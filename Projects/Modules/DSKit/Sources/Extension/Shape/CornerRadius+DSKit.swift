import SwiftUI

public enum JSCornerRadius {
    /// 8pt - Small radius (buttons, small cards)
    public static var small: CGFloat { 8.jsScaled() }
    
    /// 12pt - Medium radius (cards, inputs)
    public static var medium: CGFloat { 12.jsScaled() }
    
    /// 16pt - Large radius (modals, sheets)
    public static var large: CGFloat { 16.jsScaled() }
    
    /// 20pt - Extra large radius (bottom sheets)
    public static var extraLarge: CGFloat { 20.jsScaled() }
    
    /// 9999pt - Circular radius (pills, avatars)
    public static let circular: CGFloat = 9999
}

public enum JSShadow {
    /// Small shadow - subtle elevation
    public static var small: ShadowStyle {
        ShadowStyle(
            color: Color.black.opacity(0.08),
            radius: 4.jsScaled(),
            x: 0,
            y: 2.jsScaled()
        )
    }
    
    /// Medium shadow - standard elevation
    public static var medium: ShadowStyle {
        ShadowStyle(
            color: Color.black.opacity(0.12),
            radius: 8.jsScaled(),
            x: 0,
            y: 4.jsScaled()
        )
    }
    
    /// Large shadow - prominent elevation
    public static var large: ShadowStyle {
        ShadowStyle(
            color: Color.black.opacity(0.16),
            radius: 16.jsScaled(),
            x: 0,
            y: 8.jsScaled()
        )
    }
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
    static var jsCornerSmall: CGFloat { JSCornerRadius.small }
    static var jsCornerMedium: CGFloat { JSCornerRadius.medium }
    static var jsCornerLarge: CGFloat { JSCornerRadius.large }
    static var jsCornerExtraLarge: CGFloat { JSCornerRadius.extraLarge }
    static var jsCornerCircular: CGFloat { JSCornerRadius.circular }
    
    // Legacy aliases for backward compatibility
    static var jsRadiusSM: CGFloat { JSCornerRadius.small }
    static var jsRadiusMD: CGFloat { JSCornerRadius.medium }
    static var jsRadiusLG: CGFloat { JSCornerRadius.large }
    static var jsRadiusXL: CGFloat { JSCornerRadius.extraLarge }
    static var jsRadiusFull: CGFloat { JSCornerRadius.circular }
}
