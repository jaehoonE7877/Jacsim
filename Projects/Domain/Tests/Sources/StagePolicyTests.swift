import Foundation
import Testing

import Domain

@Test("minimumSuccessDays")
func minimumSuccessDays() {
    #expect(minimumSuccessDays(durationDays: 3) == 2)
    #expect(minimumSuccessDays(durationDays: 7) == 4)
    #expect(minimumSuccessDays(durationDays: 15) == 8)
    #expect(minimumSuccessDays(durationDays: 30) == 15)
}

@Test("evaluateStageResult - success")
func evaluateStageResultSuccess() {
    let now = Date(timeIntervalSince1970: 1_700_000_000)
    let startDate = now.addingTimeInterval(-86400 * 3)
    let endDate = startDate.addingTimeInterval(86400 * 2)

    let result = evaluateStageResult(
        endDate: endDate,
        durationDays: 3,
        successDays: 2,
        now: now
    )

    #expect(result == .success)
}

@Test("evaluateStageResult - fail")
func evaluateStageResultFail() {
    let now = Date(timeIntervalSince1970: 1_700_000_000)
    let startDate = now.addingTimeInterval(-86400 * 3)
    let endDate = startDate.addingTimeInterval(86400 * 2)

    let result = evaluateStageResult(
        endDate: endDate,
        durationDays: 3,
        successDays: 1,
        now: now
    )

    #expect(result == .fail)
}

@Test("evaluateStageResult - in progress")
func evaluateStageResultInProgress() {
    let now = Date(timeIntervalSince1970: 1_700_000_000)
    let startDate = now
    let endDate = startDate.addingTimeInterval(86400)

    let result = evaluateStageResult(
        endDate: endDate,
        durationDays: 3,
        successDays: 2,
        now: now
    )

    #expect(result == .inProgress)
}
