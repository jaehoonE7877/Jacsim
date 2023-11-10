//
//  Dependency+SPM.swift
//  ConfigurationPlugin
//
//  Created by Seo Jae Hoon on 2023/11/10.
//

import ProjectDescription

public extension TargetDependency {
    enum SPM {}
}

public extension TargetDependency.SPM {
    static let Snapkit = TargetDependency.external(name: "SnapKit")
    static let Then = TargetDependency.external(name: "Then")
    static let Toast = TargetDependency.external(name: "Toast")
    static let IQKeyboardManagerSwift = TargetDependency.external(name: "IQKeyboardManagerSwift")
    static let Kingfisher = TargetDependency.external(name: "Kingfisher")
    static let CropViewController = TargetDependency.external(name: "CropViewController")
    static let FSCalendar = TargetDependency.external(name: "FSCalendar")
    static let Floaty = TargetDependency.external(name: "Floaty")
    static let AcknowList = TargetDependency.external(name: "AcknowList")
    static let FirebaseMessaging = TargetDependency.external(name: "FirebaseMessaging")
    static let Realm = TargetDependency.external(name: "Realm")
    static let RxSwift = TargetDependency.external(name: "RxSwift")
}
