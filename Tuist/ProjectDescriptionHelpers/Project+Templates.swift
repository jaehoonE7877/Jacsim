//
//  Project+Templates.swift
//  JacsimManifests
//
//  Created by Seo Jae Hoon on 3/27/24.
//

import Foundation
import ConfigurationPlugin
import EnvironmentPlugin
import DependencyPlugin
import ProjectDescription

public extension Project {
    static func makeModule(
        name: String,
        targets: Set<FeatureTarget> = Set([.staticFramework, .unitTest, .demo]),
        packages: [Package] = [],
        internalDependencies: [TargetDependency] = [],  // 모듈간 의존성
        externalDependencies: [TargetDependency] = [],  // 외부 라이브러리 의존성
        interfaceDependencies: [TargetDependency] = [], // Feature Interface 의존성
        dependencies: [TargetDependency] = [],
        hasResources: Bool = false
    ) -> Project {
        
        let configurationName: ConfigurationName = "Debug"
        let hasDynamicFramework = targets.contains(.dynamicFramework)
        let deploymentTarget = Environment.deploymentTarget
        let destination: Set<Destination> = [.iPhone]
        
        let baseSettings: SettingsDictionary = .baseSettings
        
        var projectTargets: [Target] = []
        var schemes: [Scheme] = []
        
        // MARK: - App
        
        if targets.contains(.app) {
            let infoPlist = name.contains("Demo") ? Project.demoInfoPlist : Project.appInfoPlist
            let versionSetting: [String: SettingValue] = [
                "MARKETING_VERSION": SettingValue(stringLiteral: Environment.appVersion),
                "CURRENT_PROJECT_VERSION": "1"
            ]
            let settings: SettingsDictionary = baseSettings
                .merging(versionSetting)
                .setHeaderSearchPath(isModule: false)
                .codeSignIdentityAppleDevelopment()
            
            let target = Target.target(
                name: name,
                destinations: destination,
                product: .app,
                bundleId: "\(Environment.bundlePrefix)",
                deploymentTargets: deploymentTarget,
                infoPlist: .extendingDefault(with: infoPlist),
                sources: ["Sources/**/*.swift"],
                resources: [
                    .glob(pattern: "Resources/**", excluding: [])
                           ],
                entitlements: "\(name).entitlements",
                scripts: [],
                dependencies: [
                    internalDependencies,
                    externalDependencies,
                    [
                        
                    ]
                ].flatMap { $0 },
                settings: .settings(base: settings,
                                    configurations: XCConfig.project)
            )
            projectTargets.append(target)
        }
        
        // MARK: - Feature Interface
        
        if targets.contains(.interface) {
            let settings = baseSettings
            
            let target = Target.target(
                name: "\(name)Interface",
                destinations: destination,
                product: .framework,
                bundleId: "\(Environment.bundlePrefix).\(name)Interface",
                deploymentTargets: deploymentTarget,
                infoPlist: .default,
                sources: ["Interface/Sources/**/*.swift"],
                dependencies: interfaceDependencies,
                settings: .settings(base: settings, configurations: XCConfig.framework)
            )
            
            projectTargets.append(target)
        }
        
        // MARK: - Framework
        
        if targets.contains(where: { $0.hasFramework }) {
            let deps: [TargetDependency] = targets.contains(.interface)
            ? [.target(name: "\(name)Interface")]
            : []
            let isNetworks = (name == "Networks") || name.contains("Feature")
            let settings = baseSettings
                .setHeaderSearchPath(isModule: isNetworks)
            
            let target = Target.target(
                name: name,
                destinations: destination,
                product: hasDynamicFramework ? .framework : .staticFramework,
                bundleId: "\(Environment.bundlePrefix).\(name)",
                deploymentTargets: deploymentTarget,
                infoPlist: .default,
                sources: ["Sources/**/*.swift"],
                resources: hasResources ? [.glob(pattern: "Resources/**", excluding: ["Resources/dummy.txt"])] : [],
                dependencies: deps + internalDependencies + externalDependencies,
                settings: .settings(base: settings, configurations: XCConfig.framework)
            )
            
            projectTargets.append(target)
        }
        
        // MARK: - Feature Executable
        
        if targets.contains(.demo) {
            let deps: [TargetDependency] = [.target(name: name)]
            
            let target = Target.target(
                name: "\(name)Demo",
                destinations: .iOS,
                product: .app,
                bundleId: "\(Environment.bundlePrefix).\(name)Demo",
                deploymentTargets: deploymentTarget,
                infoPlist: .extendingDefault(with: Project.demoInfoPlist),
                sources: ["Demo/Sources/**/*.swift"],
                resources: [.glob(pattern: "Demo/Resources/**", excluding: ["Demo/Resources/dummy.txt"])],
                dependencies: [
                    deps,
                    [
                        
                    ]
                ].flatMap { $0 },
                settings: .settings(base: baseSettings,
                                    configurations: XCConfig.demo)
            )

            projectTargets.append(target)
        }
        
        // MARK: - Unit Tests
        
        if targets.contains(.unitTest) {
            let deps: [TargetDependency] = [.target(name: name)]
            
            let target = Target.target(
                name: "\(name)Tests",
                destinations: .iOS,
                product: .unitTests,
                bundleId: "\(Environment.bundlePrefix).\(name)Tests",
                deploymentTargets: deploymentTarget,
                infoPlist: .default,
                sources: ["Tests/Sources/**/*.swift"],
                resources: [],
                dependencies: [
                    deps,
                    [
                        .SPM.Quick,
                        .SPM.Nimble
                    ]
                ].flatMap { $0 },
                settings: .settings(base: SettingsDictionary(),
                                    configurations: XCConfig.tests)
            )
            
            projectTargets.append(target)
        }
        
        // MARK: - Schemes
        
        let additionalSchemes = targets.contains(.demo)
        ? [Scheme.makeScheme(target: configurationName, name: name),
           Scheme.makeDemoScheme(target: configurationName, name: name)]
        : [Scheme.makeScheme(target: configurationName, name: name)]
        
        schemes += additionalSchemes
        
        var scheme = targets.contains(.app)
        ? appSchemes
        : schemes
        
        if name.contains("Demo") {
            let testAppScheme = Scheme.makeScheme(target: "Debug", name: name)
            scheme.append(testAppScheme)
        }
            
        return Project(
            name: name,
            organizationName: Environment.workspaceName,
            packages: packages,
            settings: .settings(configurations: XCConfig.project),
            targets: projectTargets,
            schemes: scheme,
            resourceSynthesizers: [
                .fonts(),
                .assets(),
            ]
        )
    }
}

