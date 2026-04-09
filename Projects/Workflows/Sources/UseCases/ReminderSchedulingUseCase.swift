import Foundation
import Domain
import Ports
import Shared

public struct ReminderSchedulingUseCase: Sendable {
    private let notificationScheduler: NotificationSchedulerPort
    private let userSettingsRepository: UserSettingsRepositoryPort
    private let taskRepository: TaskRepositoryPort
    private let activeTaskService: ActiveTaskService

    public init(
        notificationScheduler: NotificationSchedulerPort,
        userSettingsRepository: UserSettingsRepositoryPort,
        taskRepository: TaskRepositoryPort,
        activeTaskService: ActiveTaskService = ActiveTaskService()
    ) {
        self.notificationScheduler = notificationScheduler
        self.userSettingsRepository = userSettingsRepository
        self.taskRepository = taskRepository
        self.activeTaskService = activeTaskService
    }

    public func resyncRepresentativeReminder(referenceDate: Date = .now) async {
        await notificationScheduler.cancelAllReminders()

        let isGlobalNotificationEnabled = await userSettingsRepository.isNotificationEnabled()
        guard isGlobalNotificationEnabled else { return }

        let tasks: [Task]
        do {
            tasks = try await taskRepository.fetchActiveTasks()
        } catch {
            Logger.certificationFailed(error: error)
            return
        }

        let focusSelection = activeTaskService.makeTodayFocusSelection(
            from: tasks,
            referenceDate: referenceDate
        )

        guard let reminderRequest = makeReminderRequest(
            from: focusSelection.visibleTasks,
            referenceDate: referenceDate,
            globalNotificationsEnabled: isGlobalNotificationEnabled
        ) else {
            return
        }

        do {
            try await notificationScheduler.scheduleReminder(reminderRequest)
        } catch {
            Logger.certificationFailed(error: error)
        }
    }

    public func syncGlobalReminders(
        isEnabled: Bool
    ) async {
        guard isEnabled else {
            await notificationScheduler.cancelAllReminders()
            return
        }

        await resyncRepresentativeReminder()
    }

    private func makeReminderRequest(
        from tasks: [Task],
        referenceDate: Date,
        globalNotificationsEnabled: Bool
    ) -> NotificationReminderRequest? {
        let calendar = Calendar.current

        let candidates = tasks.compactMap { task -> ReminderCandidate? in
            let eligibility = evaluateNotificationEligibility(
                task: task,
                referenceDate: referenceDate,
                globalNotificationsEnabled: globalNotificationsEnabled
            )
            guard let nextEligibleDate = eligibility.nextEligibleDate,
                  let scheduledDate = nextReminderDate(
                    for: task,
                    nextEligibleDate: nextEligibleDate,
                    referenceDate: referenceDate
                  ) else {
                return nil
            }

            return ReminderCandidate(task: task, scheduledDate: scheduledDate)
        }

        guard !candidates.isEmpty else { return nil }

        let earliestScheduledDay = candidates
            .map { calendar.startOfDay(for: $0.scheduledDate) }
            .min()

        guard let earliestScheduledDay else { return nil }

        let sameDayCandidates = candidates.filter {
            calendar.isDate($0.scheduledDate, inSameDayAs: earliestScheduledDay)
        }
        let rankedTasks = activeTaskService.rankTasksForTodayFocus(
            sameDayCandidates.map(\.task),
            referenceDate: earliestScheduledDay
        )
        guard let focusTask = rankedTasks.first,
              let scheduledDate = sameDayCandidates.first(where: { $0.task.id == focusTask.id })?.scheduledDate else {
            return nil
        }

        let bundledCount = max(0, sameDayCandidates.count - 1)
        let message = reminderMessage(
            for: focusTask,
            bundledCount: bundledCount,
            scheduledDate: scheduledDate
        )

        return NotificationReminderRequest(
            taskID: focusTask.id,
            title: message.title,
            body: message.body,
            dateComponents: calendar.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: scheduledDate
            ),
            repeats: false
        )
    }

    private func nextReminderDate(
        for task: Task,
        nextEligibleDate: Date,
        referenceDate: Date
    ) -> Date? {
        guard let alarm = task.alarm else { return nil }

        let calendar = Calendar.current
        let reminderTime = calendar.dateComponents([.hour, .minute], from: alarm)
        let stageEndDate = calendar.startOfDay(for: task.currentStage?.endDate ?? task.endDate)

        var day = calendar.startOfDay(for: nextEligibleDate)
        while day <= stageEndDate {
            var dateComponents = calendar.dateComponents([.year, .month, .day], from: day)
            dateComponents.hour = reminderTime.hour
            dateComponents.minute = reminderTime.minute

            guard let scheduledDate = calendar.date(from: dateComponents) else {
                return nil
            }
            if scheduledDate > referenceDate {
                return scheduledDate
            }

            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: day) else {
                return nil
            }
            day = calendar.startOfDay(for: nextDay)
        }

        return nil
    }

    private func reminderMessage(
        for task: Task,
        bundledCount: Int,
        scheduledDate: Date
    ) -> (title: String, body: String) {
        let calendar = Calendar.current
        let stageEndDate = calendar.startOfDay(for: task.currentStage?.endDate ?? task.endDate)
        let scheduledDay = calendar.startOfDay(for: scheduledDate)
        let remainingDays = calendar.dateComponents([.day], from: scheduledDay, to: stageEndDate).day ?? 0

        let baseBody: String
        if remainingDays <= 1 {
            baseBody = "\(task.title) 오늘 놓치지 않도록 확인해 보세요"
        } else {
            baseBody = "\(task.title) 오늘 작심을 이어갈 시간이에요"
        }

        let body: String
        if bundledCount > 0 {
            body = "\(baseBody) · 외 \(bundledCount)개 남았어요"
        } else {
            body = baseBody
        }

        return ("작심 리마인더", body)
    }

    private struct ReminderCandidate: Sendable {
        let task: Task
        let scheduledDate: Date
    }
}
