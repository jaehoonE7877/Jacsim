import SwiftUI

public extension Font {
    // MARK: - 폰트 헬퍼
    static func pretendardBold(size: CGFloat) -> Font {
        Font(UIFont.pretendardBold(size: size) as CTFont)
    }

    static func pretendardMedium(size: CGFloat) -> Font {
        Font(UIFont.pretendardMedium(size: size) as CTFont)
    }

    static func pretendardRegular(size: CGFloat) -> Font {
        Font(UIFont.pretendardRegular(size: size) as CTFont)
    }

    static func pretendardSemiBold(size: CGFloat) -> Font {
        Font(UIFont.pretendardSemiBold(size: size) as CTFont)
    }

    // MARK: - 적응형 헬퍼
    static func jsDisplayScaledBold(size: CGFloat) -> Font {
        .pretendardBold(size: size.jsScaled(.displayTypography))
    }

    static func jsDisplayScaledSemiBold(size: CGFloat) -> Font {
        .pretendardSemiBold(size: size.jsScaled(.displayTypography))
    }

    // MARK: - Display (대형 타이틀)
    static var jsDisplayLarge: Font { .jsDisplayScaledBold(size: 32) }
    static var jsDisplayMedium: Font { .jsDisplayScaledBold(size: 28) }
    static var jsDisplaySmall: Font { .jsDisplayScaledBold(size: 24) }

    // MARK: - Headline (섹션 제목)
    static var jsHeadlineLarge: Font { .jsDisplayScaledSemiBold(size: 22) }
    static var jsHeadlineMedium: Font { .jsDisplayScaledSemiBold(size: 20) }
    static var jsHeadlineSmall: Font { .jsDisplayScaledSemiBold(size: 18) }

    // MARK: - Body (주요 콘텐츠)
    static var jsBodyLarge: Font { .pretendardMedium(size: 17) }
    static var jsBodyMedium: Font { .pretendardMedium(size: 16) }
    static var jsBodySmall: Font { .pretendardMedium(size: 15) }

    // MARK: - Label (보조 텍스트)
    static var jsLabelLarge: Font { .pretendardRegular(size: 16) }
    static var jsLabelMedium: Font { .pretendardRegular(size: 14) }
    static var jsLabelSmall: Font { .pretendardRegular(size: 12) }

    // MARK: - Button
    static var jsButtonLarge: Font { .pretendardSemiBold(size: 17) }
    static var jsButtonMedium: Font { .pretendardSemiBold(size: 16) }
    static var jsButtonSmall: Font { .pretendardSemiBold(size: 14) }

    // MARK: - 호환성 토큰
    static var jsDisplay28Bold: Font { .jsDisplayScaledBold(size: 28) }
    static var jsDisplay26Bold: Font { .jsDisplayScaledBold(size: 26) }
    static var jsDisplay22Bold: Font { .jsDisplayScaledBold(size: 22) }

    static var jsHeadline20Bold: Font { .pretendardSemiBold(size: 20) }
    static var jsHeadline18Bold: Font { .pretendardSemiBold(size: 18) }
    static var jsHeadline17Bold: Font { .pretendardSemiBold(size: 17) }
    static var jsHeadline16Bold: Font { .pretendardSemiBold(size: 16) }

    static var jsBody17Medium: Font { .pretendardMedium(size: 17) }
    static var jsBody16Bold: Font { .pretendardSemiBold(size: 16) }
    static var jsBody16Medium: Font { .pretendardMedium(size: 16) }
    static var jsBody16Regular: Font { .pretendardRegular(size: 16) }
    static var jsBody15Medium: Font { .pretendardMedium(size: 15) }
    static var jsBody14Semibold: Font { .pretendardSemiBold(size: 14) }
    static var jsBody14Bold: Font { .pretendardSemiBold(size: 14) }
    static var jsBody14Regular: Font { .pretendardRegular(size: 14) }

    static var jsLabel14Bold: Font { .pretendardSemiBold(size: 14) }
    static var jsLabel13Bold: Font { .pretendardSemiBold(size: 13) }
    static var jsLabel12Bold: Font { .pretendardSemiBold(size: 12) }
    static var jsLabel12Medium: Font { .pretendardMedium(size: 12) }
    static var jsLabel12Regular: Font { .pretendardRegular(size: 12) }
    static var jsLabel11Bold: Font { .pretendardSemiBold(size: 11) }
    static var jsLabel10Bold: Font { .pretendardSemiBold(size: 10) }
    static var jsLabel10Regular: Font { .pretendardRegular(size: 10) }
}
