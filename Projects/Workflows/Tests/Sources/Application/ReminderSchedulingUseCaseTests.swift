import Foundation
import Testing
import Domain
import Ports

@testable import Workflows

// Protects reminder orchestration business rules: cancel/schedule branching,
// global toggle synchronization, and error-resilient scheduling with port doubles.

private actor NotificationSchedulerSpy {
    enum SpyError: Error {
        case forcedFailure
    }

    private(set) var scheduledTaskIDs: [TaskID] = []
    private(set) var scheduledTimes: [DateComponents] = []
    private(set) var cancelledTaskIDs: [TaskID] = []
    private var failingTaskIDs: Set<TaskID>

    init(failingTaskIDs: Set<TaskID> = []) {
        self.failingTaskIDs = failingTaskIDs
    }

    func schedule(taskID: TaskID, title: String, time: DateComponents) throws {
        _ = title
        scheduledTaskIDs.append(taskID)
        scheduledTimes.append(time)
        if failingTaskIDs.contains(taskID) {
            throw SpyError.forcedFailure
        }
    }

    func cancel(taskID: TaskID) {
        cancelledTaskIDs.append(taskID)
    }

    func scheduledCount() -> Int {
        scheduledTaskIDs.count
    }

    func cancelledCount() -> Int {
        cancelledTaskIDs.count
    }

    func firstScheduledTime() -> DateComponents? {
        scheduledTimes.first
    }

    func hasCancelled(_ taskID: TaskID) -> Bool {
        cancelledTaskIDs.contains(taskID)
    }
}

private actor UserSettingsRepositorySpy {
    private(set) var isEnabled: Bool
    private(set) var reminders: [ReminderInfo]

    init(isEnabled: Bool, reminders: [ReminderInfo] = []) {
        self.isEnabled = isEnabled
        self.reminders = reminders
    }

    func isNotificationEnabled() -> Bool {
        isEnabled
    }

    func getAllReminders() -> [ReminderInfo] {
        reminders
    }
}

@Test("scheduleReminderIfNeeded cancels existing and schedules when all flags are ON")
func scheduleReminderIfNeededSchedulesWithExtractedTime() async throws {
    let scheduler = NotificationSchedulerSpy()
    let port = makeSchedulerPort(spy: scheduler)
    let repoSpy = UserSettingsRepositorySpy(isEnabled: true)
    let userSettingsRepository = makeUserSettingsRepositoryPort(spy: repoSpy)
    let useCase = ReminderSchedulingUseCase(
        notificationScheduler: port,
        userSettingsRepository: userSettingsRepository
    )
    let taskID = TaskID(UUID())
    let alarmDate = fixedDate(year: 2026, month: 5, day: 1, hour: 8, minute: 30)

    await useCase.scheduleReminderIfNeeded(
        taskID: taskID,
        title: "Morning",
        isAlarmEnabled: true,
        alarmDate: alarmDate,
        cancelExistingReminder: true
    )

    #expect(await scheduler.cancelledCount() == 1)
    #expect(await scheduler.hasCancelled(taskID))
    #expect(await scheduler.scheduledCount() == 1)
    let time = try #require(await scheduler.firstScheduledTime())
    #expect(time.hour == 8)
    #expect(time.minute == 30)
}

@Test("scheduleReminderIfNeeded skips scheduling when alarm or global toggle is OFF")
func scheduleReminderIfNeededSkipsScheduleWhenDisabled() async {
    let scheduler = NotificationSchedulerSpy()
    let port = makeSchedulerPort(spy: scheduler)
    let repoEnabledSpy = UserSettingsRepositorySpy(isEnabled: true)
    let useCaseEnabled = ReminderSchedulingUseCase(
        notificationScheduler: port,
        userSettingsRepository: makeUserSettingsRepositoryPort(spy: repoEnabledSpy)
    )
    let taskID = TaskID(UUID())
    let alarmDate = fixedDate(year: 2026, month: 5, day: 1, hour: 9, minute: 0)

    await useCaseEnabled.scheduleReminderIfNeeded(
        taskID: taskID,
        title: "Disabled Alarm",
        isAlarmEnabled: false,
        alarmDate: alarmDate,
        cancelExistingReminder: false
    )

    let repoDisabledSpy = UserSettingsRepositorySpy(isEnabled: false)
    let useCaseDisabled = ReminderSchedulingUseCase(
        notificationScheduler: port,
        userSettingsRepository: makeUserSettingsRepositoryPort(spy: repoDisabledSpy)
    )

    await useCaseDisabled.scheduleReminderIfNeeded(
        taskID: taskID,
        title: "Global Off",
        isAlarmEnabled: true,
        alarmDate: alarmDate,
        cancelExistingReminder: false
    )

    #expect(await scheduler.cancelledCount() == 0)
    #expect(await scheduler.scheduledCount() == 0)
}

