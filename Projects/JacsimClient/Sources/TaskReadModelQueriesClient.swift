import ComposableArchitecture
import Workflows

public typealias TaskReadModelQueries = Workflows.TaskReadModelQueries

private enum TaskReadModelQueriesKey: DependencyKey {
    static let liveValue = TaskReadModelQueries.live()

    static let testValue = TaskReadModelQueries.live()
}

public extension DependencyValues {
    var taskReadModelQueries: TaskReadModelQueries {
        get { self[TaskReadModelQueriesKey.self] }
        set { self[TaskReadModelQueriesKey.self] = newValue }
    }
}
