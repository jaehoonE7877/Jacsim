//
//  FeatureTarget.swift
//  JacsimManifests
//
//  Created by Seo Jae Hoon on 3/27/24.
//

import Foundation
import ProjectDescription

public enum FeatureTarget {
    case app    // iOS App
    case interface      // Feature Interface
    case dynamicFramework
    case staticFramework
    case unitTest   // Unit Test
    case uiTest     // UI Test
    case demo       // Feature Excutable Test
    
    public var hasFramework: Bool {
        switch self {
        case .dynamicFramework, .staticFramework: return true
        default: return false
        }
    }
    
    public var isDynamicFramework: Bool { return self == .dynamicFramework }
}
