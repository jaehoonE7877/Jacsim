import ProjectDescription
import ProjectDescriptionHelpers
import DependencyPlugin
import EnvironmentPlugin

let project = Project.makeModule(
    name: Environment.workspaceName,
    swiftLanguageVersion: .v6,
    targets: [.app, .unitTest],
    internalDependencies: [
        .Modules.thirdPartyLibs,
        .Modules.dsKit,
        .domain,
        .externalInterface,
        .data
    ],
    externalDependencies: [
        .SPM.FirebaseAnalytics,
        .SPM.FirebaseCrashlytics,
        .SPM.FirebaseMessaging,
        .SPM.Promises,
        .SPM.IQKeyboardManagerSwift,
        .SPM.Kingfisher,
        .SPM.AcknowList,
        .SPM.CropViewController,
        .SPM.ComposableArchitecture,
    ],
    tags: ["app", "jacsim"]
)
