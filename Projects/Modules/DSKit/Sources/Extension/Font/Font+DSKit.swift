import SwiftUI

public extension Font {
    // MARK: - Font Helpers
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

    // MARK: - Display (Large titles)
    static var jsDisplayLarge: Font { .pretendardBold(size: 32) }
    static var jsDisplayMedium: Font { .pretendardBold(size: 28) }
    static var jsDisplaySmall: Font { .pretendardBold(size: 24) }

    // MARK: - Headline (Section titles)
    static var jsHeadlineLarge: Font { .pretendardSemiBold(size: 22) }
    static var jsHeadlineMedium: Font { .pretendardSemiBold(size: 20) }
    static var jsHeadlineSmall: Font { .pretendardSemiBold(size: 18) }

    // MARK: - Body (Primary content)
    static var jsBodyLarge: Font { .pretendardMedium(size: 17) }
    static var jsBodyMedium: Font { .pretendardMedium(size: 16) }
    static var jsBodySmall: Font { .pretendardMedium(size: 15) }

    // MARK: - Label (Secondary text)
    static var jsLabelLarge: Font { .pretendardRegular(size: 16) }
    static var jsLabelMedium: Font { .pretendardRegular(size: 14) }
    static var jsLabelSmall: Font { .pretendardRegular(size: 12) }

    // MARK: - Button
    static var jsButtonLarge: Font { .pretendardSemiBold(size: 17) }
    static var jsButtonMedium: Font { .pretendardSemiBold(size: 16) }
    static var jsButtonSmall: Font { .pretendardSemiBold(size: 14) }
}
