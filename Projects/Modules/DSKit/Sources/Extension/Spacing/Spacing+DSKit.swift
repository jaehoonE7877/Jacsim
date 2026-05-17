import SwiftUI

public enum JSSpacing {
    /// 4pt - 미세 간격 (아이콘 간격, 촘촘한 패딩)
    public static var micro: CGFloat { 4.jsScaled() }
    
    /// 8pt - 극소 간격 (조밀한 컴포넌트 패딩)
    public static var xs: CGFloat { 8.jsScaled() }
    
    /// 12pt - 소형 (컴팩트한 컴포넌트 패딩)
    public static var sm: CGFloat { 12.jsScaled() }
    
    /// 16pt - 중형 (기본 컴포넌트 패딩)
    public static var md: CGFloat { 16.jsScaled() }
    
    /// 20pt - 대형 (섹션 패딩)
    public static var lg: CGFloat { 20.jsScaled() }
    
    /// 24pt - 특대형 (화면 패딩)
    public static var xl: CGFloat { 24.jsScaled() }
    
    /// 32pt - 2배 대형 (주요 섹션 간격)
    public static var xxl: CGFloat { 32.jsScaled() }
    
    /// 44pt - 최소 터치 타겟 크기
    public static var touchTarget: CGFloat { 44.jsScaled(.touchTarget) }

    /// 16pt - Floating tab bar horizontal margin
    public static var tabBarMargin: CGFloat { 16.jsScaled() }
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
    static var jsTabBarMargin: CGFloat { JSSpacing.tabBarMargin }
}
