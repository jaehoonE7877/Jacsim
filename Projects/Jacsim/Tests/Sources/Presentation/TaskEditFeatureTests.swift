import Foundation
import Testing
import ComposableArchitecture
import Domain
import ExternalInterface
import UIKit

@testable import Jacsim

private actor TaskEditNotificationRecorder {
    struct ScheduledCall: Equatable {
        let taskID: TaskID
        let title: String
        let hour: Int
        let minute: Int
    }

    private(set) var scheduledCalls: [ScheduledCall] = []
    private(set) var cancelledTaskIDs: [TaskID] = []

    func recordSchedule(taskID: TaskID, title: String, time: DateComponents) {
        scheduledCalls.append(
            ScheduledCall(
                taskID: taskID,
                title: title,
                hour: time.hour ?? -1,
                minute: time.minute ?? -1
            )
        )
    }

    func recordCancel(taskID: TaskID) {
        cancelledTaskIDs.append(taskID)
    }

    func scheduledCount() -> Int { scheduledCalls.count }
    func cancelledCount() -> Int { cancelledTaskIDs.count }
    func lastScheduled() -> ScheduledCall? { scheduledCalls.last }
}

private actor TaskEditUserSettingsRecorder {
    private let notificationEnabled: Bool

    init(notificationEnabled: Bool) {
        self.notificationEnabled = notificationEnabled
    }

    func isNotificationEnabled() -> Bool { notificationEnabled }
}

@MainActor
@Test("작심 수정 저장 시 알림 활성 + 전역 알림 ON이면 기존 알림 취소 후 새 알림을 등록한다")
func taskEditSaveSchedulesReminderWhenEnabled() async {
    let task = makeTaskForEditTests()
    let scheduler = TaskEditNotificationRecorder()
    let settings = TaskEditUserSettingsRecorder(notificationEnabled: true)
    let alarmDate = Calendar.current.date(from: DateComponents(hour: 8, minute: 30)) ?? Date()

    var initialState = TaskEditFeature.State(task: task)
    initialState.title = "  새 제목  "
    initialState.lastAcceptedTitle = "  새 제목  "
    initialState.isAlarmEnabled = true
    initialState.alarmDate = alarmDate

    let store = TestStore(initialState: initialState) {
        TaskEditFeature()
    } withDependencies: {
        $0.notificationScheduler = NotificationSchedulerPort(
            scheduleDailyReminder: { taskID, title, time in
                await scheduler.recordSchedule(taskID: taskID, title: title, time: time)
            },
            cancelReminder: { taskID in
                await scheduler.recordCancel(taskID: taskID)
            },
            cancelAllReminders: {},
            requestAuthorization: { true }
        )
        $0.userSettingsRepository = UserSettingsRepositoryPort(
            isNotificationEnabled: { await settings.isNotificationEnabled() },
            getAllReminders: { [] },
            updateNotificationEnabled: { _ in }
        )
    }
    store.exhaustivity = .off

    await store.send(.saveButtonTapped)
    await store.finish()

    #expect(await scheduler.cancelledCount() == 1)
    #expect(await scheduler.cancelledTaskIDs.first == task.id)
    #expect(await scheduler.scheduledCount() == 1)
    let scheduled = await scheduler.lastScheduled()
    #expect(scheduled?.taskID == task.id)
    #expect(scheduled?.title == "새 제목")
    #expect(scheduled?.hour == 8)
    #expect(scheduled?.minute == 30)
}

