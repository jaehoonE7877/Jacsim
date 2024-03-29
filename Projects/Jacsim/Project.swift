import ProjectDescription
import ProjectDescriptionHelpers
import DependencyPlugin
import EnvironmentPlugin

let project = Project.makeModule(
    name: Environment.workspaceName,
    targets: [.app, .unitTest],
    externalDependencies: [
        .SPM.AcknowList,
        .SPM.FSCalendar,
        .SPM.FirebaseAnalytics,
        .SPM.FirebaseCrashlytics,
        .SPM.FirebaseMessaging,
        .SPM.IQKeyboardManagerSwift,
        .SPM.Kingfisher,
        .SPM.RealmSwift,
        .SPM.RxSwift,
        .SPM.RxCocoa,
        .SPM.Snapkit,
        .SPM.Toast,
        .SPM.Promises,
        .SPM.CropViewController,
        .SPM.Floaty,
        .SPM.Then,
        .SPM.LookinServer
    ]
)
