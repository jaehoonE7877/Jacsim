import Foundation
import SwiftData
import Domain
import ExternalInterface

public actor UserSettingsRepositoryAdapter {
    private enum GlobalSettings {
        static let id = "global"
    }

    private let context: ModelContext
    
    public init(context: ModelContext = SwiftDataStack.shared.makeContext()) {
        self.context = context
    }
    
    public func isNotificationEnabled() async -> Bool {
        fetchOrCreateGlobalSettings().isNotificationEnabled
    }
    
    public func getAllReminders() async -> [ReminderInfo] {
        let descriptor = FetchDescriptor<UserJacsimModel>(
            predicate: #Predicate { $0.isNotificationEnabled == true && $0.alarm != nil }
        )
        let results = (try? context.fetch(descriptor)) ?? []
        let now = Date()
        let tasks = results.map { mapToDomainModel($0).refreshingStageProgress(now: now) }
        let focusTaskID = ActiveTaskService()
            .filterActiveTasks(tasks, referenceDate: now)
            .first?
            .id
        
        return tasks.compactMap { task in
            guard let alarm = task.alarm else { return nil }
            let nextReminderTime = nextReminderComponents(for: task, alarm: alarm, now: now)
            let fallbackTime = Calendar.current.dateComponents([.hour, .minute], from: alarm)
            return ReminderInfo(
                taskId: task.id,
                title: task.title,
                time: nextReminderTime ?? fallbackTime,
                shouldSchedule: task.id == focusTaskID && nextReminderTime != nil
            )
        }
    }
    
    public func updateNotificationEnabled(_ enabled: Bool) async {
        let settings = fetchOrCreateGlobalSettings()
        settings.isNotificationEnabled = enabled
        try? context.save()
    }

    public func wallpaperRaw() async -> String {
        fetchOrCreateGlobalSettings().wallpaperRaw ?? "morning"
    }

    public func updateWallpaperRaw(_ rawValue: String) async {
        let settings = fetchOrCreateGlobalSettings()
        settings.wallpaperRaw = rawValue
        try? context.save()
    }

    public func socialNotificationSettings() async -> SocialNotificationSettings {
        mapSocialNotificationSettings(fetchOrCreateGlobalSettings())
    }

    public func updateSocialNotificationSettings(_ socialSettings: SocialNotificationSettings) async {
        let settings = fetchOrCreateGlobalSettings()
        settings.notifyFollowRequested = socialSettings.followRequested
        settings.notifyFollowAccepted = socialSettings.followAccepted
        settings.notifyFriendPosted = socialSettings.friendPosted
        settings.notifyFriendGraduated = socialSettings.friendGraduated
        settings.notifyPostCheered = socialSettings.postCheered
        settings.notifyPostFollowed = socialSettings.postFollowed
        settings.notifyPostCommented = socialSettings.postCommented
        settings.notifyCoachWeekly = socialSettings.coachWeekly
        settings.coachWeeklyHour = socialSettings.coachWeeklyHour
        settings.coachWeeklyMinute = socialSettings.coachWeeklyMinute
        settings.coachWeeklyWeekday = socialSettings.coachWeeklyWeekday
        try? context.save()
    }

    private func fetchOrCreateGlobalSettings() -> AppSettingsModel {
        let settingsDescriptor = FetchDescriptor<AppSettingsModel>()
        if let existing = (try? context.fetch(settingsDescriptor))?.first(where: { $0.id == GlobalSettings.id }) {
            return existing
        }

        // Migrate previous behavior where global toggle was inferred from task rows.
        let taskDescriptor = FetchDescriptor<UserJacsimModel>()
        let inferredGlobalToggle = ((try? context.fetch(taskDescriptor)) ?? []).contains { $0.isNotificationEnabled }

        let settings = AppSettingsModel(id: GlobalSettings.id, isNotificationEnabled: inferredGlobalToggle)
        context.insert(settings)
        try? context.save()
        return settings
    }

    private func mapSocialNotificationSettings(_ model: AppSettingsModel) -> SocialNotificationSettings {
        SocialNotificationSettings(
            followRequested: model.notifyFollowRequested ?? true,
            followAccepted: model.notifyFollowAccepted ?? true,
            friendPosted: model.notifyFriendPosted ?? false,
            friendGraduated: model.notifyFriendGraduated ?? true,
            postCheered: model.notifyPostCheered ?? true,
            postFollowed: model.notifyPostFollowed ?? true,
            postCommented: model.notifyPostCommented ?? true,
            coachWeekly: model.notifyCoachWeekly ?? true,
            coachWeeklyHour: model.coachWeeklyHour ?? 20,
            coachWeeklyMinute: model.coachWeeklyMinute ?? 0,
            coachWeeklyWeekday: model.coachWeeklyWeekday ?? 1
        )
    }
}
