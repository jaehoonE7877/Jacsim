import ProjectDescription
import ProjectDescriptionHelpers
import DependencyPlugin
import EnvironmentPlugin

let project = Project.makeAppProject(
    name: Environment.workspaceName,
    swiftLanguageVersion: .v6,
    internalDependencies: [
        .Modules.thirdPartyLibs,
        .Modules.designSystem,
        .Modules.shared,
        .jacsimClient,
        .domain
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
