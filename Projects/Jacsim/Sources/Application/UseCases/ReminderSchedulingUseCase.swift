import Foundation
import Domain
import ExternalInterface
import Core

public struct ReminderSchedulingUseCase: Sendable {
    public init() {}

    public func scheduleReminderIfNeeded(
        taskID: TaskID,
        title: String,
        isAlarmEnabled: Bool,
        alarmDate: Date,
        isGlobalNotificationEnabled: Bool,
        cancelExistingReminder: Bool,
        notificationScheduler: NotificationSchedulerPort
    ) async {
        if cancelExistingReminder {
            await notificationScheduler.cancelReminder(taskID)
        }

        guard isAlarmEnabled, isGlobalNotificationEnabled else { return }

        let time = Calendar.current.dateComponents([.hour, .minute], from: alarmDate)
        do {
            try await notificationScheduler.scheduleDailyReminder(taskID, title, time)
        } catch {
            Logger.certificationFailed(error: error)
        }
    }

    public func syncGlobalReminders(
        isEnabled: Bool,
        reminders: [ReminderInfo],
        notificationScheduler: NotificationSchedulerPort
    ) async {
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
