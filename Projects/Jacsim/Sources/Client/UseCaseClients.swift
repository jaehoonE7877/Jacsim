import Foundation
import ComposableArchitecture
import Domain
import ExternalInterface

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
}
