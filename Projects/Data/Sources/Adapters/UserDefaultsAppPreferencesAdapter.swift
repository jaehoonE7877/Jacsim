import Foundation
import ExternalInterface

public final class UserDefaultsAppPreferencesAdapter: @unchecked Sendable {
    private enum Keys {
        static let onboarding = "onboarding"
        static let theme = "appearance_theme"
    }

    private let userDefaults: UserDefaults

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    public func makePort() -> AppPreferencesPort {
        let adapter = self

        return AppPreferencesPort(
            isOnboardingCompleted: {
                adapter.userDefaults.bool(forKey: Keys.onboarding)
            },
            setOnboardingCompleted: { completed in
                adapter.userDefaults.set(completed, forKey: Keys.onboarding)
            },
            getThemeModeRaw: {
                adapter.userDefaults.string(forKey: Keys.theme)
            },
            setThemeModeRaw: { raw in
                adapter.userDefaults.set(raw, forKey: Keys.theme)
            }
        )
    }
}
