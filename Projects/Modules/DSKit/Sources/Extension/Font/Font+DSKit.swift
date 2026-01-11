import SwiftUI

public extension Font {
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
}
