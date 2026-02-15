import Foundation
import ComposableArchitecture
import Domain
import Ports
import Workflows

typealias CreateNewTaskUseCase = Workflows.CreateNewTaskUseCase
typealias UpdateTaskSettingsUseCase = Workflows.UpdateTaskSettingsUseCase
typealias GlobalNotificationSettingUseCase = Workflows.GlobalNotificationSettingUseCase
typealias CertifyTaskTodayUseCase = Workflows.CertifyTaskTodayUseCase
typealias StageProgressionUseCase = Workflows.StageProgressionUseCase
typealias TaskQueryUseCase = Workflows.TaskQueryUseCase
typealias DeleteTaskUseCase = Workflows.DeleteTaskUseCase
typealias LoadImageUseCase = Workflows.LoadImageUseCase
typealias RequestNotificationPermissionUseCase = Workflows.RequestNotificationPermissionUseCase
typealias AppPreferencesUseCase = Workflows.AppPreferencesUseCase
typealias NotificationSettingQueryUseCase = Workflows.NotificationSettingQueryUseCase
typealias ActiveTaskServiceUseCase = Workflows.ActiveTaskServiceUseCase
typealias TaskStatusServiceUseCase = Workflows.TaskStatusServiceUseCase
typealias CalendarEventServiceUseCase = Workflows.CalendarEventServiceUseCase
typealias ChallengeStateServiceUseCase = Workflows.ChallengeStateServiceUseCase
typealias StageEvaluationServiceUseCase = Workflows.StageEvaluationServiceUseCase

private enum CreateNewTaskUseCaseKey: DependencyKey {
    static let liveValue: CreateNewTaskUseCase = {
        let taskRepository = DependencyAssembly.taskRepository
        let imageStore = DependencyAssembly.imageStore
        let userSettingsRepository = DependencyAssembly.userSettingsRepository
        let notificationScheduler = DependencyAssembly.notificationScheduler
        let reminderScheduling = ReminderSchedulingUseCase(
            notificationScheduler: notificationScheduler,
            userSettingsRepository: userSettingsRepository
        )
        return CreateNewTaskUseCase.live(
            taskRepository: taskRepository,
            imageStore: imageStore,
            reminderSchedulingUseCase: reminderScheduling
        )
    }()

    static let testValue = CreateNewTaskUseCase(
        execute: { input in
            let now = Date()
            return Task(
                id: TaskID(UUID()),
                title: input.title,
                startDate: now,
                endDate: now,
                stages: [],
                records: []
            )
        }
    )
}

private enum UpdateTaskSettingsUseCaseKey: DependencyKey {
    static let liveValue: UpdateTaskSettingsUseCase = {
        let taskRepository = DependencyAssembly.taskRepository
        let imageStore = DependencyAssembly.imageStore
        let userSettingsRepository = DependencyAssembly.userSettingsRepository
        let notificationScheduler = DependencyAssembly.notificationScheduler
        let reminderScheduling = ReminderSchedulingUseCase(
            notificationScheduler: notificationScheduler,
            userSettingsRepository: userSettingsRepository
        )
        return UpdateTaskSettingsUseCase.live(
            taskRepository: taskRepository,
            imageStore: imageStore,
            reminderSchedulingUseCase: reminderScheduling
        )
    }()

    static let testValue = UpdateTaskSettingsUseCase(
        execute: { _ in }
    )
}

private enum GlobalNotificationSettingUseCaseKey: DependencyKey {
    static let liveValue: GlobalNotificationSettingUseCase = {
        let userSettingsRepository = DependencyAssembly.userSettingsRepository
        let notificationScheduler = DependencyAssembly.notificationScheduler
        let reminderScheduling = ReminderSchedulingUseCase(
            notificationScheduler: notificationScheduler,
            userSettingsRepository: userSettingsRepository
        )
        return GlobalNotificationSettingUseCase.live(
            userSettingsRepository: userSettingsRepository,
            notificationScheduler: notificationScheduler,
            reminderSchedulingUseCase: reminderScheduling
        )
    }()

    static let testValue = GlobalNotificationSettingUseCase(
        setEnabled: { _ in .disabled }
    )
}

