import Foundation
import struct Domain.TaskID

public struct NotificationReminderRequest: Sendable, Equatable {
    public var taskID: TaskID
    public var title: String
    public var body: String
    public var dateComponents: DateComponents
    public var repeats: Bool

    public init(
        taskID: TaskID,
        title: String,
        body: String,
        dateComponents: DateComponents,
        repeats: Bool
    ) {
        self.taskID = taskID
        self.title = title
        self.body = body
        self.dateComponents = dateComponents
        self.repeats = repeats
    }
}

public struct NotificationSchedulerPort: Sendable {
    public var scheduleReminder: @Sendable (NotificationReminderRequest) async throws -> Void
    public var cancelReminder: @Sendable (TaskID) async -> Void
    public var cancelAllReminders: @Sendable () async -> Void
    public var requestAuthorization: @Sendable () async throws -> Bool

    public init(
        scheduleReminder: @escaping @Sendable (NotificationReminderRequest) async throws -> Void,
        cancelReminder: @escaping @Sendable (TaskID) async -> Void,
        cancelAllReminders: @escaping @Sendable () async -> Void,
        requestAuthorization: @escaping @Sendable () async throws -> Bool
    ) {
        self.scheduleReminder = scheduleReminder
        self.cancelReminder = cancelReminder
        self.cancelAllReminders = cancelAllReminders
        self.requestAuthorization = requestAuthorization
    }
}