@Test("scheduleReminderIfNeeded swallows scheduling errors and stays non-throwing")
func scheduleReminderIfNeededDoesNotFailOnScheduleError() async {
    let taskID = TaskID(UUID())
    let scheduler = NotificationSchedulerSpy(failingTaskIDs: [taskID])
    let port = makeSchedulerPort(spy: scheduler)
    let repoSpy = UserSettingsRepositorySpy(isEnabled: true)
    let useCase = ReminderSchedulingUseCase(
        notificationScheduler: port,
        userSettingsRepository: makeUserSettingsRepositoryPort(spy: repoSpy)
    )

    await useCase.scheduleReminderIfNeeded(
        taskID: taskID,
        title: "Error Case",
        isAlarmEnabled: true,
        alarmDate: fixedDate(year: 2026, month: 6, day: 1, hour: 7, minute: 10),
        cancelExistingReminder: false
    )

    #expect(await scheduler.scheduledCount() == 1)
}

@Test("syncGlobalReminders ON schedules each reminder")
func syncGlobalRemindersEnabledSchedulesAll() async {
    let first = TaskID(UUID())
    let second = TaskID(UUID())
    let reminders = [
        ReminderInfo(taskId: first, title: "A", time: DateComponents(hour: 7, minute: 45)),
        ReminderInfo(taskId: second, title: "B", time: DateComponents(hour: 20, minute: 15))
    ]

    let scheduler = NotificationSchedulerSpy()
    let port = makeSchedulerPort(spy: scheduler)
    let repoSpy = UserSettingsRepositorySpy(isEnabled: true, reminders: reminders)
    let useCase = ReminderSchedulingUseCase(
        notificationScheduler: port,
        userSettingsRepository: makeUserSettingsRepositoryPort(spy: repoSpy)
    )

    await useCase.syncGlobalReminders(isEnabled: true)

    #expect(await scheduler.scheduledCount() == 2)
    #expect(await scheduler.cancelledCount() == 0)
}

@Test("syncGlobalReminders OFF cancels each reminder")
func syncGlobalRemindersDisabledCancelsAll() async {
    let first = TaskID(UUID())
    let second = TaskID(UUID())
    let reminders = [
        ReminderInfo(taskId: first, title: "A", time: DateComponents(hour: 7, minute: 45)),
        ReminderInfo(taskId: second, title: "B", time: DateComponents(hour: 20, minute: 15))
    ]

    let scheduler = NotificationSchedulerSpy()
    let port = makeSchedulerPort(spy: scheduler)
    let repoSpy = UserSettingsRepositorySpy(isEnabled: true, reminders: reminders)
    let useCase = ReminderSchedulingUseCase(
        notificationScheduler: port,
        userSettingsRepository: makeUserSettingsRepositoryPort(spy: repoSpy)
    )

    await useCase.syncGlobalReminders(isEnabled: false)

    #expect(await scheduler.scheduledCount() == 0)
    #expect(await scheduler.cancelledCount() == 2)
}

@Test("syncGlobalReminders continues scheduling remaining reminders after a failure")
func syncGlobalRemindersContinuesAfterOneScheduleFailure() async {
    let first = TaskID(UUID())
    let second = TaskID(UUID())
    let reminders = [
        ReminderInfo(taskId: first, title: "A", time: DateComponents(hour: 7, minute: 45)),
        ReminderInfo(taskId: second, title: "B", time: DateComponents(hour: 20, minute: 15))
    ]

    let scheduler = NotificationSchedulerSpy(failingTaskIDs: [first])
    let port = makeSchedulerPort(spy: scheduler)
    let repoSpy = UserSettingsRepositorySpy(isEnabled: true, reminders: reminders)
    let useCase = ReminderSchedulingUseCase(
        notificationScheduler: port,
        userSettingsRepository: makeUserSettingsRepositoryPort(spy: repoSpy)
    )

    await useCase.syncGlobalReminders(isEnabled: true)

    #expect(await scheduler.scheduledCount() == 2)
    #expect(await scheduler.cancelledCount() == 0)
}

private func makeSchedulerPort(spy: NotificationSchedulerSpy) -> NotificationSchedulerPort {
    NotificationSchedulerPort(
        scheduleDailyReminder: { taskID, title, time in
            try await spy.schedule(taskID: taskID, title: title, time: time)
        },
        cancelReminder: { taskID in
            await spy.cancel(taskID: taskID)
        },
        cancelAllReminders: {},
        requestAuthorization: { true }
    )
}

private func makeUserSettingsRepositoryPort(spy: UserSettingsRepositorySpy) -> UserSettingsRepositoryPort {
    UserSettingsRepositoryPort(
        isNotificationEnabled: { await spy.isNotificationEnabled() },
        getAllReminders: { await spy.getAllReminders() },
        updateNotificationEnabled: { _ in }
    )
}

private func fixedDate(year: Int, month: Int, day: Int, hour: Int, minute: Int) -> Date {
    let calendar = Calendar.current
    let components = DateComponents(year: year, month: month, day: day, hour: hour, minute: minute)
    return calendar.date(from: components) ?? Date(timeIntervalSince1970: 0)
}
