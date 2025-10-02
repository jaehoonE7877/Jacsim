//
//  Config.swift
//  JacsimManifests
//
//  Created by Seo Jae Hoon on 3/27/24.
//

import ProjectDescription

let config = Config.init(
    project: TuistProject.tuist(
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
