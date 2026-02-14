import Foundation

public struct AppPreferencesPort: Sendable {
    public var isOnboardingCompleted: @Sendable () -> Bool
    public var setOnboardingCompleted: @Sendable (Bool) -> Void

    public var getThemeModeRaw: @Sendable () -> String?
    public var setThemeModeRaw: @Sendable (String) -> Void

    public init(
        isOnboardingCompleted: @escaping @Sendable () -> Bool,
        setOnboardingCompleted: @escaping @Sendable (Bool) -> Void,
        getThemeModeRaw: @escaping @Sendable () -> String?,
        setThemeModeRaw: @escaping @Sendable (String) -> Void
    ) {
        self.isOnboardingCompleted = isOnboardingCompleted
        self.setOnboardingCompleted = setOnboardingCompleted
        self.getThemeModeRaw = getThemeModeRaw
        self.setThemeModeRaw = setThemeModeRaw
    }
}

public extension AppPreferencesPort {
    static let noop = AppPreferencesPort(
        isOnboardingCompleted: { false },
        setOnboardingCompleted: { _ in },
        getThemeModeRaw: { nil },
        setThemeModeRaw: { _ in }
    )

    static func inMemory() -> AppPreferencesPort {
        final class Storage: @unchecked Sendable {
            var onboardingCompleted = false
            var themeModeRaw: String?
        }

        let storage = Storage()

        return AppPreferencesPort(
            isOnboardingCompleted: { storage.onboardingCompleted },
            setOnboardingCompleted: { storage.onboardingCompleted = $0 },
            getThemeModeRaw: { storage.themeModeRaw },
            setThemeModeRaw: { storage.themeModeRaw = $0 }
        )
    }
}
