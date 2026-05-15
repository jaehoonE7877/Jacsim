import Foundation
import Testing
import ComposableArchitecture
import Domain

@testable import Jacsim

@Test("miniCardImageLoaded는 index가 아닌 id 기준으로 카드 이미지를 갱신한다")
@MainActor
func miniCardImageLoadedUpdatesById() async {
    let firstID = UUID()
    let secondID = UUID()
    let loadedImage = Data("second-image".utf8)

    var initialState = HomeFeature.State()
    initialState.miniCardDisplayData = [
        .init(id: secondID, title: "B", progress: 0.3, totalDays: 10, completedDays: 3, imageData: nil, isTodayCertified: false),
        .init(id: firstID, title: "A", progress: 0.7, totalDays: 10, completedDays: 7, imageData: nil, isTodayCertified: true)
    ]

    let store = TestStore(initialState: initialState) {
        HomeFeature()
    }

    await store.send(.miniCardImageLoaded(id: firstID, imageData: loadedImage)) {
        $0.miniCardDisplayData[1] = HomeFeature.State.MiniCardDisplayData(
            id: firstID,
            title: "A",
            progress: 0.7,
            totalDays: 10,
            completedDays: 7,
            imageData: loadedImage,
            isTodayCertified: true
        )
    }
}

@Test("miniCardImageLoaded는 존재하지 않는 id 응답을 무시한다")
@MainActor
func miniCardImageLoadedIgnoresUnknownId() async {
    let knownID = UUID()
    let unknownID = UUID()
    let originalImage = Data("original-image".utf8)

    var initialState = HomeFeature.State()
    initialState.miniCardDisplayData = [
        .init(
            id: knownID,
            title: "Known",
            progress: 0.5,
            totalDays: 20,
            completedDays: 10,
            imageData: originalImage,
            isTodayCertified: false
        )
    ]

    let store = TestStore(initialState: initialState) {
        HomeFeature()
    }

    await store.send(.miniCardImageLoaded(id: unknownID, imageData: Data("new".utf8)))
    #expect(store.state.miniCardDisplayData[0].imageData == originalImage)
}

@Test("Home primary CTA는 오늘 미인증 작심을 바로 인증 화면으로 연결한다")
@MainActor
func homePrimaryCTAOpensCheckInForPendingTask() async {
    let today = Calendar.current.startOfDay(for: Date())
    let task = makeHomeTask(startDate: today, endDate: today)

    let store = TestStore(initialState: HomeFeature.State()) {
        HomeFeature()
    }

    await store.send(.focusPrimaryButtonTapped(task)) {
        $0.path.append(.update(TaskUpdateFeature.State(task: task, index: 0)))
    }
}

@Test("Home primary CTA는 오늘 인증 완료 작심의 기록 영역으로 연결한다")
@MainActor
func homePrimaryCTAOpensRecordsForCompletedTask() async {
    let today = Calendar.current.startOfDay(for: Date())
    let record = DailyRecordSnapshot(
        id: UUID(),
        memo: "done",
        check: true,
        date: today,
        imagePath: "record.jpg"
    )
    let task = makeHomeTask(startDate: today, endDate: today, records: [record])

    let store = TestStore(initialState: HomeFeature.State()) {
        HomeFeature()
    }

    await store.send(.focusPrimaryButtonTapped(task)) {
        var detailState = TaskDetailFeature.State(task: task)
        detailState.shouldScrollToRecords = true
        $0.path.append(.detail(detailState))
    }
}

private func makeHomeTask(
    startDate: Date,
    endDate: Date,
    records: [DailyRecordSnapshot] = []
) -> Domain.Task {
    Domain.Task(
        id: TaskID(UUID()),
        title: "Home Task",
        startDate: startDate,
        endDate: endDate,
        stages: [
            StageSnapshot(
                id: UUID(),
                stageTypeRaw: StageType.three.rawValue,
                startDate: startDate,
                endDate: endDate,
                durationDays: 3,
                successDays: 0,
                resultRaw: StageResult.inProgress.rawValue
            )
        ],
        records: records
    )
}
