import Workflows

public enum UseCaseAssembly {
    public static let createNewTaskUseCase: CreateNewTaskUseCase = {
        CreateNewTaskUseCase.live(
            taskRepository: DependencyAssembly.taskRepository,
            imageStore: DependencyAssembly.imageStore,
            reminderSchedulingUseCase: reminderSchedulingUseCase
        )
    }()

    public static let updateTaskSettingsUseCase: UpdateTaskSettingsUseCase = {
        UpdateTaskSettingsUseCase.live(
            taskRepository: DependencyAssembly.taskRepository,
            imageStore: DependencyAssembly.imageStore,
            reminderSchedulingUseCase: reminderSchedulingUseCase
        )
    }()

    public static let globalNotificationSettingUseCase: GlobalNotificationSettingUseCase = {
        GlobalNotificationSettingUseCase.live(
            userSettingsRepository: DependencyAssembly.userSettingsRepository,
            notificationScheduler: DependencyAssembly.notificationScheduler,
            reminderSchedulingUseCase: reminderSchedulingUseCase
        )
    }()

    public static let certifyTaskTodayUseCase: CertifyTaskTodayUseCase = {
        CertifyTaskTodayUseCase.live(
            taskRepository: DependencyAssembly.taskRepository,
            imageStore: DependencyAssembly.imageStore,
            reminderSchedulingUseCase: reminderSchedulingUseCase
        )
    }()

    public static let stageProgressionUseCase: StageProgressionUseCase = {
        StageProgressionUseCase(
            taskRepository: DependencyAssembly.taskRepository,
            reminderSchedulingUseCase: reminderSchedulingUseCase
        )
    }()

    public static let deleteTaskUseCase: DeleteTaskUseCase = {
        DeleteTaskUseCase.live(
            taskRepository: DependencyAssembly.taskRepository,
            reminderSchedulingUseCase: reminderSchedulingUseCase
        )
    }()

    public static let reminderSchedulingUseCase = ReminderSchedulingUseCase(
        notificationScheduler: DependencyAssembly.notificationScheduler,
        userSettingsRepository: DependencyAssembly.userSettingsRepository,
        taskRepository: DependencyAssembly.taskRepository
    )
}
