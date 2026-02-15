import Foundation
import Domain

public struct ActiveTaskServiceUseCase: Sendable {
    public var filterActiveTasks: @Sendable ([Task], Date) -> [Task]

    public init(filterActiveTasks: @escaping @Sendable ([Task], Date) -> [Task]) {
        self.filterActiveTasks = filterActiveTasks
    }
}

extension ActiveTaskServiceUseCase {
    public static func live(
        activeTaskService: ActiveTaskService = ActiveTaskService()
    ) -> Self {
        Self(
            filterActiveTasks: { tasks, referenceDate in
                activeTaskService.filterActiveTasks(tasks, referenceDate: referenceDate)
            }
        )
    }
}
