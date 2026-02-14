import Data
import Domain
import ExternalInterface
import Foundation

enum DependencyAssembly {
    private static let taskRepositoryAdapter = SwiftDataTaskRepositoryAdapter()
    private static let userSettingsRepositoryAdapter = UserSettingsRepositoryAdapter()
    private static let notificationSchedulerAdapter = LocalNotificationSchedulerAdapter()
    private static let imageStoreAdapter = DocumentImageStoreAdapter()
    private static let appPreferencesAdapter = UserDefaultsAppPreferencesAdapter()

    static let taskRepository: TaskRepositoryPort = TaskRepositoryPort(
        fetchActiveTasks: { await taskRepositoryAdapter.fetchActiveTasks() },
        fetchTask: { await taskRepositoryAdapter.fetchTask(id: $0) },
        addTask: { try await taskRepositoryAdapter.addTask($0) },
        updateTask: { try await taskRepositoryAdapter.updateTask($0) },
        deleteTask: { try await taskRepositoryAdapter.deleteTask(id: $0) },
        fetchTasksByStatus: { await taskRepositoryAdapter.fetchTasksByStatus($0) }
    )

    static let userSettingsRepository: UserSettingsRepositoryPort = UserSettingsRepositoryPort(
        isNotificationEnabled: { await userSettingsRepositoryAdapter.isNotificationEnabled() },
        getAllReminders: { await userSettingsRepositoryAdapter.getAllReminders() },
        updateNotificationEnabled: { await userSettingsRepositoryAdapter.updateNotificationEnabled($0) }
    )

    static let notificationScheduler: NotificationSchedulerPort = NotificationSchedulerPort(
        scheduleDailyReminder: { try await notificationSchedulerAdapter.scheduleReminder(taskId: $0, title: $1, time: $2) },
        cancelReminder: { await notificationSchedulerAdapter.cancelReminder(taskId: $0) },
        cancelAllReminders: { await notificationSchedulerAdapter.cancelAllReminders() },
        requestAuthorization: { try await notificationSchedulerAdapter.requestAuthorization() }
    )

    static let imageStore: ImageStorePort = ImageStorePort(
        saveImage: { try await imageStoreAdapter.saveImage(key: $0, data: $1) },
        loadImage: { await imageStoreAdapter.loadImage(key: $0) },
        deleteImage: { await imageStoreAdapter.deleteImage(key: $0) },
        imageExists: { await imageStoreAdapter.imageExists(key: $0) }
    )

    static let appPreferences: AppPreferencesPort = appPreferencesAdapter.makePort()
}
