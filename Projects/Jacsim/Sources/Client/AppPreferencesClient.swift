import ComposableArchitecture
import ExternalInterface
import Data

private enum AppPreferencesKey: DependencyKey {
    static let liveValue: AppPreferencesPort = {
        let adapter = UserDefaultsAppPreferencesAdapter()
        return adapter.makePort()
    }()

    static let testValue: AppPreferencesPort = .inMemory()
}

extension DependencyValues {
    var appPreferences: AppPreferencesPort {
        get { self[AppPreferencesKey.self] }
        set { self[AppPreferencesKey.self] = newValue }
    }
}
