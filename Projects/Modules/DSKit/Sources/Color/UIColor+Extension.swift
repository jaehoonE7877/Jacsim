//
//  UIColor+Extension.swift
//  DSKit
//
//  Created by Seo Jae Hoon on 4/3/24.
//  Copyright © 2024 Jacsim. All rights reserved.
//

import UIKit

//MARK: - Primary
public extension UIColor {
    
    static var primaryNormal: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor(hexString: "#3385FF")
            }
            return UIColor(hexString: "#0066FF")
        }
    }
    
    static var primaryStrong: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor(hexString: "#1A75FF")
            }
            return UIColor(hexString: "#005EEB")
        }
    }
    
    static var primaryHeavy: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor(hexString: "#0066FF")
            }
            return UIColor(hexString: "#0054D1")
        }
    }
}

//MARK: - Label
public extension UIColor {
    
    static var labelNormal: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor(hexString: "#F7F7F8")
            }
            return UIColor(hexString: "#171719")
        }
    }
    
    static var labelStrong: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor(hexString: "#FFFFFF")
            }
            return UIColor(hexString: "#000000")
        }
    }
    
    static var labelNeutral: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor(hexString: "#C2C4C8", alpha: 0.88)
            }
            return UIColor(hexString: "#2E2F33", alpha: 0.88)
        }
    }
    
    static var labelAlternative: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor(hexString: "#AEB0B6", alpha: 0.61)
            }
            return UIColor(hexString: "#37383C", alpha: 0.61)
        }
    }
    
    static var labelAssistive: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor(hexString: "#AEB0B6", alpha: 0.28)
            }
            return UIColor(hexString: "#37383C", alpha: 0.28)
        }
    }
    
    static var labelDisable: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor(hexString: "#989BA2", alpha: 0.16)
            }
            return UIColor(hexString: "#37383C", alpha: 0.16)
        }
    }
}

//MARK: - Background
public extension UIColor {
    
    static var backgroundNormal: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor(hexString: "#1B1C1E")
            }
            return UIColor(hexString: "#FFFFFF")
        }
    }
}

extension UIColor {
    ///Hex값으로 컬러 할당 가능
    /// Tag: #Hex
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
         var hexFormatted: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
         
         if hexFormatted.hasPrefix("#") {
             hexFormatted = String(hexFormatted.dropFirst())
         }
         
         assert(hexFormatted.count == 6, "Invalid hex code used.")
         
         var rgbValue: UInt64 = 0
         Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
         
         self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                   green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                   blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                   alpha: alpha)
     }
}