private enum CertifyTaskTodayUseCaseKey: DependencyKey {
    static let liveValue: CertifyTaskTodayUseCase = {
        let taskRepository = DependencyAssembly.taskRepository
        let imageStore = DependencyAssembly.imageStore
        return CertifyTaskTodayUseCase.live(
            taskRepository: taskRepository,
            imageStore: imageStore
        )
    }()

    static let testValue = CertifyTaskTodayUseCase(
        execute: { _ in }
    )
}

private enum StageProgressionUseCaseKey: DependencyKey {
    static let liveValue: StageProgressionUseCase = {
        StageProgressionUseCase(taskRepository: DependencyAssembly.taskRepository)
    }()

    static let testValue: StageProgressionUseCase = {
        StageProgressionUseCase(taskRepository: .init(
            fetchActiveTasks: { [] },
            fetchTask: { _ in nil },
            addTask: { _ in },
            updateTask: { _ in },
            deleteTask: { _ in },
            fetchTasksByStatus: { _ in [] }
        ))
    }()
}

private enum TaskQueryUseCaseKey: DependencyKey {
    static let liveValue: TaskQueryUseCase = {
        TaskQueryUseCase.live(taskRepository: DependencyAssembly.taskRepository)
    }()

    static let testValue = TaskQueryUseCase(
        fetchActiveTasks: { [] },
        fetchTasksByStatus: { _ in [] },
        fetchTask: { _ in nil }
    )
}

private enum DeleteTaskUseCaseKey: DependencyKey {
    static let liveValue: DeleteTaskUseCase = {
        DeleteTaskUseCase.live(
            taskRepository: DependencyAssembly.taskRepository,
            notificationScheduler: DependencyAssembly.notificationScheduler
        )
    }()

    static let testValue = DeleteTaskUseCase(
        execute: { _ in }
    )
}

private enum LoadImageUseCaseKey: DependencyKey {
    static let liveValue: LoadImageUseCase = {
        LoadImageUseCase.live(imageStore: DependencyAssembly.imageStore)
    }()

    static let testValue = LoadImageUseCase(
        loadImage: { _ in nil }
    )
}

private enum RequestNotificationPermissionUseCaseKey: DependencyKey {
    static let liveValue: RequestNotificationPermissionUseCase = {
        RequestNotificationPermissionUseCase.live(
            notificationScheduler: DependencyAssembly.notificationScheduler
        )
    }()

    static let testValue = RequestNotificationPermissionUseCase(
        requestAuthorization: { false }
    )
}

private enum AppPreferencesUseCaseKey: DependencyKey {
    static let liveValue: AppPreferencesUseCase = {
        AppPreferencesUseCase.live(appPreferences: DependencyAssembly.appPreferences)
    }()

    static let testValue: AppPreferencesUseCase = {
        AppPreferencesUseCase.live(appPreferences: .inMemory())
    }()
}

private enum NotificationSettingQueryUseCaseKey: DependencyKey {
    static let liveValue: NotificationSettingQueryUseCase = {
        NotificationSettingQueryUseCase.live(
            userSettingsRepository: DependencyAssembly.userSettingsRepository
        )
    }()

    static let testValue = NotificationSettingQueryUseCase(
        isNotificationEnabled: { false }
    )
}

private enum ActiveTaskServiceUseCaseKey: DependencyKey {
    static let liveValue: ActiveTaskServiceUseCase = {
        ActiveTaskServiceUseCase.live()
    }()

    static let testValue: ActiveTaskServiceUseCase = {
        ActiveTaskServiceUseCase.live()
    }()
}

private enum TaskStatusServiceUseCaseKey: DependencyKey {
    static let liveValue: TaskStatusServiceUseCase = {
        TaskStatusServiceUseCase.live()
    }()

    static let testValue: TaskStatusServiceUseCase = {
        TaskStatusServiceUseCase.live()
    }()
}

private enum CalendarEventServiceUseCaseKey: DependencyKey {
    static let liveValue: CalendarEventServiceUseCase = {
        CalendarEventServiceUseCase.live()
    }()

    static let testValue: CalendarEventServiceUseCase = {
        CalendarEventServiceUseCase.live()
    }()
}

