import Foundation
import Testing
import Domain
import Ports

@testable import Workflows

private actor NotificationSchedulerSpy {
    enum SpyError: Error {
        case forcedFailure
    }

    private(set) var scheduledRequests: [NotificationReminderRequest] = []
    private(set) var cancelAllCount = 0
    private let shouldFailOnSchedule: Bool

    init(shouldFailOnSchedule: Bool = false) {
        self.shouldFailOnSchedule = shouldFailOnSchedule
    }

    func schedule(_ request: NotificationReminderRequest) throws {
        scheduledRequests.append(request)
        if shouldFailOnSchedule {
            throw SpyError.forcedFailure
        }
    }

    func cancelAll() {
        cancelAllCount += 1
    }

    func firstRequest() -> NotificationReminderRequest? {
        scheduledRequests.first
    }

    func scheduledCount() -> Int {
        scheduledRequests.count
    }
}

private actor UserSettingsRepositorySpy {
    private(set) var isEnabled: Bool

    init(isEnabled: Bool) {
        self.isEnabled = isEnabled
    }

    func isNotificationEnabled() -> Bool {
        isEnabled
    }
}

private actor TaskRepositorySpy {
    private let tasks: [Task]

    init(tasks: [Task]) {
        self.tasks = tasks
    }

    func fetchActiveTasks() -> [Task] {
        tasks
    }
}

@Test("resyncRepresentativeReminder schedules one bundled reminder for the highest-priority pending challenge")
func resyncRepresentativeReminderSchedulesHighestPriorityPendingChallenge() async throws {
    let now = fixedDate(year: 2026, month: 3, day: 7, hour: 7, minute: 0)
    let soonEnd = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now))!
    let laterEnd = calendar.date(byAdding: .day, value: 4, to: calendar.startOfDay(for: now))!

    let focusTask = makeTask(
        title: "독서",
        startDate: calendar.date(byAdding: .day, value: -2, to: now)!,
        endDate: soonEnd,
        alarm: fixedDate(year: 2026, month: 3, day: 7, hour: 21, minute: 0),
        isNotificationEnabled: true,
        records: [],
        stageEndDate: soonEnd
    )
    let bundledTask = makeTask(
        title: "산책",
        startDate: calendar.date(byAdding: .day, value: -2, to: now)!,
        endDate: laterEnd,
        alarm: fixedDate(year: 2026, month: 3, day: 7, hour: 22, minute: 0),
        isNotificationEnabled: true,
        records: [],
        stageEndDate: laterEnd
    )

    let scheduler = NotificationSchedulerSpy()
    let useCase = ReminderSchedulingUseCase(
        notificationScheduler: makeSchedulerPort(spy: scheduler),
        userSettingsRepository: makeUserSettingsRepositoryPort(spy: UserSettingsRepositorySpy(isEnabled: true)),
        taskRepository: makeTaskRepositoryPort(spy: TaskRepositorySpy(tasks: [bundledTask, focusTask]))
    )

    await useCase.resyncRepresentativeReminder(referenceDate: now)

    #expect(await scheduler.cancelAllCount == 1)
    #expect(await scheduler.scheduledCount() == 1)

    let request = try #require(await scheduler.firstRequest())
    #expect(request.taskID == focusTask.id)
    #expect(request.title == "작심 리마인더")
    #expect(request.body.contains("독서"))
    #expect(request.body.contains("외 1개"))
    #expect(request.repeats == false)
    #expect(request.dateComponents.hour == 21)
    #expect(request.dateComponents.minute == 0)
}

@Test("resyncRepresentativeReminder cancels stale reminders and stops when global notifications are disabled")
func resyncRepresentativeReminderCancelsAllWhenGlobalToggleIsOff() async {
    let task = makeTask(
        title: "독서",
        startDate: fixedDate(year: 2026, month: 3, day: 6),
        endDate: fixedDate(year: 2026, month: 3, day: 10),
        alarm: fixedDate(year: 2026, month: 3, day: 7, hour: 21, minute: 0),
        isNotificationEnabled: true,
        records: [],
        stageEndDate: fixedDate(year: 2026, month: 3, day: 10)
    )

    let scheduler = NotificationSchedulerSpy()
    let useCase = ReminderSchedulingUseCase(
        notificationScheduler: makeSchedulerPort(spy: scheduler),
        userSettingsRepository: makeUserSettingsRepositoryPort(spy: UserSettingsRepositorySpy(isEnabled: false)),
        taskRepository: makeTaskRepositoryPort(spy: TaskRepositorySpy(tasks: [task]))
    )

    await useCase.resyncRepresentativeReminder(referenceDate: fixedDate(year: 2026, month: 3, day: 7, hour: 9))

    #expect(await scheduler.cancelAllCount == 1)
    #expect(await scheduler.scheduledCount() == 0)
}

