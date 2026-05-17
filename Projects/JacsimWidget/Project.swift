import ProjectDescription
import ProjectDescriptionHelpers
import ConfigurationPlugin
import DependencyPlugin
import EnvironmentPlugin

let widgetTarget = Target.target(
    name: "JacsimWidget",
    destinations: [.iPhone],
    product: .appExtension,
    bundleId: "com.jaehoon.jaksim.JacsimWidget",
    deploymentTargets: Project.Environment.deploymentTarget,
    infoPlist: .extendingDefault(with: [
        "CFBundleDisplayName": "작심 위젯",
        "CFBundleShortVersionString": "\(Project.Environment.appVersion)",
        "CFBundleVersion": "$(CURRENT_PROJECT_VERSION)",
        "NSExtension": [
            "NSExtensionPointIdentifier": "com.apple.widgetkit-extension"
        ]
    ]),
    sources: ["Sources/**"],
    entitlements: "JacsimWidget.entitlements",
    dependencies: [
        .Modules.dsKit,
        .domain,
        .externalInterface,
        .data
    ],
    settings: .settings(
        base: SettingsDictionary.baseSettings
            .setSwiftLanguageVersion(SwiftLanguageVersion.v6.rawValue)
            .merging([
                "MARKETING_VERSION": SettingValue(stringLiteral: Project.Environment.appVersion),
                "CURRENT_PROJECT_VERSION": SettingValue(stringLiteral: "1")
            ])
            .setCodeSignAutomatic(),
        configurations: XCConfig.project
    ),
    metadata: .metadata(tags: ["widget", "jacsim"])
)

let project = Project(
    name: "JacsimWidget",
    organizationName: Project.Environment.workspaceName,
    settings: .settings(configurations: XCConfig.project),
    targets: [widgetTarget],
    schemes: [
        .scheme(
            name: "JacsimWidget",
            shared: true,
            buildAction: .buildAction(targets: [.target("JacsimWidget")]),
            archiveAction: .archiveAction(configuration: "Release"),
            profileAction: .profileAction(configuration: "Release"),
            analyzeAction: .analyzeAction(configuration: "Debug")
        )
    ],
    resourceSynthesizers: [
        .fonts(),
        .assets()
    ]
)
