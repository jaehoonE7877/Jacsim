import Foundation

public struct ActiveTaskService: Sendable {
    public struct TodayFocusSelection: Sendable, Equatable {
        public enum State: Sendable, Equatable {
            case empty
            case pending
            case completedStageReady
            case allDoneToday
        }

        public let state: State
        public let visibleTasks: [Task]
        public let focusTask: Task?
        public let secondaryTasks: [Task]
        public let pendingCount: Int
        public let completedTodayCount: Int

        public init(
            state: State,
            visibleTasks: [Task],
            focusTask: Task?,
            secondaryTasks: [Task],
            pendingCount: Int,
            completedTodayCount: Int
        ) {
            self.state = state
            self.visibleTasks = visibleTasks
            self.focusTask = focusTask
            self.secondaryTasks = secondaryTasks
            self.pendingCount = pendingCount
            self.completedTodayCount = completedTodayCount
        }
    }

    public init() {}
    
    public func filterActiveTasks(_ tasks: [Task], referenceDate: Date) -> [Task] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: referenceDate)

        return rankTasksForTodayFocus(
            tasks.filter { task in
                let start = calendar.startOfDay(for: task.startDate)
                let end = calendar.startOfDay(for: task.endDate)
                return start <= today && today <= end
            },
            referenceDate: today
        )
    }

    public func makeTodayFocusSelection(
        from tasks: [Task],
        referenceDate: Date
    ) -> TodayFocusSelection {
        let visibleTasks = filterActiveTasks(tasks, referenceDate: referenceDate)
        let pendingTasks = visibleTasks.filter { !$0.isCompleted(on: referenceDate) }
        let completedTasks = visibleTasks.filter { $0.isCompleted(on: referenceDate) }
        let completedTodayCount = completedTasks.count

        guard !visibleTasks.isEmpty else {
            return TodayFocusSelection(
                state: .empty,
                visibleTasks: [],
                focusTask: nil,
                secondaryTasks: [],
                pendingCount: 0,
                completedTodayCount: 0
            )
        }

        let focusTask: Task?
        let state: TodayFocusSelection.State
        if let pendingTask = pendingTasks.first {
            focusTask = pendingTask
            state = .pending
        } else if let completedStageReadyTask = completedTasks.first(where: { isCompletedStageReady($0) }) {
            focusTask = completedStageReadyTask
            state = .completedStageReady
        } else if let completedTask = completedTasks.first {
            focusTask = completedTask
            state = .allDoneToday
        } else {
            focusTask = visibleTasks.first
            state = .empty
        }

        return TodayFocusSelection(
            state: state,
            visibleTasks: visibleTasks,
            focusTask: focusTask,
            secondaryTasks: visibleTasks.filter { $0.id != focusTask?.id },
            pendingCount: pendingTasks.count,
            completedTodayCount: completedTodayCount
        )
    }

    public func rankTasksForTodayFocus(
        _ tasks: [Task],
        referenceDate: Date
    ) -> [Task] {
        let pendingTasks = tasks
            .filter { !$0.isCompleted(on: referenceDate) }
            .sorted { lhs, rhs in
                isHigherFocusPriority(lhs, than: rhs, referenceDate: referenceDate)
            }
        let completedTasks = tasks
            .filter { $0.isCompleted(on: referenceDate) }
            .sorted { lhs, rhs in
                isHigherCompletedPriority(lhs, than: rhs, referenceDate: referenceDate)
            }

        return pendingTasks + completedTasks
    }

    private func isHigherFocusPriority(
        _ lhs: Task,
        than rhs: Task,
        referenceDate: Date
    ) -> Bool {
        let lhsStageEnd = stageEndDate(for: lhs)
        let rhsStageEnd = stageEndDate(for: rhs)
        if lhsStageEnd != rhsStageEnd {
            return lhsStageEnd < rhsStageEnd
        }

        let lhsLastCompletedDate = lastCompletedDate(for: lhs) ?? .distantPast
        let rhsLastCompletedDate = lastCompletedDate(for: rhs) ?? .distantPast
        if lhsLastCompletedDate != rhsLastCompletedDate {
            return lhsLastCompletedDate < rhsLastCompletedDate
        }

        if lhs.startDate != rhs.startDate {
            return lhs.startDate < rhs.startDate
        }

        return lhs.title.localizedCompare(rhs.title) == .orderedAscending
    }

    private func isHigherCompletedPriority(
        _ lhs: Task,
        than rhs: Task,
        referenceDate: Date
    ) -> Bool {
        let lhsCompletedDate = lastCompletedDate(for: lhs) ?? .distantPast
        let rhsCompletedDate = lastCompletedDate(for: rhs) ?? .distantPast
        if lhsCompletedDate != rhsCompletedDate {
            return lhsCompletedDate > rhsCompletedDate
        }

        return isHigherFocusPriority(lhs, than: rhs, referenceDate: referenceDate)
    }

    private func stageEndDate(for task: Task) -> Date {
        task.currentStage?.endDate ?? task.endDate
    }

    private func isCompletedStageReady(_ task: Task) -> Bool {
        guard let lastStage = task.stages.last else { return false }
        return lastStage.result == .success && lastStage.stageType.next != nil
    }

    private func lastCompletedDate(for task: Task) -> Date? {
        task.records
            .filter(\.check)
            .map(\.date)
            .max()
    }
}
