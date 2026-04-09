import Foundation
import Domain

public struct AllTaskSections: Sendable, Equatable {
    public let ongoingTasks: [Task]
    public let successTasks: [Task]
    public let failTasks: [Task]

    public init(
        ongoingTasks: [Task],
        successTasks: [Task],
        failTasks: [Task]
    ) {
        self.ongoingTasks = ongoingTasks
        self.successTasks = successTasks
        self.failTasks = failTasks
    }
}

public struct CalendarSummary: Sendable, Equatable {
    public let eventDates: [Date]
    public let dateColors: [Date: TaskSuccessRate]

    public init(
        eventDates: [Date],
        dateColors: [Date: TaskSuccessRate]
    ) {
        self.eventDates = eventDates
        self.dateColors = dateColors
    }
}

public struct TaskDetailSummary: Sendable, Equatable {
    public let evaluation: ChallengeStateEvaluation
    public let stageResult: StageResult

    public init(
        evaluation: ChallengeStateEvaluation,
        stageResult: StageResult
    ) {
        self.evaluation = evaluation
        self.stageResult = stageResult
    }
}

public struct TaskReadModelQueries: Sendable {
    private let activeTaskService: ActiveTaskService
    private let taskStatusService: TaskStatusService
    private let calendarEventService: CalendarEventService
    private let challengeStateService: ChallengeStateService
    private let stageEvaluationService: StageEvaluationService

    public init(
        activeTaskService: ActiveTaskService = ActiveTaskService(),
        taskStatusService: TaskStatusService = TaskStatusService(),
        calendarEventService: CalendarEventService = CalendarEventService(),
        challengeStateService: ChallengeStateService = ChallengeStateService(),
        stageEvaluationService: StageEvaluationService = StageEvaluationService()
    ) {
        self.activeTaskService = activeTaskService
        self.taskStatusService = taskStatusService
        self.calendarEventService = calendarEventService
        self.challengeStateService = challengeStateService
        self.stageEvaluationService = stageEvaluationService
    }

    public static func live(
        activeTaskService: ActiveTaskService = ActiveTaskService(),
        taskStatusService: TaskStatusService = TaskStatusService(),
        calendarEventService: CalendarEventService = CalendarEventService(),
        challengeStateService: ChallengeStateService = ChallengeStateService(),
        stageEvaluationService: StageEvaluationService = StageEvaluationService()
    ) -> Self {
        Self(
            activeTaskService: activeTaskService,
            taskStatusService: taskStatusService,
            calendarEventService: calendarEventService,
            challengeStateService: challengeStateService,
            stageEvaluationService: stageEvaluationService
        )
    }

    public func home(
        tasks: [Task],
        referenceDate: Date
    ) -> ActiveTaskService.TodayFocusSelection {
        activeTaskService.makeTodayFocusSelection(
            from: tasks,
            referenceDate: referenceDate
        )
    }

    public func allTasks(
        ongoingTasks: [Task],
        doneTasks: [Task]
    ) -> AllTaskSections {
        AllTaskSections(
            ongoingTasks: ongoingTasks,
            successTasks: taskStatusService.filterSuccessTasks(doneTasks),
            failTasks: taskStatusService.filterFailTasks(doneTasks)
        )
    }

    public func calendar(tasks: [Task]) -> CalendarSummary {
        CalendarSummary(
            eventDates: calendarEventService.calculateEventDates(from: tasks),
            dateColors: calendarEventService.calculateDateColors(from: tasks)
        )
    }

    public func taskDetail(
        task: Task,
        referenceDate: Date
    ) -> TaskDetailSummary {
        let evaluation = challengeStateService.evaluateChallengeState(
            for: task,
            today: referenceDate
        )

        let stageResult: StageResult
        if let stage = evaluation.currentStage {
            stageResult = stageEvaluationService.evaluateStage(
                endDate: stage.endDate,
                durationDays: stage.durationDays,
                successDays: stage.successDays,
                now: referenceDate
            )
        } else {
            stageResult = .inProgress
        }

        return TaskDetailSummary(
            evaluation: evaluation,
            stageResult: stageResult
        )
    }
}
