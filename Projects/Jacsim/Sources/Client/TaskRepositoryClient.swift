import ComposableArchitecture
import ExternalInterface
import Data

private enum TaskRepositoryKey: DependencyKey {
    static let liveValue: TaskRepositoryPort = {
        let adapter = SwiftDataTaskRepositoryAdapter()
        return TaskRepositoryPort(
            fetchActiveTasks: { await adapter.fetchActiveTasks() },
            fetchTask: { await adapter.fetchTask(id: $0) },
            addTask: { try await adapter.addTask($0) },
            updateTask: { try await adapter.updateTask($0) },
            deleteTask: { try await adapter.deleteTask(id: $0) },
            fetchTasksByStatus: { await adapter.fetchTasksByStatus($0) }
        )
    }()
    
    static let testValue = TaskRepositoryPort(
        fetchActiveTasks: { [] },
        fetchTask: { _ in nil },
        addTask: { _ in },
        updateTask: { _ in },
        deleteTask: { _ in },
        fetchTasksByStatus: { _ in [] }
    )
}

extension DependencyValues {
    var taskRepository: TaskRepositoryPort {
        get { self[TaskRepositoryKey.self] }
        set { self[TaskRepositoryKey.self] = newValue }
    }
}
