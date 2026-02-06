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

public enum PresentationSectionKey: String, CaseIterable {
    case homeSummary
    case homeHero
    case homeMiniCards
    case allTaskSummary
    case calendarDailyRecords
    case taskDetailOverview
    case taskDetailTodayStatus
    case taskDetailRecordList
    case taskFormPhoto
    case taskFormAlarm
}

public enum PresentationRedesignFlags {
    private static let screenNamespace = "presentation.redesign.screen."
    private static let sectionNamespace = "presentation.redesign.section."

    public static func isEnabled(_ screen: PresentationScreenKey) -> Bool {
        if ProcessInfo.processInfo.arguments.contains("--disable-redesign") ||
            ProcessInfo.processInfo.arguments.contains("--disable-redesign-all") {
            return false
        }

        let key = screenNamespacedKey(for: screen)
        if let value = UserDefaults.standard.object(forKey: key) as? Bool {
            return value
        }

        // Keep redesign enabled by default in development builds.
        return true
    }

    public static func isSectionEnabled(_ section: PresentationSectionKey) -> Bool {
        if ProcessInfo.processInfo.arguments.contains("--disable-redesign") ||
            ProcessInfo.processInfo.arguments.contains("--disable-redesign-all") {
            return false
        }

        let key = sectionNamespacedKey(for: section)
        if let value = UserDefaults.standard.object(forKey: key) as? Bool {
            return value
        }

        return true
    }

    public static func set(_ enabled: Bool, for screen: PresentationScreenKey) {
        UserDefaults.standard.set(enabled, forKey: screenNamespacedKey(for: screen))
    }

    public static func setSection(_ enabled: Bool, for section: PresentationSectionKey) {
        UserDefaults.standard.set(enabled, forKey: sectionNamespacedKey(for: section))
    }

    public static func resetAll() {
        for screen in PresentationScreenKey.allCases {
            UserDefaults.standard.removeObject(forKey: screenNamespacedKey(for: screen))
        }

        for section in PresentationSectionKey.allCases {
            UserDefaults.standard.removeObject(forKey: sectionNamespacedKey(for: section))
        }
    }

    private static func screenNamespacedKey(for screen: PresentationScreenKey) -> String {
        screenNamespace + screen.rawValue
    }

    private static func sectionNamespacedKey(for section: PresentationSectionKey) -> String {
        sectionNamespace + section.rawValue
    }
}
