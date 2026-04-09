import Testing
import Ports

@Test("AppPreferencesPort inMemory는 값을 저장하고 조회한다")
func appPreferencesPortInMemoryStoresValues() {
    let port = AppPreferencesPort.inMemory()

    #expect(port.isOnboardingCompleted() == false)
    port.setOnboardingCompleted(true)
    #expect(port.isOnboardingCompleted() == true)

    #expect(port.getThemeModeRaw() == nil)
    port.setThemeModeRaw("dark")
    #expect(port.getThemeModeRaw() == "dark")
}

@Test("AppPreferencesPort noop은 저장하지 않는다")
func appPreferencesPortNoopDoesNotStoreValues() {
    let port = AppPreferencesPort.noop

    port.setOnboardingCompleted(true)
    #expect(port.isOnboardingCompleted() == false)

    port.setThemeModeRaw("light")
    #expect(port.getThemeModeRaw() == nil)
}
