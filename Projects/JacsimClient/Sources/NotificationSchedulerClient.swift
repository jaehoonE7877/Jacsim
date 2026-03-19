import ComposableArchitecture
import Ports

private enum NotificationSchedulerKey: DependencyKey {
    static let liveValue: NotificationSchedulerPort = DependencyAssembly.notificationScheduler
    
    static let testValue = NotificationSchedulerPort(
        scheduleReminder: { _ in },
        cancelReminder: { _ in },
        cancelAllReminders: { },
        requestAuthorization: { false }
    )
}

public extension DependencyValues {
    var notificationScheduler: NotificationSchedulerPort {
        get { self[NotificationSchedulerKey.self] }
        set { self[NotificationSchedulerKey.self] = newValue }
    }
}
