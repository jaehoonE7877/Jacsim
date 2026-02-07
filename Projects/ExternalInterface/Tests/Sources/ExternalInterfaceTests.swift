import Testing
import ExternalInterface

@Test("AppPreferencesPort inMemory는 값을 저장하고 조회한다")
func appPreferencesPortInMemoryStoresValues() {
    let port = AppPreferencesPort.inMemory()

    #expect(port.isOnboardingCompleted() == false)
    port.setOnboardingCompleted(true)
    #expect(port.isOnboardingCompleted() == true)

    #expect(port.getThemeModeRaw() == nil)
    port.setThemeModeRaw("dark")
    #expect(port.getThemeModeRaw() == "dark")

    #expect(port.getRedesignScreenEnabled("home") == nil)
    port.setRedesignScreenEnabled("home", false)
    #expect(port.getRedesignScreenEnabled("home") == false)
    port.removeRedesignScreenOverride("home")
    #expect(port.getRedesignScreenEnabled("home") == nil)

    #expect(port.getRedesignSectionEnabled("taskFormPhoto") == nil)
    port.setRedesignSectionEnabled("taskFormPhoto", true)
    #expect(port.getRedesignSectionEnabled("taskFormPhoto") == true)
    port.removeRedesignSectionOverride("taskFormPhoto")
    #expect(port.getRedesignSectionEnabled("taskFormPhoto") == nil)
}

@Test("AppPreferencesPort noop은 저장하지 않는다")
func appPreferencesPortNoopDoesNotStoreValues() {
    let port = AppPreferencesPort.noop

    port.setOnboardingCompleted(true)
    #expect(port.isOnboardingCompleted() == false)

    port.setThemeModeRaw("light")
    #expect(port.getThemeModeRaw() == nil)
}