private enum ChallengeStateServiceUseCaseKey: DependencyKey {
    static let liveValue: ChallengeStateServiceUseCase = {
        ChallengeStateServiceUseCase.live()
    }()

    static let testValue: ChallengeStateServiceUseCase = {
        ChallengeStateServiceUseCase.live()
    }()
}

private enum StageEvaluationServiceUseCaseKey: DependencyKey {
    static let liveValue: StageEvaluationServiceUseCase = {
        StageEvaluationServiceUseCase.live()
    }()

    static let testValue: StageEvaluationServiceUseCase = {
        StageEvaluationServiceUseCase.live()
    }()
}

extension DependencyValues {
    var createNewTaskUseCase: CreateNewTaskUseCase {
        get { self[CreateNewTaskUseCaseKey.self] }
        set { self[CreateNewTaskUseCaseKey.self] = newValue }
    }

    var updateTaskSettingsUseCase: UpdateTaskSettingsUseCase {
        get { self[UpdateTaskSettingsUseCaseKey.self] }
        set { self[UpdateTaskSettingsUseCaseKey.self] = newValue }
    }

    var globalNotificationSettingUseCase: GlobalNotificationSettingUseCase {
        get { self[GlobalNotificationSettingUseCaseKey.self] }
        set { self[GlobalNotificationSettingUseCaseKey.self] = newValue }
    }

    var certifyTaskTodayUseCase: CertifyTaskTodayUseCase {
        get { self[CertifyTaskTodayUseCaseKey.self] }
        set { self[CertifyTaskTodayUseCaseKey.self] = newValue }
    }

    var stageProgressionUseCase: StageProgressionUseCase {
        get { self[StageProgressionUseCaseKey.self] }
        set { self[StageProgressionUseCaseKey.self] = newValue }
    }

    var taskQueryUseCase: TaskQueryUseCase {
        get { self[TaskQueryUseCaseKey.self] }
        set { self[TaskQueryUseCaseKey.self] = newValue }
    }

    var deleteTaskUseCase: DeleteTaskUseCase {
        get { self[DeleteTaskUseCaseKey.self] }
        set { self[DeleteTaskUseCaseKey.self] = newValue }
    }

    var loadImageUseCase: LoadImageUseCase {
        get { self[LoadImageUseCaseKey.self] }
        set { self[LoadImageUseCaseKey.self] = newValue }
    }

    var requestNotificationPermissionUseCase: RequestNotificationPermissionUseCase {
        get { self[RequestNotificationPermissionUseCaseKey.self] }
        set { self[RequestNotificationPermissionUseCaseKey.self] = newValue }
    }

    var appPreferencesUseCase: AppPreferencesUseCase {
        get { self[AppPreferencesUseCaseKey.self] }
        set { self[AppPreferencesUseCaseKey.self] = newValue }
    }

    var notificationSettingQueryUseCase: NotificationSettingQueryUseCase {
        get { self[NotificationSettingQueryUseCaseKey.self] }
        set { self[NotificationSettingQueryUseCaseKey.self] = newValue }
    }

    var activeTaskServiceUseCase: ActiveTaskServiceUseCase {
        get { self[ActiveTaskServiceUseCaseKey.self] }
        set { self[ActiveTaskServiceUseCaseKey.self] = newValue }
    }

    var taskStatusServiceUseCase: TaskStatusServiceUseCase {
        get { self[TaskStatusServiceUseCaseKey.self] }
        set { self[TaskStatusServiceUseCaseKey.self] = newValue }
    }

    var calendarEventServiceUseCase: CalendarEventServiceUseCase {
        get { self[CalendarEventServiceUseCaseKey.self] }
        set { self[CalendarEventServiceUseCaseKey.self] = newValue }
    }

    var challengeStateServiceUseCase: ChallengeStateServiceUseCase {
        get { self[ChallengeStateServiceUseCaseKey.self] }
        set { self[ChallengeStateServiceUseCaseKey.self] = newValue }
    }

    var stageEvaluationServiceUseCase: StageEvaluationServiceUseCase {
        get { self[StageEvaluationServiceUseCaseKey.self] }
        set { self[StageEvaluationServiceUseCaseKey.self] = newValue }
    }
}
