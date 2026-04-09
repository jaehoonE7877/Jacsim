import Adapters
import Ports

public enum DependencyAssembly {
    private static let taskRepositoryAdapter = SwiftDataTaskRepositoryAdapter()
    private static let userSettingsRepositoryAdapter = UserSettingsRepositoryAdapter()
    private static let notificationSchedulerAdapter = LocalNotificationSchedulerAdapter()
    private static let imageStoreAdapter = DocumentImageStoreAdapter()
    private static let appPreferencesAdapter = UserDefaultsAppPreferencesAdapter()

    public static let taskRepository: TaskRepositoryPort = taskRepositoryAdapter.makePort()

    public static let userSettingsRepository: UserSettingsRepositoryPort = userSettingsRepositoryAdapter.makePort()

    public static let notificationScheduler: NotificationSchedulerPort = notificationSchedulerAdapter.makePort()

    public static let imageStore: ImageStorePort = imageStoreAdapter.makePort()

    public static let appPreferences: AppPreferencesPort = appPreferencesAdapter.makePort()
}
