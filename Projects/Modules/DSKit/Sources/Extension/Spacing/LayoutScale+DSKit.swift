import SwiftUI
import UIKit

public enum JSScaleRole {
    case layout
    case touchTarget
    case displayTypography
    case fixed
}

public enum JSLayoutScale {
    public static let baseShortSide: CGFloat = 390
    public static let minLayoutRatio: CGFloat = 0.85
    public static let maxLayoutRatio: CGFloat = 1.25
    public static let minDisplayRatio: CGFloat = 0.92
    public static let maxDisplayRatio: CGFloat = 1.12

    public static var shortSide: CGFloat {
        MainActor.assumeIsolated {
            min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        }
    }

    public static var layoutRatio: CGFloat {
        clamp(shortSide / baseShortSide, min: minLayoutRatio, max: maxLayoutRatio)
    }

    public static var displayRatio: CGFloat {
        clamp(layoutRatio, min: minDisplayRatio, max: maxDisplayRatio)
    }

    public static func scaled(_ value: CGFloat, role: JSScaleRole = .layout) -> CGFloat {
        switch role {
        case .fixed:
            return value
        case .layout:
            return value * layoutRatio
        case .touchTarget:
            let scaledValue = value * layoutRatio
            return value >= 0 ? max(44, scaledValue) : scaledValue
        case .displayTypography:
            return value * displayRatio
        }
    }

    private static func clamp(_ value: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        Swift.max(min, Swift.min(max, value))
    }
}

public extension CGFloat {
    func jsScaled(_ role: JSScaleRole = .layout) -> CGFloat {
        JSLayoutScale.scaled(self, role: role)
    }
}

public extension BinaryInteger {
    func jsScaled(_ role: JSScaleRole = .layout) -> CGFloat {
        CGFloat(self).jsScaled(role)
    }
}

public extension BinaryFloatingPoint {
    func jsScaled(_ role: JSScaleRole = .layout) -> CGFloat {
        CGFloat(self).jsScaled(role)
    }
}

public extension CGSize {
    func jsScaled(_ role: JSScaleRole = .layout) -> CGSize {
        CGSize(width: width.jsScaled(role), height: height.jsScaled(role))
    }
}
