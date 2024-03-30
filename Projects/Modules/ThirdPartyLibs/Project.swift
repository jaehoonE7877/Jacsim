import ProjectDescription
import ProjectDescriptionHelpers
import DependencyPlugin

let project = Project.makeModule(
    name: "ThirdPartyLibs",
    targets: [.staticFramework],
    externalDependencies: [
        //MARK: - Firebase
        .SPM.FirebaseAnalytics,
        .SPM.FirebaseCrashlytics,
        .SPM.FirebaseMessaging,
        .SPM.Promises,
        //MARK: - UI
        .SPM.Snapkit,
        .SPM.Then,
        .SPM.Toast,
        .SPM.IQKeyboardManagerSwift,
        .SPM.Kingfisher,
        .SPM.FSCalendar,
        .SPM.AcknowList,
        .SPM.CropViewController,
        .SPM.Floaty,
        //MARK: - DB
        .SPM.RealmSwift,
        //MARK: - ReactiveX
        .SPM.RxCocoa,
        .SPM.RxSwift,
        //MARK: - Debug
        .SPM.LookinServer
    ]
)
