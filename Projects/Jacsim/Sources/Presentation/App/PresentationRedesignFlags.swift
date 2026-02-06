import Foundation

public enum PresentationScreenKey: String, CaseIterable {
    case home
    case allTask
    case calendar
    case newTask
    case setting
    case taskDetail
    case taskEdit
    case taskUpdate
    case walkthrough
}

public enum PresentationRedesignFlags {
    private static let namespace = "presentation.redesign."

    public static func isEnabled(_ screen: PresentationScreenKey) -> Bool {
        if ProcessInfo.processInfo.arguments.contains("--disable-redesign") {
            return false
        }

        let key = namespacedKey(for: screen)
        if let value = UserDefaults.standard.object(forKey: key) as? Bool {
            return value
        }

        // Keep redesign enabled by default in development builds.
        return true
    }

    public static func set(_ enabled: Bool, for screen: PresentationScreenKey) {
        UserDefaults.standard.set(enabled, forKey: namespacedKey(for: screen))
    }

    public static func resetAll() {
        for screen in PresentationScreenKey.allCases {
            UserDefaults.standard.removeObject(forKey: namespacedKey(for: screen))
        }
    }

    private static func namespacedKey(for screen: PresentationScreenKey) -> String {
        namespace + screen.rawValue
    }
}
