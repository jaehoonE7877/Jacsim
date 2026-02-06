import Foundation
import Testing

@testable import Jacsim

@MainActor
@Test("최소 성공 일수 계산")
func minimumSuccessDays() {
    let repository = JacsimRepository.shared
    #expect(repository.minimumSuccessDays(for: 3) == 2)
    #expect(repository.minimumSuccessDays(for: 7) == 4)
    #expect(repository.minimumSuccessDays(for: 15) == 8)
    #expect(repository.minimumSuccessDays(for: 30) == 15)
}

@MainActor
@Test("스테이지 결과 판정 - 성공")
func evaluateStageResultSuccess() {
    let repository = JacsimRepository.shared
    let endDate = Date().addingTimeInterval(-86400)
    let startDate = endDate.addingTimeInterval(-86400 * 2)
    let stage = Stage(
        stageTypeRaw: StageType.three.rawValue,
        startDate: startDate,
        endDate: endDate,
        durationDays: 3,
        successDays: 2
    )

    #expect(repository.evaluateStageResult(stage) == .success)
}

@MainActor
@Test("스테이지 결과 판정 - 실패")
func evaluateStageResultFail() {
    let repository = JacsimRepository.shared
    let endDate = Date().addingTimeInterval(-86400)
    let startDate = endDate.addingTimeInterval(-86400 * 2)
    let stage = Stage(
        stageTypeRaw: StageType.three.rawValue,
        startDate: startDate,
        endDate: endDate,
        durationDays: 3,
        successDays: 1
    )

    #expect(repository.evaluateStageResult(stage) == .fail)
}

@MainActor
@Test("스테이지 결과 판정 - 진행 중")
func evaluateStageResultInProgress() {
    let repository = JacsimRepository.shared
    let endDate = Date().addingTimeInterval(86400)
    let startDate = Date()
    let stage = Stage(
        stageTypeRaw: StageType.three.rawValue,
        startDate: startDate,
        endDate: endDate,
        durationDays: 3,
        successDays: 2
    )

    #expect(repository.evaluateStageResult(stage) == .inProgress)
}
