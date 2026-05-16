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

private let appBuildNumber: String = {
    let rawValue = ProcessInfo.processInfo.environment["TUIST_APP_BUILD_NUMBER"]?
        .trimmingCharacters(in: .whitespacesAndNewlines)
    guard let rawValue, rawValue.range(of: #"^\d+$"#, options: .regularExpression) != nil else {
        return "1"
    }
    return rawValue
}()

public extension Project {
    static func makeModule(
        name: String,
        swiftLanguageVersion: SwiftLanguageVersion = .v5,
        targets: Set<FeatureTarget> = Set([.staticFramework, .unitTest, .demo]),
        packages: [Package] = [],
        internalDependencies: [TargetDependency] = [],  // 모듈간 의존성
        externalDependencies: [TargetDependency] = [],  // 외부 라이브러리 의존성
        interfaceDependencies: [TargetDependency] = [], // Feature Interface 의존성
        dependencies: [TargetDependency] = [],
        hasResources: Bool = false,
        tags: [String] = []
    ) -> Project {
        
        let configurationName: ConfigurationName = "Debug"
        let hasDynamicFramework = targets.contains(.dynamicFramework)
        let hasApp = targets.contains(.app)
        let deploymentTarget = Environment.deploymentTarget
        let destination: Set<Destination> = [.iPhone]
        let moduleTags = Array(Set(tags + [name]))
        
        let baseSettings: SettingsDictionary = .baseSettings
            .setSwiftLanguageVersion(swiftLanguageVersion.rawValue)
        
        var projectTargets: [Target] = []
        var schemes: [Scheme] = []

        func metadata(_ extraTags: [String] = []) -> TargetMetadata {
            .metadata(tags: moduleTags + extraTags)
        }
        
        // MARK: - App
        
        if targets.contains(.app) {
            let infoPlist = name.contains("Demo") ? Project.demoInfoPlist : Project.appInfoPlist
            let versionSetting: [String: SettingValue] = [
                "MARKETING_VERSION": SettingValue(stringLiteral: Environment.appVersion),
                "CURRENT_PROJECT_VERSION": SettingValue(stringLiteral: appBuildNumber)
            ]
            let settings: SettingsDictionary = baseSettings
                .merging(versionSetting)
                .setHeaderSearchPath(isModule: false)
            
            let target = Target.target(
                name: name,
                destinations: destination,
                product: .app,
                bundleId: "\(Environment.bundlePrefix)",
                deploymentTargets: deploymentTarget,
                infoPlist: .extendingDefault(with: infoPlist),
                buildableFolders: ["Sources", "Resources"],
                entitlements: "\(name).entitlements",
                scripts: [.FirebaseCrashlyticsString],
                dependencies: [
                    internalDependencies,
                    externalDependencies,
                    dependencies
                ].flatMap { $0 },
                settings: .settings(base: settings.setCodeSignAutomatic(),
                                    configurations: XCConfig.project),
                metadata: metadata(["app"])
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
                buildableFolders: ["Interface/Sources"],
                dependencies: interfaceDependencies,
                settings: .settings(base: settings, configurations: XCConfig.framework),
                metadata: metadata(["interface"])
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
                buildableFolders: hasResources ? ["Sources", "Resources"] : ["Sources"],
                dependencies: deps + internalDependencies + externalDependencies + dependencies,
                settings: .settings(base: settings.setCodeSignAutomatic(), configurations: XCConfig.framework),
                metadata: metadata(["framework"])
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
                buildableFolders: ["Demo/Sources", "Demo/Resources"],
                dependencies: [
                    deps,
                    dependencies
                ].flatMap { $0 },
                settings: .settings(base: baseSettings.setCodeSignAutomatic(),
                                    configurations: XCConfig.demo),
                metadata: metadata(["demo"])
            )
            
            projectTargets.append(target)
        }
        
        // MARK: - Unit Tests
        
        if targets.contains(.unitTest) {
            let deps: [TargetDependency] = [.target(name: name)]
            let testConfigurations = hasApp ? XCConfig.tests : XCConfig.frameworkTests
            
            let target = Target.target(
                name: "\(name)Tests",
                destinations: .iOS,
                product: .unitTests,
                bundleId: "\(Environment.bundlePrefix).\(name)Tests",
                deploymentTargets: deploymentTarget,
                infoPlist: .default,
                sources: ["Tests/Sources/**"],
                dependencies: deps,
                settings: .settings(base: baseSettings.setCodeSignAutomatic(),
                                    configurations: testConfigurations),
                metadata: metadata(["test"])
            )
            
            projectTargets.append(target)
        }
        
        // MARK: - Schemes
        
        let additionalSchemes = targets.contains(.demo)
        ? [Scheme.makeScheme(target: configurationName, name: name),
           Scheme.makeDemoScheme(target: configurationName, name: name)]
        : [Scheme.makeScheme(target: configurationName, name: name)]
        
        schemes += additionalSchemes
        
        var scheme = hasApp
        ? makeAppSchemes(name: name)
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
        let buildTarget: TargetReference = .target(name)

        return Scheme.scheme(
            name: name,
            shared: true,
            buildAction: .buildAction(targets: [buildTarget]),
            testAction: .targets(
                ["\(name)Tests"],
                configuration: target,
                options: .options(coverage: false)
            ),
            runAction: .runAction(configuration: target),
            archiveAction: .archiveAction(configuration: target),
            profileAction: .profileAction(configuration: target),
            analyzeAction: .analyzeAction(configuration: target)
        )
    }
    static func makeDemoScheme(target: ConfigurationName, name: String) -> Scheme {
        let buildTarget: TargetReference = .target("\(name)Demo")

        return Scheme.scheme(
            name: name,
            shared: true,
            buildAction: .buildAction(targets: [buildTarget]),
            testAction: .targets(
                ["\(name)Tests"],
                configuration: target,
                options: .options(coverage: false)
            ),
            runAction: .runAction(configuration: target),
            archiveAction: .archiveAction(configuration: target),
            profileAction: .profileAction(configuration: target),
            analyzeAction: .analyzeAction(configuration: target)
        )
    }
}

