import SwiftUI

enum JSHeroCardLayout {
    static var height: CGFloat { 320.jsScaled() }
    static var cornerRadius: CGFloat { 20.jsScaled() }
    static var contentPadding: CGFloat { 20.jsScaled() }
    static var contentSpacing: CGFloat { 16.jsScaled() }
    static var detailSpacing: CGFloat { 8.jsScaled() }
    static var progressSpacing: CGFloat { 12.jsScaled() }
    static var progressBarHeight: CGFloat { 6.jsScaled() }
    static var progressTextMinWidth: CGFloat { 50.jsScaled() }
    static var progressTopPadding: CGFloat { 8.jsScaled() }
    static var badgeHorizontalPadding: CGFloat { 10.jsScaled() }
    static var badgeVerticalPadding: CGFloat { 5.jsScaled() }
}

enum JSMiniHeroCardLayout {
    static var size: CGSize { CGSize(width: 160, height: 200).jsScaled() }
    static var cornerRadius: CGFloat { 20.jsScaled() }
    static var contentPadding: CGFloat { 12.jsScaled() }
    static var titleSpacing: CGFloat { 6.jsScaled() }
    static var progressSpacing: CGFloat { 8.jsScaled() }
    static var progressBarHeight: CGFloat { 4.jsScaled() }
    static var badgeHorizontalPadding: CGFloat { 8.jsScaled() }
    static var badgeVerticalPadding: CGFloat { 4.jsScaled() }
    static var carouselSpacing: CGFloat { 12.jsScaled() }
    static var carouselHorizontalPadding: CGFloat { 20.jsScaled() }
    static var carouselVerticalPadding: CGFloat { 4.jsScaled() }
}
