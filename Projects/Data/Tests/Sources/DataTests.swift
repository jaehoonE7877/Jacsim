import Foundation
import Testing
@testable import Data
@testable import Domain

@Test("Task mapping keeps notification fields")
func mapTaskPreservesNotificationFields() {
    let stage = StageSnapshot(
        id: UUID(),
        stageTypeRaw: StageType.three.rawValue,
        startDate: .now,
        endDate: .now,
        durationDays: 3,
        successDays: 0,
        resultRaw: StageResult.inProgress.rawValue
    )
    let alarm = Date(timeIntervalSince1970: 1_700_000_000)
    let task = Task(
        id: TaskID(UUID()),
        title: "알림 작심",
        startDate: .now,
        endDate: .now,
        alarmDate: alarm,
        isNotificationEnabled: true,
        stages: [stage],
        records: []
    )

    let model = mapToSwiftDataModel(task)
    #expect(model.alarm == alarm)
    #expect(model.isNotificationEnabled == true)
    #expect(model.currentStageTypeRaw == StageType.three.rawValue)

    let restored = mapToDomainModel(model)
    #expect(restored.alarmDate == alarm)
    #expect(restored.isNotificationEnabled == true)
}

@Test("Task mapping updates completion status fields")
func mapTaskUpdatesStatusFields() {
    let stage = StageSnapshot(
        id: UUID(),
        stageTypeRaw: StageType.seven.rawValue,
        startDate: .now,
        endDate: .now,
        durationDays: 7,
        successDays: 4,
        resultRaw: StageResult.success.rawValue
    )
    let task = Task(
        id: TaskID(UUID()),
        title: "완료 작심",
        startDate: .now,
        endDate: .now,
        stages: [stage],
        records: []
    )

    let model = mapToSwiftDataModel(task)
    #expect(model.isDone == true)
    #expect(model.isSuccess == true)
    #expect(model.statusRaw == ChallengeStatus.done.rawValue)
    #expect(model.resultRaw == ChallengeResult.success.rawValue)
}
