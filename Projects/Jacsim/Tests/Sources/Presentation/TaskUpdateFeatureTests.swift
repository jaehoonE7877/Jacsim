import Foundation
import Testing
import ComposableArchitecture
import Domain
import JacsimClient

@testable import Jacsim

@MainActor
@Test("인증 저장 실패 시 화면은 닫히지 않고 saveFailed 상태를 유지한다")
func taskUpdateSaveFailureKeepsScreenOpen() async {
    let task = makeTaskForUpdateTests()
    let store = TestStore(initialState: TaskUpdateFeature.State(task: task, index: 0)) {
        TaskUpdateFeature()
    } withDependencies: {
        $0.certifyTaskTodayUseCase = CertifyTaskTodayUseCase(
            execute: { _ in throw UpdateFeatureFailure.failed }
        )
    }

    await store.send(.certifyButtonTapped) {
        $0.isSaving = true
        $0.saveFailed = false
    }
    await store.receive(\.saveCompleted) {
        $0.isSaving = false
        $0.saveFailed = true
    }
}

private func makeTaskForUpdateTests() -> Task {
    let day = Calendar.current.startOfDay(for: Date())
    return Task(
        id: TaskID(UUID()),
        title: "작심",
        startDate: day,
        endDate: day,
        stages: [],
        records: [
            DailyRecordSnapshot(id: UUID(), memo: "", check: false, date: day, imagePath: nil)
        ]
    )
}

private enum UpdateFeatureFailure: Error {
    case failed
}
