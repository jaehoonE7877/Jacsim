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
    static let FirebaseCrashlytics = TargetDependency.external(name: "FirebaseCrashlytics", condition: .none)
    static let Promises = TargetDependency.external(name: "Promises", condition: .none)
    //MARK: - UI
    static let IQKeyboardManagerSwift = TargetDependency.external(name: "IQKeyboardManagerSwift", condition: .none)
    static let Kingfisher = TargetDependency.external(name: "Kingfisher", condition: .none)
    static let AcknowList = TargetDependency.external(name: "AcknowList", condition: .none)
    static let CropViewController = TargetDependency.external(name: "CropViewController", condition: .none)
    //MARK: - Test (Swift Testing 사용, 외부 테스트 라이브러리 없음)
}
