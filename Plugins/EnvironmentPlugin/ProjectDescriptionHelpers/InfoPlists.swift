//
//  InfoPlists.swift
//  EnvironmentPlugin
//
//  Created by Seo Jae Hoon on 2023/11/10.
//

import ProjectDescription

public extension Project {
    static let appInfoPlist: [String: Plist.Value] = [
        "CFBundleShortVersionString": "1.0.0",
        "CFBundleDevelopmentRegion": "ko",
        "CFBundleVersion": "1",
        "CFBundleIdentifier": "com.jaehoon.jaksim",
        "CFBundleDisplayName": "작심",
        "UILaunchStoryboardName": "LaunchScreen",
        "UIApplicationSceneManifest": [
            "UIApplicationSupportsMultipleScenes": false,
            "UISceneConfigurations": [
                "UIWindowSceneSessionRoleApplication": [
                    [
                        "UISceneConfigurationName": "Default Configuration",
                        "UISceneDelegateClassName": "$(PRODUCT_MODULE_NAME).SceneDelegate"
                    ],
                ]
            ]
        ],
        "UIAppFonts": [
//            "Item 0": "WantedSans-Bold.ttf",
//            "Item 1": "WantedSans-SemiBold.ttf",
//            "Item 2": "WantedSans-Medium.ttf",
//            "Item 3": "WantedSans-Regular.ttf",
        ],
        "UIBackgroundModes": ["remote-notification"]
    ]
    
    static let demoInfoPlist: [String: Plist.Value] = [
        "CFBundleShortVersionString": "1.0.0",
        "CFBundleDevelopmentRegion": "ko",
        "CFBundleVersion": "1",
        "CFBundleIdentifier": "com.jaehoon.jaksim",
        "CFBundleDisplayName": "작심",
        "UILaunchStoryboardName": "LaunchScreen",
        "UIApplicationSceneManifest": [
            "UIApplicationSupportsMultipleScenes": false,
            "UISceneConfigurations": [
                "UIWindowSceneSessionRoleApplication": [
                    [
                        "UISceneConfigurationName": "Default Configuration",
                        "UISceneDelegateClassName": "$(PRODUCT_MODULE_NAME).SceneDelegate"
                    ],
                ]
            ]
        ],
        "UIAppFonts": [
//            "Item 0": "WantedSans-Bold.ttf",
//            "Item 1": "WantedSans-SemiBold.ttf",
//            "Item 2": "WantedSans-Medium.ttf",
//            "Item 3": "WantedSans-Regular.ttf",
        ],
    ]
}
