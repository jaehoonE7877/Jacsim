import Foundation
import UserNotifications
import Domain
import Ports

public actor LocalNotificationSchedulerAdapter {
    private var notificationCenter: UNUserNotificationCenter?

    public init(notificationCenter: UNUserNotificationCenter? = nil) {
        self.notificationCenter = notificationCenter
    }

    public nonisolated func makePort() -> NotificationSchedulerPort {
        let adapter = self

        return NotificationSchedulerPort(
            scheduleReminder: { try await adapter.scheduleReminder(request: $0) },
            cancelReminder: { await adapter.cancelReminder(taskId: $0) },
            cancelAllReminders: { await adapter.cancelAllReminders() },
            requestAuthorization: { try await adapter.requestAuthorization() }
        )
    }
    
    public func scheduleReminder(request: NotificationReminderRequest) async throws {
        let notificationCenter = resolvedNotificationCenter()
        let identifier = "jacsim-\(request.taskID.rawValue.uuidString)"
        
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        
        let content = UNMutableNotificationContent()
        content.title = request.title
        content.body = request.body
        content.sound = .default
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: request.dateComponents,
            repeats: request.repeats
        )
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        try await addNotificationRequest(request, notificationCenter: notificationCenter)
    }
    
    public func cancelReminder(taskId: TaskID) async {
        let notificationCenter = resolvedNotificationCenter()
        let identifier = "jacsim-\(taskId.rawValue.uuidString)"
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [identifier])
    }
    
    public func cancelAllReminders() async {
        let notificationCenter = resolvedNotificationCenter()
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
    }
    
    public func requestAuthorization() async throws -> Bool {
        let notificationCenter = resolvedNotificationCenter()
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        return try await requestAuthorization(options: options, notificationCenter: notificationCenter)
    }

    private func resolvedNotificationCenter() -> UNUserNotificationCenter {
        if let notificationCenter {
            return notificationCenter
        }

        let currentNotificationCenter = UNUserNotificationCenter.current()
        notificationCenter = currentNotificationCenter
        return currentNotificationCenter
    }

    private func addNotificationRequest(
        _ request: UNNotificationRequest,
        notificationCenter: UNUserNotificationCenter
    ) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            notificationCenter.add(request) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }

    private func requestAuthorization(
        options: UNAuthorizationOptions,
        notificationCenter: UNUserNotificationCenter
    ) async throws -> Bool {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Bool, Error>) in
            notificationCenter.requestAuthorization(options: options) { granted, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: granted)
                }
            }
        }
    }
}