extension Scheme {
    static func makeScheme(target: ConfigurationName, name: String) -> Scheme {
        return Scheme.scheme(
            name: name,
            shared: true,
            buildAction: .buildAction(targets: ["\(name)"]),
            testAction: .targets(
                ["\(name)Tests"],
                configuration: target,
                options: .options(coverage: true, codeCoverageTargets: ["\(name)"])
            ),
            runAction: .runAction(configuration: target),
            archiveAction: .archiveAction(configuration: target),
            profileAction: .profileAction(configuration: target),
            analyzeAction: .analyzeAction(configuration: target)
        )
    }
    static func makeDemoScheme(target: ConfigurationName, name: String) -> Scheme {
        return Scheme.scheme(
            name: name,
            shared: true,
            buildAction: .buildAction(targets: ["\(name)DemoApp"]),
            testAction: .targets(
                ["\(name)Tests"],
                configuration: target,
                options: .options(coverage: true, codeCoverageTargets: ["\(name)DemoApp"])
            ),
            runAction: .runAction(configuration: target),
            archiveAction: .archiveAction(configuration: target),
            profileAction: .profileAction(configuration: target),
            analyzeAction: .analyzeAction(configuration: target)
        )
    }
}

extension Project {
    static let appSchemes: [Scheme] = [
        .scheme(
            name: "\(Environment.workspaceName)-DEBUG",
            shared: true,
            buildAction: .buildAction(targets: ["\(Environment.workspaceName)"]),
            testAction: .targets(
                ["\(Environment.workspaceName)Tests"],
                configuration: "Debug",
                options: .options(coverage: true, codeCoverageTargets: ["\(Environment.workspaceName)"])
            ),
            runAction: .runAction(configuration: "Debug",
                                  arguments: .arguments(environmentVariables: ["OS_ACTIVITY_MODE": "disable"],
                                                        launchArguments: [.launchArgument(name: "-FIRDebugEnabled", isEnabled: true)])
                                 ),
            archiveAction: .archiveAction(configuration: "Debug"),
            profileAction: .profileAction(configuration: "Debug"),
            analyzeAction: .analyzeAction(configuration: "Debug")
        ),
        .scheme(
            name: "\(Environment.workspaceName)",
            shared: true,
            buildAction: .buildAction(targets: ["\(Environment.workspaceName)"]),
            runAction: .runAction(configuration: "Release",
                                  arguments: .arguments(environmentVariables: ["OS_ACTIVITY_MODE": "disable"],
                                                        launchArguments: [.launchArgument(name: "-FIRDebugEnabled", isEnabled: true)])
                                 ),
            archiveAction: .archiveAction(configuration: "Release"),
            profileAction: .profileAction(configuration: "Release"),
            analyzeAction: .analyzeAction(configuration: "Release")
        )
    ]
}
