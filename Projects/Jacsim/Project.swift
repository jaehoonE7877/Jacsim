import ProjectDescription
import ProjectDescriptionHelpers
import DependencyPlugin
import EnvironmentPlugin

let project = Project.makeModule(
    name: Environment.workspaceName,
    swiftLanguageVersion: .v6,
    targets: [.app, .unitTest],
    internalDependencies: [
        .Modules.core,
        .Modules.thirdPartyLibs,
        .Modules.dsKit,
        .domain,
        .externalInterface,
        .data
    ],
    externalDependencies: [
        .SPM.FirebaseCrashlytics,
        .SPM.Promises,
        .SPM.IQKeyboardManagerSwift,
        .SPM.Kingfisher,
        .SPM.AcknowList,
        .SPM.CropViewController,
    ],
    tags: ["app", "jacsim"]
)
