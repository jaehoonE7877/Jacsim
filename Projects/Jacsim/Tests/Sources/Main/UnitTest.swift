import Foundation
import Testing
import Domain

@testable import Jacsim

@MainActor
@Test("최소 성공 일수 계산")
func minimumSuccessDays() {
    #expect(minimumSuccessDays(durationDays: 3) == 2)
    #expect(minimumSuccessDays(durationDays: 7) == 4)
    #expect(minimumSuccessDays(durationDays: 15) == 8)
    #expect(minimumSuccessDays(durationDays: 30) == 15)
}

@MainActor
@Test("스테이지 결과 판정 - 성공")
func evaluateStageResultSuccess() {
    let endDate = Date().addingTimeInterval(-86400)
    let result = evaluateStageResult(
        endDate: endDate,
        durationDays: 3,
        successDays: 2,
        now: Date()
    )
    #expect(result == .success)
}

@MainActor
@Test("스테이지 결과 판정 - 실패")
func evaluateStageResultFail() {
    let endDate = Date().addingTimeInterval(-86400)
    let result = evaluateStageResult(
        endDate: endDate,
        durationDays: 3,
        successDays: 1,
        now: Date()
    )
    #expect(result == .fail)
}

@MainActor
@Test("스테이지 결과 판정 - 진행 중")
func evaluateStageResultInProgress() {
    let endDate = Date().addingTimeInterval(86400)
    let result = evaluateStageResult(
        endDate: endDate,
        durationDays: 3,
        successDays: 2,
        now: Date()
    )
    #expect(result == .inProgress)
}
