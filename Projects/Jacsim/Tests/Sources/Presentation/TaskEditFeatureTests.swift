import Domain
import ExternalInterface
import Foundation
import Testing
import UIKit

@testable import Jacsim

private actor TaskEditNotificationRecorder {
    private(set) var scheduledCountValue = 0
    private(set) var cancelledCountValue = 0

    func recordSchedule() {
        scheduledCountValue += 1
    }

    func recordCancel() {
        cancelledCountValue += 1
    }

    func scheduledCount() -> Int { scheduledCountValue }
    func cancelledCount() -> Int { cancelledCountValue }
}

@MainActor
@Test("작심 수정 저장은 편집 sheet 안에서 알림 예약을 직접 수행하지 않는다")
func taskEditSaveSchedulesReminderWhenEnabled() async {
    let task = makeTaskForEditTests()
    let scheduler = TaskEditNotificationRecorder()
    let alarmDate = Calendar.current.date(from: DateComponents(hour: 8, minute: 30)) ?? Date()
    var saved: (String, UIImage?, Bool, Date)?
    let model = TaskEditModel(
        task: task,
        dependencies: makeTaskEditDependencies(scheduler: scheduler),
        onSaved: { saved = ($0, $1, $2, $3) }
    )
    model.title = "  새 제목  "
    model.isAlarmEnabled = true
    model.alarmDate = alarmDate

    model.saveButtonTapped()

    #expect(saved?.0 == "새 제목")
    #expect(saved?.2 == true)
    #expect(saved?.3 == alarmDate)
    #expect(await scheduler.cancelledCount() == 0)
    #expect(await scheduler.scheduledCount() == 0)
}

@MainActor
@Test("작심 수정 저장에서 알림을 꺼도 편집 sheet 안에서는 스케줄을 직접 변경하지 않는다")
func taskEditSaveCancelsOnlyWhenAlarmDisabled() async {
    let task = makeTaskForEditTests()
    let scheduler = TaskEditNotificationRecorder()
    var saved: (String, UIImage?, Bool, Date)?
    let model = TaskEditModel(
        task: task,
        dependencies: makeTaskEditDependencies(scheduler: scheduler),
        onSaved: { saved = ($0, $1, $2, $3) }
    )
    model.title = "수정 제목"
    model.isAlarmEnabled = false

    model.saveButtonTapped()

    #expect(saved?.0 == "수정 제목")
    #expect(saved?.2 == false)
    #expect(await scheduler.cancelledCount() == 0)
    #expect(await scheduler.scheduledCount() == 0)
}

@MainActor
@Test("전역 알림 OFF여도 편집 sheet 안에서는 스케줄을 직접 변경하지 않는다")
func taskEditSaveSkipsScheduleWhenGlobalNotificationOff() async {
    let task = makeTaskForEditTests()
    let scheduler = TaskEditNotificationRecorder()
    var saved: (String, UIImage?, Bool, Date)?
    let model = TaskEditModel(
        task: task,
        dependencies: makeTaskEditDependencies(scheduler: scheduler),
        onSaved: { saved = ($0, $1, $2, $3) }
    )
    model.title = "수정 제목"
    model.isAlarmEnabled = true

    model.saveButtonTapped()

    #expect(saved?.0 == "수정 제목")
    #expect(saved?.2 == true)
    #expect(await scheduler.cancelledCount() == 0)
    #expect(await scheduler.scheduledCount() == 0)
}

@MainActor
@Test("이미지 선택 액션은 대표 이미지를 갱신한다")
func taskEditImageSelectedUpdatesState() {
    let task = makeTaskForEditTests()
    let image = makeSolidTestImage()
    let model = TaskEditModel(task: task, dependencies: .test)

    model.imageSelected(image)

    #expect(model.image === image)
}

private func makeTaskEditDependencies(scheduler: TaskEditNotificationRecorder) -> JacsimDependencies {
    var dependencies = JacsimDependencies.test
    dependencies.notificationScheduler = NotificationSchedulerPort(
        scheduleDailyReminder: { _, _, _ in await scheduler.recordSchedule() },
        cancelReminder: { _ in await scheduler.recordCancel() },
        cancelAllReminders: {},
        requestAuthorization: { true }
    )
    return dependencies
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
