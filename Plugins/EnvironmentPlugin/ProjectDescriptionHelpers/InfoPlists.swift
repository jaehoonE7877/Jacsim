//
//  InfoPlists.swift
//  EnvironmentPlugin
//
//  Created by Seo Jae Hoon on 2023/11/10.
//

import ProjectDescription

public extension Project {
    static let appInfoPlist: [String: Plist.Value] = [
        "CFBundleShortVersionString": "\(Environment.appVersion)",
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
            "Item 0": "Pretendard-Bold.ttf",
            "Item 1": "Pretendard-SemiBold.ttf",
            "Item 2": "Pretendard-Medium.ttf",
            "Item 3": "Pretendard-Regular.ttf",
        ],
        "UIBackgroundModes": ["remote-notification"],
        "NSCameraUsageDescription": "작심 하기, 작심 인증을 위해 카메라 접근 권한이 필요합니다.",
        "NSPhotoLibraryUsageDescription": "작심 하기, 작심 인증을 위해 앨범 접근 권한이 필요합니다."
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
            "Item 0": "Pretendard-Bold.ttf",
            "Item 1": "Pretendard-SemiBold.ttf",
            "Item 2": "Pretendard-Medium.ttf",
            "Item 3": "Pretendard-Regular.ttf",
        ],
        "NSCameraUsageDescription": "작심 인증을 위해 카메라 접근 권한이 필요합니다.",
        "NSPhotoLibraryUsageDescription": "작심 하기, 작심 인증을 위해 앨범 접근 권한이 필요합니다."
    ]
}
