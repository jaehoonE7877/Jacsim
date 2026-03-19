import ComposableArchitecture
import Ports

private enum UserSettingsRepositoryKey: DependencyKey {
    static let liveValue: UserSettingsRepositoryPort = DependencyAssembly.userSettingsRepository

    static let testValue = UserSettingsRepositoryPort(
        isNotificationEnabled: { false },
        getAllReminders: { [] },
        updateNotificationEnabled: { _ in }
    )
}

public extension DependencyValues {
    var userSettingsRepository: UserSettingsRepositoryPort {
        get { self[UserSettingsRepositoryKey.self] }
        set { self[UserSettingsRepositoryKey.self] = newValue }
    }
}
