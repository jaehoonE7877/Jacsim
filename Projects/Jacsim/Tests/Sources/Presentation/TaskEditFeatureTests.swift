import Foundation
import Testing
import ComposableArchitecture
import Domain
import UIKit

@testable import Jacsim

@MainActor
@Test("작심 수정 저장은 delegate(.saved)로 입력값을 전달한다")
func taskEditSaveSendsDelegateSaved() async {
    let task = makeTaskForEditTests()
    let alarmDate = Calendar.current.date(from: DateComponents(hour: 8, minute: 30)) ?? Date()

    var initialState = TaskEditFeature.State(task: task)
    initialState.title = "  새 제목  "
    initialState.lastAcceptedTitle = "  새 제목  "
    initialState.isAlarmEnabled = true
    initialState.alarmDate = alarmDate

    let store = TestStore(initialState: initialState) {
        TaskEditFeature()
    }

    await store.send(.saveButtonTapped)
    await store.receive(\.delegate)
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
