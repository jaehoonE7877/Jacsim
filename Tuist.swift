//
//  Config.swift
//  JacsimManifests
//
//  Created by Seo Jae Hoon on 3/27/24.
//

import Foundation
import ProjectDescription

let defaultFullHandle = "jaehoonE7877/jacsim"
let envFullHandle = ProcessInfo.processInfo.environment["TUIST_FULL_HANDLE"]?
    .trimmingCharacters(in: .whitespacesAndNewlines)
let fullHandle = (envFullHandle?.isEmpty == false) ? envFullHandle : defaultFullHandle

let xcodeCacheFlag = ProcessInfo.processInfo.environment["TUIST_XCODE_CACHE"]?
    .trimmingCharacters(in: .whitespacesAndNewlines)
    .lowercased()
let enableXcodeCache = ["1", "true", "yes"].contains(xcodeCacheFlag ?? "")

let cacheProfiles = CacheProfiles.profiles(
    [
        "ci": .profile(.allPossible),
        "disabled": .profile(.none),
    ],
    default: .onlyExternal
)

let config = Config(
    fullHandle: fullHandle,
    project: .tuist(
        // Xcode 26.x 고정(최소 26, 27+ 포함 필요 시 from("26.0")로 전환)
        compatibleXcodeVersions: CompatibleXcodeVersions.upToNextMajor("26.0"),
        swiftVersion: Version(string: "6.0"),
        plugins: [
            .local(path: "../Plugins/DependencyPlugin"),
            .local(path: "../Plugins/EnvironmentPlugin"),
            .local(path: "../Plugins/ConfigurationPlugin")
        ],
        generationOptions: .options(
            // On CI environments without Tuist auth, skip server interactions
            // instead of failing the whole command.
            optionalAuthentication: true,
            buildInsightsDisabled: false,
            testInsightsDisabled: false,
            disableSandbox: true,
            includeGenerateScheme: true,
            // Default off to avoid CAS socket failures when cache daemon is absent.
            // Enable explicitly with TUIST_XCODE_CACHE=1.
            enableCaching: enableXcodeCache
        ),
        installOptions: .options(),
        cacheOptions: .options(
            // Keep source targets so builds can safely fall back when remote cache misses.
            keepSourceTargets: true,
            profiles: cacheProfiles
        )
    )
)
