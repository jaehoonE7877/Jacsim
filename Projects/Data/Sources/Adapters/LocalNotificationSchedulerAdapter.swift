import Foundation
import UserNotifications
import Domain
import ExternalInterface

public actor LocalNotificationSchedulerAdapter {
    private let notificationCenter: UNUserNotificationCenter
    
    public init(notificationCenter: UNUserNotificationCenter = .current()) {
        self.notificationCenter = notificationCenter
    }
    
    public func scheduleReminder(taskId: TaskID, title: String, time: DateComponents) async throws {
        let identifier = "jacsim-\(taskId.rawValue.uuidString)"
        
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        
        let content = UNMutableNotificationContent()
        content.title = "작심 인증"
        content.body = "\(title) 인증할 시간이에요"
        content.sound = .default
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: time, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        try await notificationCenter.add(request)
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
        let granted = try await notificationCenter.requestAuthorization(options: options)
        return granted
    }
}
