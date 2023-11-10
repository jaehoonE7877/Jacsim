//
//  InfoPlists.swift
//  EnvironmentPlugin
//
//  Created by Seo Jae Hoon on 2023/11/10.
//

import ProjectDescription

public extension Project {
    static let appInfoPlist: [String: InfoPlist.Value] = [
        "CFBundleShortVersionString": "1.0.0",
        "CFBundleDevelopmentRegion": "ko",
        "CFBundleVersion": "1",
        "CFBundleIdentifier": "com.sopt-stamp-iOS.release",
        "CFBundleDisplayName": "작심",
        "UILaunchStoryboardName": "LaunchScreen",
    
    ]
}