@Test("resyncRepresentativeReminder rolls a completed-today challenge forward to the next day")
func resyncRepresentativeReminderSchedulesTomorrowAfterCompletion() async throws {
    let now = fixedDate(year: 2026, month: 3, day: 7, hour: 18, minute: 0)
    let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now))!
    let task = makeTask(
        title: "작심",
        startDate: calendar.date(byAdding: .day, value: -2, to: now)!,
        endDate: calendar.date(byAdding: .day, value: 2, to: now)!,
        alarm: fixedDate(year: 2026, month: 3, day: 7, hour: 8, minute: 30),
        isNotificationEnabled: true,
        records: [
            DailyRecordSnapshot(id: UUID(), memo: "", check: true, date: calendar.startOfDay(for: now), imagePath: nil)
        ],
        stageEndDate: calendar.date(byAdding: .day, value: 2, to: now)!
    )

    let scheduler = NotificationSchedulerSpy()
    let useCase = ReminderSchedulingUseCase(
        notificationScheduler: makeSchedulerPort(spy: scheduler),
        userSettingsRepository: makeUserSettingsRepositoryPort(spy: UserSettingsRepositorySpy(isEnabled: true)),
        taskRepository: makeTaskRepositoryPort(spy: TaskRepositorySpy(tasks: [task]))
    )

    await useCase.resyncRepresentativeReminder(referenceDate: now)

    let request = try #require(await scheduler.firstRequest())
    let scheduledDate = calendar.date(from: request.dateComponents)
    #expect(calendar.isDate(scheduledDate ?? now, inSameDayAs: tomorrow))
    #expect(request.dateComponents.hour == 8)
    #expect(request.dateComponents.minute == 30)
}

@Test("resyncRepresentativeReminder swallows scheduling failures after cleanup")
func resyncRepresentativeReminderDoesNotThrowOnScheduleFailure() async {
    let task = makeTask(
        title: "산책",
        startDate: fixedDate(year: 2026, month: 3, day: 6),
        endDate: fixedDate(year: 2026, month: 3, day: 9),
        alarm: fixedDate(year: 2026, month: 3, day: 7, hour: 20, minute: 0),
        isNotificationEnabled: true,
        records: [],
        stageEndDate: fixedDate(year: 2026, month: 3, day: 9)
    )

    let scheduler = NotificationSchedulerSpy(shouldFailOnSchedule: true)
    let useCase = ReminderSchedulingUseCase(
        notificationScheduler: makeSchedulerPort(spy: scheduler),
        userSettingsRepository: makeUserSettingsRepositoryPort(spy: UserSettingsRepositorySpy(isEnabled: true)),
        taskRepository: makeTaskRepositoryPort(spy: TaskRepositorySpy(tasks: [task]))
    )

    await useCase.resyncRepresentativeReminder(referenceDate: fixedDate(year: 2026, month: 3, day: 7, hour: 9))

    #expect(await scheduler.cancelAllCount == 1)
    #expect(await scheduler.scheduledCount() == 1)
}

@Test("syncGlobalReminders OFF only clears pending reminders")
func syncGlobalRemindersOffCancelsAllOnly() async {
    let scheduler = NotificationSchedulerSpy()
    let useCase = ReminderSchedulingUseCase(
        notificationScheduler: makeSchedulerPort(spy: scheduler),
        userSettingsRepository: makeUserSettingsRepositoryPort(spy: UserSettingsRepositorySpy(isEnabled: true)),
        taskRepository: makeTaskRepositoryPort(spy: TaskRepositorySpy(tasks: []))
    )

    await useCase.syncGlobalReminders(isEnabled: false)

    #expect(await scheduler.cancelAllCount == 1)
    #expect(await scheduler.scheduledCount() == 0)
}

private let calendar = Calendar.current

private func makeSchedulerPort(spy: NotificationSchedulerSpy) -> NotificationSchedulerPort {
    NotificationSchedulerPort(
        scheduleReminder: { request in
            try await spy.schedule(request)
        },
        cancelReminder: { _ in },
        cancelAllReminders: {
            await spy.cancelAll()
        },
        requestAuthorization: { true }
    )
}

private func makeUserSettingsRepositoryPort(spy: UserSettingsRepositorySpy) -> UserSettingsRepositoryPort {
    UserSettingsRepositoryPort(
        isNotificationEnabled: { await spy.isNotificationEnabled() },
        getAllReminders: { [] },
        updateNotificationEnabled: { _ in }
    )
}

private func makeTaskRepositoryPort(spy: TaskRepositorySpy) -> TaskRepositoryPort {
    TaskRepositoryPort(
        fetchActiveTasks: { await spy.fetchActiveTasks() },
        fetchTask: { _ in nil },
        addTask: { _ in },
        updateTask: { _ in },
        deleteTask: { _ in },
        fetchTasksByStatus: { _ in [] }
    )
}

private func makeTask(
    title: String,
    startDate: Date,
    endDate: Date,
    alarm: Date,
    isNotificationEnabled: Bool,
    records: [DailyRecordSnapshot],
    stageEndDate: Date
) -> Task {
    let stage = StageSnapshot(
        id: UUID(),
        stageTypeRaw: StageType.seven.rawValue,
        startDate: startDate,
        endDate: stageEndDate,
        durationDays: 7,
        successDays: records.filter(\.check).count,
        resultRaw: StageResult.inProgress.rawValue
    )

    return Task(
        id: TaskID(UUID()),
        title: title,
        startDate: startDate,
        endDate: endDate,
        alarm: alarm,
        isNotificationEnabled: isNotificationEnabled,
        stages: [stage],
        records: records
    )
}

private func fixedDate(
    year: Int,
    month: Int,
    day: Int,
    hour: Int = 0,
    minute: Int = 0
) -> Date {
    let components = DateComponents(
        calendar: calendar,
        timeZone: .current,
        year: year,
        month: month,
        day: day,
        hour: hour,
        minute: minute
    )
    return calendar.date(from: components)!
}
