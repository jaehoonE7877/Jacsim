//
//  AppDelegate.swift
//  Jacsim
//
//  Created by Seo Jae Hoon on 2022/09/10.
//

import UIKit
import UserNotifications

import Firebase
import FirebaseCore
import FirebaseCrashlytics
import FirebaseMessaging
import IQKeyboardManagerSwift
import JacsimClient

class AppDelegate: UIResponder, UIApplicationDelegate{
    private let notificationDelegate = AppNotificationDelegate()

    private enum FCMTokenError: LocalizedError {
        case tokenNotFound

        var errorDescription: String? {
            switch self {
            case .tokenNotFound:
                return "FCM token is missing in Firebase callback."
            }
        }
    }


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if OnboardingCaptureScreen.current != nil {
            return true
        }
        
        FirebaseApp.configure()
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
        Messaging.messaging().delegate = notificationDelegate

        UNUserNotificationCenter.current().delegate = notificationDelegate
        Task { @MainActor in
            let granted = await requestNotificationAuthorization()
            guard granted else {
                print("Notification authorization denied")
                return
            }
            UIApplication.shared.registerForRemoteNotifications()
        }

        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
       
        
        return true
    }

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        NotificationCenter.default.post(
            name: .jacsimDeepLinkReceived,
            object: nil,
            userInfo: ["url": url]
        )
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

private extension AppDelegate {
    func requestNotificationAuthorization() async -> Bool {
        do {
            return try await DependencyAssembly.notificationScheduler.requestAuthorization()
        } catch {
            print("Notification authorization error: \(error)")
            return false
        }
    }

    static func fetchFCMToken() async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            Messaging.messaging().token { token, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let token else {
                    continuation.resume(throwing: FCMTokenError.tokenNotFound)
                    return
                }
                continuation.resume(returning: token)
            }
        }
    }
}

extension AppDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken

        Task {
            do {
                let token = try await Self.fetchFCMToken()
                print("FCM registration token: \(token)")
            } catch {
                print("Error fetching FCM registration token: \(error)")
            }
        }
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error)")
    }
}

private final class AppNotificationDelegate: NSObject, UNUserNotificationCenterDelegate, MessagingDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.badge, .sound, .banner, .list])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let identifier = response.notification.request.identifier
        if identifier.hasPrefix("jacsim-") {
            let idString = identifier.replacingOccurrences(of: "jacsim-", with: "")
            NotificationCenter.default.post(
                name: .jacsimLocalNotificationTapped,
                object: nil,
                userInfo: ["id": idString]
            )
        }
        completionHandler()
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
    }
}
