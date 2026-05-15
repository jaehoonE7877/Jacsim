import SwiftUI

@main
struct JacsimApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var model = AppModel()

    var body: some Scene {
        WindowGroup {
            AppView(model: model)
                .onOpenURL { url in
                    NotificationCenter.default.post(
                        name: .jacsimDeepLinkReceived,
                        object: nil,
                        userInfo: ["url": url]
                    )
                }
        }
    }
}