extension Project {
    static func makeAppSchemes(name: String) -> [Scheme] {
        [
            makeAppScheme(
                schemeName: name,
                targetName: name,
                testTargetName: "\(name)Tests",
                coverage: true
            ),
            makeAppScheme(
                schemeName: "\(name)Local",
                targetName: name,
                testTargetName: "\(name)Tests",
                coverage: false
            ),
        ]
    }

    private static func makeAppScheme(
        schemeName: String,
        targetName: String,
        testTargetName: String,
        coverage: Bool
    ) -> Scheme {
        let appTarget: TargetReference = .target(targetName)

        return .scheme(
            name: schemeName,
            shared: true,
            buildAction: .buildAction(targets: [appTarget], postActions: []),
            testAction: .targets(
                [TestableTarget(stringLiteral: testTargetName)],
                configuration: "Debug",
                options: .options(
                    coverage: coverage,
                    codeCoverageTargets: coverage ? [appTarget] : []
                )
            ),
            runAction: .runAction(
                configuration: "Debug",
                arguments: .arguments(
                    environmentVariables: ["OS_ACTIVITY_MODE": "disable"],
                    launchArguments: [.launchArgument(name: "-FIRDebugEnabled", isEnabled: true)]
                )
            ),
            archiveAction: .archiveAction(configuration: "Release"),
            profileAction: .profileAction(configuration: "Release"),
            analyzeAction: .analyzeAction(configuration: "Debug")
        )
    }
}

public extension TargetScript {
    static let FirebaseCrashlyticsString = TargetScript.post(
        script: """
        OUTPUT_FILE="${DERIVED_FILE_DIR}/FirebaseCrashlyticsUploadDone"

        if [ "$CONFIGURATION" != "Release" ]; then
          echo "Skipping Crashlytics upload for $CONFIGURATION"
          touch "$OUTPUT_FILE"
          exit 0
        fi

        PROJECT_ROOT="$SRCROOT/../.."
        RUN_SCRIPT_PATH="$PROJECT_ROOT/.build/checkouts/firebase-ios-sdk/Crashlytics/run"

        if [ ! -x "$RUN_SCRIPT_PATH" ]; then
          echo "error: Crashlytics run script not found at $RUN_SCRIPT_PATH. Run 'tuist install'."
          exit 1
        fi

        "$RUN_SCRIPT_PATH"
        touch "$OUTPUT_FILE"
    """,
        name: "Firebase Crashlytics",
        inputPaths: [
            "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}",
            "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Resources/DWARF/${TARGET_NAME}",
            "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Info.plist",
            "$(TARGET_BUILD_DIR)/$(UNLOCALIZED_RESOURCES_FOLDER_PATH)/GoogleService-Info.plist",
            "$(TARGET_BUILD_DIR)/$(EXECUTABLE_PATH)"
        ],
        outputPaths: [
            "$(DERIVED_FILE_DIR)/FirebaseCrashlyticsUploadDone"
        ],
        basedOnDependencyAnalysis: true)
}
