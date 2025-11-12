//
//  Config.swift
//  JacsimManifests
//
//  Created by Seo Jae Hoon on 3/27/24.
//

import ProjectDescription

let config = Config.init(
    project: TuistProject.tuist(
        // Xcode 26.x 고정(최소 26, 27+ 포함 필요 시 from("26.0")로 전환)
        compatibleXcodeVersions: CompatibleXcodeVersions.upToNextMajor("26.0"),
        swiftVersion: Version(string: "6.0"),
        plugins: [
            .local(path: "../Plugins/DependencyPlugin"),
            .local(path: "../Plugins/EnvironmentPlugin"),
            .local(path: "../Plugins/ConfigurationPlugin")
        ],
        generationOptions: Tuist.GenerationOptions.options(),
        installOptions: Tuist.InstallOptions.options()
    )
)
