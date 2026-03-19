//
//  Dependency+Project.swift
//  ConfigurationPlugin
//
//  Created by Seo Jae Hoon on 2023/11/10.
//

import ProjectDescription

public extension Dep {
    struct Modules { }
}
//MARK: -- Root

public extension Dep {
    static let jacsimClient = Dep.project(target: "JacsimClient", path: .jacsimClient)

    static let adapters = Dep.project(target: "Adapters", path: .adapters)
    
    static let domain = Dep.project(target: "Domain", path: .domain)

    static let ports = Dep.project(target: "Ports", path: .ports)

    static let workflows = Dep.project(target: "Workflows", path: .workflows)
}

//MARK: -- Modules

public extension Dep.Modules {
    static let designSystem = Dep.project(target: "DesignSystem", path: .designSystem, condition: .none)
    
    static let thirdPartyLibs = Dep.project(target: "ThirdPartyLibs", path: .relativeToModules("ThirdPartyLibs"), condition: .none)

    static let shared = Dep.project(target: "Shared", path: .shared, condition: .none)
}
