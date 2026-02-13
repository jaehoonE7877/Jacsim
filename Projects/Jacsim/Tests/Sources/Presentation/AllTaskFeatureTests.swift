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
