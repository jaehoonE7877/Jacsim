import Foundation
import Domain

public struct TaskDetailSummaryUseCase: Sendable {
    public struct Input: Sendable, Equatable {
        public let task: Task
        public let referenceDate: Date

        public init(task: Task, referenceDate: Date) {
            self.task = task
            self.referenceDate = referenceDate
        }
    }

    public struct Output: Sendable, Equatable {
        public let challengeState: ChallengeDetailState
        public let todayStatus: TodayStatus
        public let currentStage: StageSnapshot?
        public let stageProgress: Double
        public let stageProgressText: String
        public let remainingSuccessCount: Int
        public let todayMemo: String
        public let dayViewData: [DayViewData]
        public let stageResult: StageResult

        public init(
            challengeState: ChallengeDetailState,
            todayStatus: TodayStatus,
            currentStage: StageSnapshot?,
            stageProgress: Double,
            stageProgressText: String,
            remainingSuccessCount: Int,
            todayMemo: String,
            dayViewData: [DayViewData],
            stageResult: StageResult
        ) {
            self.challengeState = challengeState
            self.todayStatus = todayStatus
            self.currentStage = currentStage
            self.stageProgress = stageProgress
            self.stageProgressText = stageProgressText
            self.remainingSuccessCount = remainingSuccessCount
            self.todayMemo = todayMemo
            self.dayViewData = dayViewData
            self.stageResult = stageResult
        }
    }

    public var execute: @Sendable (Input) -> Output

    public init(execute: @escaping @Sendable (Input) -> Output) {
        self.execute = execute
    }
}

extension TaskDetailSummaryUseCase {
    public static func live(
        challengeStateService: ChallengeStateService = ChallengeStateService(),
        stageEvaluationService: StageEvaluationService = StageEvaluationService()
    ) -> Self {
        Self(
            execute: { input in
                let evaluation = challengeStateService.evaluateChallengeState(
                    for: input.task,
                    today: input.referenceDate
                )

                let stageResult: StageResult
                if let stage = evaluation.currentStage {
                    stageResult = stageEvaluationService.evaluateStage(
                        endDate: stage.endDate,
                        durationDays: stage.durationDays,
                        successDays: stage.successDays,
                        now: input.referenceDate
                    )
                } else {
                    stageResult = .inProgress
                }

                return Output(
                    challengeState: evaluation.challengeState,
                    todayStatus: evaluation.todayStatus,
                    currentStage: evaluation.currentStage,
                    stageProgress: evaluation.stageProgress,
                    stageProgressText: evaluation.stageProgressText,
                    remainingSuccessCount: evaluation.remainingSuccessCount,
                    todayMemo: evaluation.todayMemo,
                    dayViewData: evaluation.dayViewData,
                    stageResult: stageResult
                )
            }
        )
    }
}
