//
//  Path+Extension.swift
//  ConfigurationPlugin
//
//  Created by Seo Jae Hoon on 2023/11/10.
//

import ProjectDescription

public extension ProjectDescription.Path {
    static func relativeToFeature(_ path: String) -> Self {
        return .relativeToRoot("Projects/Features/\(path)")
    }
    
    static func relativeToModules(_ path: String) -> Self {
        return .relativeToRoot("Projects/Modules/\(path)")
    }
    
    static var app: Self {
        return .relativeToRoot("Projects/App")
    }
    
    static var adapters: Self {
        return .relativeToRoot("Projects/Data")
    }
    
    static var domain: Self {
        return .relativeToRoot("Projects/Domain")
    }
    
    static var shared: Self {
        return .relativeToRoot("Projects/Modules/Core")
    }
    
    static var designSystem: Self {
        return .relativeToRoot("Projects/Modules/DSKit")
    }
    
    static var ports: Self {
        return .relativeToRoot("Projects/ExternalInterface")
    }

    static var workflows: Self {
        return .relativeToRoot("Projects/Workflows")
    }
}
