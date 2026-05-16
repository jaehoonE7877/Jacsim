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

// MARK: - V2 Brand
public extension UIColor {

    static var v2BrandBlue: UIColor {
        UIColor { traits -> UIColor in
            if traits.accessibilityContrast == .high {
                return traits.userInterfaceStyle == .dark
                    ? UIColor(hexString: "#5AA2FF")
                    : UIColor(hexString: "#0057D8")
            }
            return traits.userInterfaceStyle == .dark
                ? UIColor(hexString: "#4D9BFF")
                : UIColor(hexString: "#0077FF")
        }
    }

    static var v2BrandBlueStrong: UIColor {
        UIColor { traits -> UIColor in
            traits.userInterfaceStyle == .dark
                ? UIColor(hexString: "#1677FF")
                : UIColor(hexString: "#005EEB")
        }
    }

    static var v2BrandBlueSoft: UIColor {
        UIColor { traits -> UIColor in
            traits.userInterfaceStyle == .dark
                ? UIColor(hexString: "#0B3A6B", alpha: 0.72)
                : UIColor(hexString: "#EAF3FF")
        }
    }

    static var v2Background: UIColor {
        UIColor { traits -> UIColor in
            traits.userInterfaceStyle == .dark
                ? UIColor(hexString: "#111316")
                : UIColor(hexString: "#FFFFFF")
        }
    }

    static var v2Surface: UIColor {
        UIColor { traits -> UIColor in
            traits.userInterfaceStyle == .dark
                ? UIColor(hexString: "#1B1E23")
                : UIColor(hexString: "#F5F8FC")
        }
    }

    static var v2SurfaceElevated: UIColor {
        UIColor { traits -> UIColor in
            traits.userInterfaceStyle == .dark
                ? UIColor(hexString: "#242830")
                : UIColor(hexString: "#FFFFFF")
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

    static var backgroundStrong: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor(hexString: "#000000")
            }
            return UIColor(hexString: "#F7F7F8")
        }
    }

    static var backgroundAlternative: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor(hexString: "#2C2D2F")
            }
            return UIColor(hexString: "#F2F3F5")
        }
    }
}

//MARK: - Status
public extension UIColor {
    
    static var positive: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor(hexString: "#1ED45A")
            }
            return UIColor(hexString: "#00BF40")
        }
    }
    
    static var cautionary: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor(hexString: "#FFA938")
            }
            return UIColor(hexString: "#FF9200")
        }
    }
    
    static var destructive: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor(hexString: "#FF6363")
            }
            return UIColor(hexString: "#FF4242")
        }
    }
}

//MARK: - Streak
public extension UIColor {
    
    static var streakActive: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor(hexString: "#FF5722")
            }
            return UIColor(hexString: "#FF6B35")
        }
    }
    
    static var streakCompleted: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor(hexString: "#66BB6A")
            }
            return UIColor(hexString: "#4CAF50")
        }
    }
    
    static var streakFrozen: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor(hexString: "#90A4AE")
            }
            return UIColor(hexString: "#78909C")
        }
    }
}

//MARK: - Progress
public extension UIColor {
    
    static var progressLow: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor(hexString: "#EF5350")
            }
            return UIColor(hexString: "#F44336")
        }
    }
    
    static var progressMedium: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor(hexString: "#FFCA28")
            }
            return UIColor(hexString: "#FFC107")
        }
    }
    
    static var progressHigh: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor(hexString: "#66BB6A")
            }
            return UIColor(hexString: "#4CAF50")
        }
    }
}

//MARK: - Achievement
public extension UIColor {
    
    static var achievement: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor(hexString: "#FFC107")
            }
            return UIColor(hexString: "#FFD700")
        }
    }
}

//MARK: - Surface
public extension UIColor {
    
    static var surfaceElevated: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor(hexString: "#2C2D2F")
            }
            return UIColor(hexString: "#FFFFFF")
        }
    }
    
    static var surfaceOverlay: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor(hexString: "#000000", alpha: 0.7)
            }
            return UIColor(hexString: "#000000", alpha: 0.5)
        }
    }
    
    static var surfaceSelected: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor(hexString: "#1565C0", alpha: 0.3)
            }
            return UIColor(hexString: "#E3F2FD")
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
