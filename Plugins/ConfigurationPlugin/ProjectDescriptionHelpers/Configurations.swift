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
        // Demo 전용 xcconfig가 없으므로 프레임워크 설정을 재사용합니다.
        static var tests: ProjectDescription.Path { .relativeToRoot("xcconfigs/targets/iOS-Tests.xcconfig") }
        static func project(_ config: String) -> ProjectDescription.Path { .relativeToRoot("xcconfigs/Base/Projects/Project-\(config).xcconfig") }
        }
    
    public static let framework: [Configuration] = [
        .debug(name: "Debug", xcconfig: Path.framework),
        .release(name: "Release", xcconfig: Path.framework),
    ]
    
    public static let tests: [Configuration] = [
        .debug(name: "Debug", xcconfig: Path.tests),
        .release(name: "Release", xcconfig: Path.tests),
    ]
    public static let demo: [Configuration] = [
        .debug(name: "Debug", xcconfig: Path.framework),
        .release(name: "Release", xcconfig: Path.framework),
    ]
    public static let project: [Configuration] = [
        .debug(name: "Debug", xcconfig: Path.project("Debug")),
        .release(name: "Release", xcconfig: Path.project("Release")),
    ]
}
