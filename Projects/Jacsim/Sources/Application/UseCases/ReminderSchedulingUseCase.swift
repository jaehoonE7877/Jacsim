import Foundation
import Domain
import ExternalInterface
import Core

public struct ReminderSchedulingUseCase: Sendable {
    private let notificationScheduler: NotificationSchedulerPort
    private let userSettingsRepository: UserSettingsRepositoryPort

    public init(
        notificationScheduler: NotificationSchedulerPort,
        userSettingsRepository: UserSettingsRepositoryPort
    ) {
        self.notificationScheduler = notificationScheduler
        self.userSettingsRepository = userSettingsRepository
    }

    public func scheduleReminderIfNeeded(
        taskID: TaskID,
        title: String,
        isAlarmEnabled: Bool,
        alarmDate: Date,
        cancelExistingReminder: Bool
    ) async {
        if cancelExistingReminder {
            await notificationScheduler.cancelReminder(taskID)
        }

        let isGlobalNotificationEnabled = await userSettingsRepository.isNotificationEnabled()
        guard isAlarmEnabled, isGlobalNotificationEnabled else { return }

        let time = Calendar.current.dateComponents([.hour, .minute], from: alarmDate)
        do {
            try await notificationScheduler.scheduleDailyReminder(taskID, title, time)
        } catch {
            Logger.certificationFailed(error: error)
        }
    }

    public func syncGlobalReminders(
        isEnabled: Bool
    ) async {
        let reminders = await userSettingsRepository.getAllReminders()
        if isEnabled {
            for reminder in reminders {
                do {
                    try await notificationScheduler.scheduleDailyReminder(
                        reminder.taskId,
                        reminder.title,
                        reminder.time
                    )
                } catch {
                    Logger.certificationFailed(error: error)
                }
            }
            return
        }

        for reminder in reminders {
            await notificationScheduler.cancelReminder(reminder.taskId)
        }
    }
}
