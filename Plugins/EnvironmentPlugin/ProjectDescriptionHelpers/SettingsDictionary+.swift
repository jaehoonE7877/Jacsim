//
//  SettingsDictionary+.swift
//  EnvironmentPlugin
//
//  Created by Seo Jae Hoon on 2023/11/10.
//

import Foundation
import ProjectDescription

private enum SigningEnvironment {
    static let fallbackTeamID = "RFHV927M8S"

    static var developmentTeamID: String {
        // Tuist manifests에서 읽히는 TUIST_* 변수를 우선 사용하고,
        // 누락 시 기존 팀 ID로 fallback하여 로컬 개발 흐름을 깨지 않는다.
        for key in ["TUIST_APPLE_TEAM_ID", "APPLE_TEAM_ID", "IOS_DEVELOPMENT_TEAM", "DEVELOPMENT_TEAM"] {
            if let value = ProcessInfo.processInfo.environment[key]?
                .trimmingCharacters(in: .whitespacesAndNewlines),
               value.isEmpty == false
            {
                return value
            }
        }
        return fallbackTeamID
    }
}

public extension SettingsDictionary {
    static let allLoadSettings: Self = [
        "OTHER_LDFLAGS" : [
            "$(inherited) -all_load",
            "-Xlinker -interposable"
        ]
    ]
    
    static let baseSettings: Self = [
        "OTHER_LDFLAGS" : [
            "$(inherited)",
            "-ObjC"
        ]
    ]
    
    func setHeaderSearchPath(isModule: Bool) -> SettingsDictionary {
        let GTMString = isModule
        ? "$(SRCROOT)/../../../Tuist/Dependencies/SwiftPackageManager/.build/checkouts/GTMAppAuth/GTMAppAuth/Sources/Public/GTMAppAuth"
        : "$(SRCROOT)/../../Tuist/Dependencies/SwiftPackageManager/.build/checkouts/GTMAppAuth/GTMAppAuth/Sources/Public/GTMAppAuth"
        let gtmString = isModule
        ? "$(SRCROOT)/../../../Tuist/Dependencies/SwiftPackageManager/.build/checkouts/gtm-session-fetcher/Sources/Core/Public"
        : "$(SRCROOT)/../../Tuist/Dependencies/SwiftPackageManager/.build/checkouts/gtm-session-fetcher/Sources/Core/Public"
        return merging(["HEADER_SEARCH_PATHS": ["$(inherited)",
                                        GTMString,
                                        gtmString]])
    }
    
    func setProductBundleIdentifier(_ value: String = "com.iOS$(BUNDLE_ID_SUFFIX)") -> SettingsDictionary {
        merging(["PRODUCT_BUNDLE_IDENTIFIER": SettingValue(stringLiteral: value)])
    }
    
    func setAssetcatalogCompilerAppIconName(_ value: String = "AppIcon$(BUNDLE_ID_SUFFIX)") -> SettingsDictionary {
        merging(["ASSETCATALOG_COMPILER_APPICON_NAME": SettingValue(stringLiteral: value)])
    }
    
    func setBuildActiveArchitectureOnly(_ value: Bool) -> SettingsDictionary {
        merging(["ONLY_ACTIVE_ARCH": SettingValue(stringLiteral: value ? "YES" : "NO")])
    }
    
    func setExcludedArchitectures(sdk: String = "iphonesimulator*", _ value: String = "arm64") -> SettingsDictionary {
        merging(["EXCLUDED_ARCHS[sdk=\(sdk)]": SettingValue(stringLiteral: value)])
    }
    
    func setSwiftActiveComplationConditions(_ value: String) -> SettingsDictionary {
        merging(["SWIFT_ACTIVE_COMPILATION_CONDITIONS": SettingValue(stringLiteral: value)])
    }
    
    func setAlwaysSearchUserPath(_ value: String = "NO") -> SettingsDictionary {
        merging(["ALWAYS_SEARCH_USER_PATHS": SettingValue(stringLiteral: value)])
    }
    
    func setStripDebugSymbolsDuringCopy(_ value: String = "NO") -> SettingsDictionary {
        merging(["COPY_PHASE_STRIP": SettingValue(stringLiteral: value)])
    }
    
    func setDynamicLibraryInstallNameBase(_ value: String = "@rpath") -> SettingsDictionary {
        merging(["DYLIB_INSTALL_NAME_BASE": SettingValue(stringLiteral: value)])
    }
    
    func setSkipInstall(_ value: Bool = false) -> SettingsDictionary {
        merging(["SKIP_INSTALL": SettingValue(stringLiteral: value ? "YES" : "NO")])
    }
    
    func setCodeSignAutomatic() -> SettingsDictionary {
        .baseSettings.automaticCodeSigning(devTeam: SigningEnvironment.developmentTeamID)
    }
}
