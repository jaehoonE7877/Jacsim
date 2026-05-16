import SwiftUI
import UIKit

public extension Font {
    // MARK: - Font Helpers
    static func pretendardBold(
        size: CGFloat,
        relativeTo textStyle: UIFont.TextStyle = .body,
        maximumPointSize: CGFloat? = nil
    ) -> Font {
        scaledPretendard(
            UIFont.pretendardBold(size: size),
            relativeTo: textStyle,
            maximumPointSize: maximumPointSize
        )
    }

    static func pretendardMedium(
        size: CGFloat,
        relativeTo textStyle: UIFont.TextStyle = .body,
        maximumPointSize: CGFloat? = nil
    ) -> Font {
        scaledPretendard(
            UIFont.pretendardMedium(size: size),
            relativeTo: textStyle,
            maximumPointSize: maximumPointSize
        )
    }

    static func pretendardRegular(
        size: CGFloat,
        relativeTo textStyle: UIFont.TextStyle = .body,
        maximumPointSize: CGFloat? = nil
    ) -> Font {
        scaledPretendard(
            UIFont.pretendardRegular(size: size),
            relativeTo: textStyle,
            maximumPointSize: maximumPointSize
        )
    }

    static func pretendardSemiBold(
        size: CGFloat,
        relativeTo textStyle: UIFont.TextStyle = .body,
        maximumPointSize: CGFloat? = nil
    ) -> Font {
        scaledPretendard(
            UIFont.pretendardSemiBold(size: size),
            relativeTo: textStyle,
            maximumPointSize: maximumPointSize
        )
    }

    // MARK: - Adaptive Helpers
    static func jsDisplayScaledBold(size: CGFloat) -> Font {
        let scaledSize = size.jsScaled(.displayTypography)
        return .pretendardBold(
            size: scaledSize,
            relativeTo: .largeTitle,
            maximumPointSize: scaledSize * 1.35
        )
    }

    static func jsDisplayScaledSemiBold(size: CGFloat) -> Font {
        let scaledSize = size.jsScaled(.displayTypography)
        return .pretendardSemiBold(
            size: scaledSize,
            relativeTo: .largeTitle,
            maximumPointSize: scaledSize * 1.35
        )
    }

    // MARK: - Display (Large titles)
    static var jsDisplayLarge: Font { .jsDisplayScaledBold(size: 32) }
    static var jsDisplayMedium: Font { .jsDisplayScaledBold(size: 28) }
    static var jsDisplaySmall: Font { .jsDisplayScaledBold(size: 24) }

    // MARK: - Headline (Section titles)
    static var jsHeadlineLarge: Font { .jsDisplayScaledSemiBold(size: 22) }
    static var jsHeadlineMedium: Font { .jsDisplayScaledSemiBold(size: 20) }
    static var jsHeadlineSmall: Font { .jsDisplayScaledSemiBold(size: 18) }

    // MARK: - Body (Primary content)
    static var jsBodyLarge: Font { .pretendardMedium(size: 17, relativeTo: .body) }
    static var jsBodyMedium: Font { .pretendardMedium(size: 16, relativeTo: .body) }
    static var jsBodySmall: Font { .pretendardMedium(size: 15, relativeTo: .callout) }

    // MARK: - Label (Secondary text)
    static var jsLabelLarge: Font { .pretendardRegular(size: 16, relativeTo: .subheadline) }
    static var jsLabelMedium: Font { .pretendardRegular(size: 14, relativeTo: .subheadline) }
    static var jsLabelSmall: Font { .pretendardRegular(size: 12, relativeTo: .caption1) }

    // MARK: - Button
    static var jsButtonLarge: Font { .pretendardSemiBold(size: 17, relativeTo: .headline) }
    static var jsButtonMedium: Font { .pretendardSemiBold(size: 16, relativeTo: .body) }
    static var jsButtonSmall: Font { .pretendardSemiBold(size: 14, relativeTo: .callout) }

    // MARK: - Compatibility Tokens
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

    static var jsLabel14Bold: Font { .pretendardSemiBold(size: 14, relativeTo: .subheadline) }
    static var jsLabel13Bold: Font { .pretendardSemiBold(size: 13, relativeTo: .footnote) }
    static var jsLabel12Bold: Font { .pretendardSemiBold(size: 12, relativeTo: .caption1) }
    static var jsLabel12Medium: Font { .pretendardMedium(size: 12, relativeTo: .caption1) }
    static var jsLabel12Regular: Font { .pretendardRegular(size: 12, relativeTo: .caption1) }
    static var jsLabel11Bold: Font { .pretendardSemiBold(size: 11, relativeTo: .caption2) }
    static var jsLabel10Bold: Font { .pretendardSemiBold(size: 10, relativeTo: .caption2) }
    static var jsLabel10Regular: Font { .pretendardRegular(size: 10, relativeTo: .caption2) }

    private static func scaledPretendard(
        _ font: UIFont,
        relativeTo textStyle: UIFont.TextStyle,
        maximumPointSize: CGFloat?
    ) -> Font {
        let metrics = UIFontMetrics(forTextStyle: textStyle)
        let scaledFont: UIFont
        if let maximumPointSize {
            scaledFont = metrics.scaledFont(for: font, maximumPointSize: maximumPointSize)
        } else {
            scaledFont = metrics.scaledFont(for: font)
        }
        return Font(scaledFont as CTFont)
    }
}
