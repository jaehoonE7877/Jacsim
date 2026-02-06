import Foundation
import Testing
@testable import Domain

struct ChallengeStateServiceTests {
    let service = ChallengeStateService()
    let calendar = Calendar.current
    
    @Test
    func testEvaluateChallengeStateForStagePending() {
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        let stage = StageSnapshot(
            id: UUID(),
            stageTypeRaw: 7,
            startDate: yesterday,
            endDate: tomorrow,
            durationDays: 7,
            successDays: 0,
            resultRaw: "inProgress"
        )
        
        let task = Task(
            id: TaskID(UUID()),
            title: "Test Task",
            startDate: yesterday,
            endDate: tomorrow,
            stages: [stage],
            records: []
        )
        
        let result = service.evaluateChallengeState(for: task, today: today)
        
        #expect(result.challengeState == .stagePending)
        #expect(result.todayStatus == .notCertified)
        #expect(result.currentStage?.stageType == .seven)
    }
    
    @Test
    func testEvaluateChallengeStateForStageSuccess() {
        let today = calendar.date(byAdding: .day, value: -2, to: Date())!
        let lastWeek = calendar.date(byAdding: .day, value: -7, to: today)!
        
        let stage = StageSnapshot(
            id: UUID(),
            stageTypeRaw: 7,
            startDate: lastWeek,
            endDate: today,
            durationDays: 7,
            successDays: 5,
            resultRaw: "success"
        )
        
        let task = Task(
            id: TaskID(UUID()),
            title: "Test Task",
            startDate: lastWeek,
            endDate: today,
            stages: [stage],
            records: []
        )
        
        let result = service.evaluateChallengeState(for: task, today: Date())
        
        #expect(result.challengeState == .stageSuccess)
    }
    
    @Test
    func testEvaluateChallengeStateForHabitCompleted() {
        let today = calendar.date(byAdding: .day, value: -2, to: Date())!
        let lastMonth = calendar.date(byAdding: .day, value: -30, to: today)!
        
        let stage = StageSnapshot(
            id: UUID(),
            stageTypeRaw: 30,
            startDate: lastMonth,
            endDate: today,
            durationDays: 30,
            successDays: 20,
            resultRaw: "success"
        )
        
        let task = Task(
            id: TaskID(UUID()),
            title: "Test Task",
            startDate: lastMonth,
            endDate: today,
            stages: [stage],
            records: []
        )
        
        let result = service.evaluateChallengeState(for: task, today: Date())
        
        #expect(result.challengeState == .habitCompleted)
    }
    
    @Test
    func testEvaluateChallengeStateForTodayCertified() {
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        let stage = StageSnapshot(
            id: UUID(),
            stageTypeRaw: 7,
            startDate: yesterday,
            endDate: tomorrow,
            durationDays: 7,
            successDays: 1,
            resultRaw: "inProgress"
        )
        
        let records = [
            DailyRecordSnapshot(id: UUID(), memo: "Done", check: true, date: today, imagePath: nil)
        ]
        
        let task = Task(
            id: TaskID(UUID()),
            title: "Test Task",
            startDate: yesterday,
            endDate: tomorrow,
            stages: [stage],
            records: records
        )
        
        let result = service.evaluateChallengeState(for: task, today: today)
        
        #expect(result.todayStatus == .certified)
        #expect(result.todayMemo == "Done")
    }
    
    @Test
    func testDayViewDataGeneration() {
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        let stage = StageSnapshot(
            id: UUID(),
            stageTypeRaw: 3,
            startDate: yesterday,
            endDate: today,
            durationDays: 3,
            successDays: 0,
            resultRaw: "inProgress"
        )
        
        let records = [
            DailyRecordSnapshot(id: UUID(), memo: "First", check: true, date: yesterday, imagePath: nil),
            DailyRecordSnapshot(id: UUID(), memo: "Second", check: false, date: today, imagePath: nil)
        ]
        
        let task = Task(
            id: TaskID(UUID()),
            title: "Test Task",
            startDate: yesterday,
            endDate: today,
            stages: [stage],
            records: records
        )
        
        let result = service.evaluateChallengeState(for: task, today: today)
        
        #expect(result.dayViewData.count == 2)
        #expect(result.dayViewData[0].memo == "Second")
        #expect(result.dayViewData[0].isChecked == false)
        #expect(result.dayViewData[1].memo == "First")
        #expect(result.dayViewData[1].isChecked == true)
    }
}
