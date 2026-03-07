import Foundation
import Testing
import ComposableArchitecture
import Domain

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

private func makeAllTaskFeatureTestTask(title: String) -> Task {
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
