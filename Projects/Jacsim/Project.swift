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
        .Modules.designSystem,
        .domain,
        .ports,
        .adapters,
        .workflows
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
