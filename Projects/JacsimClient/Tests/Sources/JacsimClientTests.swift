import Foundation
import ComposableArchitecture
import Testing
import Domain
import Ports
import JacsimClient

@Test("DependencyAssembly가 appPreferences port를 노출한다")
func dependencyAssemblyExposesAppPreferencesPort() {
    let appPreferences = DependencyAssembly.appPreferences

    _ = appPreferences
    #expect(true)
}

@Test("DependencyAssembly가 핵심 포트를 모두 노출한다")
func dependencyAssemblyExposesAllPorts() {
    let taskRepository = DependencyAssembly.taskRepository
    let userSettingsRepository = DependencyAssembly.userSettingsRepository
    let notificationScheduler = DependencyAssembly.notificationScheduler
    let imageStore = DependencyAssembly.imageStore

    _ = taskRepository
    _ = userSettingsRepository
    _ = notificationScheduler
    _ = imageStore
    #expect(true)
}

@Test("DependencyValues가 포트와 query surface를 노출한다")
func dependencyValuesExposePortsAndUseCases() {
    var values = DependencyValues()
    values.taskRepository = TaskRepositoryPort(
        fetchActiveTasks: { [] },
        fetchTask: { _ in nil },
        addTask: { _ in },
        updateTask: { _ in },
        deleteTask: { _ in },
        fetchTasksByStatus: { _ in [] }
    )
    values.userSettingsRepository = UserSettingsRepositoryPort(
        isNotificationEnabled: { false },
        getAllReminders: { [] },
        updateNotificationEnabled: { _ in }
    )
    values.appPreferences = .inMemory()
    values.notificationScheduler = NotificationSchedulerPort(
        scheduleReminder: { _ in },
        cancelReminder: { _ in },
        cancelAllReminders: {},
        requestAuthorization: { false }
    )
    values.imageStore = ImageStorePort(
        saveImage: { _, _ in "" },
        loadImage: { _ in nil },
        deleteImage: { _ in },
        imageExists: { _ in false }
    )
    values.taskReadModelQueries = TaskReadModelQueries.live()
    values.createNewTaskUseCase = CreateNewTaskUseCase(execute: { _ in
        Task(
            id: TaskID(UUID()),
            title: "테스트",
            startDate: Date(),
            endDate: Date(),
            stages: [],
            records: []
        )
    })
    values.updateTaskSettingsUseCase = UpdateTaskSettingsUseCase(execute: { _ in })
    values.globalNotificationSettingUseCase = GlobalNotificationSettingUseCase(
        setEnabled: { _ in .disabled }
    )
    values.certifyTaskTodayUseCase = CertifyTaskTodayUseCase(execute: { _ in })
    values.stageProgressionUseCase = StageProgressionUseCase(
        taskRepository: .init(
            fetchActiveTasks: { [] },
            fetchTask: { _ in nil },
            addTask: { _ in },
            updateTask: { _ in },
            deleteTask: { _ in },
            fetchTasksByStatus: { _ in [] }
        )
    )
    values.deleteTaskUseCase = DeleteTaskUseCase(execute: { _ in })
    values.reminderSchedulingUseCase = ReminderSchedulingUseCase(
        notificationScheduler: .init(
            scheduleReminder: { _ in },
            cancelReminder: { _ in },
            cancelAllReminders: { },
            requestAuthorization: { false }
        ),
        userSettingsRepository: .init(
            isNotificationEnabled: { false },
            getAllReminders: { [] },
            updateNotificationEnabled: { _ in }
        ),
        taskRepository: .init(
            fetchActiveTasks: { [] },
            fetchTask: { _ in nil },
            addTask: { _ in },
            updateTask: { _ in },
            deleteTask: { _ in },
            fetchTasksByStatus: { _ in [] }
        )
    )

    _ = values.taskRepository
    _ = values.userSettingsRepository
    _ = values.appPreferences
    _ = values.notificationScheduler
    _ = values.imageStore
    _ = values.taskReadModelQueries
    _ = values.createNewTaskUseCase
    _ = values.updateTaskSettingsUseCase
    _ = values.globalNotificationSettingUseCase
    _ = values.certifyTaskTodayUseCase
    _ = values.stageProgressionUseCase
    _ = values.deleteTaskUseCase
    _ = values.reminderSchedulingUseCase
    #expect(true)
}

@Test("UseCaseAssembly가 command usecase를 노출한다")
func useCaseAssemblyExposesWorkflowUseCases() {
    _ = UseCaseAssembly.createNewTaskUseCase
    _ = UseCaseAssembly.updateTaskSettingsUseCase
    _ = UseCaseAssembly.globalNotificationSettingUseCase
    _ = UseCaseAssembly.certifyTaskTodayUseCase
    _ = UseCaseAssembly.stageProgressionUseCase
    _ = UseCaseAssembly.deleteTaskUseCase
    _ = UseCaseAssembly.reminderSchedulingUseCase
    #expect(true)
}
