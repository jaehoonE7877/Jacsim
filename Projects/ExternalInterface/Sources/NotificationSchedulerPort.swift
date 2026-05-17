import Foundation
import struct Domain.SocialNotificationContext
import struct Domain.SocialNotificationKey
import enum Domain.SocialNotificationTrigger
import struct Domain.TaskID

public struct NotificationSchedulerPort: Sendable {
    public var scheduleDailyReminder: @Sendable (TaskID, String, DateComponents) async throws -> Void
    public var cancelReminder: @Sendable (TaskID) async -> Void
    public var cancelAllReminders: @Sendable () async -> Void
    public var requestAuthorization: @Sendable () async throws -> Bool
    public var scheduleSocial: @Sendable (SocialNotificationTrigger, SocialNotificationContext) async throws -> Void
    public var cancelSocial: @Sendable (SocialNotificationKey) async throws -> Void

    public init(
        scheduleDailyReminder: @escaping @Sendable (TaskID, String, DateComponents) async throws -> Void,
        cancelReminder: @escaping @Sendable (TaskID) async -> Void,
        cancelAllReminders: @escaping @Sendable () async -> Void,
        requestAuthorization: @escaping @Sendable () async throws -> Bool,
        scheduleSocial: @escaping @Sendable (SocialNotificationTrigger, SocialNotificationContext) async throws -> Void = { _, _ in },
        cancelSocial: @escaping @Sendable (SocialNotificationKey) async throws -> Void = { _ in }
    ) {
        self.scheduleDailyReminder = scheduleDailyReminder
        self.cancelReminder = cancelReminder
        self.cancelAllReminders = cancelAllReminders
        self.requestAuthorization = requestAuthorization
        self.scheduleSocial = scheduleSocial
        self.cancelSocial = cancelSocial
    }
}
