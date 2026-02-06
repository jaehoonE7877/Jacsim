import ComposableArchitecture
import ExternalInterface
import Data

private enum NotificationSchedulerKey: DependencyKey {
    static let liveValue: NotificationSchedulerPort = {
        let adapter = LocalNotificationSchedulerAdapter()
        return NotificationSchedulerPort(
            scheduleDailyReminder: { try await adapter.scheduleReminder(taskId: $0, title: $1, time: $2) },
            cancelReminder: { await adapter.cancelReminder(taskId: $0) },
            cancelAllReminders: { await adapter.cancelAllReminders() },
            requestAuthorization: { try await adapter.requestAuthorization() }
        )
    }()
    
    static let testValue = NotificationSchedulerPort(
        scheduleDailyReminder: { _, _, _ in },
        cancelReminder: { _ in },
        cancelAllReminders: { },
        requestAuthorization: { false }
    )
}

extension DependencyValues {
    var notificationScheduler: NotificationSchedulerPort {
        get { self[NotificationSchedulerKey.self] }
        set { self[NotificationSchedulerKey.self] = newValue }
    }
}
