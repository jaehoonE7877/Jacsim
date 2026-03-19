import Foundation
import UserNotifications
import Domain
import Ports

public actor LocalNotificationSchedulerAdapter {
    private let notificationCenter: UNUserNotificationCenter
    
    public init(notificationCenter: UNUserNotificationCenter = .current()) {
        self.notificationCenter = notificationCenter
    }
    
    public func scheduleReminder(request: NotificationReminderRequest) async throws {
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
        
        try await addNotificationRequest(request)
    }
    
    public func cancelReminder(taskId: TaskID) async {
        let identifier = "jacsim-\(taskId.rawValue.uuidString)"
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [identifier])
    }
    
    public func cancelAllReminders() async {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
    }
    
    public func requestAuthorization() async throws -> Bool {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        return try await requestAuthorization(options: options)
    }

    private func addNotificationRequest(_ request: UNNotificationRequest) async throws {
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

    private func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool {
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
