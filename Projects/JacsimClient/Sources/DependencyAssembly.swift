import Adapters
import Ports

public enum DependencyAssembly {
    private static let taskRepositoryAdapter = SwiftDataTaskRepositoryAdapter()
    private static let userSettingsRepositoryAdapter = UserSettingsRepositoryAdapter()
    private static let notificationSchedulerAdapter = LocalNotificationSchedulerAdapter()
    private static let imageStoreAdapter = DocumentImageStoreAdapter()
    private static let appPreferencesAdapter = UserDefaultsAppPreferencesAdapter()

    public static let taskRepository: TaskRepositoryPort = TaskRepositoryPort(
        fetchActiveTasks: { try await taskRepositoryAdapter.fetchActiveTasks() },
        fetchTask: { try await taskRepositoryAdapter.fetchTask(id: $0) },
        addTask: { try await taskRepositoryAdapter.addTask($0) },
        updateTask: { try await taskRepositoryAdapter.updateTask($0) },
        deleteTask: { try await taskRepositoryAdapter.deleteTask(id: $0) },
        fetchTasksByStatus: { try await taskRepositoryAdapter.fetchTasksByStatus($0) }
    )

    public static let userSettingsRepository: UserSettingsRepositoryPort = UserSettingsRepositoryPort(
        isNotificationEnabled: { await userSettingsRepositoryAdapter.isNotificationEnabled() },
        getAllReminders: { await userSettingsRepositoryAdapter.getAllReminders() },
        updateNotificationEnabled: { await userSettingsRepositoryAdapter.updateNotificationEnabled($0) }
    )

    public static let notificationScheduler: NotificationSchedulerPort = NotificationSchedulerPort(
        scheduleReminder: { try await notificationSchedulerAdapter.scheduleReminder(request: $0) },
        cancelReminder: { await notificationSchedulerAdapter.cancelReminder(taskId: $0) },
        cancelAllReminders: { await notificationSchedulerAdapter.cancelAllReminders() },
        requestAuthorization: { try await notificationSchedulerAdapter.requestAuthorization() }
    )

    public static let imageStore: ImageStorePort = ImageStorePort(
        saveImage: { try await imageStoreAdapter.saveImage(key: $0, data: $1) },
        loadImage: { await imageStoreAdapter.loadImage(key: $0) },
        deleteImage: { await imageStoreAdapter.deleteImage(key: $0) },
        imageExists: { await imageStoreAdapter.imageExists(key: $0) }
    )

    public static let appPreferences: AppPreferencesPort = appPreferencesAdapter.makePort()
}
