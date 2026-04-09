//
//  UIColor+Extension.swift
//  DSKit
//
//  Created by Seo Jae Hoon on 4/3/24.
//  Copyright © 2024 Jacsim. All rights reserved.
//

import UIKit

//MARK: - 기본 색상
public extension UIColor {
    
    static var primaryNormal: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor(hexString: "#2B6BE5")
            }
            return UIColor(hexString: "#0066FF")
        }
    }
    
    static var primaryStrong: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor(hexString: "#1F5FD6")
            }
            return UIColor(hexString: "#005EEB")
        }
    }
    
    static var primaryHeavy: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor(hexString: "#174FB9")
            }
            return UIColor(hexString: "#0054D1")
        }
    }
    
    /// Text color for use on primary colored backgrounds (always white for maximum contrast)
    static var onPrimary: UIColor {
        return UIColor { (traits) -> UIColor in
            // Keep dark primary hues contrast-safe for white foreground text.
            return UIColor(hexString: "#FFFFFF")
        }
    }
}

//MARK: - 라벨
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
                return UIColor(hexString: "#AEB0B6", alpha: 0.70)
            }
            return UIColor(hexString: "#37383C", alpha: 0.70)
        }
    }
    
    static var labelAssistive: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor(hexString: "#AEB0B6", alpha: 0.56)
            }
            return UIColor(hexString: "#37383C", alpha: 0.56)
        }
    }
    
    static var labelDisable: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor(hexString: "#989BA2", alpha: 0.24)
            }
            return UIColor(hexString: "#37383C", alpha: 0.22)
        }
    }
}

//MARK: - 배경
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

//MARK: - 상태
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

//MARK: - 연속 기록
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

//MARK: - 진행 상태
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

//MARK: - 업적
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

//MARK: - 표면
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

//MARK: - 스켈레톤
public extension UIColor {

    static var skeletonContainer: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor(hexString: "#2C2D2F")
            }
            return UIColor(hexString: "#FFFFFF")
        }
    }

    static var skeletonBase: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor(hexString: "#3A3D42")
            }
            return UIColor(hexString: "#E9EDF2")
        }
    }

    static var skeletonHighlight: UIColor {
        return UIColor { (traits) -> UIColor in
            if traits.userInterfaceStyle == .dark {
                return UIColor(hexString: "#6F7785")
            }
            return UIColor(hexString: "#D4DCE7")
        }
    }
}

extension UIColor {
    /// Hex 값으로 컬러를 할당할 수 있습니다
    /// 태그: #Hex
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
