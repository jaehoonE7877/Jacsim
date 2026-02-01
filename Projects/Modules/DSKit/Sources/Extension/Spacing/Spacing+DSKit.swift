import SwiftUI

public enum JSSpacing {
    /// 4pt - Micro spacing (icon gaps, tight padding)
    public static let micro: CGFloat = 4
    
    /// 8pt - Extra small (tight component padding)
    public static let xs: CGFloat = 8
    
    /// 12pt - Small (compact component padding)
    public static let sm: CGFloat = 12
    
    /// 16pt - Medium (standard component padding)
    public static let md: CGFloat = 16
    
    /// 20pt - Large (section padding)
    public static let lg: CGFloat = 20
    
    /// 24pt - Extra large (screen padding)
    public static let xl: CGFloat = 24
    
    /// 32pt - 2x Large (major section spacing)
    public static let xxl: CGFloat = 32
    
    /// 44pt - Minimum touch target size
    public static let touchTarget: CGFloat = 44
}

public extension CGFloat {
    static let jsMicro: CGFloat = JSSpacing.micro
    static let jsXS: CGFloat = JSSpacing.xs
    static let jsSM: CGFloat = JSSpacing.sm
    static let jsMD: CGFloat = JSSpacing.md
    static let jsLG: CGFloat = JSSpacing.lg
    static let jsXL: CGFloat = JSSpacing.xl
    static let jsXXL: CGFloat = JSSpacing.xxl
    static let jsTouchTarget: CGFloat = JSSpacing.touchTarget
}