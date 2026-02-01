import enum Domain.ChallengeStatus
import struct Domain.Task
import struct Domain.TaskID

public struct TaskRepositoryPort: Sendable {
    public var fetchActiveTasks: @Sendable () async throws -> [Task]
    public var fetchTask: @Sendable (TaskID) async throws -> Task?
    public var addTask: @Sendable (Task) async throws -> Void
    public var updateTask: @Sendable (Task) async throws -> Void
    public var deleteTask: @Sendable (TaskID) async throws -> Void
    public var fetchTasksByStatus: @Sendable (ChallengeStatus) async throws -> [Task]

    public init(
        fetchActiveTasks: @escaping @Sendable () async throws -> [Task],
        fetchTask: @escaping @Sendable (TaskID) async throws -> Task?,
        addTask: @escaping @Sendable (Task) async throws -> Void,
        updateTask: @escaping @Sendable (Task) async throws -> Void,
        deleteTask: @escaping @Sendable (TaskID) async throws -> Void,
        fetchTasksByStatus: @escaping @Sendable (ChallengeStatus) async throws -> [Task]
    ) {
        self.fetchActiveTasks = fetchActiveTasks
        self.fetchTask = fetchTask
        self.addTask = addTask
        self.updateTask = updateTask
        self.deleteTask = deleteTask
        self.fetchTasksByStatus = fetchTasksByStatus
    }
}