@MainActor
@Test("작심 수정 저장 시 알림 비활성화면 스케줄 등록 없이 기존 알림만 취소한다")
func taskEditSaveCancelsOnlyWhenAlarmDisabled() async {
    let task = makeTaskForEditTests()
    let scheduler = TaskEditNotificationRecorder()
    let settings = TaskEditUserSettingsRecorder(notificationEnabled: true)

    var initialState = TaskEditFeature.State(task: task)
    initialState.title = "수정 제목"
    initialState.lastAcceptedTitle = "수정 제목"
    initialState.isAlarmEnabled = false

    let store = TestStore(initialState: initialState) {
        TaskEditFeature()
    } withDependencies: {
        $0.notificationScheduler = NotificationSchedulerPort(
            scheduleDailyReminder: { taskID, title, time in
                await scheduler.recordSchedule(taskID: taskID, title: title, time: time)
            },
            cancelReminder: { taskID in
                await scheduler.recordCancel(taskID: taskID)
            },
            cancelAllReminders: {},
            requestAuthorization: { true }
        )
        $0.userSettingsRepository = UserSettingsRepositoryPort(
            isNotificationEnabled: { await settings.isNotificationEnabled() },
            getAllReminders: { [] },
            updateNotificationEnabled: { _ in }
        )
    }
    store.exhaustivity = .off

    await store.send(.saveButtonTapped)
    await store.finish()

    #expect(await scheduler.cancelledCount() == 1)
    #expect(await scheduler.scheduledCount() == 0)
}

@MainActor
@Test("작심 수정 저장 시 전역 알림 OFF이면 알림 ON 상태여도 새 알림을 등록하지 않는다")
func taskEditSaveSkipsScheduleWhenGlobalNotificationOff() async {
    let task = makeTaskForEditTests()
    let scheduler = TaskEditNotificationRecorder()
    let settings = TaskEditUserSettingsRecorder(notificationEnabled: false)

    var initialState = TaskEditFeature.State(task: task)
    initialState.title = "수정 제목"
    initialState.lastAcceptedTitle = "수정 제목"
    initialState.isAlarmEnabled = true

    let store = TestStore(initialState: initialState) {
        TaskEditFeature()
    } withDependencies: {
        $0.notificationScheduler = NotificationSchedulerPort(
            scheduleDailyReminder: { taskID, title, time in
                await scheduler.recordSchedule(taskID: taskID, title: title, time: time)
            },
            cancelReminder: { taskID in
                await scheduler.recordCancel(taskID: taskID)
            },
            cancelAllReminders: {},
            requestAuthorization: { true }
        )
        $0.userSettingsRepository = UserSettingsRepositoryPort(
            isNotificationEnabled: { await settings.isNotificationEnabled() },
            getAllReminders: { [] },
            updateNotificationEnabled: { _ in }
        )
    }
    store.exhaustivity = .off

    await store.send(.saveButtonTapped)
    await store.finish()

    #expect(await scheduler.cancelledCount() == 1)
    #expect(await scheduler.scheduledCount() == 0)
}

@MainActor
@Test("이미지 선택 액션은 대표 이미지를 갱신한다")
func taskEditImageSelectedUpdatesState() async {
    let task = makeTaskForEditTests()
    let image = makeSolidTestImage()

    let store = TestStore(initialState: TaskEditFeature.State(task: task)) {
        TaskEditFeature()
    }

    await store.send(.imageSelected(image)) {
        $0.image = image
    }
}

private func makeTaskForEditTests(
    id: TaskID = TaskID(UUID())
) -> Task {
    let start = Calendar.current.startOfDay(for: Date())
    let end = Calendar.current.date(byAdding: .day, value: 6, to: start) ?? start

    let stage = StageSnapshot(
        id: UUID(),
        stageTypeRaw: StageType.seven.rawValue,
        startDate: start,
        endDate: end,
        durationDays: 7,
        successDays: 0,
        resultRaw: StageResult.inProgress.rawValue
    )

    return Task(
        id: id,
        title: "기존 제목",
        startDate: start,
        endDate: end,
        alarm: nil,
        isNotificationEnabled: false,
        stages: [stage],
        records: []
    )
}

private func makeSolidTestImage() -> UIImage {
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: 12, height: 12))
    return renderer.image { context in
        UIColor.systemBlue.setFill()
        context.fill(CGRect(x: 0, y: 0, width: 12, height: 12))
    }
}
