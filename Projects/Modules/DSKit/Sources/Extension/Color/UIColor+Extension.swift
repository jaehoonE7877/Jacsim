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
                return UIColor(hexString: "#84F6B5")
            }
            return UIColor(hexString: "#0D9488")
        }
    }
    
    static var primaryStrong: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor(hexString: "#5EEAD4")
            }
            return UIColor(hexString: "#14B8A6")
        }
    }
    
    static var primaryHeavy: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor(hexString: "#2DD4BF")
            }
            return UIColor(hexString: "#0F766E")
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
            return UIColor(hexString: "#134E4A")
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
                return UIColor(hexString: "#101411")
            }
            return UIColor(hexString: "#FAF8F1")
        }
    }

    static var backgroundStrong: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor(hexString: "#070A08")
            }
            return UIColor(hexString: "#F1EFE7")
        }
    }

    static var backgroundAlternative: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor(hexString: "#1A211D")
            }
            return UIColor(hexString: "#F0FDFA")
        }
    }
}

//MARK: - Status
public extension UIColor {
    
    static var positive: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor(hexString: "#4ADE80")
            }
            return UIColor(hexString: "#16A34A")
        }
    }
    
    static var cautionary: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor(hexString: "#FDBA74")
            }
            return UIColor(hexString: "#F97316")
        }
    }
    
    static var destructive: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor(hexString: "#F87171")
            }
            return UIColor(hexString: "#DC2626")
        }
    }
}

//MARK: - Streak
public extension UIColor {
    
    static var streakActive: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor(hexString: "#FB923C")
            }
            return UIColor(hexString: "#F97316")
        }
    }
    
    static var streakCompleted: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor(hexString: "#2DD4BF")
            }
            return UIColor(hexString: "#0D9488")
        }
    }
    
    static var streakFrozen: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor(hexString: "#CBD5E1")
            }
            return UIColor(hexString: "#94A3B8")
        }
    }
}

//MARK: - Progress
public extension UIColor {
    
    static var progressLow: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor(hexString: "#F87171")
            }
            return UIColor(hexString: "#EF4444")
        }
    }
    
    static var progressMedium: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor(hexString: "#FBBF24")
            }
            return UIColor(hexString: "#F59E0B")
        }
    }
    
    static var progressHigh: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor(hexString: "#5EEAD4")
            }
            return UIColor(hexString: "#0D9488")
        }
    }
}

//MARK: - Achievement
public extension UIColor {
    
    static var achievement: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor(hexString: "#FDE68A")
            }
            return UIColor(hexString: "#D97706")
        }
    }
}

//MARK: - Surface
public extension UIColor {
    
    static var surfaceElevated: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor(hexString: "#1A211D")
            }
            return UIColor(hexString: "#FFFFFF")
        }
    }
    
    static var surfaceOverlay: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor(hexString: "#000000", alpha: 0.72)
            }
            return UIColor(hexString: "#000000", alpha: 0.5)
        }
    }
    
    static var surfaceSelected: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor(hexString: "#134E4A")
            }
            return UIColor(hexString: "#CCFBF1")
        }
    }
}

//MARK: - Focus Mode
public extension UIColor {
    static var forestAccent: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor(hexString: "#84F6B5")
            }
            return UIColor(hexString: "#1E7A4A")
        }
    }
}

//MARK: - Wallpaper
public extension UIColor {
    static var wallpaperMorning: UIColor { wallpaperMorningTop }

    static var wallpaperMorningTop: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor(hexString: "#2A2119")
            }
            return UIColor(hexString: "#FFF7ED")
        }
    }

    static var wallpaperMorningBottom: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor(hexString: "#123226")
            }
            return UIColor(hexString: "#DDF7EC")
        }
    }

    static var wallpaperForest: UIColor { wallpaperForestTop }

    static var wallpaperForestTop: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor(hexString: "#07110C")
            }
            return UIColor(hexString: "#DDEEE4")
        }
    }

    static var wallpaperForestBottom: UIColor {
        return UIColor(hexString: "#1E7A4A")
    }

    static var wallpaperDusk: UIColor { wallpaperDuskTop }

    static var wallpaperDuskTop: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor(hexString: "#171225")
            }
            return UIColor(hexString: "#F8E1D4")
        }
    }

    static var wallpaperDuskBottom: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor(hexString: "#F97316")
            }
            return UIColor(hexString: "#7C3A58")
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
