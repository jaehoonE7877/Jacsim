import Testing
import Foundation
@testable import Data

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

@Test("UserDefaultsAppPreferencesAdapter는 리디자인 플래그 override를 저장하고 제거한다")
func userDefaultsAdapterStoresAndRemovesRedesignOverrides() {
    let suiteName = "DataTests.Redesign.\(UUID().uuidString)"
    let userDefaults = UserDefaults(suiteName: suiteName)!
    defer {
        userDefaults.removePersistentDomain(forName: suiteName)
    }

    let adapter = UserDefaultsAppPreferencesAdapter(userDefaults: userDefaults)
    let port = adapter.makePort()

    #expect(port.getRedesignScreenEnabled("calendar") == nil)
    port.setRedesignScreenEnabled("calendar", false)
    #expect(port.getRedesignScreenEnabled("calendar") == false)
    port.removeRedesignScreenOverride("calendar")
    #expect(port.getRedesignScreenEnabled("calendar") == nil)

    #expect(port.getRedesignSectionEnabled("taskFormAlarm") == nil)
    port.setRedesignSectionEnabled("taskFormAlarm", true)
    #expect(port.getRedesignSectionEnabled("taskFormAlarm") == true)
    port.removeRedesignSectionOverride("taskFormAlarm")
    #expect(port.getRedesignSectionEnabled("taskFormAlarm") == nil)
}
