import Foundation

public struct StageEvaluationService: Sendable {
    public init() {}
    
    public func evaluateStage(
        endDate: Date,
        durationDays: Int,
        successDays: Int,
        now: Date = .now
    ) -> StageResult {
        evaluateStageResult(
            endDate: endDate,
            durationDays: durationDays,
            successDays: successDays,
            now: now
        )
    }
    
    public func calculateMinimumSuccessDays(durationDays: Int) -> Int {
        minimumSuccessDays(durationDays: durationDays)
    }
}
