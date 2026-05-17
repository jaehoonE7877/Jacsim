import Foundation
import UserNotifications
import Domain
import ExternalInterface
import SwiftData

public actor LocalNotificationSchedulerAdapter {
    private let notificationCenter: UNUserNotificationCenter
    private let container: ModelContainer
    private let localUserId: UserID?
    
    public init(
        notificationCenter: UNUserNotificationCenter = .current(),
        container: ModelContainer = SwiftDataStack.shared.container,
        localUserId: UserID? = nil
    ) {
        self.notificationCenter = notificationCenter
        self.container = container
        self.localUserId = localUserId
    }
    
    public func scheduleReminder(taskId: TaskID, title: String, time: DateComponents) async throws {
        let identifier = "jacsim-\(taskId.rawValue.uuidString)"
        
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        
        let content = UNMutableNotificationContent()
        content.title = "작심 인증"
        content.body = "\(title) 인증할 시간이에요"
        content.sound = .default
        
        let repeats = time.year == nil && time.month == nil && time.day == nil
        let trigger = UNCalendarNotificationTrigger(dateMatching: time, repeats: repeats)
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

    public func scheduleSocial(
        trigger: SocialNotificationTrigger,
        context: SocialNotificationContext
    ) async throws {
        if let targetUserId = context.targetUserId {
            guard let localUserId,
                  targetUserId == localUserId,
                  context.sourceUserId != localUserId else {
                return
            }
        }

        let settings = socialNotificationSettings()
        guard settings.isEnabled(trigger) else { return }

        let content = UNMutableNotificationContent()
        content.title = context.title
        content.body = context.body
        content.sound = .default

        let identifier = socialIdentifier(trigger: trigger, context: context)
        let notificationTrigger: UNNotificationTrigger
        if trigger == .coachWeekly {
            var date = DateComponents()
            date.weekday = settings.coachWeeklyWeekday
            date.hour = settings.coachWeeklyHour
            date.minute = settings.coachWeeklyMinute
            notificationTrigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        } else {
            notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        }

        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: notificationTrigger)
        try await addNotificationRequest(request)
    }

    public func cancelSocial(matching key: SocialNotificationKey) async throws {
        let identifier = "jacsim-social-\(key.trigger.rawValue)-\(key.rawValue)"
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [identifier])
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

    private func socialIdentifier(
        trigger: SocialNotificationTrigger,
        context: SocialNotificationContext
    ) -> String {
        if trigger == .coachWeekly {
            return "jacsim-social-\(trigger.rawValue)-weekly"
        }
        let rawKey = context.postId?.rawValue.uuidString
            ?? context.taskId?.rawValue.uuidString
            ?? context.sourceUserId?.rawValue.uuidString
            ?? UUID().uuidString
        return "jacsim-social-\(trigger.rawValue)-\(rawKey)"
    }

    private func socialNotificationSettings() -> SocialNotificationSettings {
        let context = ModelContext(container)
        let settings = (try? context.fetch(FetchDescriptor<AppSettingsModel>()))?.first(where: { $0.id == "global" })
        guard let settings else { return SocialNotificationSettings() }
        return SocialNotificationSettings(
            followRequested: settings.notifyFollowRequested ?? true,
            followAccepted: settings.notifyFollowAccepted ?? true,
            friendPosted: settings.notifyFriendPosted ?? false,
            friendGraduated: settings.notifyFriendGraduated ?? true,
            postCheered: settings.notifyPostCheered ?? true,
            postFollowed: settings.notifyPostFollowed ?? true,
            postCommented: settings.notifyPostCommented ?? true,
            coachWeekly: settings.notifyCoachWeekly ?? true,
            coachWeeklyHour: settings.coachWeeklyHour ?? 20,
            coachWeeklyMinute: settings.coachWeeklyMinute ?? 0,
            coachWeeklyWeekday: settings.coachWeeklyWeekday ?? 1
        )
    }
}
