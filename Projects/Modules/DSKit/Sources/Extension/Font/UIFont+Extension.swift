//
//  UIFont+Extension.swift
//  DSKit
//
//  Created by Seo Jae Hoon on 4/3/24.
//  Copyright © 2024 Jacsim. All rights reserved.
//

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
}
