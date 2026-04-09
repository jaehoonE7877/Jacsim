//
//  Project+Templates.swift
//  JacsimManifests
//
//  Created by Seo Jae Hoon on 3/27/24.
//

import Foundation
import ConfigurationPlugin
import EnvironmentPlugin
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
    static func makeAppProject(
        name: String,
        swiftLanguageVersion: SwiftLanguageVersion = .v5,
        internalDependencies: [TargetDependency] = [],
        externalDependencies: [TargetDependency] = [],
        tags: [String] = []
    ) -> Project {
        let deploymentTarget = Environment.deploymentTarget
        let destination: Set<Destination> = [.iPhone]
        let moduleTags = Array(Set(tags + [name]))

        let versionSetting: [String: SettingValue] = [
            "MARKETING_VERSION": SettingValue(stringLiteral: Environment.appVersion),
            "CURRENT_PROJECT_VERSION": SettingValue(stringLiteral: appBuildNumber)
        ]
        let settings: SettingsDictionary = .baseSettings
            .setSwiftLanguageVersion(swiftLanguageVersion.rawValue)
            .setHeaderSearchPath(isModule: false)
            .merging(versionSetting)

        let appTarget = Target.target(
            name: name,
            destinations: destination,
            product: .app,
            bundleId: "\(Environment.bundlePrefix)",
            deploymentTargets: deploymentTarget,
            infoPlist: .extendingDefault(with: Project.appInfoPlist),
            buildableFolders: ["Sources", "Resources"],
            entitlements: "\(name).entitlements",
            scripts: [.FirebaseCrashlyticsString],
            dependencies: internalDependencies + externalDependencies,
            settings: .settings(
                base: settings.setCodeSignAutomatic(),
                configurations: XCConfig.project
            ),
            metadata: .metadata(tags: moduleTags + ["app"])
        )

        let testTarget = Target.target(
            name: "\(name)Tests",
            destinations: destination,
            product: .unitTests,
            bundleId: "\(Environment.bundlePrefix).\(name)Tests",
            deploymentTargets: deploymentTarget,
            infoPlist: .default,
            buildableFolders: ["Tests/Sources"],
            dependencies: [.target(name: name)],
            settings: .settings(
                base: settings.setCodeSignAutomatic(),
                configurations: XCConfig.tests
            ),
            metadata: .metadata(tags: moduleTags + ["test"])
        )

        return Project(
            name: name,
            organizationName: Environment.workspaceName,
            packages: [],
            settings: .settings(configurations: XCConfig.project),
            targets: [appTarget, testTarget],
            schemes: Project.makeAppSchemes(name: name),
            resourceSynthesizers: [
                .fonts(),
                .assets(),
            ]
        )
    }

    static func makeFrameworkProject(
        name: String,
        swiftLanguageVersion: SwiftLanguageVersion = .v5,
        internalDependencies: [TargetDependency] = [],
        externalDependencies: [TargetDependency] = [],
        hasResources: Bool = false,
        includeTests: Bool = true,
        tags: [String] = []
    ) -> Project {
        let deploymentTarget = Environment.deploymentTarget
        let destination: Set<Destination> = [.iPhone]
        let moduleTags = Array(Set(tags + [name]))
        let baseSettings: SettingsDictionary = .baseSettings
            .setSwiftLanguageVersion(swiftLanguageVersion.rawValue)
            .setHeaderSearchPath(isModule: false)

        var projectTargets: [Target] = []

        let frameworkTarget = Target.target(
            name: name,
            destinations: destination,
            product: .staticFramework,
            bundleId: "\(Environment.bundlePrefix).\(name)",
            deploymentTargets: deploymentTarget,
            infoPlist: .default,
            buildableFolders: hasResources ? ["Sources", "Resources"] : ["Sources"],
            dependencies: internalDependencies + externalDependencies,
            settings: .settings(
                base: baseSettings.setCodeSignAutomatic(),
                configurations: XCConfig.framework
            ),
            metadata: .metadata(tags: moduleTags + ["framework"])
        )
        projectTargets.append(frameworkTarget)

        if includeTests {
            let testTarget = Target.target(
                name: "\(name)Tests",
                destinations: destination,
                product: .unitTests,
                bundleId: "\(Environment.bundlePrefix).\(name)Tests",
                deploymentTargets: deploymentTarget,
                infoPlist: .default,
                buildableFolders: ["Tests/Sources"],
                dependencies: [.target(name: name)],
                settings: .settings(
                    base: baseSettings.setCodeSignAutomatic(),
                    configurations: XCConfig.tests
                ),
                metadata: .metadata(tags: moduleTags + ["test"])
            )
            projectTargets.append(testTarget)
        }

        return Project(
            name: name,
            organizationName: Environment.workspaceName,
            packages: [],
            settings: .settings(configurations: XCConfig.project),
            targets: projectTargets,
            schemes: [Project.makeFrameworkScheme(name: name, includeTests: includeTests)],
            resourceSynthesizers: [
                .fonts(),
                .assets(),
            ]
        )
    }
}

private extension Project {
    static func makeFrameworkScheme(name: String, includeTests: Bool) -> Scheme {
        if includeTests {
            return Scheme.scheme(
                name: name,
                shared: true,
                buildAction: .buildAction(targets: ["\(name)"]),
                testAction: .targets(
                    ["\(name)Tests"],
                    configuration: "Debug",
                    options: .options(coverage: false)
                ),
                runAction: .runAction(configuration: "Debug"),
                archiveAction: .archiveAction(configuration: "Debug"),
                profileAction: .profileAction(configuration: "Debug"),
                analyzeAction: .analyzeAction(configuration: "Debug")
            )
        }

        return Scheme.scheme(
            name: name,
            shared: true,
            buildAction: .buildAction(targets: ["\(name)"]),
            runAction: .runAction(configuration: "Debug"),
            archiveAction: .archiveAction(configuration: "Debug"),
            profileAction: .profileAction(configuration: "Debug"),
            analyzeAction: .analyzeAction(configuration: "Debug")
        )
    }
}

extension Project {
    static func makeAppSchemes(name: String) -> [Scheme] {
        [
            makeAppScheme(name: name, schemeName: name, coverageEnabled: true),
            makeAppScheme(name: name, schemeName: "\(name)Local", coverageEnabled: false)
        ]
    }

    private static func makeAppScheme(name: String, schemeName: String, coverageEnabled: Bool) -> Scheme {
        let testTargets: [TestableTarget] = [
            .testableTarget(target: .target("\(name)Tests"))
        ]
        let testOptions: TestActionOptions = if coverageEnabled {
            .options(
                coverage: true,
                codeCoverageTargets: [.target(name)]
            )
        } else {
            .options(coverage: false)
        }

        return .scheme(
            name: schemeName,
            shared: true,
            buildAction: .buildAction(targets: [.target(name)], postActions: [ ]),
            testAction: .targets(
                testTargets,
                configuration: "Debug",
                options: testOptions
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
