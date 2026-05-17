//
//  InfoPlists.swift
//  EnvironmentPlugin
//
//  Created by Seo Jae Hoon on 2023/11/10.
//

import ProjectDescription

public extension Project {
    static let appInfoPlist: [String: Plist.Value] = [
        "CFBundleURLTypes": [
            [
                "CFBundleURLName": "com.jacsim.deepLink",
                "CFBundleURLSchemes": ["jacsim"]
            ]
        ],
        "CFBundleShortVersionString": "\(Environment.appVersion)",
        "CFBundleDevelopmentRegion": "ko",
        "CFBundleVersion": "$(CURRENT_PROJECT_VERSION)",
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
            "Item 4": "Newsreader_14pt-Regular.ttf",
            "Item 5": "Newsreader_24pt-Medium.ttf",
            "Item 6": "Newsreader_24pt-MediumItalic.ttf",
            "Item 7": "Newsreader_36pt-Medium.ttf",
            "Item 8": "Newsreader_60pt-Bold.ttf",
            "Item 9": "Newsreader_60pt-BoldItalic.ttf",
            "Item 10": "JetBrainsMono-Regular.ttf",
            "Item 11": "JetBrainsMono-Medium.ttf",
        ],
        "UISupportedInterfaceOrientations": [
            "UIInterfaceOrientationPortrait",
            "UIInterfaceOrientationLandscapeLeft",
            "UIInterfaceOrientationLandscapeRight"
        ],
        "NSCameraUsageDescription": "작심 인증 사진을 촬영하기 위해 카메라 접근 권한이 필요합니다.",
        "NSPhotoLibraryUsageDescription": "작심 인증 사진을 선택하기 위해 사진 보관함 접근 권한이 필요합니다.",
        "NSUserNotificationsUsageDescription": "작심 인증 알림과 친구 활동 알림을 보내기 위해 알림 권한이 필요합니다."
    ]
    
    static let demoInfoPlist: [String: Plist.Value] = [
        "CFBundleShortVersionString": "1.0.0",
        "CFBundleDevelopmentRegion": "ko",
        "CFBundleVersion": "$(CURRENT_PROJECT_VERSION)",
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
            "Item 4": "Newsreader_14pt-Regular.ttf",
            "Item 5": "Newsreader_24pt-Medium.ttf",
            "Item 6": "Newsreader_24pt-MediumItalic.ttf",
            "Item 7": "Newsreader_36pt-Medium.ttf",
            "Item 8": "Newsreader_60pt-Bold.ttf",
            "Item 9": "Newsreader_60pt-BoldItalic.ttf",
            "Item 10": "JetBrainsMono-Regular.ttf",
            "Item 11": "JetBrainsMono-Medium.ttf",
        ],
        "UISupportedInterfaceOrientations": [
            "UIInterfaceOrientationPortrait",
            "UIInterfaceOrientationLandscapeLeft",
            "UIInterfaceOrientationLandscapeRight"
        ],
        "NSCameraUsageDescription": "작심 인증 사진을 촬영하기 위해 카메라 접근 권한이 필요합니다.",
        "NSPhotoLibraryUsageDescription": "작심 인증 사진을 선택하기 위해 사진 보관함 접근 권한이 필요합니다.",
        "NSUserNotificationsUsageDescription": "작심 인증 알림과 친구 활동 알림을 보내기 위해 알림 권한이 필요합니다."
    ]
}
