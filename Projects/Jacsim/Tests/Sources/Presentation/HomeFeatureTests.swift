import Domain
import Foundation
import Testing

@testable import Jacsim

@Test("miniCardImageLoaded는 index가 아닌 id 기준으로 카드 이미지를 갱신한다")
@MainActor
func miniCardImageLoadedUpdatesById() {
    let firstID = UUID()
    let secondID = UUID()
    let loadedImage = Data("second-image".utf8)
    let model = HomeModel(dependencies: .test)
    model.miniCardDisplayData = [
        .init(id: secondID, title: "B", progress: 0.3, totalDays: 10, completedDays: 3, imageData: nil, isTodayCertified: false),
        .init(id: firstID, title: "A", progress: 0.7, totalDays: 10, completedDays: 7, imageData: nil, isTodayCertified: true)
    ]

    model.miniCardImageLoaded(id: firstID, imageData: loadedImage)

    #expect(model.miniCardDisplayData[1].imageData == loadedImage)
    #expect(model.miniCardDisplayData[0].imageData == nil)
}

@Test("miniCardImageLoaded는 존재하지 않는 id 응답을 무시한다")
@MainActor
func miniCardImageLoadedIgnoresUnknownId() {
    let knownID = UUID()
    let unknownID = UUID()
    let originalImage = Data("original-image".utf8)
    let model = HomeModel(dependencies: .test)
    model.miniCardDisplayData = [
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

    model.miniCardImageLoaded(id: unknownID, imageData: Data("new".utf8))

    #expect(model.miniCardDisplayData[0].imageData == originalImage)
}

@Test("Home primary CTA는 오늘 미인증 작심을 바로 인증 화면으로 연결한다")
@MainActor
func homePrimaryCTAOpensCheckInForPendingTask() {
    let today = Calendar.current.startOfDay(for: Date())
    let task = makeHomeTask(startDate: today, endDate: today)
    let model = HomeModel(dependencies: .test)

    model.focusPrimaryButtonTapped(task)

    #expect(model.path == [.update(task, index: 0)])
}

@Test("Home primary CTA는 오늘 인증 완료 작심의 기록 영역으로 연결한다")
@MainActor
func homePrimaryCTAOpensRecordsForCompletedTask() {
    let today = Calendar.current.startOfDay(for: Date())
    let record = DailyRecordSnapshot(
        id: UUID(),
        memo: "done",
        check: true,
        date: today,
        imagePath: "record.jpg"
    )
    let task = makeHomeTask(startDate: today, endDate: today, records: [record])
    let model = HomeModel(dependencies: .test)

    model.focusPrimaryButtonTapped(task)

    #expect(model.path == [.detail(task, scrollToRecords: true)])
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
