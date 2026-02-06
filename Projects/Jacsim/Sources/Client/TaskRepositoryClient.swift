import ComposableArchitecture
import ExternalInterface
import Domain
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

private enum UserSettingsRepositoryKey: DependencyKey {
    static let liveValue: UserSettingsRepositoryPort = {
        let adapter = UserSettingsRepositoryAdapter()
        return UserSettingsRepositoryPort(
            isNotificationEnabled: { await adapter.isNotificationEnabled() },
            getAllReminders: { await adapter.getAllReminders() },
            updateNotificationEnabled: { await adapter.updateNotificationEnabled($0) }
        )
    }()

    static let testValue = UserSettingsRepositoryPort(
        isNotificationEnabled: { false },
        getAllReminders: { [] },
        updateNotificationEnabled: { _ in }
    )
}

private enum ActiveTaskServiceKey: DependencyKey {
    static let liveValue: ActiveTaskService = ActiveTaskService()
    static let testValue: ActiveTaskService = ActiveTaskService()
}

private enum CalendarEventServiceKey: DependencyKey {
    static let liveValue: CalendarEventService = CalendarEventService()
    static let testValue: CalendarEventService = CalendarEventService()
}

private enum ChallengeStateServiceKey: DependencyKey {
    static let liveValue: ChallengeStateService = ChallengeStateService()
    static let testValue: ChallengeStateService = ChallengeStateService()
}

extension DependencyValues {
    var taskRepository: TaskRepositoryPort {
        get { self[TaskRepositoryKey.self] }
        set { self[TaskRepositoryKey.self] = newValue }
    }

    var userSettingsRepository: UserSettingsRepositoryPort {
        get { self[UserSettingsRepositoryKey.self] }
        set { self[UserSettingsRepositoryKey.self] = newValue }
    }

    var activeTaskService: ActiveTaskService {
        get { self[ActiveTaskServiceKey.self] }
        set { self[ActiveTaskServiceKey.self] = newValue }
    }

    var calendarEventService: CalendarEventService {
        get { self[CalendarEventServiceKey.self] }
        set { self[CalendarEventServiceKey.self] = newValue }
    }

    var challengeStateService: ChallengeStateService {
        get { self[ChallengeStateServiceKey.self] }
        set { self[ChallengeStateServiceKey.self] = newValue }
    }
}
