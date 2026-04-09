import Foundation
import Testing
import ComposableArchitecture
import Domain
import JacsimClient
import Ports

@testable import Jacsim

@Test("AllTask 목록 행 탭은 상세 이동 delegate를 보낸다")
@MainActor
func allTaskFeatureSendsDelegateWhenTaskTapped() async {
    let task = makeAllTaskFeatureTestTask(title: "테스트 작심")
    let store = TestStore(initialState: AllTaskFeature.State()) {
        AllTaskFeature()
    }

    await store.send(.taskTapped(task))
    await store.receive(.delegate(.navigateToDetail(task)))
}

@Test("AllTask 빈 상태 CTA는 새 작심 만들기 delegate를 보낸다")
@MainActor
func allTaskFeatureCreateTaskCTA() async {
    let store = TestStore(initialState: AllTaskFeature.State()) {
        AllTaskFeature()
    }

    await store.send(.createTaskButtonTapped)
    await store.receive(.delegate(.createTaskRequested))
}

@Test("AllTask 진행 중 섹션 토글은 펼침 상태를 반전한다")
@MainActor
func allTaskFeatureToggleOngoingSection() async {
    let store = TestStore(initialState: AllTaskFeature.State()) {
        AllTaskFeature()
    }

    await store.send(.toggleOngoing) {
        $0.isOngoingExpanded = false
    }
}

@Test("AllTask 조회 실패는 로딩을 종료하고 오류 상태를 표시한다")
@MainActor
func allTaskFeatureLoadFailureSetsErrorState() async {
    var initialState = AllTaskFeature.State()
    initialState.isLoading = true

    let store = TestStore(initialState: initialState) {
        AllTaskFeature()
    }

    await store.send(.tasksLoadFailed) {
        $0.isLoading = false
        $0.loadFailed = true
    }
}

@Test("AllTask 조회 성공은 목록과 오류 상태를 갱신한다")
@MainActor
func allTaskFeatureResponseUpdatesGroups() async {
    var initialState = AllTaskFeature.State()
    initialState.isLoading = true
    initialState.loadFailed = true

    let ongoing = makeAllTaskFeatureTestTask(title: "진행 중")
    let success = makeAllTaskFeatureTestTask(title: "성공")
    let fail = makeAllTaskFeatureTestTask(title: "실패")

    let store = TestStore(initialState: initialState) {
        AllTaskFeature()
    }

    await store.send(.tasksResponse(ongoing: [ongoing], success: [success], fail: [fail])) {
        $0.ongoingTasks = [ongoing]
        $0.successTasks = [success]
        $0.failTasks = [fail]
        $0.isLoading = false
        $0.loadFailed = false
    }
}

@Test("AllTask onAppear는 repository와 summary usecase 결과로 섹션을 구성한다")
@MainActor
func allTaskFeatureOnAppearBuildsSectionsFromDependencies() async {
    let ongoing = makeAllTaskFeatureTestTask(title: "진행 중", result: .inProgress)
    let success = makeAllTaskFeatureTestTask(title: "성공", result: .success)
    let fail = makeAllTaskFeatureTestTask(title: "실패", result: .fail)

    let store = TestStore(initialState: AllTaskFeature.State()) {
        AllTaskFeature()
    } withDependencies: {
        $0.taskRepository = TaskRepositoryPort(
            fetchActiveTasks: { [ongoing] },
            fetchTask: { _ in nil },
            addTask: { _ in },
            updateTask: { _ in },
            deleteTask: { _ in },
            fetchTasksByStatus: { _ in [success, fail] }
        )
    }

    await store.send(.onAppear) {
        $0.isLoading = true
        $0.loadFailed = false
    }
    await store.receive(.tasksResponse(ongoing: [ongoing], success: [success], fail: [fail])) {
        $0.ongoingTasks = [ongoing]
        $0.successTasks = [success]
        $0.failTasks = [fail]
        $0.isLoading = false
        $0.loadFailed = false
    }
}

private func makeAllTaskFeatureTestTask(title: String, result: StageResult = .inProgress) -> Task {
    let start = Calendar.current.startOfDay(for: Date())
    let end = Calendar.current.date(byAdding: .day, value: 6, to: start) ?? start
    let stage = StageSnapshot(
        id: UUID(),
        stageTypeRaw: StageType.seven.rawValue,
        startDate: start,
        endDate: end,
        durationDays: 7,
        successDays: 0,
        resultRaw: result.rawValue
    )

    return Task(
        id: TaskID(UUID()),
        title: title,
        startDate: start,
        endDate: end,
        alarm: nil,
        isNotificationEnabled: false,
        stages: [stage],
        records: []
    )
}
