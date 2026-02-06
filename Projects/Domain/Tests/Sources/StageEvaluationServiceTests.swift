import Foundation
import Testing
@testable import Domain

struct StageEvaluationServiceTests {
    let service = StageEvaluationService()
    let calendar = Calendar.current
    
    @Test
    func testEvaluateStageReturnsInProgressWhenNotEnded() {
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date())!
        
        let result = service.evaluateStage(
            endDate: tomorrow,
            durationDays: 7,
            successDays: 0,
            now: Date()
        )
        
        #expect(result == .inProgress)
    }
    
    @Test
    func testEvaluateStageReturnsSuccessWhenThresholdMet() {
        let yesterday = calendar.date(byAdding: .day, value: -2, to: Date())!
        
        let result = service.evaluateStage(
            endDate: yesterday,
            durationDays: 7,
            successDays: 4,
            now: Date()
        )
        
        #expect(result == .success)
    }
    
    @Test
    func testEvaluateStageReturnsFailWhenThresholdNotMet() {
        let yesterday = calendar.date(byAdding: .day, value: -2, to: Date())!
        
        let result = service.evaluateStage(
            endDate: yesterday,
            durationDays: 7,
            successDays: 2,
            now: Date()
        )
        
        #expect(result == .fail)
    }
    
    @Test
    func testCalculateMinimumSuccessDays() {
        #expect(service.calculateMinimumSuccessDays(durationDays: 3) == 2)
        #expect(service.calculateMinimumSuccessDays(durationDays: 7) == 4)
        #expect(service.calculateMinimumSuccessDays(durationDays: 15) == 8)
        #expect(service.calculateMinimumSuccessDays(durationDays: 30) == 15)
    }
}
