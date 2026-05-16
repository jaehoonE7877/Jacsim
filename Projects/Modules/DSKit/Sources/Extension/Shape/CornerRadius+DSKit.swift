import SwiftUI

public enum JSCornerRadius {
    /// 8pt - 작은 반경 (버튼, 작은 카드)
    public static var small: CGFloat { 8.jsScaled() }
    
    /// 12pt - 중간 반경 (카드, 입력 필드)
    public static var medium: CGFloat { 12.jsScaled() }
    
    /// 16pt - 큰 반경 (모달, 시트)
    public static var large: CGFloat { 16.jsScaled() }
    
    /// 20pt - 특대 반경 (하단 시트)
    public static var extraLarge: CGFloat { 20.jsScaled() }
    
    /// 9999pt - 원형 반경 (필 및 아바타)
    public static let circular: CGFloat = 9999
}

public enum JSShadow {
    /// 작은 그림자 - 은은한 입체감
    public static var small: ShadowStyle {
        ShadowStyle(
            color: Color.black.opacity(0.08),
            radius: 4.jsScaled(),
            x: 0,
            y: 2.jsScaled()
        )
    }
    
    /// 중간 그림자 - 기본 입체감
    public static var medium: ShadowStyle {
        ShadowStyle(
            color: Color.black.opacity(0.12),
            radius: 8.jsScaled(),
            x: 0,
            y: 4.jsScaled()
        )
    }
    
    /// 큰 그림자 - 강조된 입체감
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
    
    public static var clear: ShadowStyle {
        ShadowStyle(color: .clear, radius: 0, x: 0, y: 0)
    }
    
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
    
    // 레거시 별칭 (하위 호환성 유지)
    static var jsRadiusSM: CGFloat { JSCornerRadius.small }
    static var jsRadiusMD: CGFloat { JSCornerRadius.medium }
    static var jsRadiusLG: CGFloat { JSCornerRadius.large }
    static var jsRadiusXL: CGFloat { JSCornerRadius.extraLarge }
    static var jsRadiusFull: CGFloat { JSCornerRadius.circular }
}
