import ComposableArchitecture
import Ports

private enum TaskRepositoryKey: DependencyKey {
    static let liveValue: TaskRepositoryPort = DependencyAssembly.taskRepository

    static let testValue = TaskRepositoryPort(
        fetchActiveTasks: { [] },
        fetchTask: { _ in nil },
        addTask: { _ in },
        updateTask: { _ in },
        deleteTask: { _ in },
        fetchTasksByStatus: { _ in [] }
    )
}

public extension DependencyValues {
    var taskRepository: TaskRepositoryPort {
        get { self[TaskRepositoryKey.self] }
        set { self[TaskRepositoryKey.self] = newValue }
    }
}
