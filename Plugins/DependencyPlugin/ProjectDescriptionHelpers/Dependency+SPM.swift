//
//  Dependency+SPM.swift
//  ConfigurationPlugin
//
//  Created by Seo Jae Hoon on 2023/11/10.
//

import ProjectDescription

public extension TargetDependency {
    struct SPM {}
}

public extension TargetDependency.SPM {
    //MARK: - Firebase
    static let FirebaseMessaging = TargetDependency.external(name: "FirebaseMessaging", condition: .none)
    static let FirebaseAnalytics = TargetDependency.external(name: "FirebaseAnalytics", condition: .none)
    static let FirebaseCrashlytics = TargetDependency.external(name: "FirebaseCrashlytics", condition: .none)
    static let Promises = TargetDependency.external(name: "Promises", condition: .none)
    //MARK: - UI
    static let Snapkit = TargetDependency.external(name: "SnapKit", condition: .none)
    static let Toast = TargetDependency.external(name: "Toast", condition: .none)
    static let IQKeyboardManagerSwift = TargetDependency.external(name: "IQKeyboardManagerSwift", condition: .none)
    static let Kingfisher = TargetDependency.external(name: "Kingfisher", condition: .none)
    static let FSCalendar = TargetDependency.external(name: "FSCalendar", condition: .none)
    static let AcknowList = TargetDependency.external(name: "AcknowList", condition: .none)
    static let CropViewController = TargetDependency.external(name: "CropViewController", condition: .none)
    static let Floaty = TargetDependency.external(name: "Floaty", condition: .none)
    static let Then = TargetDependency.external(name: "Then", condition: .none)
    //MARK: - DB
    static let Realm = TargetDependency.external(name: "Realm", condition: .none)
    static let RealmSwift = TargetDependency.external(name: "RealmSwift", condition: .none)
    //MARK: - ReactiveX
    static let RxSwift = TargetDependency.external(name: "RxSwift", condition: .none)
    static let RxCocoa = TargetDependency.external(name: "RxCocoa", condition: .none)
    //MARK: - Test
    static let Nimble = TargetDependency.external(name: "Nimble", condition: .none)
    static let Quick = TargetDependency.external(name: "Quick", condition: .none)
    //MARK: - Debug
    static let LookinServer = TargetDependency.external(name: "LookinServer", condition: .none)
}
