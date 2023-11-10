//
//  Configurations.swift
//  ConfigurationPlugin
//
//  Created by Seo Jae Hoon on 2023/11/10.
//

import ProjectDescription

public struct XCConfig {
    private struct Path {
        static var framework: ProjectDescription.Path { return .relativeToRoot("xcconfigs/targets/iOS-Framework.xcconfig") }
        static var demo: ProjectDescription.Path { return .relativeToRoot("xcconfigs/targets/iOS-Demo.xcconfig") }
        static var tests: ProjectDescription.Path { .relativeToRoot("xcconfigs/targets/iOS-Tests.xcconfig") }
        static func project(_ config: String) -> ProjectDescription.Path { .relativeToRoot("xcconfigs/Base/Projects/Project-\(config).xcconfig") }
        }
    
    public static let framework: [Configuration] = [
        .debug(name: "Develop", xcconfig: Path.framework),
        .debug(name: "Debug", xcconfig: Path.framework),
        .debug(name: "QA", xcconfig: Path.framework),
        .release(name: "Release", xcconfig: Path.framework),
    ]
    
    public static let tests: [Configuration] = [
        .debug(name: "Develop", xcconfig: Path.tests),
        .debug(name: "Debug", xcconfig: Path.tests),
        .debug(name: "QA", xcconfig: Path.tests),
        .release(name: "Release", xcconfig: Path.tests),
    ]
    public static let demo: [Configuration] = [
        .debug(name: "Develop", xcconfig: Path.demo),
        .debug(name: "Debug", xcconfig: Path.demo),
        .debug(name: "QA", xcconfig: Path.demo),
        .release(name: "Release", xcconfig: Path.demo),
    ]
    public static let project: [Configuration] = [
        .debug(name: "Develop", xcconfig: Path.project("Develop")),
        .debug(name: "Debug", xcconfig: Path.project("Debug")),
        .debug(name: "QA", xcconfig: Path.project("QA")),
        .release(name: "Release", xcconfig: Path.project("Release")),
    ]
}
