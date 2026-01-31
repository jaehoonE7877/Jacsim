// swift-tools-version: 5.9
import PackageDescription

#if TUIST
    import ProjectDescription
    import ProjectDescriptionHelpers
    import ConfigurationPlugin

    let packageSettings = PackageSettings(
        productTypes: [
            "Promises": .framework,
            "FBLPromises": .framework, // default is .staticFramework
        ],
        baseSettings: .settings(configurations: XCConfig.framework),
        projectOptions: [
            "Promises": .options(disableBundleAccessors: true, disableSynthesizedResourceAccessors: true),
            "FBLPromises": .options(disableBundleAccessors: true, disableSynthesizedResourceAccessors: true)
        ]
    )
#endif


let package = Package(
    name: "PackageName",
    dependencies: [
        //MARK: - Firebase
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git",
                 from: "10.23.0"),
        .package(url: "https://github.com/google/promises.git", exact: "2.4.0"),
        
        //MARK: - UI
        .package(url: "https://github.com/hackiftekhar/IQKeyboardManager.git", from: "6.5.0"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.9.1"),
        .package(url: "https://github.com/vtourraine/AcknowList", from: "3.0.1"),
        .package(url: "https://github.com/TimOliver/TOCropViewController.git", from: "2.6.1"),
        
        //MARK: - DI
        .package(url: "https://github.com/Swinject/Swinject.git", from: "2.8.4"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.23.1"),
    ]
)
