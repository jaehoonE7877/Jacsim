import ComposableArchitecture
import ExternalInterface

private enum NotificationSchedulerKey: DependencyKey {
    static let liveValue: NotificationSchedulerPort = DependencyAssembly.notificationScheduler
    
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
