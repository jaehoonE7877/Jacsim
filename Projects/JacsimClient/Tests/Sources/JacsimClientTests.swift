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

@Test("DependencyValues가 포트와 workflow usecase를 노출한다")
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
    values.requestNotificationPermissionUseCase = RequestNotificationPermissionUseCase(
        requestAuthorization: { false }
    )
    values.homeSummaryUseCase = HomeSummaryUseCase.live()
    values.allTaskSummaryUseCase = AllTaskSummaryUseCase.live()
    values.calendarSummaryUseCase = CalendarSummaryUseCase.live()
    values.taskDetailSummaryUseCase = TaskDetailSummaryUseCase.live()

    _ = values.taskRepository
    _ = values.userSettingsRepository
    _ = values.appPreferences
    _ = values.notificationScheduler
    _ = values.imageStore
    _ = values.createNewTaskUseCase
    _ = values.requestNotificationPermissionUseCase
    _ = values.homeSummaryUseCase
    _ = values.allTaskSummaryUseCase
    _ = values.calendarSummaryUseCase
    _ = values.taskDetailSummaryUseCase
    #expect(true)
}

@Test("UseCaseAssembly가 앱 외부에서 필요한 workflow usecase를 노출한다")
func useCaseAssemblyExposesWorkflowUseCases() {
    _ = UseCaseAssembly.requestNotificationPermissionUseCase
    _ = UseCaseAssembly.homeSummaryUseCase
    _ = UseCaseAssembly.allTaskSummaryUseCase
    _ = UseCaseAssembly.calendarSummaryUseCase
    _ = UseCaseAssembly.taskDetailSummaryUseCase
    #expect(true)
}
