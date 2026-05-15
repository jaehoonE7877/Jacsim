import ProjectDescription
import ProjectDescriptionHelpers
import DependencyPlugin

let project = Project.makeModule(
    name: "ThirdPartyLibs",
    swiftLanguageVersion: .v6,
    targets: [.staticFramework],
    externalDependencies: [
        //MARK: - Firebase
        .SPM.FirebaseCrashlytics,
        .SPM.Promises,
        //MARK: - UI
        .SPM.IQKeyboardManagerSwift,
        .SPM.Kingfisher,
        .SPM.AcknowList,
        .SPM.CropViewController,
        .SPM.ComposableArchitecture,
    ],
    tags: ["module", "third-party"]
)
