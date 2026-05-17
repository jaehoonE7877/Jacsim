//
//  UIFont+Extension.swift
//  DSKit
//
//  Created by Seo Jae Hoon on 4/3/24.
//  Copyright © 2024 Jacsim. All rights reserved.
//

import CoreText
import UIKit

public extension UIFont {
    
    static func pretendardBold(size: CGFloat) -> UIFont {
        return DSKitFontFamily.Pretendard.bold.font(size: size)
    }
    
    static func pretendardMedium(size: CGFloat) -> UIFont {
        return DSKitFontFamily.Pretendard.medium.font(size: size)
    }
    
    static func pretendardRegular(size: CGFloat) -> UIFont {
        return DSKitFontFamily.Pretendard.regular.font(size: size)
    }
    
    static func pretendardSemiBold(size: CGFloat) -> UIFont {
        return DSKitFontFamily.Pretendard.semiBold.font(size: size)
    }

    static func newsreaderRegular(size: CGFloat) -> UIFont {
        return newsreader14ptRegular(size: size)
    }

    static func newsreaderMedium(size: CGFloat) -> UIFont {
        return newsreader24ptMedium(size: size)
    }

    static func newsreaderSemiBold(size: CGFloat) -> UIFont {
        return newsreader60ptBold(size: size)
    }

    static func newsreader14ptRegular(size: CGFloat) -> UIFont {
        return bundledFont(name: "Newsreader14pt-Regular", path: "Newsreader_14pt-Regular.ttf", size: size)
    }

    static func newsreader24ptMedium(size: CGFloat) -> UIFont {
        return bundledFont(name: "Newsreader24pt-Medium", path: "Newsreader_24pt-Medium.ttf", size: size)
    }

    static func newsreader24ptMediumItalic(size: CGFloat) -> UIFont {
        return bundledFont(name: "Newsreader24pt-MediumItalic", path: "Newsreader_24pt-MediumItalic.ttf", size: size)
    }

    static func newsreader36ptMedium(size: CGFloat) -> UIFont {
        return bundledFont(name: "Newsreader36pt-Medium", path: "Newsreader_36pt-Medium.ttf", size: size)
    }

    static func newsreader60ptBold(size: CGFloat) -> UIFont {
        return bundledFont(name: "Newsreader60pt-Bold", path: "Newsreader_60pt-Bold.ttf", size: size)
    }

    static func newsreader60ptBoldItalic(size: CGFloat) -> UIFont {
        return bundledFont(name: "Newsreader60pt-BoldItalic", path: "Newsreader_60pt-BoldItalic.ttf", size: size)
    }

    static func jetBrainsMonoRegular(size: CGFloat) -> UIFont {
        return bundledFont(name: "JetBrainsMono-Regular", path: "JetBrainsMono-Regular.ttf", size: size)
    }

    static func jetBrainsMonoMedium(size: CGFloat) -> UIFont {
        return bundledFont(name: "JetBrainsMono-Medium", path: "JetBrainsMono-Medium.ttf", size: size)
    }

    static func registerFocusModeFonts() {
        _ = [
            newsreader14ptRegular(size: 1),
            newsreader24ptMedium(size: 1),
            newsreader24ptMediumItalic(size: 1),
            newsreader36ptMedium(size: 1),
            newsreader60ptBold(size: 1),
            newsreader60ptBoldItalic(size: 1),
            jetBrainsMonoRegular(size: 1),
            jetBrainsMonoMedium(size: 1)
        ]
    }

    private static func bundledFont(name: String, path: String, size: CGFloat) -> UIFont {
        if let font = UIFont(name: name, size: size) {
            return font
        }

        guard let fontURL = Bundle.module.url(forResource: path, withExtension: nil) else {
            fatalError("Missing font resource '\(path)'")
        }

        CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, nil)

        guard let font = UIFont(name: name, size: size) else {
            fatalError("Unable to initialize font '\(name)' from '\(path)'")
        }

        return font
    }
}
