import CoreText
import SwiftUI
import UIKit

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

    // MARK: - Newsreader (Serif)
    /// Newsreader contains no Hangul glyphs. SwiftUI auto-falls-back to the system Hangul font.
    /// If a screen needs visually tight English+Korean composition (e.g. "Day 04 째"),
    /// split runs across separate `Text` views and use Pretendard for the Korean run.
    /// Do NOT attempt to bundle a Korean serif substitute in this goal.
    static func newsreaderRegular(size: CGFloat) -> Font {
        .newsreader14ptRegular(size: size)
    }

    static func newsreaderMedium(size: CGFloat) -> Font {
        .newsreader24ptMedium(size: size)
    }

    static func newsreaderSemiBold(size: CGFloat) -> Font {
        .newsreader60ptBold(size: size)
    }

    static func newsreader14ptRegular(size: CGFloat) -> Font {
        Font(UIFont.newsreader14ptRegular(size: size) as CTFont)
    }

    static func newsreader24ptMedium(size: CGFloat) -> Font {
        Font(UIFont.newsreader24ptMedium(size: size) as CTFont)
    }

    static func newsreader24ptMediumItalic(size: CGFloat) -> Font {
        Font(UIFont.newsreader24ptMediumItalic(size: size) as CTFont)
    }

    static func newsreader36ptMedium(size: CGFloat) -> Font {
        Font(UIFont.newsreader36ptMedium(size: size) as CTFont)
    }

    static func newsreader60ptBold(size: CGFloat) -> Font {
        Font(UIFont.newsreader60ptBold(size: size) as CTFont)
    }

    static func newsreader60ptBoldItalic(size: CGFloat) -> Font {
        Font(UIFont.newsreader60ptBoldItalic(size: size) as CTFont)
    }

    // MARK: - JetBrains Mono (Numerics)
    static func jetBrainsMonoRegular(size: CGFloat) -> Font {
        Font(UIFont.jetBrainsMonoRegular(size: size) as CTFont)
    }

    static func jetBrainsMonoMedium(size: CGFloat) -> Font {
        Font(UIFont.jetBrainsMonoMedium(size: size) as CTFont)
    }

    // MARK: - Adaptive Helpers
    static func jsDisplayScaledBold(size: CGFloat) -> Font {
        .pretendardBold(size: size.jsScaled(.displayTypography))
    }

    static func jsDisplayScaledSemiBold(size: CGFloat) -> Font {
        .pretendardSemiBold(size: size.jsScaled(.displayTypography))
    }

    static func jsSerif(_ size: CGFloat, italic: Bool = false) -> Font {
        let scaledSize = size.jsScaled(.displayTypography)

        switch size {
        case 40...:
            return italic
                ? .newsreader60ptBoldItalic(size: scaledSize)
                : .newsreader60ptBold(size: scaledSize)
        case 28..<40:
            return .newsreader36ptMedium(size: scaledSize)
        default:
            return italic
                ? .newsreader24ptMediumItalic(size: scaledSize)
                : .newsreader24ptMedium(size: scaledSize)
        }
    }

    // MARK: - Display (Large titles)
    static var jsDisplayLarge: Font { .jsDisplayScaledBold(size: 32) }
    static var jsDisplayMedium: Font { .jsDisplayScaledBold(size: 28) }
    static var jsDisplaySmall: Font { .jsDisplayScaledBold(size: 24) }

    // MARK: - Serif (Editorial moments)
    static var jsSerifHero: Font { .jsSerif(56) }
    static var jsSerifDisplay: Font { .jsSerif(36) }
    static var jsSerifTitle: Font { .jsSerif(24) }
    static var jsSerifQuote: Font { .jsSerif(18, italic: true) }

    // MARK: - Serif Display Compatibility
    static var jsSerifDisplayLarge: Font { .jsSerifDisplay }
    static var jsSerifDisplayMedium: Font { .jsSerif(28) }
    static var jsSerifDisplaySmall: Font { .jsSerifTitle }

    // MARK: - Headline (Section titles)
    static var jsHeadlineLarge: Font { .jsDisplayScaledSemiBold(size: 22) }
    static var jsHeadlineMedium: Font { .jsDisplayScaledSemiBold(size: 20) }
    static var jsHeadlineSmall: Font { .jsDisplayScaledSemiBold(size: 18) }

    // MARK: - Body (Primary content)
    static var jsBodyLarge: Font { .pretendardMedium(size: 17) }
    static var jsBodyMedium: Font { .pretendardMedium(size: 16) }
    static var jsBodySmall: Font { .pretendardMedium(size: 15) }

    // MARK: - Label (Secondary text)
    static var jsLabelLarge: Font { .pretendardRegular(size: 16) }
    static var jsLabelMedium: Font { .pretendardRegular(size: 14) }
    static var jsLabelSmall: Font { .pretendardRegular(size: 12) }

    // MARK: - Mono (Counters and structured data)
    static var jsMonoLarge: Font { .jetBrainsMonoMedium(size: 28) }
    static var jsMonoMedium: Font { .jetBrainsMonoMedium(size: 20) }
    static var jsMonoSmall: Font { .jetBrainsMonoRegular(size: 14) }

    // MARK: - Button
    static var jsButtonLarge: Font { .pretendardSemiBold(size: 17) }
    static var jsButtonMedium: Font { .pretendardSemiBold(size: 16) }
    static var jsButtonSmall: Font { .pretendardSemiBold(size: 14) }

    // MARK: - Compatibility Tokens
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
