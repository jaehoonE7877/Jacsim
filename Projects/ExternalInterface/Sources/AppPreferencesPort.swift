import Foundation

public struct AppPreferencesPort: Sendable {
    public var isOnboardingCompleted: @Sendable () -> Bool
    public var setOnboardingCompleted: @Sendable (Bool) -> Void

    public var getThemeModeRaw: @Sendable () -> String?
    public var setThemeModeRaw: @Sendable (String) -> Void

    public var getRedesignScreenEnabled: @Sendable (String) -> Bool?
    public var setRedesignScreenEnabled: @Sendable (String, Bool) -> Void
    public var removeRedesignScreenOverride: @Sendable (String) -> Void

    public var getRedesignSectionEnabled: @Sendable (String) -> Bool?
    public var setRedesignSectionEnabled: @Sendable (String, Bool) -> Void
    public var removeRedesignSectionOverride: @Sendable (String) -> Void

    public init(
        isOnboardingCompleted: @escaping @Sendable () -> Bool,
        setOnboardingCompleted: @escaping @Sendable (Bool) -> Void,
        getThemeModeRaw: @escaping @Sendable () -> String?,
        setThemeModeRaw: @escaping @Sendable (String) -> Void,
        getRedesignScreenEnabled: @escaping @Sendable (String) -> Bool?,
        setRedesignScreenEnabled: @escaping @Sendable (String, Bool) -> Void,
        removeRedesignScreenOverride: @escaping @Sendable (String) -> Void,
        getRedesignSectionEnabled: @escaping @Sendable (String) -> Bool?,
        setRedesignSectionEnabled: @escaping @Sendable (String, Bool) -> Void,
        removeRedesignSectionOverride: @escaping @Sendable (String) -> Void
    ) {
        self.isOnboardingCompleted = isOnboardingCompleted
        self.setOnboardingCompleted = setOnboardingCompleted
        self.getThemeModeRaw = getThemeModeRaw
        self.setThemeModeRaw = setThemeModeRaw
        self.getRedesignScreenEnabled = getRedesignScreenEnabled
        self.setRedesignScreenEnabled = setRedesignScreenEnabled
        self.removeRedesignScreenOverride = removeRedesignScreenOverride
        self.getRedesignSectionEnabled = getRedesignSectionEnabled
        self.setRedesignSectionEnabled = setRedesignSectionEnabled
        self.removeRedesignSectionOverride = removeRedesignSectionOverride
    }
}

public extension AppPreferencesPort {
    static let noop = AppPreferencesPort(
        isOnboardingCompleted: { false },
        setOnboardingCompleted: { _ in },
        getThemeModeRaw: { nil },
        setThemeModeRaw: { _ in },
        getRedesignScreenEnabled: { _ in nil },
        setRedesignScreenEnabled: { _, _ in },
        removeRedesignScreenOverride: { _ in },
        getRedesignSectionEnabled: { _ in nil },
        setRedesignSectionEnabled: { _, _ in },
        removeRedesignSectionOverride: { _ in }
    )

    static func inMemory() -> AppPreferencesPort {
        final class Storage: @unchecked Sendable {
            var onboardingCompleted = false
            var themeModeRaw: String?
            var screenFlags: [String: Bool] = [:]
            var sectionFlags: [String: Bool] = [:]
        }

        let storage = Storage()

        return AppPreferencesPort(
            isOnboardingCompleted: { storage.onboardingCompleted },
            setOnboardingCompleted: { storage.onboardingCompleted = $0 },
            getThemeModeRaw: { storage.themeModeRaw },
            setThemeModeRaw: { storage.themeModeRaw = $0 },
            getRedesignScreenEnabled: { storage.screenFlags[$0] },
            setRedesignScreenEnabled: { storage.screenFlags[$0] = $1 },
            removeRedesignScreenOverride: { storage.screenFlags.removeValue(forKey: $0) },
            getRedesignSectionEnabled: { storage.sectionFlags[$0] },
            setRedesignSectionEnabled: { storage.sectionFlags[$0] = $1 },
            removeRedesignSectionOverride: { storage.sectionFlags.removeValue(forKey: $0) }
        )
    }
}
