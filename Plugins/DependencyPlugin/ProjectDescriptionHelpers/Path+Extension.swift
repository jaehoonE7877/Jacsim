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
    
    // 현재 앱 경로는 Projects/Jacsim 기준으로 사용합니다.
    static var app: Self {
        return .relativeToRoot("Projects/Jacsim")
    }
    
    // Data/Domain 경로는 현재 레포 구조에 존재하지 않습니다(보류).
    static var data: Self { .relativeToRoot("Projects/Data") }
    static var domain: Self { .relativeToRoot("Projects/Domain") }
    
    static var core: Self {
        return .relativeToRoot("Projects/Modules/Core")
    }
    
    static var dsKit: Self {
        return .relativeToRoot("Projects/Modules/DSKit")
    }
    
    static var externalInterface: Self {
        return .relativeToRoot("Projects/ExternalInterface")
    }
}
