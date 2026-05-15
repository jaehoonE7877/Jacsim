import Foundation
import ExternalInterface

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

@MainActor
public enum PresentationRedesignFlags {
    public static var appPreferences: AppPreferencesPort = JacsimDependencies.live.appPreferences

    public static func isEnabled(_ screen: PresentationScreenKey) -> Bool {
        if ProcessInfo.processInfo.arguments.contains("--disable-redesign") ||
            ProcessInfo.processInfo.arguments.contains("--disable-redesign-all") {
            return false
        }

        if let value = appPreferences.getRedesignScreenEnabled(screen.rawValue) {
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

        if let value = appPreferences.getRedesignSectionEnabled(section.rawValue) {
            return value
        }

        return true
    }

    public static func set(_ enabled: Bool, for screen: PresentationScreenKey) {
        appPreferences.setRedesignScreenEnabled(screen.rawValue, enabled)
    }

    public static func setSection(_ enabled: Bool, for section: PresentationSectionKey) {
        appPreferences.setRedesignSectionEnabled(section.rawValue, enabled)
    }

    public static func resetAll() {
        for screen in PresentationScreenKey.allCases {
            appPreferences.removeRedesignScreenOverride(screen.rawValue)
        }

        for section in PresentationSectionKey.allCases {
            appPreferences.removeRedesignSectionOverride(section.rawValue)
        }
    }
}
