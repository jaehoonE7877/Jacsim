import Foundation
import Domain

public struct HomeSummaryUseCase: Sendable {
    public struct Input: Sendable, Equatable {
        public let tasks: [Task]
        public let referenceDate: Date

        public init(tasks: [Task], referenceDate: Date) {
            self.tasks = tasks
            self.referenceDate = referenceDate
        }
    }

    public enum TodayFocusState: Sendable, Equatable {
        case empty
        case pending
        case completedStageReady
        case allDoneToday
    }

    public struct SecondaryTaskSummary: Sendable, Equatable {
        public let taskID: TaskID
        public let title: String
        public let progress: Double
        public let totalDays: Int
        public let completedDays: Int
        public let isTodayCertified: Bool

        public init(
            taskID: TaskID,
            title: String,
            progress: Double,
            totalDays: Int,
            completedDays: Int,
            isTodayCertified: Bool
        ) {
            self.taskID = taskID
            self.title = title
            self.progress = progress
            self.totalDays = totalDays
            self.completedDays = completedDays
            self.isTodayCertified = isTodayCertified
        }
    }

    public struct Output: Sendable, Equatable {
        public let visibleTasks: [Task]
        public let focusTask: Task?
        public let secondaryTasks: [Task]
        public let todayFocusState: TodayFocusState
        public let pendingCount: Int
        public let completedTodayCount: Int
        public let secondaryTaskSummaries: [SecondaryTaskSummary]

        public init(
            visibleTasks: [Task],
            focusTask: Task?,
            secondaryTasks: [Task],
            todayFocusState: TodayFocusState,
            pendingCount: Int,
            completedTodayCount: Int,
            secondaryTaskSummaries: [SecondaryTaskSummary]
        ) {
            self.visibleTasks = visibleTasks
            self.focusTask = focusTask
            self.secondaryTasks = secondaryTasks
            self.todayFocusState = todayFocusState
            self.pendingCount = pendingCount
            self.completedTodayCount = completedTodayCount
            self.secondaryTaskSummaries = secondaryTaskSummaries
        }
    }

    public var execute: @Sendable (Input) -> Output

    public init(execute: @escaping @Sendable (Input) -> Output) {
        self.execute = execute
    }
}

extension HomeSummaryUseCase {
    public static func live(
        activeTaskService: ActiveTaskService = ActiveTaskService()
    ) -> Self {
        Self(
            execute: { input in
                let focusSelection = activeTaskService.makeTodayFocusSelection(
                    from: input.tasks,
                    referenceDate: input.referenceDate
                )

                let todayFocusState = switch focusSelection.state {
                case .empty: TodayFocusState.empty
                case .pending: TodayFocusState.pending
                case .completedStageReady: TodayFocusState.completedStageReady
                case .allDoneToday: TodayFocusState.allDoneToday
                }

                let secondaryTaskSummaries = focusSelection.secondaryTasks.map { task in
                    let completedDays = task.records.filter(\.check).count
                    let totalDays = task.dayArray.count
                    let progress = totalDays > 0 ? Double(completedDays) / Double(totalDays) : 0

                    return SecondaryTaskSummary(
                        taskID: task.id,
                        title: task.title,
                        progress: progress,
                        totalDays: totalDays,
                        completedDays: completedDays,
                        isTodayCertified: task.isCompleted(on: input.referenceDate)
                    )
                }

                return Output(
                    visibleTasks: focusSelection.visibleTasks,
                    focusTask: focusSelection.focusTask,
                    secondaryTasks: focusSelection.secondaryTasks,
                    todayFocusState: todayFocusState,
                    pendingCount: focusSelection.pendingCount,
                    completedTodayCount: focusSelection.completedTodayCount,
                    secondaryTaskSummaries: secondaryTaskSummaries
                )
            }
        )
    }
}
