import ComposableArchitecture
import ExternalInterface

private enum AppPreferencesKey: DependencyKey {
    static let liveValue: AppPreferencesPort = DependencyAssembly.appPreferences

    static let testValue: AppPreferencesPort = .inMemory()
}

extension DependencyValues {
    var appPreferences: AppPreferencesPort {
        get { self[AppPreferencesKey.self] }
        set { self[AppPreferencesKey.self] = newValue }
    }
}
