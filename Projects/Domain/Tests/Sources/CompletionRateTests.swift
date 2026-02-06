import Foundation
import Testing

import Domain

@Test("CompletionRateResult - basic calculation")
func completionRateResultBasic() {
    let result = CompletionRateResult(totalCount: 4, completedCount: 2)
    #expect(result.rate == 0.5)
    #expect(result.displayText == "50%")
}

@Test("CompletionRateResult - no active tasks")
func completionRateResultNoTasks() {
    let result = CompletionRateResult(totalCount: 0, completedCount: 0)
    #expect(result.rate == nil)
    #expect(result.displayText == "데이터 없음")
}

@Test("calculateCompletionRate - with active tasks and records")
func calculateCompletionRateWithRecords() {
    let now = Date(timeIntervalSince1970: 1_700_000_000)
    let startDate = now.addingTimeInterval(-86400)
    let endDate = now.addingTimeInterval(86400)
    
    let stage = StageSnapshot(
        id: UUID(),
        stageTypeRaw: 3,
        startDate: startDate,
        endDate: endDate,
        durationDays: 3,
        successDays: 0,
        resultRaw: "inProgress"
    )
    
    let record = DailyRecordSnapshot(
        id: UUID(),
        memo: "",
        check: true,
        date: now,
        imagePath: nil
    )
    
    let task = Task(
        id: TaskID(UUID()),
        title: "Test",
        startDate: startDate,
        endDate: endDate,
        stages: [stage],
        records: [record]
    )
    
    let result = calculateCompletionRate(for: now, tasks: [task])
    #expect(result.totalCount == 1)
    #expect(result.completedCount == 1)
    #expect(result.rate == 1.0)
}

@Test("calculateCompletionRate - task without record")
func calculateCompletionRateWithoutRecord() {
    let now = Date(timeIntervalSince1970: 1_700_000_000)
    let startDate = now.addingTimeInterval(-86400)
    let endDate = now.addingTimeInterval(86400)
    
    let stage = StageSnapshot(
        id: UUID(),
        stageTypeRaw: 3,
        startDate: startDate,
        endDate: endDate,
        durationDays: 3,
        successDays: 0,
        resultRaw: "inProgress"
    )
    
    let task = Task(
        id: TaskID(UUID()),
        title: "Test",
        startDate: startDate,
        endDate: endDate,
        stages: [stage],
        records: []
    )
    
    let result = calculateCompletionRate(for: now, tasks: [task])
    #expect(result.totalCount == 1)
    #expect(result.completedCount == 0)
    #expect(result.rate == 0.0)
}