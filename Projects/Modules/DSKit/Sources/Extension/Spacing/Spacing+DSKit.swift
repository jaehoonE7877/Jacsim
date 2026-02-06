import SwiftUI

public enum JSSpacing {
    /// 4pt - Micro spacing (icon gaps, tight padding)
    public static var micro: CGFloat { 4.jsScaled() }
    
    /// 8pt - Extra small (tight component padding)
    public static var xs: CGFloat { 8.jsScaled() }
    
    /// 12pt - Small (compact component padding)
    public static var sm: CGFloat { 12.jsScaled() }
    
    /// 16pt - Medium (standard component padding)
    public static var md: CGFloat { 16.jsScaled() }
    
    /// 20pt - Large (section padding)
    public static var lg: CGFloat { 20.jsScaled() }
    
    /// 24pt - Extra large (screen padding)
    public static var xl: CGFloat { 24.jsScaled() }
    
    /// 32pt - 2x Large (major section spacing)
    public static var xxl: CGFloat { 32.jsScaled() }
    
    /// 44pt - Minimum touch target size
    public static var touchTarget: CGFloat { 44.jsScaled(.touchTarget) }
}

public extension CGFloat {
    static var jsMicro: CGFloat { JSSpacing.micro }
    static var jsXS: CGFloat { JSSpacing.xs }
    static var jsSM: CGFloat { JSSpacing.sm }
    static var jsMD: CGFloat { JSSpacing.md }
    static var jsLG: CGFloat { JSSpacing.lg }
    static var jsXL: CGFloat { JSSpacing.xl }
    static var jsXXL: CGFloat { JSSpacing.xxl }
    static var jsTouchTarget: CGFloat { JSSpacing.touchTarget }
}
