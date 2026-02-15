import Ports

public struct AppPreferencesUseCase: Sendable {
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

extension AppPreferencesUseCase {
    public static func live(appPreferences: AppPreferencesPort) -> Self {
        Self(
            isOnboardingCompleted: {
                appPreferences.isOnboardingCompleted()
            },
            setOnboardingCompleted: { completed in
                appPreferences.setOnboardingCompleted(completed)
            },
            getThemeModeRaw: {
                appPreferences.getThemeModeRaw()
            },
            setThemeModeRaw: { raw in
                appPreferences.setThemeModeRaw(raw)
            }
        )
    }
}
