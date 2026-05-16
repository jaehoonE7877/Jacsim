import Foundation
import struct Domain.TaskID

public struct NotificationSchedulerPort: Sendable {
    public var scheduleDailyReminder: @Sendable (TaskID, String, DateComponents) async throws -> Void
    public var cancelReminder: @Sendable (TaskID) async -> Void
    public var cancelAllReminders: @Sendable () async -> Void
    public var requestAuthorization: @Sendable () async throws -> Bool

    public init(
        scheduleDailyReminder: @escaping @Sendable (TaskID, String, DateComponents) async throws -> Void,
        cancelReminder: @escaping @Sendable (TaskID) async -> Void,
        cancelAllReminders: @escaping @Sendable () async -> Void,
        requestAuthorization: @escaping @Sendable () async throws -> Bool
    ) {
        self.scheduleDailyReminder = scheduleDailyReminder
        self.cancelReminder = cancelReminder
        self.cancelAllReminders = cancelAllReminders
        self.requestAuthorization = requestAuthorization
    }
}
