import Foundation
import Domain

public struct ChallengeStateServiceUseCase: Sendable {
    public var evaluateChallengeState: @Sendable (Task, Date) -> ChallengeStateEvaluation

    public init(evaluateChallengeState: @escaping @Sendable (Task, Date) -> ChallengeStateEvaluation) {
        self.evaluateChallengeState = evaluateChallengeState
    }
}

extension ChallengeStateServiceUseCase {
    public static func live(
        challengeStateService: ChallengeStateService = ChallengeStateService()
    ) -> Self {
        Self(
            evaluateChallengeState: { task, today in
                challengeStateService.evaluateChallengeState(for: task, today: today)
            }
        )
    }
}
