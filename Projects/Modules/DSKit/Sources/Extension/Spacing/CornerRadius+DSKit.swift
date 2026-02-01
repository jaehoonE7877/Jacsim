import SwiftUI

public enum JSCornerRadius {
    /// 4pt - Small corners (tags, small buttons)
    public static let sm: CGFloat = 4

    /// 8pt - Medium corners (cards, inputs)
    public static let md: CGFloat = 8

    /// 12pt - Large corners (modals, sheets)
    public static let lg: CGFloat = 12

    /// 16pt - Extra large corners (main containers)
    public static let xl: CGFloat = 16

    /// 24pt - Full rounded (buttons, pills)
    public static let full: CGFloat = 24
}

public extension CGFloat {
    static let jsRadiusSM: CGFloat = JSCornerRadius.sm
    static let jsRadiusMD: CGFloat = JSCornerRadius.md
    static let jsRadiusLG: CGFloat = JSCornerRadius.lg
    static let jsRadiusXL: CGFloat = JSCornerRadius.xl
    static let jsRadiusFull: CGFloat = JSCornerRadius.full
}