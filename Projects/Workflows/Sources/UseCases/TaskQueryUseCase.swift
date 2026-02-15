import Domain
import Ports

public struct TaskQueryUseCase: Sendable {
    public var fetchActiveTasks: @Sendable () async throws -> [Task]
    public var fetchTasksByStatus: @Sendable (ChallengeStatus) async throws -> [Task]
    public var fetchTask: @Sendable (TaskID) async throws -> Task?

    public init(
        fetchActiveTasks: @escaping @Sendable () async throws -> [Task],
        fetchTasksByStatus: @escaping @Sendable (ChallengeStatus) async throws -> [Task],
        fetchTask: @escaping @Sendable (TaskID) async throws -> Task?
    ) {
        self.fetchActiveTasks = fetchActiveTasks
        self.fetchTasksByStatus = fetchTasksByStatus
        self.fetchTask = fetchTask
    }
}

extension TaskQueryUseCase {
    public static func live(taskRepository: TaskRepositoryPort) -> Self {
        Self(
            fetchActiveTasks: {
                try await taskRepository.fetchActiveTasks()
            },
            fetchTasksByStatus: { status in
                try await taskRepository.fetchTasksByStatus(status)
            },
            fetchTask: { taskID in
                try await taskRepository.fetchTask(taskID)
            }
        )
    }
}
