import Foundation
import struct Domain.TaskID

public struct ReminderInfo: Sendable {
    public let taskId: TaskID
    public let title: String
    public let time: DateComponents
    public let shouldSchedule: Bool

    public init(
        taskId: TaskID,
        title: String,
        time: DateComponents,
        shouldSchedule: Bool = true
    ) {
        self.taskId = taskId
        self.title = title
        self.time = time
        self.shouldSchedule = shouldSchedule
    }
}

public struct UserSettingsRepositoryPort: Sendable {
    public var isNotificationEnabled: @Sendable () async -> Bool
    public var getAllReminders: @Sendable () async -> [ReminderInfo]
    public var updateNotificationEnabled: @Sendable (_ enabled: Bool) async -> Void
    
    public init(
        isNotificationEnabled: @escaping @Sendable () async -> Bool,
        getAllReminders: @escaping @Sendable () async -> [ReminderInfo],
        updateNotificationEnabled: @escaping @Sendable (_ enabled: Bool) async -> Void
    ) {
        self.isNotificationEnabled = isNotificationEnabled
        self.getAllReminders = getAllReminders
        self.updateNotificationEnabled = updateNotificationEnabled
    }
}
