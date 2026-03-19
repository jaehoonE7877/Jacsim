import SwiftUI
import UIKit

public extension Font {
    private static func scaledFont(
        _ font: UIFont,
        textStyle: UIFont.TextStyle
    ) -> Font {
        let scaled = UIFontMetrics(forTextStyle: textStyle).scaledFont(for: font)
        return Font(scaled as CTFont)
    }

    // MARK: - 폰트 헬퍼
    static func pretendardBold(
        size: CGFloat,
        relativeTo textStyle: UIFont.TextStyle = .body
    ) -> Font {
        scaledFont(UIFont.pretendardBold(size: size), textStyle: textStyle)
    }

    static func pretendardMedium(
        size: CGFloat,
        relativeTo textStyle: UIFont.TextStyle = .body
    ) -> Font {
        scaledFont(UIFont.pretendardMedium(size: size), textStyle: textStyle)
    }

    static func pretendardRegular(
        size: CGFloat,
        relativeTo textStyle: UIFont.TextStyle = .body
    ) -> Font {
        scaledFont(UIFont.pretendardRegular(size: size), textStyle: textStyle)
    }

    static func pretendardSemiBold(
        size: CGFloat,
        relativeTo textStyle: UIFont.TextStyle = .body
    ) -> Font {
        scaledFont(UIFont.pretendardSemiBold(size: size), textStyle: textStyle)
    }

    // MARK: - 적응형 헬퍼
    static func jsDisplayScaledBold(size: CGFloat) -> Font {
        .pretendardBold(size: size, relativeTo: .largeTitle)
    }

    static func jsDisplayScaledSemiBold(size: CGFloat) -> Font {
        .pretendardSemiBold(size: size, relativeTo: .title1)
    }

    // MARK: - Display (대형 타이틀)
    static var jsDisplayLarge: Font { .jsDisplayScaledBold(size: 32) }
    static var jsDisplayMedium: Font { .jsDisplayScaledBold(size: 28) }
    static var jsDisplaySmall: Font { .jsDisplayScaledBold(size: 24) }

    // MARK: - Headline (섹션 제목)
    static var jsHeadlineLarge: Font { .pretendardSemiBold(size: 22, relativeTo: .title2) }
    static var jsHeadlineMedium: Font { .pretendardSemiBold(size: 20, relativeTo: .title3) }
    static var jsHeadlineSmall: Font { .pretendardSemiBold(size: 18, relativeTo: .headline) }

    // MARK: - Body (주요 콘텐츠)
    static var jsBodyLarge: Font { .pretendardMedium(size: 17, relativeTo: .body) }
    static var jsBodyMedium: Font { .pretendardMedium(size: 16, relativeTo: .body) }
    static var jsBodySmall: Font { .pretendardMedium(size: 15, relativeTo: .callout) }

    // MARK: - Label (보조 텍스트)
    static var jsLabelLarge: Font { .pretendardRegular(size: 16, relativeTo: .callout) }
    static var jsLabelMedium: Font { .pretendardRegular(size: 14, relativeTo: .subheadline) }
    static var jsLabelSmall: Font { .pretendardRegular(size: 12, relativeTo: .caption1) }

    // MARK: - Button
    static var jsButtonLarge: Font { .pretendardSemiBold(size: 17, relativeTo: .headline) }
    static var jsButtonMedium: Font { .pretendardSemiBold(size: 16, relativeTo: .subheadline) }
    static var jsButtonSmall: Font { .pretendardSemiBold(size: 14, relativeTo: .footnote) }

    // MARK: - 호환성 토큰
    static var jsDisplay28Bold: Font { .jsDisplayScaledBold(size: 28) }
    static var jsDisplay26Bold: Font { .jsDisplayScaledBold(size: 26) }
    static var jsDisplay22Bold: Font { .jsDisplayScaledBold(size: 22) }

    static var jsHeadline20Bold: Font { .pretendardSemiBold(size: 20, relativeTo: .title3) }
    static var jsHeadline18Bold: Font { .pretendardSemiBold(size: 18, relativeTo: .headline) }
    static var jsHeadline17Bold: Font { .pretendardSemiBold(size: 17, relativeTo: .headline) }
    static var jsHeadline16Bold: Font { .pretendardSemiBold(size: 16, relativeTo: .headline) }

    static var jsBody17Medium: Font { .pretendardMedium(size: 17, relativeTo: .body) }
    static var jsBody16Bold: Font { .pretendardSemiBold(size: 16, relativeTo: .body) }
    static var jsBody16Medium: Font { .pretendardMedium(size: 16, relativeTo: .body) }
    static var jsBody16Regular: Font { .pretendardRegular(size: 16, relativeTo: .body) }
    static var jsBody15Medium: Font { .pretendardMedium(size: 15, relativeTo: .callout) }
    static var jsBody14Semibold: Font { .pretendardSemiBold(size: 14, relativeTo: .subheadline) }
    static var jsBody14Bold: Font { .pretendardSemiBold(size: 14, relativeTo: .subheadline) }
    static var jsBody14Regular: Font { .pretendardRegular(size: 14, relativeTo: .subheadline) }

    static var jsLabel14Bold: Font { .pretendardSemiBold(size: 14, relativeTo: .footnote) }
    static var jsLabel13Bold: Font { .pretendardSemiBold(size: 13, relativeTo: .caption1) }
    static var jsLabel12Bold: Font { .pretendardSemiBold(size: 12, relativeTo: .caption1) }
    static var jsLabel12Medium: Font { .pretendardMedium(size: 12, relativeTo: .caption1) }
    static var jsLabel12Regular: Font { .pretendardRegular(size: 12, relativeTo: .caption1) }
    static var jsLabel11Bold: Font { .pretendardSemiBold(size: 12, relativeTo: .caption1) }
    static var jsLabel10Bold: Font { .pretendardSemiBold(size: 12, relativeTo: .caption1) }
    static var jsLabel10Regular: Font { .pretendardRegular(size: 12, relativeTo: .caption1) }
}
