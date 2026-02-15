import Domain

public struct TaskStatusServiceUseCase: Sendable {
    public var filterSuccessTasks: @Sendable ([Task]) -> [Task]
    public var filterFailTasks: @Sendable ([Task]) -> [Task]

    public init(
        filterSuccessTasks: @escaping @Sendable ([Task]) -> [Task],
        filterFailTasks: @escaping @Sendable ([Task]) -> [Task]
    ) {
        self.filterSuccessTasks = filterSuccessTasks
        self.filterFailTasks = filterFailTasks
    }
}

extension TaskStatusServiceUseCase {
    public static func live(
        taskStatusService: TaskStatusService = TaskStatusService()
    ) -> Self {
        Self(
            filterSuccessTasks: { tasks in
                taskStatusService.filterSuccessTasks(tasks)
            },
            filterFailTasks: { tasks in
                taskStatusService.filterFailTasks(tasks)
            }
        )
    }
}
