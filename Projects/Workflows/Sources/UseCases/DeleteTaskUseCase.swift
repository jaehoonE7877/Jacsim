import Domain
import Ports

public struct DeleteTaskUseCase: Sendable {
    public var execute: @Sendable (TaskID) async throws -> Void

    public init(execute: @escaping @Sendable (TaskID) async throws -> Void) {
        self.execute = execute
    }
}

extension DeleteTaskUseCase {
    public static func live(
        taskRepository: TaskRepositoryPort,
        notificationScheduler: NotificationSchedulerPort
    ) -> Self {
        Self(
            execute: { taskID in
                await notificationScheduler.cancelReminder(taskID)
                try await taskRepository.deleteTask(taskID)
            }
        )
    }
}
