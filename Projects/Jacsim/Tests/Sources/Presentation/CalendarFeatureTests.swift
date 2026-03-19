import Foundation
import Testing
import ComposableArchitecture
import Domain
import JacsimClient
import Ports

@testable import Jacsim

private struct CalendarFeatureTestError: Error {}

@Test("Calendar onAppear는 taskRepository 결과를 eventDates와 dateColors로 반영한다")
@MainActor
func calendarFeatureOnAppearBuildsCalendarState() async {
    let task = makeCalendarFeatureTestTask()

    let store = TestStore(initialState: CalendarFeature.State()) {
        CalendarFeature()
    } withDependencies: {
        $0.taskRepository = TaskRepositoryPort(
            fetchActiveTasks: { [task] },
            fetchTask: { _ in nil },
            addTask: { _ in },
            updateTask: { _ in },
            deleteTask: { _ in },
            fetchTasksByStatus: { _ in [] }
        )
    }

    await store.send(.onAppear) {
        $0.isLoading = true
        $0.loadFailed = false
    }
    await store.receive(\.tasksResponse) {
        $0.tasks = [task]
        $0.eventDates = UseCaseAssembly.calendarSummaryUseCase.execute(.init(tasks: [task])).eventDates
        $0.dateColors = UseCaseAssembly.calendarSummaryUseCase.execute(.init(tasks: [task])).dateColors
        $0.isLoading = false
        $0.loadFailed = false
    }
}

@Test("Calendar onAppear 실패는 오류 상태를 반영한다")
@MainActor
func calendarFeatureOnAppearFailureSetsErrorState() async {
    let store = TestStore(initialState: CalendarFeature.State()) {
        CalendarFeature()
    } withDependencies: {
        $0.taskRepository = TaskRepositoryPort(
            fetchActiveTasks: { throw CalendarFeatureTestError() },
            fetchTask: { _ in nil },
            addTask: { _ in },
            updateTask: { _ in },
            deleteTask: { _ in },
            fetchTasksByStatus: { _ in [] }
        )
    }

    await store.send(.onAppear) {
        $0.isLoading = true
        $0.loadFailed = false
    }
    await store.receive(\.tasksLoadFailed) {
        $0.isLoading = false
        $0.loadFailed = true
    }
}

private func makeCalendarFeatureTestTask() -> Task {
    let calendar = Calendar.current
    let start = calendar.startOfDay(for: Date())
    let end = calendar.date(byAdding: .day, value: 2, to: start) ?? start

    let stage = StageSnapshot(
        id: UUID(),
        stageTypeRaw: StageType.three.rawValue,
        startDate: start,
        endDate: end,
        durationDays: 3,
        successDays: 1,
        resultRaw: StageResult.inProgress.rawValue
    )

    let records = [
        DailyRecordSnapshot(id: UUID(), memo: "", check: true, date: start, imagePath: nil),
        DailyRecordSnapshot(
            id: UUID(),
            memo: "",
            check: false,
            date: calendar.date(byAdding: .day, value: 1, to: start) ?? start,
            imagePath: nil
        )
    ]

    return Task(
        id: TaskID(UUID()),
        title: "달력 테스트",
        startDate: start,
        endDate: end,
        alarm: nil,
        isNotificationEnabled: false,
        stages: [stage],
        records: records
    )
}
