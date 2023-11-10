//
//  Dependency+Project.swift
//  ConfigurationPlugin
//
//  Created by Seo Jae Hoon on 2023/11/10.
//

import ProjectDescription

public extension Dep {
    struct Features {
        
    }
    
    struct Modules { }
}
//MARK: -- Root

public extension Dep {
    static let data = Dep.project(target: "Data", path: .data)
    
    static let domain = Dep.project(target: "Domain", path: .domain)
    
    static let core = Dep.project(target: "Core", path: .core)
}

//MARK: -- Modules

public extension Dep.Modules {
    static let dsKit = Dep.project(target: "DSKit", path: .relativeToModules("DSKit"))
    
    static let thirdPartyLibs = Dep.project(target: "ThirdPartyLibs", path: .relativeToModules("ThirdPartyLibs"))
    
}

