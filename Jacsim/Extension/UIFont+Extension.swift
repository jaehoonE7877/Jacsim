//
//  UIFont+Extension.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/23.
//

import UIKit

extension UIFont {
    
    enum Style: String {
        case Medium, Light
    }
    
    static func gothic(style: Style, size: CGFloat) -> UIFont {
        return UIFont(name: "AppleSDGothicNeo-\(style)", size: size)!
    }
    
}

