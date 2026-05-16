import Foundation

public struct ActiveTaskService: Sendable {
    public init() {}
    
    public func filterActiveTasks(_ tasks: [Task], referenceDate: Date) -> [Task] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: referenceDate)

        return tasks
            .filter { isHomeVisible($0, today: today, calendar: calendar) }
            .sorted { lhs, rhs in
                let lhsPriority = focusPriority(for: lhs, today: today, calendar: calendar)
                let rhsPriority = focusPriority(for: rhs, today: today, calendar: calendar)
                if lhsPriority != rhsPriority {
                    return lhsPriority < rhsPriority
                }

                let lhsEnd = calendar.startOfDay(for: focusEndDate(for: lhs))
                let rhsEnd = calendar.startOfDay(for: focusEndDate(for: rhs))
                if lhsEnd != rhsEnd {
                    return lhsEnd < rhsEnd
                }

                return lhs.createdAt > rhs.createdAt
            }
    }

    private func isHomeVisible(_ task: Task, today: Date, calendar: Calendar) -> Bool {
        guard !task.isDeleted else { return false }

        let stage = task.stages.last
        let start = calendar.startOfDay(for: stage?.startDate ?? task.startDate)
        let end = calendar.startOfDay(for: stage?.endDate ?? task.endDate)

        guard today >= start else { return false }

        switch stage?.result ?? .inProgress {
        case .inProgress:
            return today <= end
        case .success:
            return stage?.stageType.next != nil
        case .fail:
            return true
        }
    }

    private func focusPriority(for task: Task, today: Date, calendar: Calendar) -> Int {
        let stage = task.stages.last
        let start = calendar.startOfDay(for: stage?.startDate ?? task.startDate)
        let end = calendar.startOfDay(for: stage?.endDate ?? task.endDate)
        let isTodayInStage = today >= start && today <= end

        switch stage?.result ?? .inProgress {
        case .inProgress where isTodayInStage && !task.isCompleted(on: today):
            return 0
        case .success where stage?.stageType.next != nil:
            return 1
        case .inProgress:
            return 2
        case .fail:
            return 3
        case .success:
            return 4
        }
    }

    private func focusEndDate(for task: Task) -> Date {
        task.stages.last?.endDate ?? task.endDate
    }
}
