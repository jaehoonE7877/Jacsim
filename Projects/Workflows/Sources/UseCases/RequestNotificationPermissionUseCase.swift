import Ports

public struct RequestNotificationPermissionUseCase: Sendable {
    public var requestAuthorization: @Sendable () async throws -> Bool

    public init(requestAuthorization: @escaping @Sendable () async throws -> Bool) {
        self.requestAuthorization = requestAuthorization
    }
}

extension RequestNotificationPermissionUseCase {
    public static func live(notificationScheduler: NotificationSchedulerPort) -> Self {
        Self(
            requestAuthorization: {
                try await notificationScheduler.requestAuthorization()
            }
        )
    }
}
