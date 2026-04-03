import ProjectDescription
import ProjectDescriptionHelpers
import DependencyPlugin

let project = Project.makeFrameworkProject(
    name: "ThirdPartyLibs",
    swiftLanguageVersion: .v6,
    externalDependencies: [
        //MARK: - Firebase
        .SPM.FirebaseAnalytics,
        .SPM.FirebaseCrashlytics,
        .SPM.FirebaseMessaging,
        .SPM.Promises,
        //MARK: - UI
        .SPM.IQKeyboardManagerSwift,
        .SPM.Kingfisher,
        .SPM.AcknowList,
        .SPM.CropViewController,
        .SPM.ComposableArchitecture,
    ],
    includeTests: false,
    tags: ["module", "third-party"]
)
