import Domain

public struct AllTaskSummaryUseCase: Sendable {
    public struct Input: Sendable, Equatable {
        public let ongoingTasks: [Task]
        public let doneTasks: [Task]

        public init(ongoingTasks: [Task], doneTasks: [Task]) {
            self.ongoingTasks = ongoingTasks
            self.doneTasks = doneTasks
        }
    }

    public struct Output: Sendable, Equatable {
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

    public var execute: @Sendable (Input) -> Output

    public init(execute: @escaping @Sendable (Input) -> Output) {
        self.execute = execute
    }
}

extension AllTaskSummaryUseCase {
    public static func live(
        taskStatusService: TaskStatusService = TaskStatusService()
    ) -> Self {
        Self(
            execute: { input in
                Output(
                    ongoingTasks: input.ongoingTasks,
                    successTasks: taskStatusService.filterSuccessTasks(input.doneTasks),
                    failTasks: taskStatusService.filterFailTasks(input.doneTasks)
                )
            }
        )
    }
}
