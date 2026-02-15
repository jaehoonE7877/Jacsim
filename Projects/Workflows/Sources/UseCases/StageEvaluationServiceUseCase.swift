import Foundation
import Domain

public struct StageEvaluationServiceUseCase: Sendable {
    public var evaluateStage: @Sendable (Date, Int, Int, Date) -> StageResult
    public var calculateMinimumSuccessDays: @Sendable (Int) -> Int

    public init(
        evaluateStage: @escaping @Sendable (Date, Int, Int, Date) -> StageResult,
        calculateMinimumSuccessDays: @escaping @Sendable (Int) -> Int
    ) {
        self.evaluateStage = evaluateStage
        self.calculateMinimumSuccessDays = calculateMinimumSuccessDays
    }
}

extension StageEvaluationServiceUseCase {
    public static func live(
        stageEvaluationService: StageEvaluationService = StageEvaluationService()
    ) -> Self {
        Self(
            evaluateStage: { endDate, durationDays, successDays, now in
                stageEvaluationService.evaluateStage(
                    endDate: endDate,
                    durationDays: durationDays,
                    successDays: successDays,
                    now: now
                )
            },
            calculateMinimumSuccessDays: { durationDays in
                stageEvaluationService.calculateMinimumSuccessDays(durationDays: durationDays)
            }
        )
    }
}
