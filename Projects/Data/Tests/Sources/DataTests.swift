import Testing
import Foundation
@testable import Adapters

@Test("UserDefaultsAppPreferencesAdapter는 온보딩/테마 값을 읽고 쓴다")
func userDefaultsAdapterStoresOnboardingAndTheme() {
    let suiteName = "DataTests.AppPreferences.\(UUID().uuidString)"
    let userDefaults = UserDefaults(suiteName: suiteName)!
    defer {
        userDefaults.removePersistentDomain(forName: suiteName)
    }

    let adapter = UserDefaultsAppPreferencesAdapter(userDefaults: userDefaults)
    let port = adapter.makePort()

    #expect(port.isOnboardingCompleted() == false)
    port.setOnboardingCompleted(true)
    #expect(port.isOnboardingCompleted() == true)

    #expect(port.getThemeModeRaw() == nil)
    port.setThemeModeRaw("dark")
    #expect(port.getThemeModeRaw() == "dark")
}
