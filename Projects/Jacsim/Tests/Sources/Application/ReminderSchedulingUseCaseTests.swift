import Foundation
import Testing

import Domain
import ExternalInterface

@testable import Jacsim

private actor ReminderSchedulingRecorder {
    struct ScheduledCall: Equatable {
        let taskID: TaskID
        let title: String
        let components: DateComponents
    }

    private(set) var scheduledCalls: [ScheduledCall] = []
    private(set) var cancelledTaskIDs: [TaskID] = []

    func recordSchedule(taskID: TaskID, title: String, components: DateComponents) {
        scheduledCalls.append(ScheduledCall(taskID: taskID, title: title, components: components))
    }

    func recordCancel(taskID: TaskID) {
        cancelledTaskIDs.append(taskID)
    }

    func scheduledCount() -> Int { scheduledCalls.count }
    func cancelledCount() -> Int { cancelledTaskIDs.count }
    func lastScheduled() -> ScheduledCall? { scheduledCalls.last }
}

@Test("다음 인증 알림은 오늘 미인증이고 알림 시간이 남아 있으면 오늘 1회성으로 예약한다")
func scheduleNextReminderUsesTodayWhenStillPending() async {
    let calendar = Calendar.current
    let now = calendar.date(from: DateComponents(year: 2026, month: 5, day: 2, hour: 10, minute: 0))!
    let alarm = calendar.date(from: DateComponents(year: 2026, month: 5, day: 2, hour: 21, minute: 0))!
    let task = makeReminderTask(now: now, alarm: alarm, checkedDays: [])
    let recorder = ReminderSchedulingRecorder()

    await ReminderSchedulingUseCase().scheduleNextReminderIfNeeded(
        task: task,
        isGlobalNotificationEnabled: true,
        now: now,
        notificationScheduler: makeScheduler(recorder)
    )

    #expect(await recorder.cancelledCount() == 1)
    #expect(await recorder.scheduledCount() == 1)
    let scheduled = await recorder.lastScheduled()
    #expect(scheduled?.taskID == task.id)
    #expect(scheduled?.title == task.title)
    #expect(scheduled?.components.year == 2026)
    #expect(scheduled?.components.month == 5)
    #expect(scheduled?.components.day == 2)
    #expect(scheduled?.components.hour == 21)
    #expect(scheduled?.components.minute == 0)
}

@Test("오늘 인증이 끝났으면 다음 미인증 날짜 1건만 예약한다")
func scheduleNextReminderSkipsCertifiedToday() async {
    let calendar = Calendar.current
    let now = calendar.date(from: DateComponents(year: 2026, month: 5, day: 2, hour: 10, minute: 0))!
    let alarm = calendar.date(from: DateComponents(year: 2026, month: 5, day: 2, hour: 21, minute: 0))!
    let task = makeReminderTask(now: now, alarm: alarm, checkedDays: [0])
    let recorder = ReminderSchedulingRecorder()

    await ReminderSchedulingUseCase().scheduleNextReminderIfNeeded(
        task: task,
        isGlobalNotificationEnabled: true,
        now: now,
        notificationScheduler: makeScheduler(recorder)
    )

    #expect(await recorder.cancelledCount() == 1)
    #expect(await recorder.scheduledCount() == 1)
    let scheduled = await recorder.lastScheduled()
    #expect(scheduled?.components.year == 2026)
    #expect(scheduled?.components.month == 5)
    #expect(scheduled?.components.day == 3)
    #expect(scheduled?.components.hour == 21)
    #expect(scheduled?.components.minute == 0)
}

@Test("남은 인증 날짜가 없으면 오래된 알림을 취소하고 새 알림은 예약하지 않는다")
func scheduleNextReminderCancelsWhenNoPendingDayExists() async {
    let calendar = Calendar.current
    let now = calendar.date(from: DateComponents(year: 2026, month: 5, day: 4, hour: 10, minute: 0))!
    let alarm = calendar.date(from: DateComponents(year: 2026, month: 5, day: 2, hour: 21, minute: 0))!
    let task = makeReminderTask(now: now, alarm: alarm, checkedDays: [0, 1, 2])
    let recorder = ReminderSchedulingRecorder()

    await ReminderSchedulingUseCase().scheduleNextReminderIfNeeded(
        task: task,
        isGlobalNotificationEnabled: true,
        now: now,
        notificationScheduler: makeScheduler(recorder)
    )

    #expect(await recorder.cancelledCount() == 1)
    #expect(await recorder.scheduledCount() == 0)
}

@Test("전역 알림 동기화는 예약 대상이 아닌 stale reminder를 취소한다")
func syncGlobalRemindersCancelsStaleReminderWhenEnabled() async {
    let taskID = TaskID(UUID())
    let recorder = ReminderSchedulingRecorder()
    let reminder = ReminderInfo(
        taskId: taskID,
        title: "완료된 작심",
        time: DateComponents(hour: 21, minute: 0),
        shouldSchedule: false
    )

    await ReminderSchedulingUseCase().syncGlobalReminders(
        isEnabled: true,
        reminders: [reminder],
        notificationScheduler: makeScheduler(recorder)
    )

    #expect(await recorder.cancelledCount() == 1)
    #expect(await recorder.scheduledCount() == 0)
}

private func makeScheduler(_ recorder: ReminderSchedulingRecorder) -> NotificationSchedulerPort {
    NotificationSchedulerPort(
        scheduleDailyReminder: { taskID, title, components in
            await recorder.recordSchedule(taskID: taskID, title: title, components: components)
        },
        cancelReminder: { taskID in
            await recorder.recordCancel(taskID: taskID)
        },
        cancelAllReminders: {},
        requestAuthorization: { true }
    )
}

private func makeReminderTask(
    now: Date,
    alarm: Date,
    checkedDays: Set<Int>
) -> Task {
    let calendar = Calendar.current
    let start = calendar.startOfDay(for: now)
    let end = calendar.date(byAdding: .day, value: 2, to: start)!
    let stage = StageSnapshot(
        id: UUID(),
        stageTypeRaw: StageType.three.rawValue,
        startDate: start,
        endDate: end,
        durationDays: 3,
        successDays: 0,
        resultRaw: StageResult.inProgress.rawValue
    )
    let records = (0..<3).map { offset in
        DailyRecordSnapshot(
            id: UUID(),
            memo: "",
            check: checkedDays.contains(offset),
            date: calendar.date(byAdding: .day, value: offset, to: start)!,
            imagePath: nil
        )
    }

    return Task(
        id: TaskID(UUID()),
        title: "저녁 인증",
        startDate: start,
        endDate: end,
        alarm: alarm,
        isNotificationEnabled: true,
        stages: [stage],
        records: records
    )
}
