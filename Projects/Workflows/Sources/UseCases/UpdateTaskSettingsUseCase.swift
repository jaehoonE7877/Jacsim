import Foundation
import Domain
import Ports

public struct UpdateTaskSettingsUseCase: Sendable {
    public struct Input: Sendable, Equatable {
        public var task: Task
        public var title: String
        public var durationDays: Int
        public var isAlarmEnabled: Bool
        public var alarmDate: Date
        public var mainImageData: Data?

        public init(
            task: Task,
            title: String,
            durationDays: Int,
            isAlarmEnabled: Bool,
            alarmDate: Date,
            mainImageData: Data?
        ) {
            self.task = task
            self.title = title
            self.durationDays = durationDays
            self.isAlarmEnabled = isAlarmEnabled
            self.alarmDate = alarmDate
            self.mainImageData = mainImageData
        }
    }

    public var execute: @Sendable (Input) async throws -> Void

    public init(execute: @escaping @Sendable (Input) async throws -> Void) {
        self.execute = execute
    }
}

extension UpdateTaskSettingsUseCase {
    public static func live(
        taskRepository: TaskRepositoryPort,
        imageStore: ImageStorePort,
        reminderSchedulingUseCase: ReminderSchedulingUseCase
    ) -> Self {
        let taskUpdateUseCase = TaskUpdateUseCase(taskRepository: taskRepository)
        return Self(
            execute: { input in
                let updatedTask = try await taskUpdateUseCase.updateTaskInfo(
                    task: input.task,
                    title: input.title,
                    durationDays: input.durationDays,
                    isNotificationEnabled: input.isAlarmEnabled,
                    alarmDate: input.alarmDate
                )

                if let data = input.mainImageData {
                    _ = try await imageStore.saveImage(updatedTask.mainImageKey, data)
                }

                await reminderSchedulingUseCase.scheduleReminderIfNeeded(
                    taskID: updatedTask.id,
                    title: updatedTask.title,
                    isAlarmEnabled: input.isAlarmEnabled,
                    alarmDate: input.alarmDate,
                    cancelExistingReminder: true
                )
            }
        )
    }
}
