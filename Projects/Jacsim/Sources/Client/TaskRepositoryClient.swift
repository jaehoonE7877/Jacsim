import ComposableArchitecture
import Ports
import Domain

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

private enum UserSettingsRepositoryKey: DependencyKey {
    static let liveValue: UserSettingsRepositoryPort = DependencyAssembly.userSettingsRepository

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

private enum TaskStatusServiceKey: DependencyKey {
    static let liveValue: TaskStatusService = TaskStatusService()
    static let testValue: TaskStatusService = TaskStatusService()
}

private enum StageEvaluationServiceKey: DependencyKey {
    static let liveValue: StageEvaluationService = StageEvaluationService()
    static let testValue: StageEvaluationService = StageEvaluationService()
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

    var taskStatusService: TaskStatusService {
        get { self[TaskStatusServiceKey.self] }
        set { self[TaskStatusServiceKey.self] = newValue }
    }

    var stageEvaluationService: StageEvaluationService {
        get { self[StageEvaluationServiceKey.self] }
        set { self[StageEvaluationServiceKey.self] = newValue }
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
