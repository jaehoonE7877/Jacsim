import Foundation
import Testing
import Domain

@testable import Workflows

@Test("TaskReadModelQueries는 오늘 미완료 task를 hero로 선택한다")
func taskReadModelQueriesBuildsPendingFocus() {
    let today = Calendar.current.startOfDay(for: Date())
    let completed = makeTask(
        title: "완료됨",
        startDate: Calendar.current.date(byAdding: .day, value: -1, to: today) ?? today,
        endDate: Calendar.current.date(byAdding: .day, value: 3, to: today) ?? today,
        completedDates: [today]
    )
    let pending = makeTask(
        title: "미완료",
        startDate: Calendar.current.date(byAdding: .day, value: -1, to: today) ?? today,
        endDate: Calendar.current.date(byAdding: .day, value: 1, to: today) ?? today
    )

    let summary = TaskReadModelQueries.live().home(
        tasks: [completed, pending],
        referenceDate: today
    )

    #expect(summary.visibleTasks == [pending, completed])
    #expect(summary.focusTask?.id == pending.id)
    #expect(summary.state == .pending)
    #expect(summary.pendingCount == 1)
    #expect(summary.completedTodayCount == 1)
}

@Test("TaskReadModelQueries는 완료 task를 성공과 실패로 분류한다")
func taskReadModelQueriesSplitsCompletedTasks() {
    let ongoing = makeTask(title: "진행 중", stageResult: .inProgress)
    let success = makeTask(title: "성공", stageResult: .success)
    let fail = makeTask(title: "실패", stageResult: .fail)

    let summary = TaskReadModelQueries.live().allTasks(
        ongoingTasks: [ongoing],
        doneTasks: [success, fail]
    )

    #expect(summary.ongoingTasks == [ongoing])
    #expect(summary.successTasks == [success])
    #expect(summary.failTasks == [fail])
}

@Test("TaskReadModelQueries는 날짜와 성공률 색상을 계산한다")
func taskReadModelQueriesBuildsDatesAndColors() {
    let start = Calendar.current.startOfDay(for: Date())
    let end = Calendar.current.date(byAdding: .day, value: 2, to: start) ?? start
    let task = makeTask(
        title: "달력",
        startDate: start,
        endDate: end,
        completedOffsets: [0]
    )

    let summary = TaskReadModelQueries.live().calendar(tasks: [task])

    #expect(summary.eventDates.count == 3)
    #expect(summary.eventDates.first == start)
    #expect(summary.dateColors[start] == .medium)
}

@Test("TaskReadModelQueries는 상세 상태와 stage 결과를 함께 계산한다")
func taskReadModelQueriesBuildsDetailPresentationSummary() {
    let today = Calendar.current.startOfDay(for: Date())
    let endedYesterday = Calendar.current.date(byAdding: .day, value: -1, to: today) ?? today
    let task = makeTask(
        title: "상세",
        startDate: Calendar.current.date(byAdding: .day, value: -6, to: today) ?? today,
        endDate: endedYesterday,
        completedOffsets: [0, 1],
        successDays: 0,
        stageResult: .inProgress
    )

    let summary = TaskReadModelQueries.live().taskDetail(
        task: task,
        referenceDate: today
    )

    #expect(summary.evaluation.challengeState == .stagePending)
    #expect(summary.evaluation.currentStage?.id == task.stages.last?.id)
    #expect(summary.evaluation.dayViewData.count == task.dayArray.count)
    #expect(summary.stageResult == .fail)
}

private func makeTask(
    title: String,
    startDate: Date = Calendar.current.startOfDay(for: Date()),
    endDate: Date? = nil,
    completedOffsets: [Int] = [],
    completedDates: [Date] = [],
    successDays: Int = 0,
    stageResult: StageResult = .inProgress
) -> Task {
    let calendar = Calendar.current
    let resolvedEndDate = endDate ?? (calendar.date(byAdding: .day, value: 6, to: startDate) ?? startDate)
    let stage = StageSnapshot(
        id: UUID(),
        stageTypeRaw: StageType.seven.rawValue,
        startDate: startDate,
        endDate: resolvedEndDate,
        durationDays: 7,
        successDays: successDays,
        resultRaw: stageResult.rawValue
    )
    let recordsFromOffsets = completedOffsets.map { offset in
        DailyRecordSnapshot(
            id: UUID(),
            memo: "",
            check: true,
            date: calendar.date(byAdding: .day, value: offset, to: startDate) ?? startDate,
            imagePath: nil
        )
    }
    let recordsFromDates = completedDates.map { date in
        DailyRecordSnapshot(
            id: UUID(),
            memo: "",
            check: true,
            date: date,
            imagePath: nil
        )
    }

    return Task(
        id: TaskID(UUID()),
        title: title,
        startDate: startDate,
        endDate: resolvedEndDate,
        alarm: nil,
        isNotificationEnabled: false,
        stages: [stage],
        records: recordsFromOffsets + recordsFromDates
    )
}
