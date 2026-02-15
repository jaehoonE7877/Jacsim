import Ports

public struct NotificationSettingQueryUseCase: Sendable {
    public var isNotificationEnabled: @Sendable () async -> Bool

    public init(isNotificationEnabled: @escaping @Sendable () async -> Bool) {
        self.isNotificationEnabled = isNotificationEnabled
    }
}

extension NotificationSettingQueryUseCase {
    public static func live(userSettingsRepository: UserSettingsRepositoryPort) -> Self {
        Self(
            isNotificationEnabled: {
                await userSettingsRepository.isNotificationEnabled()
            }
        )
    }
}
